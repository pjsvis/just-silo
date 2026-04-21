#!/usr/bin/env bash
set -euo pipefail
trap '' PIPE

# google-docs-pick-docx-md.sh
#
# Dedicated workflow:
# - List .docx files from rclone remote/path
# - Interactive filename filter + multi-select (gum)
# - Pull selected files as markdown (.md)
# - Track downloaded docs in a local manifest
# - Optionally hide already-downloaded entries by default
#
# Requirements:
# - rclone
# - jq
# - gum
#
# Default behavior:
# - extension source filter: .docx only
# - output format: markdown (.md)
# - hide already-downloaded rows
# - multi-select enabled
#
# Typical usage:
#   ./scripts/google-docs-pick-docx-md.sh
#   ./scripts/google-docs-pick-docx-md.sh --path briefs
#   ./scripts/google-docs-pick-docx-md.sh --show-downloaded
#   ./scripts/google-docs-pick-docx-md.sh --topup "briefs/2026"
#   ./scripts/google-docs-pick-docx-md.sh --refresh-qmd
#
# Notes:
# - Downloaded tracking manifest:
#     scratch/cache/google-docs-picker/downloaded.jsonl
# - Cache listing:
#     scratch/cache/google-docs-picker/<cache-key>.tsv

SCRIPT_NAME="$(basename "$0")"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REMOTE="${REMOTE:-gdrive}"
REMOTE_PATH="${REMOTE_PATH:-}"
DEST_DIR_DEFAULT="${DEST_DIR_DEFAULT:-scratch/google-docs-imports}"

CACHE_ROOT_DEFAULT="${CACHE_ROOT_DEFAULT:-scratch/cache/google-docs-picker}"
CACHE_TTL_SECONDS="${CACHE_TTL_SECONDS:-900}"  # 15m
CACHE_DISABLE=0
CACHE_FORCE_REFRESH=0
TOPUP_PATH=""

DRY_RUN=0
FORCE=0
REFRESH_QMD=0
AUTO_SANITIZE=1

SHOW_DOWNLOADED=0
HIDE_DOWNLOADED_DEFAULT=1

MANIFEST_FILE_DEFAULT="${MANIFEST_FILE_DEFAULT:-scratch/cache/google-docs-picker/downloaded.jsonl}"

log()  { printf '[%s] %s\n' "$SCRIPT_NAME" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  scripts/google-docs-pick-docx-md.sh [options]

Core options:
  --remote <name>         rclone remote name (default: gdrive)
  --path <subpath>        remote subpath to list (default: remote root)
  --dest-dir <path>       repo-relative destination dir for .md files
                          (default: scratch/google-docs-imports)
  --refresh-qmd           run "just qmd-refresh" after successful pulls
  --force                 pass --force to pull script (overwrite existing files)
  --dry-run               print actions only
  --sanitize              run markdown sanitizer on each successful import (default: on)
  --no-sanitize           disable per-file markdown sanitization

Downloaded visibility:
  --show-downloaded       include rows already tracked in manifest
                          (default: hide downloaded rows)

Cache options:
  --cache-ttl <seconds>   cache freshness window (default: 900)
  --cache-dir <path>      cache root dir (repo-relative or absolute)
  --refresh-cache         force full cache refresh from remote
  --no-cache              disable cache for this run
  --topup <subpath>       top-up cache from narrower subpath and merge

Other:
  -h, --help              show help

Examples:
  scripts/google-docs-pick-docx-md.sh
  scripts/google-docs-pick-docx-md.sh --path briefs
  scripts/google-docs-pick-docx-md.sh --show-downloaded
  scripts/google-docs-pick-docx-md.sh --topup "briefs/2026"
  scripts/google-docs-pick-docx-md.sh --refresh-qmd
  scripts/google-docs-pick-docx-md.sh --no-sanitize
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

resolve_path() {
  local p="$1"
  if [[ "$p" == /* ]]; then
    printf '%s' "$p"
  else
    printf '%s/%s' "$ROOT_DIR" "$p"
  fi
}

to_remote_root() {
  printf '%s:' "$1"
}

to_remote_path() {
  local remote="$1"
  local subpath="${2:-}"
  if [[ -z "$subpath" ]]; then
    printf '%s:' "$remote"
  else
    subpath="${subpath#/}"
    printf '%s:%s' "$remote" "$subpath"
  fi
}

hash_key() {
  local raw="$1"
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$raw" | shasum -a 256 | awk '{print $1}'
  else
    printf '%s' "$raw" | cksum | awk '{print $1}'
  fi
}

cache_is_fresh() {
  local cache_file="$1"
  [[ -f "$cache_file" ]] || return 1
  local now mtime age
  now="$(date +%s)"
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
  awk -F '\t' '
    NF >= 4 {
      p=$4
      if (!seen[p]++) print
    }
  '
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
    fetch_rows_from_remote "$remote_listing_path"
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
    cat "$cache_file"
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

  [[ "$CACHE_DISABLE" -eq 0 ]] || { warn "Skipping top-up: cache disabled"; return 0; }

  local cache_file="$cache_root/${cache_key}.tsv"
  local full_topup_path topup_remote_path topup_rows merged_rows

  if [[ -n "$base_path" ]]; then
    full_topup_path="${base_path%/}/${topup_subpath#/}"
  else
    full_topup_path="${topup_subpath#/}"
  fi

  topup_remote_path="$(to_remote_path "$remote" "$full_topup_path")"
  log "Top-up cache from: $topup_remote_path"

  topup_rows="$(fetch_rows_from_remote "$topup_remote_path" || true)"
  [[ -n "$topup_rows" ]] || { warn "Top-up returned no rows"; return 0; }

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

sanitize_filename() {
  local s="$1"
  s="${s// /-}"
  s="${s//\//-}"
  s="$(sed -E 's/[^A-Za-z0-9._-]+/-/g; s/-+/-/g; s/^-+//; s/-+$//' <<< "$s")"
  printf '%s' "$s"
}

manifest_has_source() {
  local manifest="$1"
  local src="$2"
  [[ -f "$manifest" ]] || return 1
  jq -e --arg src "$src" 'select(.source == $src) | true' "$manifest" >/dev/null 2>&1
}

append_manifest_entry() {
  local manifest="$1"
  local source="$2"
  local dest="$3"
  local status="$4"

  mkdir -p "$(dirname "$manifest")"

  jq -nc \
    --arg ts "$(date -Iseconds)" \
    --arg source "$source" \
    --arg dest "$dest" \
    --arg status "$status" \
    '{
      pulled_at: $ts,
      source: $source,
      dest: $dest,
      status: $status
    }' >> "$manifest"
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
      --sanitize)
        AUTO_SANITIZE=1
        shift
        ;;
      --no-sanitize)
        AUTO_SANITIZE=0
        shift
        ;;
      --show-downloaded)
        SHOW_DOWNLOADED=1
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
  require_cmd jq
  require_cmd gum
  require_cmd awk
  require_cmd sed
  if [[ "$AUTO_SANITIZE" -eq 1 ]]; then
    [[ -x "$ROOT_DIR/scripts/markdown-sanitize.sh" ]] || die "Sanitizer script not found or not executable: scripts/markdown-sanitize.sh"
  fi

  [[ "$CACHE_TTL_SECONDS" =~ ^[0-9]+$ ]] || die "--cache-ttl must be integer >= 0"

  local cache_root manifest_file
  cache_root="$(resolve_path "$CACHE_ROOT_DEFAULT")"
  manifest_file="$(resolve_path "$MANIFEST_FILE_DEFAULT")"

  local remote_root remote_listing_path cache_key
  remote_root="$(to_remote_root "$REMOTE")"
  remote_listing_path="$(to_remote_path "$REMOTE" "$REMOTE_PATH")"
  cache_key="$(hash_key "${REMOTE}|${REMOTE_PATH}")"

  log "Checking remote: $remote_root"
  rclone lsd "$remote_root" >/dev/null 2>&1 || die "Cannot access remote '$REMOTE'"

  if [[ -n "$TOPUP_PATH" ]]; then
    topup_cache "$REMOTE" "$REMOTE_PATH" "$TOPUP_PATH" "$cache_root" "$cache_key"
  fi

  log "Listing files in: $remote_listing_path"
  local rows
  rows="$(load_rows_with_cache "$remote_listing_path" "$cache_root" "$cache_key")"
  [[ -n "$rows" ]] || die "No files found under $remote_listing_path"

  # Filter source files to .docx only
  local docx_rows
  docx_rows="$(
    awk -F '\t' '
      {
        n = tolower($1)
        if (n ~ /\.docx$/) print
      }
    ' <<< "$rows"
  )"
  [[ -n "$docx_rows" ]] || die "No .docx files found"

  # Build source + suggested dest + downloaded flag
  # Output fields:
  # 1 status(NEW|DOWNLOADED) 2 name 3 modtime 4 size 5 relpath 6 source 7 suggested_dest
  local enriched
  enriched="$(
    awk -F '\t' '{print $1 "\t" $2 "\t" $3 "\t" $4}' <<< "$docx_rows" \
      | while IFS=$'\t' read -r name modtime size relpath; do
          local source
          if [[ -z "$REMOTE_PATH" ]]; then
            source="${REMOTE}:${relpath}"
          else
            source="${REMOTE}:${REMOTE_PATH%/}/${relpath}"
          fi

          local base suggested_dest status
          base="$(sanitize_filename "${name%.*}")"
          [[ -n "$base" ]] || base="google-doc"
          suggested_dest="${DEST_DIR_DEFAULT%/}/${base}.md"

          status="NEW"
          if manifest_has_source "$manifest_file" "$source"; then
            status="DOWNLOADED"
          fi

          printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$status" "$name" "$modtime" "$size" "$relpath" "$source" "$suggested_dest"
        done
  )"

  [[ -n "$enriched" ]] || die "No enriched rows available"

  # Default: hide downloaded unless explicitly shown
  local visible
  if [[ "$SHOW_DOWNLOADED" -eq 1 || "$HIDE_DOWNLOADED_DEFAULT" -eq 0 ]]; then
    visible="$enriched"
  else
    visible="$(awk -F '\t' '$1 == "NEW"' <<< "$enriched")"
    if [[ -z "$visible" ]]; then
      warn "All matching .docx files are already marked downloaded."
      warn "Re-run with --show-downloaded to include them."
      exit 0
    fi
  fi

  # Build display
  local display
  display="$(
    awk -F '\t' '{
      printf "[%s] %-50s | %10s bytes | %s\n", $1, $2, $4, $3
    }' <<< "$visible"
  )"

  # Multi-select
  # gum choose supports --no-limit for multi selection.
  # UX fallback: if user confirms without marking rows (empty output), fall back to single-pick filter.
  gum style --foreground 214 "Multi-select tips:"
  gum style "  • Space = mark/unmark a row"
  gum style "  • Enter = confirm selected rows"
  gum style "  • If no rows are marked, we'll ask for a single selection next"
  local selected_lines
  set +e
  selected_lines="$(gum choose --no-limit <<< "$display")"
  local choose_status=$?
  set -e

  [[ $choose_status -eq 0 ]] || die "Selection cancelled or failed"

  if [[ -z "$selected_lines" ]]; then
    warn "No rows marked in multi-select. Falling back to single selection..."
    set +e
    selected_lines="$(gum filter --placeholder "Select one DOCX row (Enter to choose)" --limit 1 <<< "$display")"
    choose_status=$?
    set -e
    [[ $choose_status -eq 0 ]] || die "Selection cancelled or failed"
    [[ -n "$selected_lines" ]] || die "No files selected"
  fi

  # Build selected records by exact display-line match
  local selected_records
  selected_records="$(
    awk -F '\t' '
      BEGIN { OFS="\t" }
      NR==FNR { sel[$0]=1; next }
      {
        disp = sprintf("[%s] %-50s | %10s bytes | %s", $1, $2, $4, $3)
        if (sel[disp]) print $0
      }
    ' <(printf '%s\n' "$selected_lines") <(printf '%s\n' "$visible")
  )"
  [[ -n "$selected_records" ]] || die "Could not map selected rows"

  gum style --foreground 212 "Selected files:"
  awk -F '\t' '{printf "  - %s (%s)\n", $2, $1}' <<< "$selected_records"

  # Pull loop
  local ok_count=0
  local fail_count=0

  while IFS=$'\t' read -r status name modtime size relpath source suggested_dest; do
    [[ -n "$source" ]] || continue

    local cmd=( "./scripts/google-docs-pull.sh" "--source" "$source" "--dest" "$suggested_dest" "--output-ext" "md" )
    [[ "$DRY_RUN" -eq 1 ]] && cmd+=( "--dry-run" )
    [[ "$FORCE" -eq 1 ]] && cmd+=( "--force" )
    [[ "$REFRESH_QMD" -eq 1 ]] && cmd+=( "--refresh-qmd" )

    gum style --foreground 99 "Pulling: $name -> $suggested_dest"

    set +e
    (cd "$ROOT_DIR" && "${cmd[@]}")
    pull_status=$?
    set -e

    if [[ $pull_status -eq 0 ]]; then
      if [[ "$AUTO_SANITIZE" -eq 1 ]]; then
        gum style --foreground 99 "Sanitizing: $suggested_dest"
        local sanitize_cmd=( "./scripts/markdown-sanitize.sh" "--file" "$suggested_dest" "--write" )
        set +e
        (cd "$ROOT_DIR" && "${sanitize_cmd[@]}")
        sanitize_status=$?
        set -e

        if [[ $sanitize_status -ne 0 ]]; then
          fail_count=$((fail_count + 1))
          append_manifest_entry "$manifest_file" "$source" "$suggested_dest" "sanitize_failed"
          warn "Sanitizer failed: $suggested_dest"
          continue
        fi
      fi

      ok_count=$((ok_count + 1))
      append_manifest_entry "$manifest_file" "$source" "$suggested_dest" "ok"
    else
      fail_count=$((fail_count + 1))
      append_manifest_entry "$manifest_file" "$source" "$suggested_dest" "failed"
      warn "Failed pull: $source"
    fi
  done <<< "$selected_records"

  gum style --foreground 42 "Done. pulled_ok=${ok_count} pulled_failed=${fail_count}"
  log "Manifest: $manifest_file"
}

main "$@"
