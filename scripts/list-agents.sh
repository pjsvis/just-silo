#!/bin/bash
# list-agents.sh - List all available agents

AGENTS_DIR="${1:-agents}"

if [ ! -d "$AGENTS_DIR" ]; then
    echo "No agents directory found"
    exit 0
fi

# List agent directories (only -agent suffix)
for agent_dir in "$AGENTS_DIR"/*-agent/; do
    if [ -d "$agent_dir" ]; then
        name=$(basename "$agent_dir" | sed 's/-agent$//')
        alias=""
        description="No description"
        
        # Read manifest if exists
        if [ -f "$agent_dir/manifest.json" ]; then
            alias=$(grep -o '"alias": "[^"]*"' "$agent_dir/manifest.json" | cut -d'"' -f4)
            description=$(grep -o '"description": "[^"]*"' "$agent_dir/manifest.json" | cut -d'"' -f4)
        fi
        
        alias_str="${alias:-(none)}"
        echo "| $name | $alias_str | $description |"
    fi
done
