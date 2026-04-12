#!/bin/bash
# publish.sh — Publish draft (dev version)
# Usage: ./publish.sh DRAFT_FILE

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DRAFT="${1:-}"
if [ -z "$DRAFT" ]; then
    echo "Usage: ./publish.sh drafts/DRAFT.md"
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

# Render first
./scripts/render.sh "$DRAFT"

# Extract for archive
DATE=$(date +%Y-%m-%d)
DRAFT_BASENAME=$(basename "$DRAFT")
ARCHIVE_DIR="$SILO_DIR/drafts/_archive"
mkdir -p "$ARCHIVE_DIR"
mv "$DRAFT" "$ARCHIVE_DIR/${DATE}-${DRAFT_BASENAME}"

echo ""
echo "Published and archived"
