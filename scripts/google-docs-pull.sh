#!/usr/bin/env bash
set -euo pipefail

# google-docs-pull.sh
#
# Targeted Google Docs/Drive pull for single-file imports into this repo.
# Uses rclone and exports Google Docs to Markdown by default.
#
# Usage:
#   ./scripts/google-docs-pull.sh --source "gdrive:Folder/My Doc" --dest "scratch/google-docs-imports/my-doc.md"
#   ./scripts/google-docs-pull.sh --source "gdrive:Folder/My Doc" --dest "briefs/2026-04-21-brief-my-doc.md"
#   ./scripts/google-docs-pull.sh --source "gdrive:Folder/My Doc" --dest "playbooks/my-playbook.md" --refresh-qmd
#   ./scripts/google-docs-pull.sh --source "gdrive:Folder/My Doc" --dest "scratch/google-docs-imports/my-doc.md" --dry-run
#   ./scripts/google-docs-pull.sh --source "gdrive:Folder/My Doc" --dest "scratch/google-docs-imports/my-doc.md" --output-ext md
#
# Notes:
# - --source must be an rclone path to a single file/doc, e.g. "gdrive:Path/To/Doc Name"
# - --dest is a repo-relative file path (must remain inside repo)
# - --output-ext can force destination extension and strict export behavior (e.g. md)
# - Copy strategy:
#   * with --output-ext: strict export-only (no plain-copy fallback)
#   * without --output-ext: extension-based heuristic + export fallback to plain copy
# - Optional QMD refresh after successful import

SCRIPT_NAME="$(basename "$0")"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RCLONE_EXPORT_FORMATS="${RCLONE_EXPORT_FORMATS:-md,txt,docx}"
RCLONE_EXTRA_FLAGS="${RCLONE_EXTRA_FLAGS:-}"

SOURCE=""
DEST_REL=""
OUTPUT_EXT=""
DRY_RUN=0
REFRESH_QMD=0
FORCE_OVERWRITE=0
MKDIR_P=1

log()  { printf '[%s] %s\n' "$SCRIPT_NAME" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  scripts/google-docs-pull.sh --source <rclone-path> --dest <repo-relative-path> [options]

Required:
  --source <path>       rclone source path to a single file/doc (e.g. gdrive:Folder/Doc Name)
  --dest <path>         destination file path relative to repo root

Options:
  --output-ext <ext>    force destination extension and export-first strategy
                        example: --output-ext md
  --dry-run             print actions without writing files
  --refresh-qmd         run `just qmd-refresh` after successful pull
  --force               overwrite destination if it already exists
  --no-mkdir            do not create destination parent directory
  -h, --help            show this help

Environment:
  RCLONE_EXPORT_FORMATS  export preference for native Google Docs (default: md,txt,docx)
  RCLONE_EXTRA_FLAGS     extra flags appended to rclone copyto

Examples:
  scripts/google-docs-pull.sh \
    --source "gdrive:Specs/Payments PRD" \
    --dest "scratch/google-docs-imports/payments-prd.md"

  scripts/google-docs-pull.sh \
    --source "gdrive:Specs/Brief 2026-04-21" \
    --dest "briefs/2026-04-21-brief-payments.md" \
    --refresh-qmd

  scripts/google-docs-pull.sh \
    --source "gdrive:Defining Alpha in Financial Analysis.docx" \
    --dest "scratch/google-docs-imports/defining-alpha-in-financial-analysis.md" \
    --output-ext md
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

is_inside_repo() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) return 0 ;;
    *) return 1 ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source)
        [[ $# -ge 2 ]] || die "Missing value for --source"
        SOURCE="$2"
        shift 2
        ;;
      --dest)
        [[ $# -ge 2 ]] || die "Missing value for --dest"
        DEST_REL="$2"
        shift 2
        ;;
      --output-ext)
        [[ $# -ge 2 ]] || die "Missing value for --output-ext"
        OUTPUT_EXT="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --refresh-qmd)
        REFRESH_QMD=1
        shift
        ;;
      --force)
        FORCE_OVERWRITE=1
        shift
        ;;
      --no-mkdir)
        MKDIR_P=0
        shift
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

  [[ -n "$SOURCE" ]] || die "--source is required"
  [[ -n "$DEST_REL" ]] || die "--dest is required"

  require_cmd rclone
  if [[ "$REFRESH_QMD" -eq 1 ]]; then
    require_cmd just
  fi

  [[ "$SOURCE" == *:* ]] || die "--source must be an rclone remote path (expected remote:path)"

  local source_basename source_ext lower_ext use_plain_first
  source_basename="$(basename "$SOURCE")"
  source_ext="${source_basename##*.}"
  lower_ext="${source_ext,,}"
  use_plain_first=0
  case "$lower_ext" in
    docx|pdf|pptx|xlsx|csv|zip|jpg|jpeg|png|gif|webp|bmp|tiff|mp3|mp4|mov|avi|mkv|txt|rtf)
      use_plain_first=1
      ;;
  esac

  if [[ -n "$OUTPUT_EXT" ]]; then
    OUTPUT_EXT="${OUTPUT_EXT,,}"
    OUTPUT_EXT="${OUTPUT_EXT#.}"
    [[ -n "$OUTPUT_EXT" ]] || die "Invalid --output-ext value"
    use_plain_first=0
  fi

  if [[ -n "$OUTPUT_EXT" ]]; then
    local dest_base
    dest_base="${DEST_REL%.*}"
    if [[ "$dest_base" == "$DEST_REL" ]]; then
      DEST_REL="${DEST_REL}.${OUTPUT_EXT}"
    else
      DEST_REL="${dest_base}.${OUTPUT_EXT}"
    fi
  fi

  local dest_abs
  dest_abs="$ROOT_DIR/$DEST_REL"

  # normalize path checks
  local dest_parent
  dest_parent="$(dirname "$dest_abs")"

  # ensure destination is within repo
  mkdir -p "$dest_parent"
  local dest_abs_resolved parent_resolved
  parent_resolved="$(cd "$dest_parent" && pwd -P)"
  dest_abs_resolved="$parent_resolved/$(basename "$dest_abs")"

  is_inside_repo "$dest_abs_resolved" || die "--dest resolves outside repository: $dest_abs_resolved"

  if [[ -e "$dest_abs_resolved" && "$FORCE_OVERWRITE" -ne 1 ]]; then
    die "Destination exists: $DEST_REL (use --force to overwrite)"
  fi

  if [[ "$MKDIR_P" -eq 1 ]]; then
    run_cmd "mkdir -p \"$parent_resolved\""
  else
    [[ -d "$parent_resolved" ]] || die "Destination directory does not exist: $parent_resolved (omit --no-mkdir to auto-create)"
  fi

  log "Source: $SOURCE"
  log "Dest:   $DEST_REL"
  log "Export: $RCLONE_EXPORT_FORMATS"

  # When output extension is explicitly requested, try source path with that extension first.
  # This supports cases where Drive listing exposes a different extension view (e.g. .md export).
  local source_for_export
  source_for_export="$SOURCE"
  if [[ -n "$OUTPUT_EXT" ]]; then
    local source_stem alt_source
    source_stem="${SOURCE%.*}"
    alt_source="${source_stem}.${OUTPUT_EXT}"
    if [[ "$alt_source" != "$SOURCE" ]]; then
      source_for_export="$alt_source"
      log "Export source override: $source_for_export"
    fi
  fi

  # copyto handles single-file pull.
  # Strategy:
  # - with --output-ext: strict export-only (required for true format conversion)
  # - without --output-ext:
  #     known binary/document extensions => plain copy first
  #     otherwise                        => export-format copy first
  local copy_cmd_export copy_cmd_plain
  copy_cmd_export="rclone copyto \
    --drive-export-formats \"$RCLONE_EXPORT_FORMATS\" \
    $RCLONE_EXTRA_FLAGS \
    \"$source_for_export\" \"$dest_abs_resolved\""
  copy_cmd_plain="rclone copyto \
    $RCLONE_EXTRA_FLAGS \
    \"$SOURCE\" \"$dest_abs_resolved\""

  if [[ -n "$OUTPUT_EXT" ]]; then
    log "Copy strategy: strict export-only (--output-ext=$OUTPUT_EXT)"
    run_cmd "$copy_cmd_export"
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      if [[ "$use_plain_first" -eq 1 ]]; then
        log "Copy strategy: plain (by extension .$lower_ext)"
        run_cmd "$copy_cmd_plain"
      else
        log "Copy strategy: export-first"
        run_cmd "$copy_cmd_export"
      fi
    else
      if [[ "$use_plain_first" -eq 1 ]]; then
        log "Copy strategy: plain (by extension .$lower_ext)"
        run_cmd "$copy_cmd_plain"
      else
        log "Copy strategy: export-first"
        set +e
        eval "$copy_cmd_export"
        copy_status=$?
        set -e

        if [[ $copy_status -ne 0 ]]; then
          warn "Export-format copy failed (status=$copy_status). Retrying plain copy..."
          run_cmd "$copy_cmd_plain"
        fi
      fi
    fi
  fi

  if [[ "$REFRESH_QMD" -eq 1 ]]; then
    log "Refreshing QMD index/embeddings..."
    run_cmd "cd \"$ROOT_DIR\" && just qmd-refresh"
  fi

  log "Done."
}

main "$@"
