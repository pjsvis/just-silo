#!/bin/bash
# run-agent.sh - Run agent command

AGENTS_DIR="${AGENTS_DIR:-agents}"
INPUT="$1"
CMD="$2"

if [ -z "$INPUT" ] || [ -z "$CMD" ]; then
    echo "Usage: run-agent.sh <name-or-alias> <command>"
    exit 1
fi

AGENT_DIR=$(./scripts/resolve-agent.sh "$INPUT" 2>/dev/null) || {
    echo "Agent '$INPUT' not found"
    exit 1
}

if [ ! -f "$AGENT_DIR/justfile" ]; then
    echo "Agent '$INPUT' has no justfile"
    exit 1
fi

just --justfile "$AGENT_DIR/justfile" $CMD
