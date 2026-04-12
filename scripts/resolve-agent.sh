#!/bin/bash
# resolve-agent.sh - Resolve agent name/alias to directory

AGENTS_DIR="${AGENTS_DIR:-agents}"
INPUT="$1"

# If empty, show usage
if [ -z "$INPUT" ]; then
    echo "Usage: resolve-agent.sh <name-or-alias>"
    exit 1
fi

# Direct match: agents/<input>-agent
if [ -d "$AGENTS_DIR/${INPUT}-agent" ]; then
    echo "$AGENTS_DIR/${INPUT}-agent"
    exit 0
fi

# Direct match: agents/<input>
if [ -d "$AGENTS_DIR/$INPUT" ]; then
    echo "$AGENTS_DIR/$INPUT"
    exit 0
fi

# Search by alias
for agent_dir in "$AGENTS_DIR"/*-agent/; do
    if [ -d "$agent_dir" ]; then
        manifest="$agent_dir/manifest.json"
        if [ -f "$manifest" ]; then
            alias=$(grep -o '"alias": "[^"]*"' "$manifest" 2>/dev/null | cut -d'"' -f4)
            if [ "$alias" = "$INPUT" ]; then
                echo "$agent_dir"
                exit 0
            fi
        fi
    fi
done

# Not found
echo "Agent '$INPUT' not found" >&2
exit 1
