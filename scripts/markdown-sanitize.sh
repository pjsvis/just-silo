#!/usr/bin/env bash
set -euo pipefail

# markdown-sanitize.sh
#
# Sanitizes Markdown files imported from Google Docs.
#
# Focus areas:
# 1) Normalize line endings (CRLF -> LF)
# 2) Remove UTF-8 BOM if present
# 3) Preserve literal LaTeX-style backslashes in math regions
#    by fixing accidental control characters from escaped sequences:
#      - carriage return inserted from "\rangle" parsing
#      - newline inserted from "\nabla" parsing
#      - tab inserted from "\theta" parsing
#
# Usage:
#   ./scripts/markdown-sanitize.sh --file scratch/google-docs-imports/doc.md
#   ./scripts/markdown-sanitize.sh --dir scratch/google-docs-imports
#   ./scripts/markdown-sanitize.sh --glob "scratch/google-docs-imports/*.md"
#   ./scripts/markdown-sanitize.sh --file path/to/doc.md --write
#   ./scripts/markdown-sanitize.sh --dir scratch/google-docs-imports --write --verbose
#
# Default mode is CHECK (no file writes). Use --write to apply changes.
#
# Exit codes:
#   0 = success (no findings, or findings fixed in --write mode)
#   1 = findings detected in check mode, or error

MODE="check"   # check | write
VERBOSE=0
TARGET_KIND=""
TARGET_VALUE=""
FOUND=0
FIXED=0
ERRORS=0

log() {
  printf '[markdown-sanitize] %s\n' "$*"
}

vlog() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    log "$*"
  fi
}

warn() {
  printf '[markdown-sanitize][warn] %s\n' "$*" >&2
}

die() {
  printf '[markdown-sanitize][error] %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  scripts/markdown-sanitize.sh (--file <path> | --dir <path> | --glob <pattern>) [options]

Target options (choose one):
  --file <path>         Sanitize a single markdown file
  --dir <path>          Sanitize all *.md and *.markdown files under directory (recursive)
  --glob <pattern>      Sanitize files matched by shell glob pattern

Mode options:
  --write               Apply fixes in-place
  --check               Check only (default)

Other:
  --verbose             Print per-file actions
  -h, --help            Show help

Examples:
  ./scripts/markdown-sanitize.sh --file scratch/google-docs-imports/doc.md
  ./scripts/markdown-sanitize.sh --dir scratch/google-docs-imports --write
  ./scripts/markdown-sanitize.sh --glob "scratch/google-docs-imports/*.md" --write --verbose
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

is_markdown_file() {
  local f="$1"
  [[ "$f" == *.md || "$f" == *.markdown ]]
}

collect_files() {
  local kind="$1"
  local value="$2"

  case "$kind" in
    file)
      [[ -f "$value" ]] || die "File not found: $value"
      is_markdown_file "$value" || warn "Target file does not look like Markdown: $value"
      printf '%s\n' "$value"
      ;;
    dir)
      [[ -d "$value" ]] || die "Directory not found: $value"
      find "$value" -type f \( -name '*.md' -o -name '*.markdown' \) | sort
      ;;
    glob)
      # shellcheck disable=SC2086
      local matches
      matches=$(compgen -G "$value" || true)
      if [[ -z "$matches" ]]; then
        die "No files matched glob: $value"
      fi
      while IFS= read -r f; do
        [[ -f "$f" ]] || continue
        is_markdown_file "$f" || continue
        printf '%s\n' "$f"
      done <<< "$matches"
      ;;
    *)
      die "Internal error: unknown target kind: $kind"
      ;;
  esac
}

sanitize_with_python() {
  local file="$1"

  python3 - "$file" "$MODE" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
mode = sys.argv[2]  # check | write

try:
    raw = path.read_bytes()
except Exception as e:
    print(f"ERROR\t{path}\tread_failed:{e}")
    sys.exit(2)

original = raw

# 1) Remove UTF-8 BOM
if raw.startswith(b"\xef\xbb\xbf"):
    raw = raw[3:]

# 2) Normalize CRLF/CR -> LF
raw = raw.replace(b"\r\n", b"\n").replace(b"\r", b"\n")

# Decode as UTF-8 (replace invalid bytes to keep pipeline robust)
text = raw.decode("utf-8", errors="replace")
orig_text = text

# 3) Repair accidental control chars that commonly come from escaped TeX commands
#    These controls are not expected in clean markdown math:
#      \r from \rangle
#      \n from \nabla
#      \t from \theta
#
# Heuristic replacements:
# - replace literal control chars followed by known suffix tokens
# - also replace standalone occurrences of those controls before alphabetic suffixes
repairs = [
    ("\rangle", r"\rangle"),
    ("\nabla", r"\nabla"),
    ("\theta", r"\theta"),
    ("\tau", r"\tau"),
    ("\rho", r"\rho"),
]

for bad, good in repairs:
    text = text.replace(bad, good)

# Extra guarded regexes:
# Carriage return/newline/tab before common LaTeX-ish tails
text = re.sub(r"\r(?=angle\b)", r"\\r", text)
text = re.sub(r"\n(?=abla\b)", r"\\n", text)
text = re.sub(r"\t(?=heta\b)", r"\\t", text)

changed = (text != orig_text) or (raw != original and text == orig_text)

# Re-encode post-edit content
new_bytes = text.encode("utf-8")

if mode == "write":
    if new_bytes != original:
        try:
            path.write_bytes(new_bytes)
        except Exception as e:
            print(f"ERROR\t{path}\twrite_failed:{e}")
            sys.exit(2)
        print(f"FIXED\t{path}")
    else:
        print(f"OK\t{path}")
else:
    if new_bytes != original:
        print(f"FOUND\t{path}")
    else:
        print(f"OK\t{path}")
PY
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file)
        [[ $# -ge 2 ]] || die "Missing value for --file"
        [[ -z "$TARGET_KIND" ]] || die "Choose only one of --file/--dir/--glob"
        TARGET_KIND="file"
        TARGET_VALUE="$2"
        shift 2
        ;;
      --dir)
        [[ $# -ge 2 ]] || die "Missing value for --dir"
        [[ -z "$TARGET_KIND" ]] || die "Choose only one of --file/--dir/--glob"
        TARGET_KIND="dir"
        TARGET_VALUE="$2"
        shift 2
        ;;
      --glob)
        [[ $# -ge 2 ]] || die "Missing value for --glob"
        [[ -z "$TARGET_KIND" ]] || die "Choose only one of --file/--dir/--glob"
        TARGET_KIND="glob"
        TARGET_VALUE="$2"
        shift 2
        ;;
      --write)
        MODE="write"
        shift
        ;;
      --check)
        MODE="check"
        shift
        ;;
      --verbose)
        VERBOSE=1
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

  [[ -n "$TARGET_KIND" ]] || {
    usage
    die "Missing target: use one of --file, --dir, --glob"
  }

  require_cmd python3
  require_cmd find

  local files
  files="$(collect_files "$TARGET_KIND" "$TARGET_VALUE")"
  [[ -n "$files" ]] || die "No markdown files found"

  while IFS= read -r f; do
    [[ -n "$f" ]] || continue

    vlog "Processing: $f"
    set +e
    out="$(sanitize_with_python "$f" 2>&1)"
    rc=$?
    set -e

    if [[ $rc -ne 0 ]]; then
      ERRORS=$((ERRORS + 1))
      warn "$out"
      continue
    fi

    status="${out%%$'\t'*}"

    case "$status" in
      FOUND)
        FOUND=$((FOUND + 1))
        log "FOUND: $f"
        ;;
      FIXED)
        FIXED=$((FIXED + 1))
        log "FIXED: $f"
        ;;
      OK)
        vlog "OK: $f"
        ;;
      ERROR)
        ERRORS=$((ERRORS + 1))
        warn "$out"
        ;;
      *)
        # Defensive parse fallback
        if grep -q '^FOUND' <<< "$out"; then
          FOUND=$((FOUND + 1))
          log "FOUND: $f"
        elif grep -q '^FIXED' <<< "$out"; then
          FIXED=$((FIXED + 1))
          log "FIXED: $f"
        elif grep -q '^OK' <<< "$out"; then
          vlog "OK: $f"
        else
          ERRORS=$((ERRORS + 1))
          warn "Unexpected sanitizer output for $f: $out"
        fi
        ;;
    esac
  done <<< "$files"

  log "Summary: mode=$MODE found=$FOUND fixed=$FIXED errors=$ERRORS"

  if [[ "$MODE" == "check" ]]; then
    if (( FOUND > 0 || ERRORS > 0 )); then
      exit 1
    fi
  else
    if (( ERRORS > 0 )); then
      exit 1
    fi
  fi

  exit 0
}

main "$@"
