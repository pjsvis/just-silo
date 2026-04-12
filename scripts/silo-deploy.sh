#!/bin/bash
# silo-deploy.sh — Deploy silo from dev to silos/
# Usage: ./silo-deploy.sh NAME

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_DIR="$PROJECT_ROOT/dev"
SILOS_DIR="$PROJECT_ROOT/silos"

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo "Usage: ./silo-deploy.sh NAME"
    echo "Example: ./silo-deploy.sh blog_writer_silo"
    exit 1
fi

SILO_DIR="$DEV_DIR/$NAME"
DEPLOY_DIR="$SILOS_DIR/$NAME"

# Check if dev workspace exists
if [ ! -d "$SILO_DIR" ]; then
    echo "Error: $SILO_DIR does not exist"
    echo "  Run './silo-build.sh $NAME' first"
    exit 1
fi

echo "=== Deploying Silo: $NAME ==="
echo "From: $SILO_DIR"
echo "To:   $DEPLOY_DIR"
echo ""

# Create silos directory if needed
mkdir -p "$SILOS_DIR"

# Check for required files
if [ ! -f "$SILO_DIR/.silo" ]; then
    echo "Error: No .silo manifest found"
    exit 1
fi

# Update manifest for deployment
TMPFILE=$(mktemp)
jq 'del(.dev_path) | .status = "deployed"' "$SILO_DIR/.silo" > "$TMPFILE"
mv "$TMPFILE" "$SILO_DIR/.silo"

# Copy to silos
cp -r "$SILO_DIR" "$DEPLOY_DIR"
echo "✓ Copied to silos/"

# Update paths in deployed silo (remove parent references)
echo ""
echo "Updating paths for standalone deployment..."
find "$DEPLOY_DIR" -type f \( -name "*.sh" -o -name "*.just" -o -name "justfile" \) -exec sed -i '' \
    -e 's|\.\./\.\./\.\./|../|g' \
    -e 's|\.\./\.\./|../|g' \
    -e 's|dev_path.*||g' \
    {} \;
echo "✓ Paths updated"

echo ""
echo "=== Deployed Successfully ==="
echo ""
echo "Location: $DEPLOY_DIR"
echo ""
echo "Next steps:"
echo "  just silo-test $NAME    - Run acceptance tests"
echo "  just silo-list         - See all silos"
echo ""
echo "To remove dev workspace:"
echo "  just silo-clean $NAME"
