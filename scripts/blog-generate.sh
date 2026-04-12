#!/bin/bash
# blog-generate.sh — Generate blog post from stories
# Usage: ./blog-generate.sh [--tag TAG] [--type TYPE] [--count N] [--output FILE]
#
# Generates a blog post markdown from collected stories

set -euo pipefail

STORIES_FILE="${STORIES_FILE:-stories/stories.jsonl}"
POSTS_DIR="${POSTS_DIR:-stories/_posts}"

mkdir -p "$POSTS_DIR"

# Parse arguments
FILTER_TAG=""
FILTER_TYPE=""
COUNT=5
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag|-t)
            FILTER_TAG="$2"
            shift 2 ;;
        --type|-y)
            FILTER_TYPE="$2"
            shift 2 ;;
        --count|-n)
            COUNT="$2"
            shift 2 ;;
        --output|-o)
            OUTPUT_FILE="$2"
            shift 2 ;;
        --help|-h)
            echo "Usage: blog-generate.sh [--tag TAG] [--type TYPE] [--count N] [--output FILE]"
            exit 0 ;;
        *)
            shift ;;
    esac
done

# Generate slug from title
slugify() {
    echo "$1" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//' | sed 's/-$//'
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
        echo ""
        echo "---"
        echo ""
        echo "## The Story"
        echo ""
        
        # Filter and select stories (use [inputs] for JSONL)
        local filter="[inputs][:${COUNT}] | .[]"
        if [ -n "$FILTER_TAG" ]; then
            filter="[inputs | select(.tags | index(\"$FILTER_TAG\") != null)][:${COUNT}] | .[]"
        elif [ -n "$FILTER_TYPE" ]; then
            filter="[inputs | select(.type == \"$FILTER_TYPE\")][:${COUNT}] | .[]"
        fi
        
        local count=0
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            
            local type=$(echo "$line" | jq -r '.type')
            local narrative=$(echo "$line" | jq -r '.narrative')
            local source=$(echo "$line" | jq -r '.source')
            
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
        
        echo "---"
        echo ""
        echo "## Related Stories"
        echo ""
        echo "See also: \`stories/stories.jsonl\`"
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
    
    # Count stories (use [inputs] to read all JSONL records)
    local count=$(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    
    if [ "$count" -eq 0 ]; then
        echo "No stories found. Run: story-scan.sh first"
        exit 1
    fi
    
    local title="Wee Stories: $(date +%Y-%m-%d)"
    
    generate_post "$title"
}

main
