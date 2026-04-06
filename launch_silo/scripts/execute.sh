#!/bin/bash
# Execute Phase: Write approved content to JSONL

APPROVED_DIR="approved"
PROPOSAL_FILE="proposal.md"
OUTPUT_DIR="output"
OUTPUT_FILE="final_launch_schedule.jsonl"
AUDIT_LOG="logs/audit.log"

TIMESTAMP=$(date -Iseconds)

log() {
    echo "[$TIMESTAMP] $1" >> "$AUDIT_LOG"
}

# Check approval
if [ ! -f "$APPROVED_DIR/.approved" ]; then
    echo "✗ Not approved. Run 'just review' first."
    exit 1
fi

# Read approval info
APPROVAL=$(cat "$APPROVED_DIR/.approved")

# Parse approval
CHANNEL=$(echo "$APPROVAL" | sed -n 's/.*channel: \([^|]*\).*/\1/p' | tr -d ' ')
VIBE=$(echo "$APPROVAL" | sed -n 's/.*vibe: \([^|]*\)/\1/p' | tr -d ' ')

# Read proposal content
PROPOSAL=$(cat "$APPROVED_DIR/$PROPOSAL_FILE")

# Extract content (between ## and Selected:)
CONTENT=$(echo "$PROPOSAL" | sed -n '/^## /,/^Selected:/p' | sed -n '2,/^Selected:/p' | head -n -1)

mkdir -p "$OUTPUT_DIR"

# Write JSONL (compact, one line per entry)
jq -n \
    --arg ts "$TIMESTAMP" \
    --arg draft "$CONTENT" \
    --arg channel "$CHANNEL" \
    --arg vibe "${VIBE:-null}" \
    --arg status "approved" \
    '{timestamp: $ts, draft: ($draft | gsub("\n"; " ") | gsub("\\s+"; " ") | sub("^ "; "")), channel: $channel, vibe: (if $vibe == "null" then null else $vibe end), status: $status}' \
    | jq -c '.' >> "$OUTPUT_DIR/$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_DIR/$OUTPUT_FILE" | tr -d ' ')

# Show spin while writing
if command -v gum >/dev/null 2>&1; then
    gum spin --title "Writing approved assets..." -- sleep 0.5
fi

echo ""
echo "✅ Execution complete!"
echo ""
echo "Output: $OUTPUT_DIR/$OUTPUT_FILE ($count entries)"
log "EXECUTED: wrote to $OUTPUT_FILE"

# Show last entry
tail -1 "$OUTPUT_DIR/$OUTPUT_FILE" | jq .
