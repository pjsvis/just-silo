#!/bin/bash
# story-list.sh — List and search stories
# Usage: ./story-list.sh [--tag TAG] [--type TYPE] [--source FILE] [--min-quality N]
#
# Lists stories from insights/stories.jsonl
# Features:
# - Quality score filtering
# - Topic tag grouping
# - Balance report (type distribution)

set -euo pipefail

STORIES_FILE="${STORIES_FILE:-insights/stories.jsonl}"

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
MIN_QUALITY=""
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
        --min-quality|-q)
            MIN_QUALITY="$2"
            shift 2 ;;
        --all|-a)
            SHOW_ALL=true
            shift ;;
        --help|-h)
            echo "Usage: story-list.sh [--tag TAG] [--type TYPE] [--source FILE] [--min-quality N]"
            echo ""
            echo "Options:"
            echo "  --tag, -t TAG       Filter by tag"
            echo "  --type, -y TYPE     Filter by type (origin|lesson|insight|anti-pattern)"
            echo "  --source, -s FILE   Filter by source file"
            echo "  --min-quality, -q N Filter by minimum quality score (0.0-1.0)"
            echo "  --all, -a          Show all stories and stats"
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
if [ -n "$MIN_QUALITY" ]; then
    FILTER="$FILTER | select(.quality >= $MIN_QUALITY)"
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

# Quality color
quality_color() {
    local q="$1"
    if (( $(echo "$q >= 0.7" | bc -l) )); then
        echo "$GREEN"
    elif (( $(echo "$q >= 0.4" | bc -l) )); then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# Balance report
balance_report() {
    local total=$(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    
    echo "=== Story Balance Report ==="
    echo ""
    echo -e "${CYAN}Total stories:${NC} $total"
    echo ""
    
    echo -e "${CYAN}By Type:${NC}"
    local types=$(jq -n '[inputs] | group_by(.type) | map({type: .[0].type, count: length}) | sort_by(.type)' "$STORIES_FILE" 2>/dev/null || echo [])
    echo "$types" | jq -r '.[] | "  \(.type): \(.count)"'
    echo ""
    
    # Quality distribution
    echo -e "${CYAN}Quality Distribution:${NC}"
    local high=$(jq -n '[inputs | select(.quality >= 0.35)] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    local med=$(jq -n '[inputs | select(.quality >= 0.2 and .quality < 0.35)] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    local low=$(jq -n '[inputs | select(.quality < 0.2)] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    echo -e "  ${GREEN}High (≥0.35):${NC} $high"
    echo -e "  ${YELLOW}Medium (0.2-0.35):${NC} $med"
    echo -e "  ${RED}Low (<0.2):${NC} $low"
    echo ""
    
    echo -e "${CYAN}By Topic (top 10):${NC}"
    local topics=$(jq -n '[inputs | select(.tags | length > 0)] | group_by(.tags[0]) | map({topic: .[0].tags[0], count: length}) | sort_by(.count) | reverse | .[:10]' "$STORIES_FILE" 2>/dev/null || echo [])
    if [ "$topics" != "[]" ]; then
        echo "$topics" | jq -r '.[] | "  \(.topic): \(.count)"'
    else
        echo "  (no tagged stories)"
    fi
    echo ""
    
    echo -e "${CYAN}Type Balance Assessment:${NC}"
    local origins=$(echo "$types" | jq -r '.[] | select(.type == "origin") | .count' 2>/dev/null || echo 0)
    local lessons=$(echo "$types" | jq -r '.[] | select(.type == "lesson") | .count' 2>/dev/null || echo 0)
    local insights=$(echo "$types" | jq -r '.[] | select(.type == "insight") | .count' 2>/dev/null || echo 0)
    
    if [ "$origins" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No origin stories${NC}"
    elif [ "$origins" -lt 3 ]; then
        echo -e "${YELLOW}⚠️  Few origin stories ($origins)${NC}"
    else
        echo -e "${GREEN}✓ Origin stories: $origins${NC}"
    fi
    
    if [ "$lessons" -lt 5 ]; then
        echo -e "${YELLOW}⚠️  Few lesson stories ($lessons)${NC}"
    else
        echo -e "${GREEN}✓ Lesson stories: $lessons${NC}"
    fi
    
    if [ "$insights" -gt $(( total / 2 )) ]; then
        echo -e "${YELLOW}⚠️  $insights insights (dominates ${total})${NC}"
    fi
    echo ""
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
        quality=$(echo "$line" | jq -r '.quality // 0.5')
        tags=$(echo "$line" | jq -r '.tags | join(", ")')
        
        # Color by quality
        qcolor=$(quality_color "$quality")
        
        echo -e "$(icon "$type") [${type}] ${qcolor}($quality)${NC} ${source}"
        [ -n "$tags" ] && [ "$tags" != "" ] && echo -e "  Tags: $CYAN$tags$NC"
        echo "  ${narrative:0:120}..."
        echo ""
        
        count=$((count + 1))
        
    done < <(jq -c "$FILTER" "$STORIES_FILE" 2>/dev/null)
    
    echo "---"
    echo "Showing: $count stories"
}

# Topic browser
topic_browser() {
    echo "=== Topics ==="
    echo ""
    
    # Get unique topics with counts
    jq -n '[inputs | select(.tags | length > 0)] | group_by(.tags[0]) | map({topic: .[0].tags[0], count: length, types: map(.type) | group_by(.) | map({type: .[0], count: length})}) | sort_by(.count) | reverse' "$STORIES_FILE" 2>/dev/null | jq -r '.[] |
        "\(.count) \(.topic):"'
}

# Main
main() {
    if [ ! -f "$STORIES_FILE" ]; then
        echo "No stories found. Run: story-scan.sh"
        exit 0
    fi
    
    if [ "$SHOW_ALL" = true ]; then
        balance_report
        echo ""
        list_stories
    else
        list_stories
    fi
}

main
