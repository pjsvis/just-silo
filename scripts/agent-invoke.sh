#!/usr/bin/env bash
# agent-invoke.sh - Invoke an agent
# Usage: just agent:invoke <name> [input-file]

set -euo pipefail

NAME="${1:-}"
INPUT="${2:--}"

if [[ -z "$NAME" ]]; then
  echo "Usage: agent-invoke.sh <name> [input-file]"
  echo "  input-file: Path to input JSON, or - for stdin"
  exit 1
fi

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../agents" && pwd)"
AGENT_DIR="$AGENTS_DIR/$NAME"
MARKERS_DIR="$AGENT_DIR/markers"

# Check if agent exists
if [[ ! -d "$AGENT_DIR" ]]; then
  echo "Error: Agent '$NAME' not found at $AGENT_DIR"
  exit 1
fi

# Check if .agent manifest exists
if [[ ! -f "$AGENT_DIR/.agent" ]]; then
  echo "Error: Agent '$NAME' has no .agent manifest"
  exit 1
fi

# Read agent type from manifest
AGENT_TYPE=$(grep '"type"' "$AGENT_DIR/.agent" | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

echo "Invoking agent '$NAME' (type: $AGENT_TYPE)..."

# Create request payload
TIMESTAMP=$(date +%s)
REQUEST_FILE="$MARKERS_DIR/request/payload-$TIMESTAMP.jsonl"

# Read input
if [[ "$INPUT" == "-" ]]; then
  cat > "$REQUEST_FILE"
else
  cat "$INPUT" > "$REQUEST_FILE"
fi

echo "Request written to: $REQUEST_FILE"

# For tool-type agents, execute immediately
if [[ "$AGENT_TYPE" == "tool" ]]; then
  echo "Executing tool agent..."
  if [[ -f "$AGENT_DIR/run.sh" ]]; then
    (cd "$AGENT_DIR" && bash run.sh < "$REQUEST_FILE" > "$MARKERS_DIR/done/output-$TIMESTAMP.jsonl" 2>&1)
    echo "✓ Output written to: $MARKERS_DIR/done/output-$TIMESTAMP.jsonl"
  else
    echo "Warning: No run.sh found for tool agent"
  fi
else
  # For mounted/standalone agents, just write the request
  echo "✓ Request queued for mounted agent"
  echo "  Waiting for parent agent to process..."
fi

# Write state
cat > "$MARKERS_DIR/state/last-invoke.json" << EOF
{
  "agent": "$NAME",
  "timestamp": $TIMESTAMP,
  "request": "$REQUEST_FILE",
  "status": "invoked"
}
EOF

echo "✓ Invocation complete"
