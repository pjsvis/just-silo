#!/bin/bash
# publish.sh — Publish draft to posts/
# Usage: ./publish.sh DRAFT

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$SILO_DIR/scripts/audit.sh"
STATUS_SCRIPT="$SILO_DIR/scripts/status.sh"

DRAFT="${1:-}"
if [ -z "$DRAFT" ]; then
    echo "Usage: ./publish.sh DRAFT"
    echo "Example: ./publish.sh drafts/draft-2026-04-12-gemma4.md"
    exit 1
fi

# Resolve path
if [[ "$DRAFT" != /* ]]; then
    DRAFT="$SILO_DIR/$DRAFT"
fi

if [ ! -f "$DRAFT" ]; then
    echo "Error: Draft not found: $DRAFT"
    exit 1
fi

echo "=== Publishing Draft ==="
echo "Draft: $DRAFT"
echo ""

# Extract metadata
TITLE=$(sed -n '/^title: */s///p' "$DRAFT" | tr -d '"' || echo "Untitled")
TOPIC=$(sed -n '/^topic: */s///p' "$DRAFT" || echo "unknown")
DATE=$(sed -n '/^date: */s///p' "$DRAFT" || date +%Y-%m-%d)

# Render to final post
SLUG=$(echo "$TITLE" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
OUTPUT_DIR="$SILO_DIR/posts"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/${DATE}-${SLUG}.md"

# Copy and clean the draft for publishing
{
    # Frontmatter
    echo "---"
    echo "title: \"$TITLE\""
    echo "topic: $TOPIC"
    echo "date: $DATE"
    echo "tags: [$TOPIC]"
    echo "published: true"
    echo "---"
    echo ""
    
    # Content
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
        
        # Skip metadata
        if [[ "$line" =~ ^(title:|topic:|date:|stories_used:) ]]; then
            continue
        fi
        
        # Skip story comments
        if [[ "$line" =~ ^<!--\ STORY ]]; then
            continue
        fi
        
        # Skip TODOs
        if [[ "$line" == "*Add your"* ]] || [[ "$line" == *TODO* ]] || [[ "$line" == *FIXME* ]]; then
            continue
        fi
        
        # Skip old published marker
        if [[ "$line" =~ ^\*Published: ]]; then
            continue
        fi
        
        echo "$line"
        
    done < "$DRAFT"
    
    echo ""
    echo "---"
    echo "*Published: $(date)*"
    
} > "$OUTPUT_FILE"

echo "Published: $OUTPUT_FILE"
echo ""

# Archive the draft
DRAFT_BASENAME=$(basename "$DRAFT")
ARCHIVE_DIR="$SILO_DIR/drafts/_archive"
mkdir -p "$ARCHIVE_DIR"
mv "$DRAFT" "$ARCHIVE_DIR/${DATE}-${DRAFT_BASENAME}"
echo "Archived: $ARCHIVE_DIR/${DATE}-${DRAFT_BASENAME}"
echo ""

# Clean up backups
rm -f "${DRAFT}.bak" 2>/dev/null || true

echo "Done!"
echo ""
echo "Next steps:"
echo "  cat $OUTPUT_FILE          - Preview post"
echo "  just list-posts           - See all posts"
echo ""

# Track status and audit
if [ -x "$STATUS_SCRIPT" ]; then
    "$STATUS_SCRIPT" add-post "$DRAFT" "$OUTPUT_FILE" 2>/dev/null || true
fi

if [ -x "$AUDIT_SCRIPT" ]; then
    "$AUDIT_SCRIPT" draft_published "{\"draft\": \"$(basename "$DRAFT")\", \"post\": \"$(basename "$OUTPUT_FILE")\", \"topic\": \"$TOPIC\"}" 2>/dev/null || true
fi
