#!/usr/bin/env bash
# agent-status.sh - Show agent status
# Usage: just agent:status [name]

set -euo pipefail

NAME="${1:-}"
AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../agents" && pwd)"

show_agent() {
  local agent_dir="$1"
  local agent_name=$(basename "$agent_dir")
  
  echo "=== $agent_name ==="
  
  # Read .agent manifest if exists
  if [[ -f "$agent_dir/.agent" ]]; then
    echo "Manifest:"
    grep -E '"(name|type|role|version)"' "$agent_dir/.agent" | sed 's/^[ ]*/  /'
  else
    echo "  (no .agent manifest)"
  fi
  
  # Show markers state
  if [[ -d "$agent_dir/markers" ]]; then
    echo "Markers:"
    for type in request done error state; do
      marker_dir="$agent_dir/markers/$type"
      if [[ -d "$marker_dir" ]]; then
        count=$(ls "$marker_dir" 2>/dev/null | wc -l | tr -d ' ')
      else
        count=0
      fi
      echo "  $type: $count"
    done
  else
    echo "Markers: (none configured)"
  fi
  
  # Show last state
  if [[ -f "$agent_dir/markers/state/last-invoke.json" ]]; then
    echo "Last invoke:"
    cat "$agent_dir/markers/state/last-invoke.json" | sed 's/^[ ]*/  /'
  fi
  
  echo ""
}

if [[ -n "$NAME" ]]; then
  # Show specific agent
  AGENT_DIR="$AGENTS_DIR/$NAME"
  if [[ ! -d "$AGENT_DIR" ]]; then
    echo "Error: Agent '$NAME' not found"
    exit 1
  fi
  show_agent "$AGENT_DIR"
else
  # Show all agents
  echo "=== Agent Status ==="
  echo ""
  
  if [[ ! -d "$AGENTS_DIR" ]] || [[ -z "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]]; then
    echo "No agents found"
    exit 0
  fi
  
  for dir in "$AGENTS_DIR"/*; do
    if [[ -d "$dir" ]]; then
      show_agent "$dir"
    fi
  done
fi
