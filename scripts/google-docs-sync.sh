#!/usr/bin/env bash
set -euo pipefail

# google-docs-sync.sh
#
# Sync Google Docs from Google Drive to local markdown folders (for QMD indexing),
# using rclone as the transport layer.
#
# Design goals:
# - Local-first, scriptable, and deterministic.
# - Safe staging: sync into temporary staging dirs, then atomic-ish promote.
# - Conservative defaults (read-only scope expected on remote).
#
# Typical flow:
# 1) rclone sync Drive folder -> staging/<collection>
# 2) validate staging result
# 3) replace target local folder contents with staging contents
# 4) (optional) trigger QMD refresh
#
# Usage:
#   ./scripts/google-docs-sync.sh --help
#   ./scripts/google-docs-sync.sh --config scripts/google-docs-sync.env
#   ./scripts/google-docs-sync.sh --dry-run
#
#   # Sync one collection only:
#   ./scripts/google-docs-sync.sh --only briefs
#
#   # Skip QMD refresh:
#   ./scripts/google-docs-sync.sh --no-qmd-refresh
#
#   # Show resolved configuration:
#   ./scripts/google-docs-sync.sh --print-config
#
# Required:
# - rclone installed and configured with a Google Drive remote
# - just + qmd only if QMD refresh is enabled
#
# NOTE:
# This script expects Drive folders to be organized by collection.
# It exports Google Docs as markdown via rclone's export formats.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_NAME="$(basename "$0")"

# ----------------------------
# Defaults (override via env or --config file)
# ----------------------------

# rclone remote name (configured in rclone config)
RCLONE_REMOTE="${RCLONE_REMOTE:-gdrive}"

# Optional base path inside remote (e.g. "just-silo-docs")
# Final source path = "${RCLONE_REMOTE}:${RCLONE_BASE_PATH}/${REMOTE_SUBPATH}"
RCLONE_BASE_PATH="${RCLONE_BASE_PATH:-}"

# rclone export format preference for Google Docs
# Keep markdown first to get native .md export where possible.
RCLONE_EXPORT_FORMATS="${RCLONE_EXPORT_FORMATS:-md,txt,docx}"

# Safety: require rclone remote to be reachable before syncing
RCLONE_CHECK_REMOTE="${RCLONE_CHECK_REMOTE:-1}"

# Optional rclone extra flags (single string, appended as-is)
RCLONE_EXTRA_FLAGS="${RCLONE_EXTRA_FLAGS:-}"

# Local target directories (relative to repo root)
LOCAL_BRIEFS_DIR="${LOCAL_BRIEFS_DIR:-briefs}"
LOCAL_DEBRIEFS_DIR="${LOCAL_DEBRIEFS_DIR:-debriefs}"
LOCAL_BRIEFS_ARCHIVE_DIR="${LOCAL_BRIEFS_ARCHIVE_DIR:-briefs_archive}"
LOCAL_DEBRIEFS_ARCHIVE_DIR="${LOCAL_DEBRIEFS_ARCHIVE_DIR:-debriefs_archive}"

# Remote subpaths (relative to RCLONE_BASE_PATH)
REMOTE_BRIEFS_SUBPATH="${REMOTE_BRIEFS_SUBPATH:-briefs}"
REMOTE_DEBRIEFS_SUBPATH="${REMOTE_DEBRIEFS_SUBPATH:-debriefs}"
REMOTE_BRIEFS_ARCHIVE_SUBPATH="${REMOTE_BRIEFS_ARCHIVE_SUBPATH:-briefs_archive}"
REMOTE_DEBRIEFS_ARCHIVE_SUBPATH="${REMOTE_DEBRIEFS_ARCHIVE_SUBPATH:-debriefs_archive}"

# Collection selector:
# all | briefs | debriefs | briefs-archive | debriefs-archive
ONLY_COLLECTION="${ONLY_COLLECTION:-all}"

# Whether to run QMD refresh after successful sync
RUN_QMD_REFRESH="${RUN_QMD_REFRESH:-1}"

# For very large sets, keep a minimum expected file count per collection
# (0 means no minimum check)
MIN_FILES_BRIEFS="${MIN_FILES_BRIEFS:-0}"
MIN_FILES_DEBRIEFS="${MIN_FILES_DEBRIEFS:-0}"
MIN_FILES_BRIEFS_ARCHIVE="${MIN_FILES_BRIEFS_ARCHIVE:-0}"
MIN_FILES_DEBRIEFS_ARCHIVE="${MIN_FILES_DEBRIEFS_ARCHIVE:-0}"

# Internal
DRY_RUN=0
PRINT_CONFIG=0
CONFIG_FILE=""
NO_QMD_REFRESH_FLAG=0

# ----------------------------
# Logging
# ----------------------------

ts() { date +"%Y-%m-%dT%H:%M:%S%z"; }

log() {
  printf "[%s] [%s] %s\n" "$(ts)" "$SCRIPT_NAME" "$*"
}

warn() {
  printf "[%s] [%s] WARN: %s\n" "$(ts)" "$SCRIPT_NAME" "$*" >&2
}

err() {
  printf "[%s] [%s] ERROR: %s\n" "$(ts)" "$SCRIPT_NAME" "$*" >&2
}

die() {
  err "$*"
  exit 1
}

# ----------------------------
# Helpers
# ----------------------------

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --config <file>         Source environment config file
  --only <collection>     all|briefs|debriefs|briefs-archive|debriefs-archive
  --dry-run               Print actions without mutating local files
  --no-qmd-refresh        Skip "just qmd-refresh"
  --print-config          Print resolved config and exit
  -h, --help              Show this help

Environment/config variables:
  RCLONE_REMOTE
  RCLONE_BASE_PATH
  RCLONE_EXPORT_FORMATS
  RCLONE_EXTRA_FLAGS
  RCLONE_CHECK_REMOTE

  LOCAL_BRIEFS_DIR
  LOCAL_DEBRIEFS_DIR
  LOCAL_BRIEFS_ARCHIVE_DIR
  LOCAL_DEBRIEFS_ARCHIVE_DIR

  REMOTE_BRIEFS_SUBPATH
  REMOTE_DEBRIEFS_SUBPATH
  REMOTE_BRIEFS_ARCHIVE_SUBPATH
  REMOTE_DEBRIEFS_ARCHIVE_SUBPATH

  RUN_QMD_REFRESH
  MIN_FILES_BRIEFS
  MIN_FILES_DEBRIEFS
  MIN_FILES_BRIEFS_ARCHIVE
  MIN_FILES_DEBRIEFS_ARCHIVE

Examples:
  $SCRIPT_NAME --config scripts/google-docs-sync.env
  $SCRIPT_NAME --only briefs --dry-run
  $SCRIPT_NAME --no-qmd-refresh
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

abs_repo_path() {
  local rel="$1"
  printf "%s/%s" "$ROOT_DIR" "$rel"
}

normalize_remote_path() {
  local sub="$1"
  if [[ -n "$RCLONE_BASE_PATH" ]]; then
    printf "%s:%s/%s" "$RCLONE_REMOTE" "$RCLONE_BASE_PATH" "$sub"
  else
    printf "%s:%s" "$RCLONE_REMOTE" "$sub"
  fi
}

safe_rm_contents() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  # Remove all children but keep directory
  find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

count_md_files() {
  local dir="$1"
  [[ -d "$dir" ]] || { echo "0"; return 0; }
  find "$dir" -type f \( -name "*.md" -o -name "*.markdown" \) | wc -l | tr -d ' '
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

print_config() {
  cat <<EOF
ROOT_DIR=$ROOT_DIR
RCLONE_REMOTE=$RCLONE_REMOTE
RCLONE_BASE_PATH=$RCLONE_BASE_PATH
RCLONE_EXPORT_FORMATS=$RCLONE_EXPORT_FORMATS
RCLONE_EXTRA_FLAGS=$RCLONE_EXTRA_FLAGS
RCLONE_CHECK_REMOTE=$RCLONE_CHECK_REMOTE

LOCAL_BRIEFS_DIR=$LOCAL_BRIEFS_DIR
LOCAL_DEBRIEFS_DIR=$LOCAL_DEBRIEFS_DIR
LOCAL_BRIEFS_ARCHIVE_DIR=$LOCAL_BRIEFS_ARCHIVE_DIR
LOCAL_DEBRIEFS_ARCHIVE_DIR=$LOCAL_DEBRIEFS_ARCHIVE_DIR

REMOTE_BRIEFS_SUBPATH=$REMOTE_BRIEFS_SUBPATH
REMOTE_DEBRIEFS_SUBPATH=$REMOTE_DEBRIEFS_SUBPATH
REMOTE_BRIEFS_ARCHIVE_SUBPATH=$REMOTE_BRIEFS_ARCHIVE_SUBPATH
REMOTE_DEBRIEFS_ARCHIVE_SUBPATH=$REMOTE_DEBRIEFS_ARCHIVE_SUBPATH

ONLY_COLLECTION=$ONLY_COLLECTION
RUN_QMD_REFRESH=$RUN_QMD_REFRESH
MIN_FILES_BRIEFS=$MIN_FILES_BRIEFS
MIN_FILES_DEBRIEFS=$MIN_FILES_DEBRIEFS
MIN_FILES_BRIEFS_ARCHIVE=$MIN_FILES_BRIEFS_ARCHIVE
MIN_FILES_DEBRIEFS_ARCHIVE=$MIN_FILES_DEBRIEFS_ARCHIVE
DRY_RUN=$DRY_RUN
EOF
}

# ----------------------------
# Sync unit
# ----------------------------

sync_collection() {
  local name="$1"
  local remote_subpath="$2"
  local local_rel_dir="$3"
  local min_files="$4"

  local local_dir
  local staging_root
  local staging_dir
  local remote_path
  local md_count

  local_dir="$(abs_repo_path "$local_rel_dir")"
  staging_root="$(mktemp -d "${TMPDIR:-/tmp}/google-docs-sync.${name}.XXXXXX")"
  staging_dir="$staging_root/$name"
  remote_path="$(normalize_remote_path "$remote_subpath")"

  mkdir -p "$staging_dir"
  mkdir -p "$local_dir"

  log "=== Syncing collection: $name ==="
  log "Remote: $remote_path"
  log "Local:  $local_dir"
  log "Stage:  $staging_dir"

  # rclone sync remote -> staging with markdown export preference
  # --drive-export-formats applies to Google Docs native files.
  local rclone_cmd
  rclone_cmd="rclone sync \
    --drive-export-formats \"$RCLONE_EXPORT_FORMATS\" \
    --exclude \".DS_Store\" \
    --exclude \"**/~*\" \
    --exclude \"**/*.tmp\" \
    $RCLONE_EXTRA_FLAGS \
    \"$remote_path\" \"$staging_dir\""

  run_cmd "$rclone_cmd"

  # Validation
  md_count="$(count_md_files "$staging_dir")"
  log "Staging markdown file count ($name): $md_count"

  if [[ "$min_files" =~ ^[0-9]+$ ]] && (( min_files > 0 )); then
    if (( md_count < min_files )); then
      rm -rf "$staging_root"
      die "Collection '$name' failed minimum file count check (found=$md_count, min=$min_files)"
    fi
  fi

  # Promote staging -> local
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: would replace local contents of $local_dir from staging"
  else
    safe_rm_contents "$local_dir"
    cp -a "$staging_dir"/. "$local_dir"/
    log "Promoted staging to local for $name"
  fi

  rm -rf "$staging_root"
}

# ----------------------------
# Main
# ----------------------------

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --config)
        [[ $# -lt 2 ]] && die "Missing value for --config"
        CONFIG_FILE="$2"
        shift 2
        ;;
      --only)
        [[ $# -lt 2 ]] && die "Missing value for --only"
        ONLY_COLLECTION="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --no-qmd-refresh)
        NO_QMD_REFRESH_FLAG=1
        shift
        ;;
      --print-config)
        PRINT_CONFIG=1
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

  if [[ -n "$CONFIG_FILE" ]]; then
    [[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE"
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
  fi

  # Re-apply --no-qmd-refresh precedence after config load
  if [[ "$NO_QMD_REFRESH_FLAG" -eq 1 ]]; then
    RUN_QMD_REFRESH=0
  fi

  if [[ "$PRINT_CONFIG" -eq 1 ]]; then
    print_config
    exit 0
  fi

  require_cmd rclone

  case "$ONLY_COLLECTION" in
    all|briefs|debriefs|briefs-archive|debriefs-archive) ;;
    *)
      die "Invalid --only value: $ONLY_COLLECTION"
      ;;
  esac

  if [[ "$RCLONE_CHECK_REMOTE" == "1" ]]; then
    log "Checking rclone remote availability: $RCLONE_REMOTE"
    run_cmd "rclone lsd \"$RCLONE_REMOTE:\" >/dev/null"
  fi

  if [[ "$ONLY_COLLECTION" == "all" || "$ONLY_COLLECTION" == "briefs" ]]; then
    sync_collection \
      "briefs" \
      "$REMOTE_BRIEFS_SUBPATH" \
      "$LOCAL_BRIEFS_DIR" \
      "$MIN_FILES_BRIEFS"
  fi

  if [[ "$ONLY_COLLECTION" == "all" || "$ONLY_COLLECTION" == "debriefs" ]]; then
    sync_collection \
      "debriefs" \
      "$REMOTE_DEBRIEFS_SUBPATH" \
      "$LOCAL_DEBRIEFS_DIR" \
      "$MIN_FILES_DEBRIEFS"
  fi

  if [[ "$ONLY_COLLECTION" == "all" || "$ONLY_COLLECTION" == "briefs-archive" ]]; then
    sync_collection \
      "briefs-archive" \
      "$REMOTE_BRIEFS_ARCHIVE_SUBPATH" \
      "$LOCAL_BRIEFS_ARCHIVE_DIR" \
      "$MIN_FILES_BRIEFS_ARCHIVE"
  fi

  if [[ "$ONLY_COLLECTION" == "all" || "$ONLY_COLLECTION" == "debriefs-archive" ]]; then
    sync_collection \
      "debriefs-archive" \
      "$REMOTE_DEBRIEFS_ARCHIVE_SUBPATH" \
      "$LOCAL_DEBRIEFS_ARCHIVE_DIR" \
      "$MIN_FILES_DEBRIEFS_ARCHIVE"
  fi

  if [[ "$RUN_QMD_REFRESH" == "1" ]]; then
    if command -v just >/dev/null 2>&1; then
      log "Triggering QMD refresh: just qmd-refresh"
      run_cmd "cd \"$ROOT_DIR\" && just qmd-refresh"
    else
      warn "Skipping QMD refresh: 'just' not found"
    fi
  else
    log "QMD refresh disabled"
  fi

  log "Google Docs sync complete."
}

main "$@"
