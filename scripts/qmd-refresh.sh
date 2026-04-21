#!/usr/bin/env bash
set -euo pipefail

# qmd-refresh.sh
# Refreshes volatile QMD collections and embeddings.
#
# Default behavior:
#   - updates: briefs, debriefs, briefs-archive, debriefs-archive
#   - runs embed after update
#
# Usage:
#   ./scripts/qmd-refresh.sh
#   ./scripts/qmd-refresh.sh --collections "briefs,debriefs"
#   ./scripts/qmd-refresh.sh --no-embed
#   ./scripts/qmd-refresh.sh --dry-run
#   ./scripts/qmd-refresh.sh --help

COLLECTIONS_DEFAULT="briefs,debriefs,briefs-archive,debriefs-archive"
COLLECTIONS="$COLLECTIONS_DEFAULT"
RUN_EMBED=1
DRY_RUN=0

log() {
  printf '[qmd-refresh] %s\n' "$*"
}

warn() {
  printf '[qmd-refresh][warn] %s\n' "$*" >&2
}

die() {
  printf '[qmd-refresh][error] %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: scripts/qmd-refresh.sh [options]

Options:
  -c, --collections CSV   Comma-separated collection names to refresh
                          (default: briefs,debriefs,briefs-archive,debriefs-archive)
      --no-embed          Skip embedding pass after update
      --dry-run           Print commands without executing
  -h, --help              Show this help

Examples:
  ./scripts/qmd-refresh.sh
  ./scripts/qmd-refresh.sh --collections "briefs,debriefs"
  ./scripts/qmd-refresh.sh --no-embed
  ./scripts/qmd-refresh.sh --dry-run
EOF
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

collection_exists() {
  local name="$1"
  qmd collection list 2>/dev/null | grep -qE "^${name} \(qmd://"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--collections)
        [[ $# -ge 2 ]] || die "Missing value for $1"
        COLLECTIONS="$2"
        shift 2
        ;;
      --no-embed)
        RUN_EMBED=0
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1 (use --help)"
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  require_cmd qmd

  IFS=',' read -r -a raw <<< "$COLLECTIONS"
  if [[ "${#raw[@]}" -eq 0 ]]; then
    die "No collections specified"
  fi

  local valid=()
  for c in "${raw[@]}"; do
    c="$(echo "$c" | xargs)"
    [[ -n "$c" ]] || continue
    if collection_exists "$c"; then
      valid+=("$c")
    else
      warn "Skipping unknown collection: $c"
    fi
  done

  if [[ "${#valid[@]}" -eq 0 ]]; then
    die "None of the requested collections exist"
  fi

  log "Refreshing collections: ${valid[*]}"

  log "Updating index (single pass)"
  run_cmd qmd update

  if [[ "$RUN_EMBED" -eq 1 ]]; then
    log "Embedding changed/new documents"
    run_cmd qmd embed
  else
    log "Skipping embed (--no-embed)"
  fi

  log "Done"
}

main "$@"
