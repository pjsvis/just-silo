#!/bin/bash
# swap.sh — Swap a story in a draft
# Usage: ./swap.sh DRAFT STORY_ID SECTION

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="${STORIES_FILE:-$SILO_DIR/../stories/stories.jsonl}"

DRAFT="${1:-}"
STORY_ID="${2:-}"
SECTION="${3:-}"

if [ -z "$DRAFT" ] || [ -z "$STORY_ID" ]; then
    echo "Usage: ./swap.sh DRAFT STORY_ID [SECTION]"
    echo "Example: ./swap.sh drafts/my-draft.md abc123-... insights"
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

echo "=== Swapping Story ==="
echo "Draft: $DRAFT"
echo "Story ID: $STORY_ID"
echo ""

# Find the story
STORY=$(jq -n --arg id "$STORY_ID" \
    '[inputs | select(.id == $id)] | .[0]' \
    "$STORIES_FILE" 2>/dev/null)

if [ -z "$STORY" ] || [ "$STORY" = "null" ]; then
    echo "Error: Story not found: $STORY_ID"
    exit 1
fi

TYPE=$(echo "$STORY" | jq -r '.type')
QUALITY=$(echo "$STORY" | jq -r '.quality')
NARRATIVE=$(echo "$STORY" | jq -r '.narrative')
SOURCE=$(echo "$STORY" | jq -r '.source')

echo "Found story: $TYPE (q=$QUALITY)"
echo "Source: $SOURCE"
echo ""
echo "Narrative:"
echo "$NARRATIVE" | cut -c1-150
echo "..."
echo ""

# Find the section in the draft
if [ -n "$SECTION" ]; then
    # Find section by type
    case "$TYPE" in
        origin)
            SECTION_PATTERN="## How It Started"
            ;;
        lesson)
            SECTION_PATTERN="## The Hard Parts"
            ;;
        insight)
            SECTION_PATTERN="## What We Learned"
            ;;
        anti-pattern)
            SECTION_PATTERN="## Anti-Patterns"
            ;;
    esac
else
    SECTION_PATTERN="##"
fi

# For now, just find and replace the story metadata comment
# The user will need to manually update the narrative
echo "To swap this story:"
echo "1. Find the old story's <!-- STORY --> comment"
echo "2. Replace it with:"
echo ""
echo "<!-- STORY id=$STORY_ID type=$TYPE quality=$QUALITY -->"
echo "$NARRATIVE"
echo ""
echo "3. Update the narrative if needed"

# Create a backup
cp "$DRAFT" "${DRAFT}.bak"

# Find the story comment and show what needs to change
echo ""
echo "Looking for story in draft..."
grep -n "STORY" "$DRAFT" | head -10 || echo "No STORY comments found"
