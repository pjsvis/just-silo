#!/usr/bin/env bash
set -euo pipefail

# qmd-health-check.sh
# Validates QMD operational health for this repo:
#  - required collections exist
#  - index has documents/vectors
#  - sentinel queries return expected signals
#
# Usage:
#   ./scripts/qmd-health-check.sh
#   ./scripts/qmd-health-check.sh --verbose
#   ./scripts/qmd-health-check.sh --json
#   ./scripts/qmd-health-check.sh --min-score 0.30

REQUIRED_COLLECTIONS=(
  "playbooks"
  "briefs"
  "debriefs"
  "briefs-archive"
  "debriefs-archive"
)

VERBOSE=0
JSON_OUT=0
MIN_SCORE="0.30"

pass_count=0
warn_count=0
fail_count=0
declare -a REPORT_LINES=()

log() {
  printf '[qmd-health] %s\n' "$*"
}

vlog() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    printf '[qmd-health][verbose] %s\n' "$*"
  fi
}

pass() {
  pass_count=$((pass_count + 1))
  REPORT_LINES+=("PASS: $*")
  log "PASS: $*"
}

warn() {
  warn_count=$((warn_count + 1))
  REPORT_LINES+=("WARN: $*")
  log "WARN: $*"
}

fail() {
  fail_count=$((fail_count + 1))
  REPORT_LINES+=("FAIL: $*")
  log "FAIL: $*"
}

usage() {
  cat <<'EOF'
Usage: scripts/qmd-health-check.sh [options]

Options:
  --verbose            Extra diagnostic output
  --json               Emit machine-readable JSON summary
  --min-score <num>    Sentinel min relevance score (default: 0.30)
  -h, --help           Show help

Exit codes:
  0  all checks passed
  1  one or more checks failed
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[qmd-health] FAIL: required command not found: $1" >&2
    exit 1
  }
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose)
        VERBOSE=1
        shift
        ;;
      --json)
        JSON_OUT=1
        shift
        ;;
      --min-score)
        [[ $# -ge 2 ]] || { echo "Missing value for --min-score" >&2; exit 1; }
        MIN_SCORE="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
}

has_collection() {
  local name="$1"
  qmd collection list 2>/dev/null | grep -qE "^${name} \(qmd://"
}

extract_total_docs() {
  local status="$1"
  printf '%s\n' "$status" | awk '/Total:[[:space:]]+[0-9]+ files indexed/ {print $2; exit}'
}

extract_total_vectors() {
  local status="$1"
  printf '%s\n' "$status" | awk '/Vectors:[[:space:]]+[0-9]+ embedded/ {print $2; exit}'
}

run_json_query() {
  local query="$1"
  local collection="$2"
  qmd query "$query" -c "$collection" --json -n 1 --min-score "$MIN_SCORE" 2>/dev/null || true
}

json_array_len() {
  local raw="$1"
  # Lightweight array-length estimate without jq dependency.
  # Safe enough for qmd --json output which is a top-level array.
  printf '%s' "$raw" | tr -d '\n' | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | awk '
      BEGIN { n=0 }
      {
        s=$0
        if (s == "[]") { print 0; exit }
        # Count objects by opening brace at top-ish level (works for qmd results)
        for (i=1; i<=length(s); i++) {
          c=substr(s,i,1)
          if (c=="{") n++
        }
        print n
      }
    '
}

main() {
  parse_args "$@"

  require_cmd qmd
  require_cmd awk
  require_cmd grep
  require_cmd sed
  require_cmd tr

  vlog "Running qmd status..."
  local status_out
  status_out="$(qmd status 2>/dev/null || true)"

  if [[ -z "$status_out" ]]; then
    fail "qmd status returned no output"
  else
    pass "qmd status is available"
  fi

  # Collection checks
  for c in "${REQUIRED_COLLECTIONS[@]}"; do
    if has_collection "$c"; then
      pass "collection exists: $c"
    else
      fail "missing required collection: $c"
    fi
  done

  # Index population checks
  local total_docs total_vectors
  total_docs="$(extract_total_docs "$status_out" || true)"
  total_vectors="$(extract_total_vectors "$status_out" || true)"

  if [[ -n "${total_docs:-}" && "$total_docs" =~ ^[0-9]+$ ]]; then
    if (( total_docs > 0 )); then
      pass "index has documents ($total_docs)"
    else
      fail "index has zero documents"
    fi
  else
    warn "could not parse total document count from qmd status"
  fi

  if [[ -n "${total_vectors:-}" && "$total_vectors" =~ ^[0-9]+$ ]]; then
    if (( total_vectors > 0 )); then
      pass "index has vectors ($total_vectors)"
    else
      warn "index has zero vectors (run: qmd embed)"
    fi
  else
    warn "could not parse vector count from qmd status"
  fi

  # Sentinel query checks
  # 1) playbooks: gamma-loop should resolve strongly
  vlog "Running sentinel query: playbooks/gamma-loop"
  local s1
  s1="$(run_json_query "gamma-loop" "playbooks")"
  local n1
  n1="$(json_array_len "$s1")"
  if [[ "$n1" =~ ^[0-9]+$ ]] && (( n1 > 0 )); then
    pass "sentinel query returned results: playbooks/gamma-loop"
  else
    fail "sentinel query empty: playbooks/gamma-loop"
  fi

  # 2) debriefs-archive: lessons learned should hit historical docs
  vlog "Running sentinel query: debriefs-archive/lessons learned"
  local s2
  s2="$(run_json_query "lessons learned" "debriefs-archive")"
  local n2
  n2="$(json_array_len "$s2")"
  if [[ "$n2" =~ ^[0-9]+$ ]] && (( n2 > 0 )); then
    pass "sentinel query returned results: debriefs-archive/lessons learned"
  else
    warn "sentinel query empty: debriefs-archive/lessons learned"
  fi

  # 3) briefs: architecture should resolve in active briefs
  vlog "Running sentinel query: briefs/architecture"
  local s3
  s3="$(run_json_query "architecture" "briefs")"
  local n3
  n3="$(json_array_len "$s3")"
  if [[ "$n3" =~ ^[0-9]+$ ]] && (( n3 > 0 )); then
    pass "sentinel query returned results: briefs/architecture"
  else
    warn "sentinel query empty: briefs/architecture"
  fi

  if [[ "$JSON_OUT" -eq 1 ]]; then
    # Simple JSON emitter without external JSON tools.
    printf '{\n'
    printf '  "ok": %s,\n' "$([[ "$fail_count" -eq 0 ]] && echo "true" || echo "false")"
    printf '  "passes": %d,\n' "$pass_count"
    printf '  "warnings": %d,\n' "$warn_count"
    printf '  "failures": %d,\n' "$fail_count"
    printf '  "minScore": "%s",\n' "$MIN_SCORE"
    printf '  "lines": [\n'
    for i in "${!REPORT_LINES[@]}"; do
      line="${REPORT_LINES[$i]}"
      esc="$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')"
      if [[ "$i" -lt "$((${#REPORT_LINES[@]} - 1))" ]]; then
        printf '    "%s",\n' "$esc"
      else
        printf '    "%s"\n' "$esc"
      fi
    done
    printf '  ]\n'
    printf '}\n'
  else
    log "Summary: passes=$pass_count warnings=$warn_count failures=$fail_count"
  fi

  if [[ "$fail_count" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
