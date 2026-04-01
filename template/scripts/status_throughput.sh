#!/bin/bash
# Status: Throughput metrics
# Uses gum for pretty output if available

DATA_FILE="${DATA_FILE:-data.jsonl}"
QUARANTINE_FILE="${QUARANTINE_FILE:-quarantine.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-final_output.jsonl}"

# Check for gum
use_gum() {
    command -v gum >/dev/null 2>&1
}

active=$( ([ -f "$DATA_FILE" ] && jq -s 'length' "$DATA_FILE") || echo 0)
quarantined=$( ([ -f "$QUARANTINE_FILE" ] && jq -s 'length' "$QUARANTINE_FILE") || echo 0)
output=$( ([ -f "$OUTPUT_FILE" ] && jq -s 'length' "$OUTPUT_FILE") || echo 0)

if use_gum; then
    echo "  THROUGHPUT:" | gum style --bold
    gum table << EOF
Active|$active
Quarantined|$quarantined
Archived|$output
EOF
else
    echo "  THROUGHPUT:"
    echo "  Active: $active"
    echo "  Quarantined: $quarantined"
    echo "  Archived: $output"
fi
