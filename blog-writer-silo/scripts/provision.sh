#!/bin/bash
# provision.sh — Provision blog-writer-silo
# Sets up the silo environment

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STORIES_FILE="${STORIES_FILE:-$SILO_DIR/../stories/stories.jsonl}"

echo "=== Provisioning blog-writer-silo ==="
echo "Silo dir: $SILO_DIR"
echo "Stories: $STORIES_FILE"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# jq
if command -v jq &> /dev/null; then
    echo "  ✓ jq"
else
    echo "  ✗ jq (required)"
    exit 1
fi

# uuidgen
if command -v uuidgen &> /dev/null; then
    echo "  ✓ uuidgen"
else
    echo "  ✗ uuidgen (required)"
    exit 1
fi

# bc
if command -v bc &> /dev/null; then
    echo "  ✓ bc"
else
    echo "  ✗ bc (required)"
    exit 1
fi

echo ""

# Check stories file
if [ -f "$STORIES_FILE" ]; then
    STORY_COUNT=$(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    echo "  ✓ Stories file: $STORY_COUNT stories"
else
    echo "  ! Stories file not found at $STORIES_FILE"
    echo "    Will use: stories/stories.jsonl (relative to repo root)"
    echo ""
    echo "  Run 'just blog-scan' in repo root to generate stories"
fi

echo ""

# Create directories
echo "Setting up directories..."
mkdir -p "$SILO_DIR/drafts"
mkdir -p "$SILO_DIR/drafts/_archive"
mkdir -p "$SILO_DIR/posts"
mkdir -p "$SILO_DIR/templates"
echo "  ✓ directories created"

echo ""

# Verify templates
if [ -d "$SILO_DIR/templates" ]; then
    TEMPLATE_COUNT=$(find "$SILO_DIR/templates" -name "*.md" 2>/dev/null | wc -l)
    echo "  ✓ Templates: $TEMPLATE_COUNT found"
else
    echo "  ! No templates directory"
fi

echo ""

# Validate schema
if [ -f "$SILO_DIR/schema.json" ]; then
    if jq empty "$SILO_DIR/schema.json" 2>/dev/null; then
        echo "  ✓ schema.json valid"
    else
        echo "  ! schema.json has errors"
    fi
fi

echo ""
echo "=== Provisioning Complete ==="
echo ""
echo "Next steps:"
echo "  just verify           - Verify setup"
echo "  just draft TOPIC      - Create a draft"
echo "  just stats            - See available stories"
