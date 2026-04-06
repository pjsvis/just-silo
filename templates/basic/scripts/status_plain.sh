#!/bin/bash
# Plain status output (no gum required)

echo "=== {{name}} Silo Status ==="
echo ""

# Throughput
DATA_COUNT=$( [ -f data.jsonl ] && jq -s 'length' data.jsonl 2>/dev/null || echo 0 )
QUARANTINE_COUNT=$( [ -f quarantine.jsonl ] && jq -s 'length' quarantine.jsonl 2>/dev/null || echo 0 )
OUTPUT_COUNT=$( [ -f final_output.jsonl ] && jq -s 'length' final_output.jsonl 2>/dev/null || echo 0 )

echo "THROUGHPUT:"
echo "  Active:     $DATA_COUNT"
echo "  Quarantine: $QUARANTINE_COUNT"
echo "  Output:     $OUTPUT_COUNT"
echo ""

# Alerts
if [ -f data.jsonl ]; then
    ALERTS=$( jq -c 'select(.alert == true)' data.jsonl 2>/dev/null | jq -s 'length' || echo 0 )
    if [ "$ALERTS" -gt 0 ]; then
        echo "ALERTS: $ALERTS entries flagged"
    else
        echo "ALERTS: None"
    fi
else
    echo "ALERTS: No data"
fi

# Pipeline status
if [ -f pipeline.json ]; then
    echo ""
    echo "PIPELINE:"
    jq -r '.stages[] | "  \(.id): \(.agent // "unassigned")"' pipeline.json 2>/dev/null || true
fi
