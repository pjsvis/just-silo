#!/bin/bash
# Generate status.json for dashboard

DATA_FILE="${DATA_FILE:-data.jsonl}"
QUARANTINE_FILE="${QUARANTINE_FILE:-quarantine.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-final_output.jsonl}"

# Count entries
ACTIVE=$( [ -f "$DATA_FILE" ] && jq -s 'length' "$DATA_FILE" 2>/dev/null || echo 0 )
QUARANTINE=$( [ -f "$QUARANTINE_FILE" ] && jq -s 'length' "$QUARANTINE_FILE" 2>/dev/null || echo 0 )
OUTPUT=$( [ -f "$OUTPUT_FILE" ] && jq -s 'length' "$OUTPUT_FILE" 2>/dev/null || echo 0 )

# Determine state
if [ "$QUARANTINE" -gt 0 ]; then
    STATE="amber"
    MESSAGE="Entries in quarantine"
elif [ "$ACTIVE" -eq 0 ] && [ "$OUTPUT" -eq 0 ]; then
    STATE="green"
    MESSAGE="Idle - no data"
else
    STATE="green"
    MESSAGE="OK"
fi

# Write status.json
cat > status.json << EOF
{
  "state": "$STATE",
  "message": "$MESSAGE",
  "lastUpdate": "$(date -Iseconds)",
  "active": $ACTIVE,
  "quarantine": $QUARANTINE,
  "output": $OUTPUT
}
EOF

echo "Status written to status.json"
