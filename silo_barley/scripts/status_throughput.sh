#!/bin/bash
# Status: Throughput metrics
set -euo pipefail

DATA_FILE="${DATA_FILE:-data.jsonl}"
QUARANTINE_FILE="${QUARANTINE_FILE:-quarantine.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-final_output.jsonl}"

echo "  THROUGHPUT:"
active=$( ([ -f "$DATA_FILE" ] && jq -s 'length' "$DATA_FILE") || echo 0)
quarantined=$( ([ -f "$QUARANTINE_FILE" ] && jq -s 'length' "$QUARANTINE_FILE") || echo 0)
output=$( ([ -f "$OUTPUT_FILE" ] && jq -s 'length' "$OUTPUT_FILE") || echo 0)

echo "  Active: $active"
echo "  Quarantined: $quarantined"
echo "  Archived: $output"
