#!/usr/bin/env bash
# agent-create.sh - Create new agent from template
# Usage: just agent:create <name> [type]
# Types: mounted, standalone, tool (default: mounted)

set -euo pipefail

NAME="${1:-}"
TYPE="${2:-mounted}"

if [[ -z "$NAME" ]]; then
  echo "Usage: agent-create.sh <name> [type]"
  echo "  type: mounted, standalone, tool (default: mounted)"
  exit 1
fi

# Validate name
if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: Agent name must be lowercase alphanumeric with dashes only"
  exit 1
fi

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../agents" && pwd)"
TEMPLATE_DIR="$AGENTS_DIR/_template"
NEW_AGENT_DIR="$AGENTS_DIR/$NAME"

# Check if template exists
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Creating template directory..."
  mkdir -p "$TEMPLATE_DIR"
  
  # Create minimal template
  cat > "$TEMPLATE_DIR/.agent" << 'EOF'
{
  "name": "AGENT_NAME",
  "type": "mounted",
  "role": "Agent role",
  "version": "0.1.0",
  "description": "Agent description",
  "inputs": { "format": "json", "schema": null },
  "outputs": { "format": "json", "path": "markers/done/output.json" },
  "parent": { "required": true, "protocol": "markers" },
  "resources": { "timeout": 60, "memory": "256mb", "parallel": false }
}
EOF

  mkdir -p "$TEMPLATE_DIR/markers/request" "$TEMPLATE_DIR/markers/done" "$TEMPLATE_DIR/markers/error" "$TEMPLATE_DIR/markers/state"
fi

# Check if agent already exists
if [[ -d "$NEW_AGENT_DIR" ]]; then
  echo "Error: Agent '$NAME' already exists at $NEW_AGENT_DIR"
  exit 1
fi

# Copy template
echo "Creating agent '$NAME' ($TYPE)..."
cp -r "$TEMPLATE_DIR" "$NEW_AGENT_DIR"

# Update .agent with actual name
sed -i '' "s/AGENT_NAME/$NAME/g" "$NEW_AGENT_DIR/.agent"
sed -i '' "s/\"type\": \"[^\"]*\"/\"type\": \"$TYPE\"/" "$NEW_AGENT_DIR/.agent"

# Initialize markers
mkdir -p "$NEW_AGENT_DIR/markers/request"
mkdir -p "$NEW_AGENT_DIR/markers/done"
mkdir -p "$NEW_AGENT_DIR/markers/error"
mkdir -p "$NEW_AGENT_DIR/markers/state"

echo "✓ Agent '$NAME' created at $NEW_AGENT_DIR"
echo ""
echo "Next steps:"
echo "  just agent:show $NAME   # View agent details"
echo "  just agent:invoke $NAME # Invoke agent"
