#!/bin/bash
# draft.sh — Create draft from stories (dev version)
# Usage: ./draft.sh TOPIC [COUNT]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="$SILO_DIR/../../stories/stories.jsonl"

TOPIC="${1:-}"
COUNT="${2:-5}"

if [ -z "$TOPIC" ]; then
    echo "Usage: ./draft.sh TOPIC [COUNT]"
    exit 1
fi

echo "=== Creating Draft ==="
echo "Topic: $TOPIC"

# Check stories
if [ ! -f "$STORIES_FILE" ]; then
    echo "Error: No stories found"
    exit 1
fi

# Get stories for topic
TMPFILE=$(mktemp)
jq -n --arg topic "$TOPIC" \
    '[inputs | select(.tags | index($topic) != null) | select(.quality >= 0.2)]' \
    "$STORIES_FILE" > "$TMPFILE"

STORY_COUNT=$(jq 'length' "$TMPFILE")
echo "Found $STORY_COUNT stories for '$TOPIC'"

if [ "$STORY_COUNT" -eq 0 ]; then
    echo "No stories found. Try a different topic."
    rm -f "$TMPFILE"
    exit 1
fi

# Generate draft
DATE=$(date +%Y-%m-%d)
SLUG=$(echo "$TOPIC" | sed -e 's/[^a-zA-Z0-9]/-/g')
FILENAME="draft-${DATE}-${SLUG}.md"
OUTPUT="$SILO_DIR/drafts/$FILENAME"

mkdir -p "$SILO_DIR/drafts"

{
    echo "---"
    echo "title: \"$TOPIC\""
    echo "topic: $TOPIC"
    echo "date: $DATE"
    echo "---"
    echo ""
    echo "# $TOPIC"
    echo ""
    echo "## How It Started"
    echo ""
    
    # Output origin stories
    ORIGIN_COUNT=0
    while IFS= read -r story; do
        [ -z "$story" ] && continue
        [ "$ORIGIN_COUNT" -ge 1 ] && continue
        
        id=$(echo "$story" | jq -r '.id')
        type=$(echo "$story" | jq -r '.type')
        quality=$(echo "$story" | jq -r '.quality')
        narrative=$(echo "$story" | jq -r '.narrative')
        
        echo "<!-- STORY id=$id type=$type quality=$quality -->"
        echo "$narrative"
        echo ""
        ORIGIN_COUNT=$((ORIGIN_COUNT + 1))
    done < <(jq -c '.[] | select(.type == "origin")' "$TMPFILE")
    
    if [ "$ORIGIN_COUNT" -eq 0 ]; then
        echo "*No origin stories for this topic*"
        echo ""
    fi
    
    echo "## What We Learned"
    echo ""
    
    INSIGHT_COUNT=0
    while IFS= read -r story; do
        [ -z "$story" ] && continue
        [ "$INSIGHT_COUNT" -ge "$COUNT" ] && break
        
        id=$(echo "$story" | jq -r '.id')
        type=$(echo "$story" | jq -r '.type')
        quality=$(echo "$story" | jq -r '.quality')
        narrative=$(echo "$story" | jq -r '.narrative')
        
        echo "<!-- STORY id=$id type=$type quality=$quality -->"
        echo "$narrative"
        echo ""
        INSIGHT_COUNT=$((INSIGHT_COUNT + 1))
    done < <(jq -c '.[] | select(.type == "insight")' "$TMPFILE")
    
    if [ "$INSIGHT_COUNT" -eq 0 ]; then
        echo "*No insights for this topic*"
        echo ""
    fi
    
    echo "## Lessons Learned"
    echo ""
    
    LESSON_COUNT=0
    while IFS= read -r story; do
        [ -z "$story" ] && continue
        [ "$LESSON_COUNT" -ge 2 ] && break
        
        id=$(echo "$story" | jq -r '.id')
        type=$(echo "$story" | jq -r '.type')
        quality=$(echo "$story" | jq -r '.quality')
        narrative=$(echo "$story" | jq -r '.narrative')
        
        echo "<!-- STORY id=$id type=$type quality=$quality -->"
        echo "$narrative"
        echo ""
        LESSON_COUNT=$((LESSON_COUNT + 1))
    done < <(jq -c '.[] | select(.type == "lesson")' "$TMPFILE")
    
    if [ "$LESSON_COUNT" -eq 0 ]; then
        echo "*No lesson stories for this topic*"
        echo ""
    fi
    
    echo "---"
    echo "*Generated: $(date)*"
    
} > "$OUTPUT"

rm -f "$TMPFILE"

echo ""
echo "Created: $OUTPUT"
echo ""
echo "Next: Edit draft and run ./scripts/render.sh"
