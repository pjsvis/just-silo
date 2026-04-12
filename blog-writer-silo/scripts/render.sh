#!/bin/bash
# render.sh — Render draft to final post
# Usage: ./render.sh FILE

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILE="${1:-}"
if [ -z "$FILE" ]; then
    echo "Usage: ./render.sh FILE"
    echo "Example: ./render.sh drafts/draft-2026-04-12-gemma4.md"
    exit 1
fi

# Resolve path
if [[ "$FILE" != /* ]]; then
    FILE="$SILO_DIR/$FILE"
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

echo "=== Rendering Draft ==="
echo "File: $FILE"
echo ""

# Extract metadata
TITLE=$(sed -n '/^title: */s///p' "$FILE" | tr -d '"' || echo "Untitled")
TOPIC=$(sed -n '/^topic: */s///p' "$FILE" || echo "unknown")
DATE=$(sed -n '/^date: */s///p' "$FILE" || date +%Y-%m-%d)

echo "Title: $TITLE"
echo "Topic: $TOPIC"
echo "Date: $DATE"
echo ""

# Generate output filename
SLUG=$(echo "$TITLE" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
OUTPUT_DIR="$SILO_DIR/posts"
mkdir -p "$OUTPUT_DIR"

# Clean the draft for rendering
# 1. Remove YAML frontmatter
# 2. Remove story metadata comments
# 3. Clean up any TODO markers

OUTPUT_FILE="$OUTPUT_DIR/${DATE}-${SLUG}.md"

echo "Output: $OUTPUT_FILE"
echo ""

# Render the content
{
    # Frontmatter
    echo "---"
    echo "title: \"$TITLE\""
    echo "topic: $TOPIC"
    echo "date: $DATE"
    echo "published: true"
    echo "---"
    echo ""
    
    # Extract content (skip frontmatter and metadata lines)
    SKIP=false
    while IFS= read -r line; do
        # Skip frontmatter
        if [ "$line" = "---" ]; then
            if [ "$SKIP" = false ]; then
                SKIP=true
                continue
            fi
        fi
        if [ "$SKIP" = false ]; then
            continue
        fi
        
        # Skip metadata lines
        if [[ "$line" =~ ^(title:|topic:|date:|stories_used:) ]]; then
            continue
        fi
        
        # Skip story metadata comments
        if [[ "$line" == "<!--"* ]]; then
            continue
        fi
        
        # Skip TODOs
        if [[ "$line" == "*Add your"* ]] || [[ "$line" == *TODO* ]] || [[ "$line" == *FIXME* ]]; then
            continue
        fi
        
        echo "$line"
        
    done < "$FILE"
    
    echo ""
    echo "---"
    echo "*Published: $(date)*"
    
} > "$OUTPUT_FILE"

echo "Rendered: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  just publish $FILE   - Move to posts/ and clean up"
echo "  cat $OUTPUT_FILE    - Preview the post"
