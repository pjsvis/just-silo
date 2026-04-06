#!/usr/bin/env bash
# render_status.sh — Render README.md with live pipeline status
# Usage: ./render_status.sh [--stdout|--glow]

set -euo pipefail

MODE="${1:-stdout}"

# Get pipeline counts
count_file() {
    local file="$1"
    if [ -f "$file" ]; then
        grep -c . "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

HARVEST=$(count_file "harvest.jsonl")
DATA=$(count_file "data.jsonl")
QUARANTINE=$(count_file "quarantine.jsonl")
OUTPUT=$(count_file "final_output.jsonl")
ALERTS=$(grep -c '"alert":true' data.jsonl 2>/dev/null || echo 0)

# Workspace status
WORKSPACE_STATUS="Unlocked"
if [ -f ".silo" ]; then
    MACHINE_ID=$(hostname -s)-$(whoami)
    LOCKED_TO=$(jq -r '.workspace.machine_id // null' .silo 2>/dev/null)
    if [ "$LOCKED_TO" = "$MACHINE_ID" ]; then
        WORKSPACE_STATUS="Locked to this machine"
    elif [ "$LOCKED_TO" != "null" ]; then
        WORKSPACE_STATUS="Locked to: $LOCKED_TO"
    fi
fi

# Visibility
VISIBILITY=$(jq -r '.visibility // "shared"' .silo 2>/dev/null)
if [[ "$VISIBILITY" == *"private"* ]] || [[ "$VISIBILITY" == "_"* ]]; then
    VISIBILITY="Private (not synced)"
else
    VISIBILITY="Shared (synced)"
fi

# Build status table in Markdown
STATUS_TABLE="\`\`\`
╔═══════════════════════════════════════════════╗
║  PIPELINE STATUS                              ║
╠═══════════════════════════════════════════════╣
║  harvest     $(printf '%6s' "$HARVEST") entries             ║
║  active      $(printf '%6s' "$DATA") entries             ║
║  quarantine  $(printf '%6s' "$QUARANTINE") entries             ║
║  archived    $(printf '%6s' "$OUTPUT") entries             ║
║  alerts      $(printf '%6s' "$ALERTS")                       ║
╠═══════════════════════════════════════════════╣
║  workspace   $WORKSPACE_STATUS        ║
║  visibility  $VISIBILITY               ║
╚═══════════════════════════════════════════════╝
\`\`\`
"

# Create temporary file with status injected
if [ -f "README.md" ]; then
    # Check if README already has status marker
    if grep -q "<!-- PIPELINE_STATUS -->" README.md; then
        # Replace existing status
        sed -i '' '/<!-- PIPELINE_STATUS -->/,/<!-- \/PIPELINE_STATUS -->/c\'"$STATUS_TABLE" README.md
    else
        # Append at the end
        echo "" >> README.md
        echo "<!-- PIPELINE_STATUS -->" >> README.md
        echo "$STATUS_TABLE" >> README.md
        echo "<!-- /PIPELINE_STATUS -->" >> README.md
    fi
else
    echo "# Status Report"
    echo ""
    echo "$STATUS_TABLE"
fi

# Output based on mode
case "$MODE" in
    --glow)
        if command -v glow >/dev/null 2>&1; then
            glow -p README.md 2>/dev/null || cat README.md
        else
            cat README.md
        fi
        ;;
    --stdout|*)
        cat README.md
        ;;
esac
