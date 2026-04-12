#!/bin/bash
# story-list.sh — List and search stories
# Usage: ./story-list.sh [--tag TAG] [--type TYPE] [--source FILE]
#
# Lists stories from stories/stories.jsonl

set -euo pipefail

STORIES_FILE="${STORIES_FILE:-stories/stories.jsonl}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
FILTER_TAG=""
FILTER_TYPE=""
FILTER_SOURCE=""
SHOW_ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag|-t)
            FILTER_TAG="$2"
            shift 2 ;;
        --type|-y)
            FILTER_TYPE="$2"
            shift 2 ;;
        --source|-s)
            FILTER_SOURCE="$2"
            shift 2 ;;
        --all|-a)
            SHOW_ALL=true
            shift ;;
        --help|-h)
            echo "Usage: story-list.sh [--tag TAG] [--type TYPE] [--source FILE]"
            echo ""
            echo "Options:"
            echo "  --tag, -t TAG    Filter by tag"
            echo "  --type, -y TYPE  Filter by type (origin|lesson|insight|anti-pattern)"
            echo "  --source, -s FILE  Filter by source file"
            echo "  --all, -a       Show all stories (not just recent)"
            exit 0 ;;
        *)
            shift ;;
    esac
done

# Check if stories exist
if [ ! -f "$STORIES_FILE" ]; then
    echo "No stories found. Run: story-scan.sh"
    exit 0
fi

# Build jq filter
FILTER="."
if [ -n "$FILTER_TAG" ]; then
    FILTER="$FILTER | select(.tags | index(\"$FILTER_TAG\") != null)"
fi
if [ -n "$FILTER_TYPE" ]; then
    FILTER="$FILTER | select(.type == \"$FILTER_TYPE\")"
fi
if [ -n "$FILTER_SOURCE" ]; then
    FILTER="$FILTER | select(.source | contains(\"$FILTER_SOURCE\"))"
fi

# Type icons
icon() {
    case "$1" in
        origin) echo "🌱" ;;
        lesson) echo "📚" ;;
        insight) echo "💡" ;;
        anti-pattern) echo "⚠️" ;;
        *) echo "📝" ;;
    esac
}

# List stories
list_stories() {
    local count=0
    
    echo "=== Stories ==="
    echo ""
    
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        
        # Parse story
        id=$(echo "$line" | jq -r '.id')
        source=$(echo "$line" | jq -r '.source')
        type=$(echo "$line" | jq -r '.type')
        narrative=$(echo "$line" | jq -r '.narrative')
        usefulness=$(echo "$line" | jq -r '.usefulness')
        
        # Color by usefulness
        case "$usefulness" in
            high) color="$GREEN" ;;
            medium) color="$YELLOW" ;;
            low) color="$RED" ;;
            *) color="$NC" ;;
        esac
        
        echo -e "${color}$(icon "$type")${NC} [${type}] ${source}"
        echo "  ${narrative:0:120}..."
        echo ""
        
        count=$((count + 1))
        
    done < <(jq -c "$FILTER" "$STORIES_FILE" 2>/dev/null)
    
    echo "---"
    echo "Total: $count stories"
}

# Stats
stats() {
    echo "=== Story Stats ==="
    echo ""
    echo "By type:"
    jq -s 'map(.type) | group_by(.) | map("\(.[0]): \(length)") | .[]' "$STORIES_FILE" 2>/dev/null || echo "  (no data)"
    echo ""
    echo "By source:"
    jq -s 'map(.source | split("/")[0]) | group_by(.) | map("\(.[0]): \(length)") | .[]' "$STORIES_FILE" 2>/dev/null || echo "  (no data)"
    echo ""
    echo "Total stories: $(wc -l < "$STORIES_FILE")"
}

# Main
main() {
    if [ ! -f "$STORIES_FILE" ]; then
        echo "No stories found. Run: story-scan.sh"
        exit 0
    fi
    
    if [ "$SHOW_ALL" = true ]; then
        stats
        echo ""
        list_stories
    else
        list_stories
    fi
}

main
