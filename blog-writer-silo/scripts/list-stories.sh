#!/bin/bash
# list-stories.sh — List and search stories
# Usage: ./list-stories.sh [--tag TAG] [--type TYPE] [--min-quality N]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="${STORIES_FILE:-$SILO_DIR/../stories/stories.jsonl}"

FILTER_TAG=""
FILTER_TYPE=""
MIN_QUALITY=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag|-t)
            FILTER_TAG="$2"
            shift 2 ;;
        --type|-y)
            FILTER_TYPE="$2"
            shift 2 ;;
        --min-quality|-q)
            MIN_QUALITY="$2"
            shift 2 ;;
        *)
            shift ;;
    esac
done

if [ ! -f "$STORIES_FILE" ]; then
    echo "No stories found. Run 'just blog-scan' first."
    exit 0
fi

# Build filter
FILTER="[inputs]"
if [ -n "$FILTER_TAG" ]; then
    FILTER="$FILTER | map(select(.tags | index(\"$FILTER_TAG\") != null))"
fi
if [ -n "$FILTER_TYPE" ]; then
    FILTER="$FILTER | map(select(.type == \"$FILTER_TYPE\"))"
fi
if [ -n "$MIN_QUALITY" ]; then
    FILTER="$FILTER | map(select(.quality >= $MIN_QUALITY))"
fi

# List stories
echo "=== Stories ==="
echo ""

count=0
while IFS= read -r story; do
    [ -z "$story" ] && continue
    
    id=$(echo "$story" | jq -r '.id')
    type=$(echo "$story" | jq -r '.type')
    quality=$(echo "$story" | jq -r '.quality')
    narrative=$(echo "$story" | jq -r '.narrative')
    tags=$(echo "$story" | jq -r '.tags | join(", ")')
    source=$(echo "$story" | jq -r '.source')
    
    # Color by quality
    if (( $(echo "$quality >= 0.35" | bc -l) )); then
        color='\033[0;32m'
    elif (( $(echo "$quality >= 0.2" | bc -l) )); then
        color='\033[1;33m'
    else
        color='\033[0;31m'
    fi
    NC='\033[0m'
    
    # Icon by type
    case "$type" in
        origin) icon="🌱" ;;
        lesson) icon="📚" ;;
        insight) icon="💡" ;;
        anti-pattern) icon="⚠️" ;;
        *) icon="📝" ;;
    esac
    
    echo -e "$icon [$type] ${color}($quality)${NC}"
    [ -n "$tags" ] && [ "$tags" != "" ] && echo "  Tags: $tags"
    echo "  ${narrative:0:120}..."
    echo ""
    
    count=$((count + 1))
    
done < <(jq -c "$FILTER" "$STORIES_FILE" 2>/dev/null)

echo "---"
echo "Total: $count stories"
