#!/bin/bash
# status.sh — Status management for blog-writer-silo
# Usage: ./status.sh [CMD] [ARGS]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$SILO_DIR/status.json"

# Status states
STATE_DRAFT="draft"
STATE_RENDERED="rendered"
STATE_PUBLISHED="published"
STATE_ARCHIVED="archived"

# Initialize status file
init_status() {
    if [ ! -f "$STATUS_FILE" ]; then
        cat > "$STATUS_FILE" << 'EOF'
{
  "version": "0.1.0",
  "updated": null,
  "drafts": [],
  "posts": [],
  "stats": {
    "total_drafts": 0,
    "total_posts": 0,
    "stories_used": 0
  }
}
EOF
    fi
}

# Get current status
get_status() {
    init_status
    cat "$STATUS_FILE"
}

# Add or update a draft
set_draft() {
    local file="$1"
    local topic="${2:-unknown}"
    
    init_status
    
    local basename=$(basename "$file")
    local date=$(date +%Y-%m-%d)
    
    # Check if already exists
    if jq -e ".drafts[] | select(.file == \"$basename\")" "$STATUS_FILE" > /dev/null 2>&1; then
        # Update existing
        jq ".drafts |= map(if .file == \"$basename\" then {file: \"$basename\", topic: \"$topic\", state: \"$STATE_DRAFT\", updated: \"$date\"} else . end)" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    else
        # Add new
        jq ".drafts += [{\"file\": \"$basename\", \"topic\": \"$topic\", \"state\": \"$STATE_DRAFT\", \"created\": \"$date\", \"updated\": \"$date\"}]" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    fi
    
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    update_stats
}

# Update draft state
update_draft_state() {
    local file="$1"
    local new_state="$2"
    
    init_status
    
    local basename=$(basename "$file")
    local date=$(date +%Y-%m-%d)
    
    jq ".drafts |= map(if .file == \"$basename\" then .state = \"$new_state\" | .updated = \"$date\" else . end)" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    update_stats
}

# Move draft to posts
add_post() {
    local draft_file="$1"
    local post_file="$2"
    
    init_status
    
    local draft_basename=$(basename "$draft_file")
    local post_basename=$(basename "$post_file")
    local date=$(date +%Y-%m-%d)
    
    # Get topic from draft
    local topic=$(jq -r ".drafts[] | select(.file == \"$draft_basename\") | .topic" "$STATUS_FILE" 2>/dev/null || echo "unknown")
    
    # Add to posts
    jq ".posts += [{\"file\": \"$post_basename\", \"topic\": \"$topic\", \"published\": \"$date\"}]" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    
    # Remove from drafts
    jq ".drafts |= map(select(.file != \"$draft_basename\"))" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    
    update_stats
}

# Update stats
update_stats() {
    local draft_count=$(jq '.drafts | length' "$STATUS_FILE")
    local post_count=$(jq '.posts | length' "$STATUS_FILE")
    
    jq ".stats = {\"total_drafts\": $draft_count, \"total_posts\": $post_count}" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    
    jq ".updated = \"$(date -Iseconds)\"" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
}

# List status
list_status() {
    init_status
    
    echo "=== Blog-Writer Silo Status ==="
    echo ""
    
    local version=$(jq -r '.version' "$STATUS_FILE")
    local updated=$(jq -r '.updated' "$STATUS_FILE")
    echo "Version: $version"
    echo "Updated: ${updated:-never}"
    echo ""
    
    local stats=$(jq -r '.stats' "$STATUS_FILE")
    echo "Stats:"
    echo "  Drafts: $(echo "$stats" | jq -r '.total_drafts')"
    echo "  Posts: $(echo "$stats" | jq -r '.total_posts')"
    echo ""
    
    local drafts=$(jq -r '.drafts' "$STATUS_FILE")
    local draft_count=$(echo "$drafts" | jq 'length')
    
    if [ "$draft_count" -gt 0 ]; then
        echo "Drafts:"
        echo "$drafts" | jq -r '.[] | "  [\(.state)] \(.file) - \(.topic) (\(.updated))"'
        echo ""
    fi
    
    local posts=$(jq -r '.posts' "$STATUS_FILE")
    local post_count=$(echo "$posts" | jq 'length')
    
    if [ "$post_count" -gt 0 ]; then
        echo "Posts:"
        echo "$posts" | jq -r '.[] | "  \(.file) - \(.topic) (\(.published))"'
    fi
}

# Remove draft from status
remove_draft() {
    local file="$1"
    
    init_status
    
    local basename=$(basename "$file")
    jq ".drafts |= map(select(.file != \"$basename\"))" "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    update_stats
}

# If called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-show}" in
        show|get)
            get_status | jq .
            ;;
        list|ls)
            list_status
            ;;
        add-draft)
            set_draft "${2:-}" "${3:-}"
            ;;
        update-state)
            update_draft_state "${2:-}" "${3:-}"
            ;;
        add-post)
            add_post "${2:-}" "${3:-}"
            ;;
        rm-draft)
            remove_draft "${2:-}"
            ;;
        init)
            init_status
            echo "Status initialized"
            ;;
        *)
            echo "Usage: status.sh [show|list|add-draft|update-state|add-post|rm-draft]"
            ;;
    esac
fi
