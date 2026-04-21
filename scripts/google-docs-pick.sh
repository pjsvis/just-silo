#!/usr/bin/env bash
set -euo pipefail

# Ignore SIGPIPE from downstream consumers in interactive flows.
trap '' PIPE

# google-docs-pick.sh
#
# Interactive Google Docs picker using gum + rclone.
# FLOW:
# 1) Pick file extension first
# 2) Load cached listing if fresh (or fetch live)
# 3) Optionally top-up cache incrementally from a narrower path
# 4) Filter/select one via gum
# 5) Prompt destination path
# 6) Delegate import to scripts/google-docs-pull.sh
#
# Usage:
#   ./scripts/google-docs-pick.sh
#   ./scripts/google-docs-pick.sh --remote gdrive --path briefs
#   ./scripts/google-docs-pick.sh --ext docx
#   ./scripts/google-docs-pick.sh --refresh-qmd
#   ./scripts/google-docs-pick.sh --dry-run
#
# Cache:
# - Cache file stores TSV rows: Name \t ModTime \t Size \t Path
# - Default cache root: scratch/cache/google-docs-picker
# - Cache key: remote + path
# - TTL controls when a full refresh is required.
# - Top-up merges additional path scan into cache without full rescan.
#
# Notes:
# - Requires: rclone, gum, jq
# - Defaults to extension-first chooser with docx prioritized.
# - Extension "all" shows everything.
# - Pull delegates to google-docs-pull.sh (single-file import).

SCRIPT_NAME="$(basename "$0")"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REMOTE="${REMOTE:-gdrive}"
REMOTE_PATH="${REMOTE_PATH:-}"
DEST_DIR_DEFAULT="${DEST_DIR_DEFAULT:-scratch/google-docs-imports}"
EXT_DEFAULT="${EXT_DEFAULT:-md}"

DRY_RUN=0
REFRESH_QMD=0
FORCE=0
NO_COLOR=0
EXT_OVERRIDE=""

# Cache settings
CACHE_ROOT_DEFAULT="${CACHE_ROOT_DEFAULT:-scratch/cache/google-docs-picker}"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-900}"   # 15 minutes default
CACHE_FORCE_REFRESH=0
CACHE_DISABLE=0
TOPUP_PATH=""

log()  { printf '[%s] %s\n' "$SCRIPT_NAME" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  scripts/google-docs-pick.sh [options]

Options:
  --remote <name>         rclone remote name (default: gdrive)
  --path <subpath>        remote subpath to list (default: remote root)
  --dest-dir <path>       default repo-relative destination directory
                          (default: scratch/google-docs-imports)
  --ext <ext>             skip extension picker and use this extension
                          examples: docx, md, pdf, txt, all
  --refresh-qmd           run qmd refresh after pull
  --force                 overwrite destination if file exists
  --dry-run               print actions only (delegated to pull script)
  --no-color              disable gum color prompts where possible

Cache options:
  --cache-ttl <seconds>   cache freshness window (default: 900)
  --cache-dir <path>      cache root dir (repo-relative or absolute)
  --refresh-cache         force refresh listing from remote
  --no-cache              disable cache for this run
  --topup <subpath>       top-up cache from narrower subpath and merge

  -h, --help              show this help

Examples:
  scripts/google-docs-pick.sh
  scripts/google-docs-pick.sh --path briefs --ext docx
  scripts/google-docs-pick.sh --refresh-cache
  scripts/google-docs-pick.sh --topup "briefs/2026"
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

sanitize_filename() {
  local s
  s="$(printf '%s' "$1")"
  s="${s// /-}"
  s="${s//\//-}"
  s="$(sed -E 's/[^A-Za-z0-9._-]+/-/g; s/-+/-/g; s/^-+//; s/-+$//' <<< "$s")"
  printf '%s' "$s"
}

to_remote_root() {
  local remote="$1"
  printf '%s:' "$remote"
}

to_remote_path() {
  local remote="$1"
  local subpath="$2"

  if [[ -z "$subpath" ]]; then
    printf '%s:' "$remote"
  else
    subpath="${subpath#/}" # trim accidental leading slash
    printf '%s:%s' "$remote" "$subpath"
  fi
}

pick_extension() {
  local chosen
  chosen="$(printf '%s\n' \
    "docx" \
    "md" \
    "txt" \
    "pdf" \
    "pptx" \
    "xlsx" \
    "csv" \
    "rtf" \
    "html" \
    "all" \
    | gum filter --placeholder "Pick extension first (type to filter, Enter to select)" --limit 1)"

  [[ -n "$chosen" ]] || die "No extension selected"
  printf '%s' "$chosen"
}

hash_key() {
  local raw="$1"
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$raw" | shasum -a 256 | awk '{print $1}'
  else
    # fallback (less ideal)
    printf '%s' "$raw" | cksum | awk '{print $1}'
  fi
}

cache_is_fresh() {
  local cache_file="$1"
  local now mtime age

  [[ -f "$cache_file" ]] || return 1
  now="$(date +%s)"
  # macOS stat format
  mtime="$(stat -f "%m" "$cache_file" 2>/dev/null || echo 0)"
  [[ "$mtime" =~ ^[0-9]+$ ]] || return 1
  age=$(( now - mtime ))
  (( age <= CACHE_TTL_SECONDS ))
}

fetch_rows_from_remote() {
  local remote_listing_path="$1"
  rclone lsjson "$remote_listing_path" --files-only --recursive \
    | jq -r '.[] | [.Name, .ModTime, (.Size|tostring), .Path] | @tsv'
}

merge_rows_unique_by_path() {
  # Input: multiple TSV streams
  # Output: unique by 4th column (Path), keep first occurrence
  awk -F '\t' '
    NF >= 4 {
      p=$4
      if (!seen[p]++) print
    }
  '
}

resolve_cache_root() {
  local raw="$1"
  if [[ "$raw" == /* ]]; then
    printf '%s' "$raw"
  else
    printf '%s/%s' "$ROOT_DIR" "$raw"
  fi
}

load_rows_with_cache() {
  local remote_listing_path="$1"
  local cache_root="$2"
  local cache_key="$3"
  local cache_file="$cache_root/${cache_key}.tsv"
  local rows=""

  mkdir -p "$cache_root"

  if [[ "$CACHE_DISABLE" -eq 1 ]]; then
    log "Cache disabled; fetching live listing..."
    rows="$(fetch_rows_from_remote "$remote_listing_path")"
    printf '%s' "$rows"
    return
  fi

  if [[ "$CACHE_FORCE_REFRESH" -eq 1 ]]; then
    log "Refreshing cache (forced): $cache_file"
    rows="$(fetch_rows_from_remote "$remote_listing_path")"
    printf '%s\n' "$rows" > "$cache_file"
    printf '%s' "$rows"
    return
  fi

  if cache_is_fresh "$cache_file"; then
    log "Using cached listing: $cache_file"
    rows="$(cat "$cache_file")"
    printf '%s' "$rows"
    return
  fi

  if [[ -f "$cache_file" ]]; then
    log "Cache stale; refreshing listing..."
  else
    log "Cache miss; fetching listing..."
  fi

  rows="$(fetch_rows_from_remote "$remote_listing_path")"
  printf '%s\n' "$rows" > "$cache_file"
  printf '%s' "$rows"
}

topup_cache() {
  local remote="$1"
  local base_path="$2"
  local topup_subpath="$3"
  local cache_root="$4"
  local cache_key="$5"

  [[ "$CACHE_DISABLE" -eq 0 ]] || { warn "Skipping top-up: cache is disabled"; return 0; }

  local cache_file="$cache_root/${cache_key}.tsv"
  local full_topup_path
  local topup_remote_path
  local topup_rows merged_rows

  if [[ -n "$base_path" ]]; then
    full_topup_path="${base_path%/}/${topup_subpath#/}"
  else
    full_topup_path="${topup_subpath#/}"
  fi

  topup_remote_path="$(to_remote_path "$remote" "$full_topup_path")"
  log "Top-up cache from: $topup_remote_path"

  topup_rows="$(fetch_rows_from_remote "$topup_remote_path" || true)"
  if [[ -z "$topup_rows" ]]; then
    warn "Top-up returned no rows for: $topup_remote_path"
    return 0
  fi

  mkdir -p "$cache_root"

  if [[ -f "$cache_file" ]]; then
    merged_rows="$(
      {
        cat "$cache_file"
        printf '\n'
        printf '%s\n' "$topup_rows"
      } | merge_rows_unique_by_path
    )"
  else
    merged_rows="$topup_rows"
  fi

  printf '%s\n' "$merged_rows" > "$cache_file"
  log "Top-up merged into cache: $cache_file"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --remote)
        [[ $# -ge 2 ]] || die "Missing value for --remote"
        REMOTE="$2"
        shift 2
        ;;
      --path)
        [[ $# -ge 2 ]] || die "Missing value for --path"
        REMOTE_PATH="$2"
        shift 2
        ;;
      --dest-dir)
        [[ $# -ge 2 ]] || die "Missing value for --dest-dir"
        DEST_DIR_DEFAULT="$2"
        shift 2
        ;;
      --ext)
        [[ $# -ge 2 ]] || die "Missing value for --ext"
        EXT_OVERRIDE="$2"
        shift 2
        ;;
      --refresh-qmd)
        REFRESH_QMD=1
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --no-color)
        NO_COLOR=1
        shift
        ;;
      --cache-ttl)
        [[ $# -ge 2 ]] || die "Missing value for --cache-ttl"
        CACHE_TTL_SECONDS="$2"
        shift 2
        ;;
      --cache-dir)
        [[ $# -ge 2 ]] || die "Missing value for --cache-dir"
        CACHE_ROOT_DEFAULT="$2"
        shift 2
        ;;
      --refresh-cache)
        CACHE_FORCE_REFRESH=1
        shift
        ;;
      --no-cache)
        CACHE_DISABLE=1
        shift
        ;;
      --topup)
        [[ $# -ge 2 ]] || die "Missing value for --topup"
        TOPUP_PATH="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  require_cmd rclone
  require_cmd gum
  require_cmd jq
  require_cmd awk
  require_cmd sed

  [[ "$CACHE_TTL_SECONDS" =~ ^[0-9]+$ ]] || die "--cache-ttl must be an integer >= 0"

  local remote_root remote_listing_path
  remote_root="$(to_remote_root "$REMOTE")"
  remote_listing_path="$(to_remote_path "$REMOTE" "$REMOTE_PATH")"

  local cache_root cache_key
  cache_root="$(resolve_cache_root "$CACHE_ROOT_DEFAULT")"
  cache_key="$(hash_key "${REMOTE}|${REMOTE_PATH}")"

  log "Checking remote: $remote_root"
  rclone lsd "$remote_root" >/dev/null 2>&1 || die "Cannot access remote '$REMOTE'"

  # Optional top-up first (useful before loading)
  if [[ -n "$TOPUP_PATH" ]]; then
    topup_cache "$REMOTE" "$REMOTE_PATH" "$TOPUP_PATH" "$cache_root" "$cache_key"
  fi

  local selected_ext
  if [[ -n "$EXT_OVERRIDE" ]]; then
    selected_ext="$EXT_OVERRIDE"
  else
    selected_ext="$(pick_extension)"
  fi

  selected_ext="$(sed 's/^\.//' <<< "${selected_ext,,}")"
  [[ -n "$selected_ext" ]] || die "Invalid extension selection"

  log "Listing files in: $remote_listing_path"
  log "Extension filter: $selected_ext"

  local rows
  rows="$(load_rows_with_cache "$remote_listing_path" "$cache_root" "$cache_key")"
  [[ -n "$rows" ]] || die "No files found under $remote_listing_path"

  local filtered_rows
  if [[ "$selected_ext" == "all" ]]; then
    filtered_rows="$rows"
  else
    filtered_rows="$(
      awk -F '\t' -v ext="$selected_ext" '
        {
          name=tolower($1)
          if (name ~ ("\\." ext "$")) print
        }
      ' <<< "$rows"
    )"
  fi

  [[ -n "$filtered_rows" ]] || die "No files match extension '$selected_ext' under $remote_listing_path"

  local display
  display="$(awk -F '\t' '{printf "%-50s | %10s bytes | %s\n", $1, $3, $2}' <<< "$filtered_rows")"

  local selected_line gum_status
  set +e
  selected_line="$(gum filter --placeholder "Filter selected-extension files (Enter to pick one)" --limit 1 <<< "$display")"
  gum_status=$?
  set -e

  [[ $gum_status -eq 0 ]] || die "Selection cancelled or failed"
  [[ -n "$selected_line" ]] || die "No file selected"

  # Recover selected row by exact display-line match (avoids SIGPIPE from nl|awk under strict mode)
  local selected_row
  selected_row="$(
    awk -F '\t' -v sel="$selected_line" '
      {
        disp = sprintf("%-50s | %10s bytes | %s", $1, $3, $2)
        if (disp == sel) {
          print $0
          exit
        }
      }
    ' <<< "$filtered_rows"
  )"
  [[ -n "$selected_row" ]] || die "Selected row not found"

  local name modtime size relpath
  IFS=$'\t' read -r name modtime size relpath <<< "$selected_row"

  local source
  if [[ -z "$REMOTE_PATH" ]]; then
    source="${REMOTE}:${relpath}"
  else
    source="${REMOTE}:${REMOTE_PATH%/}/${relpath}"
  fi

  local base guessed_ext suggested_name suggested_dest dest_rel output_ext_for_pull
  guessed_ext="${name##*.}"
  if [[ "$name" == "$guessed_ext" ]]; then
    # no extension in name
    guessed_ext="$EXT_DEFAULT"
  fi
  base="$(sanitize_filename "${name%.*}")"
  [[ -n "$base" ]] || base="google-doc"

  # Pass selected extension through to pull script as output format preference.
  # This allows selecting .docx in picker while still pulling markdown via --output-ext md.
  output_ext_for_pull="$selected_ext"
  if [[ "$output_ext_for_pull" == "all" ]]; then
    output_ext_for_pull="$guessed_ext"
  fi

  suggested_name="${base}.${output_ext_for_pull}"
  suggested_dest="${DEST_DIR_DEFAULT%/}/${suggested_name}"

  gum style --foreground 212 "Selected:"
  gum style "  Name:      $name"
  gum style "  Ext:       $selected_ext"
  gum style "  ModTime:   $modtime"
  gum style "  Size:      $size"
  gum style "  Source:    $source"
  gum style "  Dest (?):  $suggested_dest"

  dest_rel="$(gum input --placeholder "Destination path (repo-relative)" --value "$suggested_dest")"
  [[ -n "$dest_rel" ]] || die "Destination is required"

  local cmd=( "./scripts/google-docs-pull.sh" "--source" "$source" "--dest" "$dest_rel" "--output-ext" "$output_ext_for_pull" )
  [[ "$DRY_RUN" -eq 1 ]] && cmd+=( "--dry-run" )
  [[ "$REFRESH_QMD" -eq 1 ]] && cmd+=( "--refresh-qmd" )
  [[ "$FORCE" -eq 1 ]] && cmd+=( "--force" )

  gum style --foreground 99 "Running pull..."
  (cd "$ROOT_DIR" && "${cmd[@]}")

  gum style --foreground 42 "Done."
}
main "$@"
