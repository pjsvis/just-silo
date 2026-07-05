#!/usr/bin/env bash
# canon.sh - Canon bundle management (OKF-conformant curated playbooks)
# Usage: ./canon.sh <command> [args...]
#
# Commands:
#   index            Regenerate canon/index.md from INDEX.jsonl (source of truth)
#   check            Validate OKF frontmatter + INDEX.jsonl <-> filesystem sync
#   list             Human-readable listing of canon entries
#
# OKF: Open Knowledge Format — minimum required field is `type` in YAML
# frontmatter. See https://github.com/GoogleCloudPlatform/knowledge-catalog

set -euo pipefail

CANON_DIR="canon"
INDEX_JSONL="$CANON_DIR/INDEX.jsonl"
INDEX_MD="$CANON_DIR/index.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }

require_jq() {
  command -v jq >/dev/null 2>&1 || { err "jq is required (brew install jq)"; exit 1; }
}

# ─────────────────────────────────────────────────────────────
# INDEX: regenerate canon/index.md from INDEX.jsonl
# ─────────────────────────────────────────────────────────────
cmd_index() {
  require_jq
  [[ -f "$INDEX_JSONL" ]] || { err "Missing $INDEX_JSONL"; exit 1; }

  info "Regenerating $INDEX_MD from $INDEX_JSONL"

  # Build the table rows from JSONL
  local rows
  rows=$(jq -r '
    "| [`\(.file)`](\(.file)) | \(.type // "—") | \(.title // "—") | \(.status // "—") | \(.summary // "—") |"
  ' "$INDEX_JSONL" 2>/dev/null || echo "| (failed to parse INDEX.jsonl) | | | | |")

  local count
  count=$(jq -s 'length' "$INDEX_JSONL" 2>/dev/null || echo "?")

  # Write index.md
  cat > "$INDEX_MD" <<EOF
# Canon — Curated Method Playbooks

> An OKF bundle of authoritative, portable playbooks curated by \`just-silo\`
> for cross-silo reuse. Source of truth: \`INDEX.jsonl\`. This file is generated.

## First Task — Verify Consistency

**Before reading, editing, or pulling from canon, run the consistency check.**

\`\`\`bash
just canon-check
\`\`\`

This validates that \`INDEX.jsonl\` (the source of truth) matches the files on
disk, that every entry carries OKF-conformant frontmatter, and that no entry
has drifted out of the registry. **If this check fails, do not proceed.** Fix
the drift first — see "How to Proceed" below. Canon is operational only when
the bundle is self-consistent.

## What Belongs in Canon

A playbook belongs in \`canon/\` when it is **method** — when its lessons
transfer across repos and carry zero project-specific references. A playbook
that fights the tool default, references a specific repo's \`justfile\`, or
depends on a particular silo's directory layout belongs in that silo's own
\`playbooks/\`, not here.

Canon is the curation boundary, not a kind of playbook. A playbook in canon
is still a playbook; the \`canon/\` directory marks a **role** — curated,
authoritative, externally publishable.

## How to Consume

Canon entries are OKF-conformant markdown. A consuming silo can:

- **Pull specific files** into its own \`playbooks/\` (the OKF portability
  model — destination path is the consumer's choice).
- **Browse \`INDEX.jsonl\`** for the machine-readable catalogue.
- **Browse this \`index.md\`** for the human-readable catalogue.
- **Check \`log.md\`** for promotion, revision, and deprecation history.

\`\`\`bash
# Pull a single playbook into a consuming silo
cp ~/Dev/GitHub/just-silo/canon/analysis-playbook.md \\
   <dest-silo>/playbooks/

# Or browse before deciding
just canon-list
\`\`\`

## How to Proceed — Adding to or Editing Canon

Canon is operational, not static. Work proceeds in this order:

1. **Run \`just canon-check\` first.** Verify the bundle is self-consistent
   before touching anything. If it fails, fix the drift before proceeding —
   do not build on an inconsistent foundation.
2. **Branch off main** (e.g. \`chore/canon-add-<name>\` or
   \`chore/canon-revise-<name>\`). Never commit directly to main.
3. **Add or revise one entry per commit.** A commit should add or substantially
   revise a single playbook. This isolates front-matter errors and stripping
   misses — when a check fails, the cause is unambiguous.
4. **Update \`INDEX.jsonl\`** — the source of truth. Add or amend the entry's
   line with \`file\`, \`type\`, \`title\`, \`date\`, \`status\`, \`summary\`,
   \`tags\`. This is the authoritative record; everything else is derived.
5. **Regenerate the derived artifact:** \`just canon-index\`.
6. **Append to \`log.md\`** under today's date: one bullet — what changed, where,
   and why. Promotion, revision, and deprecation all earn a log entry.
7. **Validate the result:** \`just canon-check\`. It must pass before commit.
8. **Commit and PR** to main. Server-side AI reviewers will comment — fix
   their findings before merging.

**Stripping rule.** A playbook that cannot survive without project-specific
references (a specific repo's paths, tooling, or directory layout) does not
belong in canon. If migration requires leaving behind a reference to the
source repo, the playbook is not yet portable — finish stripping first.

**Deprecation.** If a canon entry is superseded, do not delete it silently.
Mark its status \`deprecated\` in \`INDEX.jsonl\`, note the successor in
\`log.md\`, and leave the file in place for one cycle before removal.

## Contents

| File | Type | Title | Status | Summary |
|------|------|-------|--------|---------|
EOF

  echo "$rows" >> "$INDEX_MD"

  cat >> "$INDEX_MD" <<EOF

## OKF Conformance

Every entry conforms to the Open Knowledge Format (OKF): a directory of
markdown files with YAML frontmatter, minimum required field \`type\`.

See: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

## Regeneration

\`\`\`bash
just canon-index        # regenerate this index from INDEX.jsonl
just canon-check        # validate OKF frontmatter + registry sync
just canon-list         # human-readable listing
\`\`\`

Do not edit this file by hand — your edit will be overwritten. Update
\`INDEX.jsonl\` and regenerate.
EOF

  ok "Wrote $INDEX_MD ($count entr$( (( count == 1 )) && echo "y" || echo "ies"))"
}

# ─────────────────────────────────────────────────────────────
# CHECK: validate OKF frontmatter + INDEX.jsonl <-> filesystem sync
# ─────────────────────────────────────────────────────────────
cmd_check() {
  require_jq
  local problems=0

  info "Validating canon bundle: $CANON_DIR"

  # 1. Directory exists
  if [[ ! -d "$CANON_DIR" ]]; then
    err "Missing $CANON_DIR directory"
    exit 1
  fi
  ok "Directory exists: $CANON_DIR"

  # 2. INDEX.jsonl exists and is non-empty
  if [[ ! -s "$INDEX_JSONL" ]]; then
    err "Missing or empty $INDEX_JSONL"
    exit 1
  fi
  ok "Registry present: $INDEX_JSONL"

  # 3. Every INDEX.jsonl line is valid JSON
  # Parse first, refuse to continue if malformed — downstream steps (4-7)
  # call jq again on the same lines, and with `set -e -o pipefail` those
  # calls abort the script before the summary report prints. Detect JSON
  # errors here, report line numbers, exit cleanly.
  local lineno=0
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    [[ -z "$line" ]] && continue
    if ! echo "$line" | jq -e . >/dev/null 2>&1; then
      err "$INDEX_JSONL:$lineno — not valid JSON"
      problems=$((problems + 1))
    fi
  done < "$INDEX_JSONL"
  if [[ $problems -gt 0 ]]; then
    echo ""
    err "Fix INDEX.jsonl JSON parse errors first, then re-run canon-check"
    exit 1
  fi
  ok "All INDEX.jsonl lines parse as JSON"

  # 4. Every registry entry has required fields (file, type, title)
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local file type title
    file=$(echo "$line" | jq -r '.file // empty')
    type=$(echo "$line" | jq -r '.type // empty')
    title=$(echo "$line" | jq -r '.title // empty')
    [[ -z "$file" ]]  && { err "Registry entry missing 'file': $line";  problems=$((problems + 1)); }
    [[ -z "$type" ]]  && { err "$file: missing 'type' (OKF requires it)"; problems=$((problems + 1)); }
    [[ -z "$title" ]] && { warn "$file: missing recommended 'title'"; }
  done < "$INDEX_JSONL"

  # 5. Registry entries reference files that exist
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local file
    file=$(echo "$line" | jq -r '.file // empty')
    [[ -z "$file" ]] && continue
    if [[ ! -f "$CANON_DIR/$file" ]]; then
      err "STALE: $file in INDEX.jsonl but not on disk"
      problems=$((problems + 1))
    fi
  done < "$INDEX_JSONL"

  # 6. Markdown files on disk that aren't in the registry (excluding reserved names)
  for f in "$CANON_DIR"/*.md; do
    [[ -e "$f" ]] || continue
    local base
    base=$(basename "$f")
    [[ "$base" == "index.md" ]] && continue
    [[ "$base" == "log.md" ]] && continue
    if ! grep -q "\"file\":\"$base\"" "$INDEX_JSONL" && ! grep -q "\"file\": \"$base\"" "$INDEX_JSONL"; then
      err "MISSING: $base on disk but not in INDEX.jsonl"
      problems=$((problems + 1))
    fi
  done

  # 7. OKF frontmatter: every .md entry has a `type:` field in its YAML block
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local file
    file=$(echo "$line" | jq -r '.file // empty')
    [[ -z "$file" ]] && continue
    [[ "$file" == "index.md" || "$file" == "log.md" ]] && continue
    local path="$CANON_DIR/$file"
    [[ -f "$path" ]] || continue
    # First non-blank line must be `---`, and a `type:` line must appear before the closing `---`
    if ! awk 'NR==1 && $0!="---" { exit 1 } $0=="---" && NR>1 { exit 0 } /^type:/ { found=1 } END { exit !found }' "$path"; then
      err "$file: missing OKF frontmatter or 'type:' field"
      problems=$((problems + 1))
    fi
  done < "$INDEX_JSONL"

  # Report
  echo ""
  if [[ $problems -eq 0 ]]; then
    ok "Canon bundle is consistent and OKF-conformant"
  else
    err "Canon check failed: $problems problem(s)"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────
# LIST: human-readable listing
# ─────────────────────────────────────────────────────────────
cmd_list() {
  require_jq
  [[ -f "$INDEX_JSONL" ]] || { err "Missing $INDEX_JSONL"; exit 1; }
  echo -e "${BLUE}Canon — Curated Method Playbooks${NC}"
  echo ""
  jq -r '"  • \(.title // .file) [\(.type // "?")] — \(.summary // "")"' "$INDEX_JSONL"
}

# ─────────────────────────────────────────────────────────────
# Dispatch
# ─────────────────────────────────────────────────────────────
subcommand="${1:-}"
[[ $# -gt 0 ]] && shift

case "$subcommand" in
  index)  cmd_index "$@" ;;
  check)  cmd_check "$@" ;;
  list)   cmd_list "$@" ;;
  ""|-h|--help|help)
    sed -n '2,12p' "$0"
    ;;
  *)
    err "Unknown command: $subcommand"
    sed -n '2,12p' "$0"
    exit 1
    ;;
esac
