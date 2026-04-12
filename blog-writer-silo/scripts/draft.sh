#!/bin/bash
# draft.sh — Create draft from stories
# Usage: ./draft.sh TOPIC [STORIES] [TEMPLATE]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="${STORIES_FILE:-$SILO_DIR/../stories/stories.jsonl}"
AUDIT_SCRIPT="$SILO_DIR/scripts/audit.sh"
STATUS_SCRIPT="$SILO_DIR/scripts/status.sh"

TOPIC="${1:-}"
STORIES="${2:-6}"
TEMPLATE="${3:-default}"

if [ -z "$TOPIC" ]; then
    echo "Usage: ./draft.sh TOPIC [STORIES] [TEMPLATE]"
    echo "Example: ./draft.sh gemma4 6 default"
    exit 1
fi

echo "=== Creating Draft ==="
echo "Topic: $TOPIC"
echo "Stories: $STORIES"
echo "Template: $TEMPLATE"
echo ""

# Check stories file
if [ ! -f "$STORIES_FILE" ]; then
    echo "Error: Stories file not found: $STORIES_FILE"
    echo "Run 'just blog-scan' in repo root first"
    exit 1
fi

# Get stories for topic (use temp file to avoid shell parsing issues)
TMPFILE=$(mktemp)
jq -n --arg topic "$TOPIC" \
    '[inputs | select(.tags | index($topic) != null) | select(.quality >= 0.2)]' \
    "$STORIES_FILE" > "$TMPFILE"

STORY_COUNT=$(jq 'length' "$TMPFILE")
echo "Found $STORY_COUNT stories for topic '$TOPIC'"

if [ "$STORY_COUNT" -eq 0 ]; then
    echo "No stories found. Try a different topic or run story-scan.sh"
    rm -f "$TMPFILE"
    exit 1
fi

# Load template
TEMPLATE_FILE="$SILO_DIR/templates/${TEMPLATE}.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template not found: $TEMPLATE_FILE"
    TEMPLATE_FILE="$SILO_DIR/templates/default.md"
    if [ ! -f "$TEMPLATE_FILE" ]; then
        # Create inline default template
        mkdir -p "$SILO_DIR/templates"
        cat > "$TEMPLATE_FILE" << 'TEMPLATE'
---
title: "{{title}}"
topic: {{topic}}
date: {{date}}
---

# {{title}}

## How It Started
{{origin:1}}

## What We Learned  
{{insights:3}}

## The Hard Parts
{{lesson:1}}

## Key Takeaways
{{final:1}}
TEMPLATE
    fi
fi

# Generate filename
DATE=$(date +%Y-%m-%d)
SLUG=$(echo "$TOPIC" | sed -e 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
FILENAME="draft-${DATE}-${SLUG}.md"
OUTPUT="$SILO_DIR/drafts/$FILENAME"

echo "Output: $OUTPUT"
echo ""

# Generate title from topic
TITLE=$(echo "$TOPIC" | sed -e 's/-/ /g' -e 's/\b\w/\U&/g')

# Build the draft
{
    echo "---"
    echo "title: \"$TITLE\""
    echo "topic: $TOPIC"
    echo "date: $DATE"
    echo "stories_used: []"
    echo "---"
    echo ""
    echo "# $TITLE"
    echo ""
    
    # Helper function to output stories
    output_stories() {
        local type_filter="$1"
        local section_title="$2"
        local max_count="${3:-5}"
        
        echo "## $section_title"
        echo ""
        
        local count=0
        while IFS= read -r story; do
            [ -z "$story" ] && continue
            
            local id=$(echo "$story" | jq -r '.id')
            local type=$(echo "$story" | jq -r '.type')
            local quality=$(echo "$story" | jq -r '.quality')
            local narrative=$(echo "$story" | jq -r '.narrative')
            
            echo "<!-- STORY id=$id type=$type quality=$quality -->"
            echo "$narrative"
            echo ""
            
            count=$((count + 1))
            if [ $count -ge $max_count ]; then
                break
            fi
        done
        
        if [ $count -eq 0 ]; then
            echo "*No $section_title found for this topic*"
            echo ""
        fi
    }
    
    # Origin section
    jq -c '.[] | select(.type == "origin")' "$TMPFILE" | output_stories "origin" "How It Started" 1
    
    # Insights section
    jq -c '.[] | select(.type == "insight")' "$TMPFILE" | output_stories "insight" "What We Learned" 4
    
    # Lessons section
    jq -c '.[] | select(.type == "lesson")' "$TMPFILE" | output_stories "lesson" "The Hard Parts" 2
    
    # Final section
    echo "## Key Takeaways"
    echo ""
    echo "*Add your key takeaways here*"
    echo ""
    
    echo "---"
    echo ""
    echo "*Generated: $(date)*"
    echo "*Stories: $STORY_COUNT available for topic '$TOPIC'*"
    
} > "$OUTPUT"

rm -f "$TMPFILE"

# Audit and status tracking
echo "Created: $OUTPUT"
echo ""
echo "Next steps:"
echo "  just render drafts/$(basename "$OUTPUT")   - Render to final post"
echo "  vim $OUTPUT           - Edit draft"
echo ""

# Track status and audit
if [ -x "$STATUS_SCRIPT" ]; then
    "$STATUS_SCRIPT" add-draft "$OUTPUT" "$TOPIC" 2>/dev/null || true
fi

if [ -x "$AUDIT_SCRIPT" ]; then
    "$AUDIT_SCRIPT" draft_created "{\"topic\": \"$TOPIC\", \"file\": \"$(basename "$OUTPUT")\", \"stories_available\": $STORY_COUNT}" 2>/dev/null || true
fi
