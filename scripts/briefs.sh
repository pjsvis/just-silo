#!/usr/bin/env bash
# briefs.sh - Briefs management toolkit
# Usage: ./briefs.sh <command> [args...]
#
# Commands:
#   catalog          Scan briefs, generate index.json
#   archive          Archive stale briefs (interactive with fzf)
#   sync             Update BRIEFS-ROADMAP from index
#   plan             Generate briefs-plan.md (interactive with fzf)
#   debriefs         Extract lessons, append to playbook, archive
#   status           Show brief counts by status
#   find [query]      Find briefs matching query (fzf)

set -euo pipefail

BRIEFS_DIR="briefs"
INDEX_FILE="$BRIEFS_DIR/index.json"
TODAY=$(date +%Y-%m-%d)
ARCHIVE_DIR="$BRIEFS_DIR/$TODAY"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
ok() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*" >&2; }

# ─────────────────────────────────────────────────────────────
# CATALOG: Scan briefs, generate index.json
# ─────────────────────────────────────────────────────────────
cmd_catalog() {
  local dry_run=false
  [[ "${1:-}" == "--dry-run" ]] && dry_run=true

  info "Cataloging briefs..."

  local tmp_index=$(mktemp)
  local count=0
  local first=true

  # Start building briefs array in temp file
  echo '[' > "$tmp_index"

  # Find all .md files in briefs/
  while IFS= read -r -d '' f; do
    local relpath="${f#$BRIEFS_DIR/}"
    local content=$(cat "$f")
    
    # Extract metadata
    local title=$(echo "$content" | head -5 | grep "^# " | sed 's/^#* //' | tr -d '*"`' | head -1)
    local date=$(echo "$relpath" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1)
    local status=$(echo "$content" | grep -oiE "status:[[:space:]]*(draft|active|released|reference|orphan)" | cut -d: -f2 | tr -d ' ' | head -1)
    [[ -z "$status" ]] && status="active"
    
    # Detect project
    local project=$(echo "$content" | grep -oE "v[0-9]+\.[0-9]+" | head -1 || echo "")

    # Summary: first paragraph after ## heading
    local summary=$(echo "$content" | awk '/^## [^L]/,/^#/{if(++n>1 && !/^#/) print}' | head -3 | tr '\n' ' ' | cut -c1-200)

    # Add comma if not first
    $first || echo "," >> "$tmp_index"
    first=false

    # Build JSON object inline
    jq -n \
      --arg path "$relpath" \
      --arg title "$title" \
      --arg date "${date:-unknown}" \
      --arg status "$status" \
      --arg project "${project:-}" \
      --arg summary "$summary" \
      '{
        file: $path,
        title: $title,
        date: $date,
        status: $status,
        project: (if $project == "" then null else $project end),
        tags: [],
        summary: $summary
      }' >> "$tmp_index"
    
    ((count++)) || true
    
  done < <(find "$BRIEFS_DIR" -name "*.md" ! -name "BRIEFS-*" ! -name "index.json" ! -path "*/archive/*" -type f -print0 | sort -z)

  echo ']' >> "$tmp_index"

  # Convert briefs array to proper JSON
  local briefs_array=$(jq '.' "$tmp_index" 2>/dev/null || echo '[]')
  
  # Generate byStatus summary
  local by_status=$(echo "$briefs_array" | jq '[.[].status] | group_by(.) | map({key: .[0], value: length}) | from_entries' 2>/dev/null || echo '{}')
  
  # Build final index
  jq -n \
    --arg generated "$(date -Iseconds)" \
    --argjson total "$count" \
    --argjson byStatus "$by_status" \
    --argjson briefs "$briefs_array" \
    '{
      generated: $generated,
      total: $total,
      byStatus: $byStatus,
      briefs: $briefs
    }' > "${tmp_index}.out"

  if $dry_run; then
    info "Dry run - would write:"
    jq '.' "${tmp_index}.out"
  else
    mv "${tmp_index}.out" "$INDEX_FILE"
    ok "Indexed $count briefs → $INDEX_FILE"
  fi

  rm -f "$tmp_index" "${tmp_index}.out"
}

# ─────────────────────────────────────────────────────────────
# ARCHIVE: Move stale briefs to date folders
# ─────────────────────────────────────────────────────────────
cmd_archive() {
  local dry_run=false
  [[ "${1:-}" == "--dry-run" ]] && dry_run=true

  if [[ ! -f "$INDEX_FILE" ]]; then
    err "No index.json. Run: briefs.sh catalog"
    exit 1
  fi

  info "Finding briefs to archive..."

  local now_ts=$(date +%s)
  
  # Find archiveable briefs (released >30d, reference >60d)
  local to_archive=$(echo "[]" | jq -n)
  
  # Check each brief
  for file in $(jq -r '.briefs[] | select(.archived == null) | .file' "$INDEX_FILE"); do
    local status=$(jq -r --arg f "$file" '.briefs[] | select(.file == $f) | .status' "$INDEX_FILE")
    local date=$(jq -r --arg f "$file" '.briefs[] | select(.file == $f) | .date' "$INDEX_FILE")
    
    # Skip if already in subdir
    [[ "$file" == *"/"* ]] && continue
    
    # Calculate age
    local date_ts=$(date -j -f "%Y-%m-%d" "$date" +%s 2>/dev/null || echo "0")
    local age_days=$(( (now_ts - date_ts) / 86400 ))
    
    local archive=false
    case "$status" in
      released) [[ $age_days -gt 30 ]] && archive=true ;;
      reference) [[ $age_days -gt 60 ]] && archive=true ;;
    esac
    
    if $archive; then
      to_archive=$(echo "$to_archive" | jq ". + [\"$file\"]")
    fi
  done

  local count=$(echo "$to_archive" | jq 'length')

  # Show orphans (flag only)
  local orphans=$(jq -r '.briefs[] | select(.status == "orphan") | "\(.file) (\(.date))"' "$INDEX_FILE")
  if [[ -n "$orphans" ]]; then
    warn "Orphaned briefs (review needed):"
    echo "$orphans" | while read -r line; do echo "   $line"; done
  fi

  if [[ "$count" -eq 0 ]]; then
    ok "Nothing to archive."
    return
  fi

  warn "Will archive $count brief(s):"
  echo "$to_archive" | jq -r '.[]' | sed 's/^/   /'

  if $dry_run; then
    info "Dry run - no changes made."
    return
  fi

  # Interactive selection with fzf
  if command -v fzf &>/dev/null; then
    local selected=$(echo "$to_archive" | jq -r '.[]' | fzf --prompt="Archive these? " -m)
    if [[ -z "$selected" ]]; then
      info "Aborted."
      return
    fi
    to_archive=$(echo "[]" | jq -n --argjson s "$(echo "$selected" | jq -R . | jq -s .)" '$s')
  fi

  # Create archive dir and move files
  mkdir -p "$ARCHIVE_DIR"
  
  echo "$to_archive" | jq -r '.[]' | while read -r file; do
    local src="$BRIEFS_DIR/$file"
    local dst="$ARCHIVE_DIR/$(basename "$file")"
    [[ -f "$src" ]] && mv "$src" "$dst" && ok "Archived: $file"
  done

  # Re-catalog to update index
  cmd_catalog
}

# ─────────────────────────────────────────────────────────────
# SYNC: Update BRIEFS-ROADMAP from index
# ─────────────────────────────────────────────────────────────
cmd_sync() {
  if [[ ! -f "$INDEX_FILE" ]]; then
    err "No index.json. Run: briefs.sh catalog"
    exit 1
  fi

  info "Syncing BRIEFS-ROADMAP..."

  # Get counts
  local active_count=$(jq '[.briefs[] | select(.status == "active" and .archived == null)] | length' "$INDEX_FILE")
  local released_count=$(jq '[.briefs[] | select(.status == "released")] | length' "$INDEX_FILE")
  local reference_count=$(jq '[.briefs[] | select(.status == "reference")] | length' "$INDEX_FILE")
  local orphan_count=$(jq '[.briefs[] | select(.status == "orphan")] | length' "$INDEX_FILE")
  local total=$(jq '.total' "$INDEX_FILE")

  {
    echo "# BRIEFS-ROADMAP"
    echo ""
    echo '> Auto-generated by briefs.sh. Last updated:' $(date +%Y-%m-%d)
    echo ""
    echo "## Summary"
    echo ""
    echo "| Status | Count |"
    echo "|--------|-------|"
    echo "| Active | $active_count |"
    echo "| Released | $released_count |"
    echo "| Reference | $reference_count |"
    echo "| Orphan | $orphan_count |"
    echo "| **Total** | **$total** |"
    echo ""
    echo "## Active Briefs"
    echo ""
    jq -r '[.briefs[] | select(.status == "active" and .archived == null)] | sort_by(.date) | reverse | .[] | "| [\(.file)](\(.file)) | \(.project // "-") | \(.date) |"' "$INDEX_FILE"
    echo ""
    echo "## Orphaned (Review Needed)"
    echo ""
    jq -r '[.briefs[] | select(.status == "orphan")] | .[] | "| \(.file) | \(.date) |"' "$INDEX_FILE"
    echo ""
    echo "## Released"
    echo ""
    jq -r '[.briefs[] | select(.status == "released")] | group_by(.project) | .[] | "### \(.[0].project // "Other")" + "\n\n| Brief | Archived |\n|-------|----------|\n" + (.[] | "| \(.file) | \(.archived // "-") |") + "\n"' "$INDEX_FILE"
  } > "$BRIEFS_DIR/BRIEFS-ROADMAP.md"

  ok "Updated $BRIEFS_DIR/BRIEFS-ROADMAP.md"
}

# ─────────────────────────────────────────────────────────────
# PLAN: Generate workplan with fzf for prioritization
# ─────────────────────────────────────────────────────────────
cmd_plan() {
  if [[ ! -f "$INDEX_FILE" ]]; then
    err "No index.json. Run: ./scripts/briefs.sh catalog"
    exit 1
  fi

  info "Generating workplan..."

  local tmp=$(mktemp)
  local total=0

  # Process each active brief
  while IFS= read -r line; do
    local file=$(echo "$line" | jq -r '.file')
    local date=$(echo "$line" | jq -r '.date')
    local title=$(echo "$line" | jq -r '.title // empty')
    local combined="$file $title"
    
    # Classify epic
    local epic="misc"
    if echo "$combined" | grep -qi "api\|server\|sse\|provision\|lexicon\|entropy\|cadence\|scaling\|rate-limit\|justfile"; then
      epic="infra"
    elif echo "$combined" | grep -qi "agent\|compliance\|review\|debrief\|management\|lifecycle"; then
      epic="agents"
    elif echo "$combined" | grep -qi "docs\|documentation\|blog\|bestiary\|knowledge\|competency\|conceptual"; then
      epic="docs"
    elif echo "$combined" | grep -qi "presentation\|pxy\|workflow\|voice\|phone"; then
      epic="presentation"
    elif echo "$combined" | grep -qi "gamma\|sys2\|prompt\|architecture\|entropy-led"; then
      epic="gamma"
    elif echo "$combined" | grep -qi "gemma\|research\|experiment\|poc"; then
      epic="research"
    elif echo "$combined" | grep -qi "test\|coverage\|counter-blast"; then
      epic="testing"
    fi
    
    # Fallback title from filename
    if [[ -z "$title" ]] || [[ "$title" == "null" ]]; then
      title=$(basename "$file" .md | sed 's/^[0-9-]*-brief-//' | tr '-' ' ')
    fi
    
    echo -e "$epic\t$date\t$file\t$title"
    ((total++)) || true
  done < <(jq -c '.briefs[] | select(.status == "active")' "$INDEX_FILE") > "$tmp"

  local epic_order=("infra" "agents" "docs" "presentation" "gamma" "research" "testing" "misc")

  {
    echo "# Briefs Workplan"
    echo ""
    echo "> Auto-generated by ./scripts/briefs.sh plan ($(date +%Y-%m-%d))"
    echo "> Sorted by date within epic — reorder before coding"
    echo ""

    for epic in "${epic_order[@]}"; do
      local epic_briefs=$(grep "^$epic\t" "$tmp" | sort -t$'	' -k2 | cut -f3-)
      [[ -z "$epic_briefs" ]] && continue

      local count=$(echo "$epic_briefs" | wc -l | tr -d ' ')

      echo "## $epic ($count)"
      echo ""

      echo "$epic_briefs" | while IFS=$'	' read -r file title; do
        echo "- [ ] $title"
        echo "  - \`$file\`"
        echo ""
      done
    done

    echo "---"
    echo ""
    echo "Total: $total briefs"

  } > "$BRIEFS_DIR/briefs-plan.md"

  rm -f "$tmp"
  ok "Plan written → $BRIEFS_DIR/briefs-plan.md ($total briefs)"
}

cmd_debriefs() {
  local dry_run=false
  [[ "${1:-}" == "--dry-run" ]] && dry_run=true

  local DEBRIEFS_DIR="debriefs"
  local ARCHIVE_DIR="$DEBRIEFS_DIR/archive"
  local PLAYBOOK_LESSONS="playbooks/lessons-learned.md"

  [[ ! -d "$DEBRIEFS_DIR" ]] && { err "No debriefs/ directory found."; exit 1; }

  info "Processing debriefs..."
  mkdir -p "$ARCHIVE_DIR"

  local count=0
  for f in "$DEBRIEFS_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    local filename=$(basename "$f")
    [[ -f "$ARCHIVE_DIR/$filename" ]] && continue

    local content=$(cat "$f")
    
    if echo "$content" | grep -qi "lesson\|retro\|post-mortem"; then
      local title=$(echo "$content" | head -3 | grep "^# " | sed 's/^#* //' || echo "$filename")
      local date=$(echo "$filename" | grep -oE "^[0-9]{4}-[0-9]{2}-[0-9]{2}")
      
      # Extract lessons section
      local lessons=$(echo "$content" | awk '/^##.*[Ll]esson/,/^##[^#]/ { 
        if (/^##[^#]/ && !/^##.*[Ll]esson/) exit
        print
      }')
      
      if [[ -n "$lessons" ]]; then
        count=$((count + 1))
        
        if $dry_run; then
          info "[DRY-RUN] Would extract lessons from: $filename"
        else
          cat >> "$PLAYBOOK_LESSONS" << LESSONS

## $title

*Source: $filename ($date)*

$lessons
LESSONS
          ok "Extracted lessons: $filename → $PLAYBOOK_LESSONS"
          mv "$f" "$ARCHIVE_DIR/$filename"
          ok "Archived: $filename"
        fi
      fi
    fi
  done

  [[ $count -eq 0 ]] && ok "No new debriefs to process."
}

# ─────────────────────────────────────────────────────────────
# STATUS: Show brief counts
# ─────────────────────────────────────────────────────────────
cmd_status() {
  if [[ -f "$INDEX_FILE" ]]; then
    info "Briefs index ($(jq -r '.generated' "$INDEX_FILE" | cut -dT -f1)):"
    echo ""
    jq -r '.byStatus | to_entries | .[] | "  \(.key): \(.value)"' "$INDEX_FILE"
    echo ""
    echo "  Total: $(jq '.total' "$INDEX_FILE")"
  else
    warn "No index.json. Run: ./scripts/briefs.sh catalog"
  fi
}

# ─────────────────────────────────────────────────────────────
# FIND: Interactive search with fzf
# ─────────────────────────────────────────────────────────────
cmd_find() {
  local query="${1:-}"
  
  command -v fzf &>/dev/null || { err "fzf not installed"; exit 1; }

  if [[ -f "$INDEX_FILE" ]]; then
    jq -r '.briefs[] | "\(.file)\t\(.title // .file)\t\(.status)"' "$INDEX_FILE" \
      | fzf --query="$query" \
            --prompt="Search briefs: " \
            --preview="cat $BRIEFS_DIR/{1}" \
            --preview-window="right:60%"
  else
    find "$BRIEFS_DIR" -name "*.md" ! -path "*/archive/*" \
      | sed "s|$BRIEFS_DIR/||" \
      | fzf --query="$query" \
            --prompt="Search briefs: " \
            --preview="cat $BRIEFS_DIR/{1}" \
            --preview-window="right:60%"
  fi
}

# ─────────────────────────────────────────────────────────────
# HELP
# ─────────────────────────────────────────────────────────────
cmd_help() {
  cat << 'EOF'
briefs.sh - Briefs management toolkit

Usage: ./scripts/briefs.sh <command>

Commands:
  catalog          Scan briefs, generate index.json
  archive          Archive stale briefs
  sync             Update BRIEFS-ROADMAP from index
  plan             Generate workplan (sorted by epic + date)
  debriefs         Extract lessons → playbook, archive
  status           Show brief counts
  find [query]     Search briefs (fzf)

Just recipes:
  just briefs          # This help
  just briefs-catalog  just briefs-archive
  just briefs-sync     just briefs-plan
  just briefs-debriefs just briefs-status
  just briefs-maintain # catalog + debriefs + sync
EOF
}

# MAIN
# ─────────────────────────────────────────────────────────────
main() {
  local cmd="${1:-}"
  
  case "$cmd" in
    catalog) cmd_catalog "${2:-}" ;;
    archive) cmd_archive "${2:-}" ;;
    sync) cmd_sync ;;
    plan) cmd_plan ;;
    debriefs) cmd_debriefs "${2:-}" ;;
    status) cmd_status ;;
    find) cmd_find "${2:-}" ;;
    help|--help|-h|"") cmd_help ;;
    *) err "Unknown command: $cmd"; cmd_help ;;
  esac
}

main "$@"
