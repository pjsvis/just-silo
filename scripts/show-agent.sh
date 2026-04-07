#!/bin/bash
# show-agent.sh - Show agent summary

AGENTS_DIR="${AGENTS_DIR:-agents}"
INPUT="$1"

if [ -z "$INPUT" ]; then
    echo "Usage: show-agent.sh <name-or-alias>"
    exit 1
fi

AGENT_DIR=$(./scripts/resolve-agent.sh "$INPUT" 2>/dev/null) || {
    echo "Agent '$INPUT' not found"
    exit 1
}

NAME=$(basename "$AGENT_DIR")
echo "=== $NAME ==="
echo ""

if [ -f "$AGENT_DIR/README.md" ]; then
    head -30 "$AGENT_DIR/README.md"
else
    echo "No README.md"
fi
