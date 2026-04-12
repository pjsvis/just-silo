#!/bin/bash
# silo-build.sh — Start building a new silo in dev workspace
# Usage: ./silo-build.sh NAME

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_DIR="$PROJECT_ROOT/dev"
SILOS_DIR="$PROJECT_ROOT/silos"
TEMPLATE_DIR="$DEV_DIR/_template"

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo "Usage: ./silo-build.sh NAME"
    echo "Example: ./silo-build.sh blog_writer_silo"
    exit 1
fi

# Validate name (must end with _silo)
if [[ ! "$NAME" =~ _silo$ ]]; then
    echo "Error: Name must end with _silo (e.g., blog_writer_silo)"
    exit 1
fi

SILO_DIR="$DEV_DIR/$NAME"

# Check if already exists
if [ -d "$SILO_DIR" ]; then
    echo "Error: $SILO_DIR already exists"
    echo "  Run './silo-clean.sh $NAME' to remove it first"
    exit 1
fi

echo "=== Building Silo: $NAME ==="
echo "Workspace: $SILO_DIR"
echo ""

# Copy template
if [ -d "$TEMPLATE_DIR" ]; then
    cp -r "$TEMPLATE_DIR" "$SILO_DIR"
    echo "✓ Copied template"
else
    mkdir -p "$SILO_DIR/scripts"
    mkdir -p "$SILO_DIR/templates"
    mkdir -p "$SILO_DIR/agents"
    mkdir -p "$SILO_DIR/docs"
    echo "✓ Created directories"
fi

# Create .silo manifest
cat > "$SILO_DIR/.silo" << EOF
{
  "name": "$NAME",
  "version": "0.1.0",
  "domain": "pending",
  "parent": "just-silo",
  "created": "$(date +%Y-%m-%d)",
  "status": "development",
  "dev_path": "../../../",
  "deps": []
}
EOF
echo "✓ Created .silo manifest"

# Create README
cat > "$SILO_DIR/README.md" << EOF
# $NAME

**Status:** In Development

This silo is being built in the parent silo context.
Use parent resources for development.

## Development Commands

From parent justfile:
- just silo-test $NAME   - Test the silo
- just silo-deploy $NAME - Deploy to silos/
- just silo-clean $NAME   - Remove dev workspace

## Notes

- Scripts can access parent via: dev_path (../../..)
- When deployed, paths become relative to silo root
EOF
echo "✓ Created README"

# Create justfile
cat > "$SILO_DIR/justfile" << 'EOF'
# Development justfile for this silo
# Paths are relative to parent silo during development

set shell := ["bash", "-o", "pipefail", "-c"]

# Development-only commands
# These won't exist after deployment

dev:
    @echo "Development workspace for this silo"
    @echo "Parent resources available via ../../../"

verify:
    @echo "Verifying dependencies..."
    @test -f "../../../insights/stories.jsonl" && echo "✓ Parent stories" || echo "✗ No stories"
    @test -d "../../../scripts" && echo "✓ Parent scripts" || echo "✗ No scripts"
EOF
echo "✓ Created justfile"

echo ""
echo "=== Silo Created ==="
echo ""
echo "Workspace: $SILO_DIR"
echo ""
echo "Next steps:"
echo "  cd $SILO_DIR"
echo "  just dev              - See available commands"
echo "  just verify           - Check parent resources"
echo "  just silo-deploy $NAME - Deploy when ready"
echo "  just silo-clean $NAME   - Remove workspace"
