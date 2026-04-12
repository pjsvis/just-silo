#!/bin/bash
# silo-clean.sh — Remove dev workspace
# Usage: ./silo-clean.sh NAME

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_DIR="$PROJECT_ROOT/dev"

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo "Usage: ./silo-clean.sh NAME"
    echo "Example: ./silo-clean.sh blog_writer_silo"
    exit 1
fi

SILO_DIR="$DEV_DIR/$NAME"

# Check if exists
if [ ! -d "$SILO_DIR" ]; then
    echo "Workspace $SILO_DIR does not exist"
    exit 0
fi

echo "=== Cleaning Dev Workspace ==="
echo "Removing: $SILO_DIR"

# Remove
rm -rf "$SILO_DIR"

echo "✓ Removed"
echo ""
echo "Note: Deployed silo in silos/$NAME is unaffected"
