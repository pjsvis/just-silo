#!/bin/bash
# blog-generate.sh — Generate blog post from stories
# Usage: ./blog-generate.sh [--tag TAG] [--type TYPE] [--count N] [--output FILE] [--min-quality N]
#
# Generates a blog post markdown from collected stories
# Features:
# - Topic/tag filtering
# - Quality filtering
# - Balanced type selection

set -euo pipefail

STORIES_FILE="${STORIES_FILE:-insights/stories.jsonl}"
POSTS_DIR="${POSTS_DIR:-insights/_posts}"

mkdir -p "$POSTS_DIR"

# Parse arguments
FILTER_TAG=""
FILTER_TYPE=""
MIN_QUALITY=""
COUNT=5
OUTPUT_FILE=""
BALANCED=false

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
        --count|-n)
            COUNT="$2"
            shift 2 ;;
        --output|-o)
            OUTPUT_FILE="$2"
            shift 2 ;;
        --balanced|-b)
            BALANCED=true
            shift ;;
        --help|-h)
            echo "Usage: blog-generate.sh [--tag TAG] [--type TYPE] [--count N] [--min-quality N] [--balanced]"
            echo ""
            echo "Options:"
            echo "  --tag, -t TAG       Filter by topic tag"
            echo "  --type, -y TYPE     Filter by type (origin|lesson|insight|anti-pattern)"
            echo "  --min-quality, -q N Minimum quality score (0.0-1.0)"
            echo "  --count, -n N       Number of stories to include"
            echo "  --balanced, -b     Try to balance story types (1 of each)"
            exit 0 ;;
        *)
            shift ;;
    esac
done

# Generate slug from title
slugify() {
    echo "$1" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//' | sed 's/-$//'
}

# Get stories as JSON array for balanced selection
get_stories() {
    local filter="[inputs]"
    
    if [ -n "$FILTER_TAG" ]; then
        filter="$filter | map(select(.tags | index(\"$FILTER_TAG\") != null))"
    fi
    if [ -n "$FILTER_TYPE" ]; then
        filter="$filter | map(select(.type == \"$FILTER_TYPE\"))"
    fi
    if [ -n "$MIN_QUALITY" ]; then
        filter="$filter | map(select(.quality >= $MIN_QUALITY))"
    fi
    
    jq -n "$filter" "$STORIES_FILE" 2>/dev/null
}

# Balanced story selection - get 1 of each type
get_balanced_stories() {
    local all_stories=$(get_stories)
    local selected=()
    
    # Get one of each type (prioritize by quality)
    for type in origin lesson insight anti-pattern; do
        local story=$(echo "$all_stories" | jq -c ".[] | select(.type == \"$type\") | select(.quality > 0.3) | {story: ., quality: .quality}" 2>/dev/null | sort -t: -k2 -rn | head -1 | jq -r '.story' 2>/dev/null)
        if [ -n "$story" ] && [ "$story" != "null" ]; then
            selected+=("$story")
        fi
    done
    
    # Output as JSON array
    printf '%s\n' "${selected[@]}" | jq -s .
}

# Generate the post
generate_post() {
    local title="$1"
    local date=$(date +%Y-%m-%d)
    local slug=$(slugify "$title")
    local filename="${date}-${slug}.md"
    local output="${OUTPUT_FILE:-$POSTS_DIR/$filename}"
    
    echo "Generating: $output"
    
    {
        echo "# $title"
        echo ""
        echo "**Date:** $date"
        echo "**Tags:** ${FILTER_TAG:-all}"
        [ -n "$MIN_QUALITY" ] && echo "**Quality:** ≥$MIN_QUALITY"
        [ "$BALANCED" = true ] && echo "**Mode:** Balanced"
        echo ""
        echo "---"
        echo ""
        echo "## The Story"
        echo ""
        
        local count=0
        
        if [ "$BALANCED" = true ]; then
            # Balanced selection
            local stories=$(get_balanced_stories)
            local total=$(echo "$stories" | jq 'length')
            
            echo "<!-- Balanced selection: $total stories -->"
            echo ""
            
            for story in $(echo "$stories" | jq -c '.[]'); do
                [ -z "$story" ] || [ "$story" = "null" ] && continue
                
                local type=$(echo "$story" | jq -r '.type')
                local narrative=$(echo "$story" | jq -r '.narrative')
                local source=$(echo "$story" | jq -r '.source')
                local quality=$(echo "$story" | jq -r '.quality // 0.5')
                local tags=$(echo "$story" | jq -r '.tags | join(", ")')
                
                case "$type" in
                    origin) echo "### 🌱 Origin" ;;
                    lesson) echo "### 📚 Lesson Learned" ;;
                    insight) echo "### 💡 Key Insight" ;;
                    anti-pattern) echo "### ⚠️ Anti-Pattern" ;;
                esac
                
                echo ""
                echo "$narrative"
                echo ""
                echo "*Source: \`$source\`*"
                [ -n "$tags" ] && [ "$tags" != "" ] && echo "*Tags: $tags*"
                echo ""
                
                count=$((count + 1))
            done
        else
            # Standard selection with filters
            local filter="[inputs][:${COUNT}] | .[]"
            if [ -n "$FILTER_TAG" ]; then
                filter="[inputs | select(.tags | index(\"$FILTER_TAG\") != null)][:${COUNT}] | .[]"
            elif [ -n "$FILTER_TYPE" ]; then
                filter="[inputs | select(.type == \"$FILTER_TYPE\")][:${COUNT}] | .[]"
            fi
            if [ -n "$MIN_QUALITY" ]; then
                filter="[inputs | select(.quality >= $MIN_QUALITY)][:${COUNT}] | .[]"
            fi
            
            while IFS= read -r line; do
                [ -z "$line" ] && continue
                
                local type=$(echo "$line" | jq -r '.type')
                local narrative=$(echo "$line" | jq -r '.narrative')
                local source=$(echo "$line" | jq -r '.source')
                local quality=$(echo "$line" | jq -r '.quality // 0.5')
                
                case "$type" in
                    origin) echo "### 🌱 Origin" ;;
                    lesson) echo "### 📚 Lesson Learned" ;;
                    insight) echo "### 💡 Key Insight" ;;
                    anti-pattern) echo "### ⚠️ Anti-Pattern" ;;
                esac
                
                echo ""
                echo "$narrative"
                echo ""
                echo "*Source: \`$source\`*"
                echo ""
                
                count=$((count + 1))
            done < <(jq -c "$filter" "$STORIES_FILE" 2>/dev/null)
        fi
        
        echo "---"
        echo ""
        echo "## Related Stories"
        echo ""
        echo "See also: \`insights/stories.jsonl\`"
        echo ""
        
    } > "$output"
    
    echo "Created: $output ($count stories)"
    echo "$output"
}

# Main
main() {
    if [ ! -f "$STORIES_FILE" ]; then
        echo "No stories found. Run: story-scan.sh first"
        exit 1
    fi
    
    # Count available stories
    local filter="[inputs]"
    if [ -n "$FILTER_TAG" ]; then
        filter="$filter | map(select(.tags | index(\"$FILTER_TAG\") != null))"
    fi
    if [ -n "$FILTER_TYPE" ]; then
        filter="$filter | map(select(.type == \"$FILTER_TYPE\"))"
    fi
    if [ -n "$MIN_QUALITY" ]; then
        filter="$filter | map(select(.quality >= $MIN_QUALITY))"
    fi
    
    local count=$(jq -n "$filter | length" "$STORIES_FILE" 2>/dev/null || echo 0)
    
    if [ "$count" -eq 0 ]; then
        echo "No stories match filter. Run: story-scan.sh first"
        exit 1
    fi
    
    echo "Found $count stories matching criteria"
    
    local title="Wee Stories: $(date +%Y-%m-%d)"
    
    generate_post "$title"
}

main
