#!/bin/bash
# process.sh — Core domain logic for blog-writer-silo
# Provides reusable functions for story processing

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="${STORIES_FILE:-$SILO_DIR/../../stories/stories.jsonl}"

# ============================================================
# STORY QUERIES
# ============================================================

# Get all stories for a topic
get_stories_for_topic() {
    local topic="$1"
    local min_quality="${2:-0.2}"
    
    jq -n --arg topic "$topic" --argjson quality "$min_quality" \
        '[inputs | select(.tags | index($topic) != null) | select(.quality >= $quality)]' \
        "$STORIES_FILE" 2>/dev/null
}

# Get stories by type
get_stories_by_type() {
    local type="$1"
    
    jq -n --arg type "$type" \
        '[inputs | select(.type == $type) | select(.quality >= 0.2)]' \
        "$STORIES_FILE" 2>/dev/null
}

# Get high quality stories
get_high_quality_stories() {
    local min_quality="${1:-0.35}"
    
    jq -n --argjson quality "$min_quality" \
        '[inputs | select(.quality >= $quality)]' \
        "$STORIES_FILE" 2>/dev/null
}

# ============================================================
# STORY STATS
# ============================================================

# Get story counts
get_stats() {
    cat << EOF
{
  "total": $(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0),
  "by_type": $(jq -n '[inputs] | group_by(.type) | map({type: .[0].type, count: length})' "$STORIES_FILE" 2>/dev/null || echo []),
  "by_quality": {
    "high": $(jq -n '[inputs | select(.quality >= 0.35)] | length' "$STORIES_FILE" 2>/dev/null || echo 0),
    "medium": $(jq -n '[inputs | select(.quality >= 0.2 and .quality < 0.35)] | length' "$STORIES_FILE" 2>/dev/null || echo 0),
    "low": $(jq -n '[inputs | select(.quality < 0.2)] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
  },
  "by_topic": $(jq -n '[inputs | select(.tags | length > 0)] | group_by(.tags[0]) | map({topic: .[0].tags[0], count: length}) | sort_by(.count) | reverse' "$STORIES_FILE" 2>/dev/null || echo [])
}
EOF
}

# ============================================================
# STORY SELECTION
# ============================================================

# Select balanced story set for a topic
select_balanced_set() {
    local topic="$1"
    local count="${2:-6}"
    
    # Get stories for topic
    local topic_stories=$(get_stories_for_topic "$topic")
    
    # Select 1 origin, 1-2 lessons, rest insights
    local origins=$(echo "$topic_stories" | jq -c '[.[] | select(.type == "origin")] | .[:1]')
    local lessons=$(echo "$topic_stories" | jq -c '[.[] | select(.type == "lesson")] | .[:2]')
    local insights=$(echo "$topic_stories" | jq -c '[.[] | select(.type == "insight")] | .[:'$((count - 3))']')
    
    # Combine and shuffle
    echo "$origins" | jq -s '.[0] + .[1] + .[2]' <(echo "$lessons") <(echo "$insights") 2>/dev/null || \
    echo "$topic_stories" | jq ".[:$count]"
}

# ============================================================
# DRAFT BUILDING
# ============================================================

# Build draft section from stories
build_section() {
    local section_name="$1"
    local stories_json="$2"
    local section_type="$3"
    
    echo "## $section_name"
    echo ""
    
    local count=0
    while IFS= read -r story; do
        [ -z "$story" ] || [ "$story" = "null" ] && continue
        
        local id=$(echo "$story" | jq -r '.id')
        local type=$(echo "$story" | jq -r '.type')
        local quality=$(echo "$story" | jq -r '.quality')
        local narrative=$(echo "$story" | jq -r '.narrative')
        
        echo "<!-- STORY id=$id type=$type quality=$quality -->"
        echo "$narrative"
        echo ""
        
        count=$((count + 1))
    done < <(echo "$stories_json" | jq -c '.[]')
    
    if [ $count -eq 0 ]; then
        echo "*No $section_type stories available*"
        echo ""
    fi
}

# ============================================================
# VALIDATION
# ============================================================

# Validate story file
validate_stories() {
    local errors=0
    
    # Check file exists
    if [ ! -f "$STORIES_FILE" ]; then
        echo "Error: Stories file not found: $STORIES_FILE"
        return 1
    fi
    
    # Check JSON validity
    if ! jq empty "$STORIES_FILE" 2>/dev/null; then
        echo "Error: Invalid JSON in stories file"
        return 1
    fi
    
    # Check required fields
    local story_count=$(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    if [ "$story_count" -eq 0 ]; then
        echo "Warning: No stories found"
    fi
    
    return 0
}

# ============================================================
# EXPORT
# ============================================================

# Export functions for use by other scripts
export SILO_DIR STORIES_FILE

# If sourced, run a command
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Called directly
    case "${1:-stats}" in
        stats)
            get_stats
            ;;
        validate)
            validate_stories
            ;;
        *)
            echo "Usage: process.sh [stats|validate]"
            exit 1
            ;;
    esac
fi
