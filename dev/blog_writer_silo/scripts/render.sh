#!/bin/bash
# render.sh — Render draft to final post (dev version)
# Usage: ./render.sh DRAFT_FILE

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FILE="${1:-}"
if [ -z "$FILE" ]; then
    echo "Usage: ./render.sh drafts/DRAFT.md"
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

# Extract metadata
TITLE=$(sed -n '/^title: */s///p' "$FILE" | tr -d '"' || echo "Untitled")
TOPIC=$(sed -n '/^topic: */s///p' "$FILE" || echo "unknown")
DATE=$(sed -n '/^date: */s///p' "$FILE" || date +%Y-%m-%d)

SLUG=$(echo "$TITLE" | sed -e 's/[^a-zA-Z0-9]/-/g')
OUTPUT_DIR="$SILO_DIR/posts"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/${DATE}-${SLUG}.md"

echo "Title: $TITLE"
echo "Output: $OUTPUT_FILE"

{
    echo "---"
    echo "title: \"$TITLE\""
    echo "topic: $TOPIC"
    echo "date: $DATE"
    echo "published: true"
    echo "---"
    echo ""
    
    SKIP=false
    while IFS= read -r line; do
        if [ "$line" = "---" ]; then
            if [ "$SKIP" = false ]; then
                SKIP=true
                continue
            fi
        fi
        if [ "$SKIP" = false ]; then
            continue
        fi
        
        [[ "$line" =~ ^(title:|topic:|date:) ]] && continue
        [[ "$line" == "<!--"* ]] && continue
        [[ "$line" == "*Add your"* ]] && continue
        
        echo "$line"
    done < "$FILE"
    
    echo ""
    echo "---"
    echo "*Published: $(date)*"
    
} > "$OUTPUT_FILE"

echo ""
echo "Rendered: $OUTPUT_FILE"
