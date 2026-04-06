#!/bin/bash
# Pretty status output using gum

DATA_COUNT=$( [ -f data.jsonl ] && jq -s 'length' data.jsonl 2>/dev/null || echo 0 )
QUARANTINE_COUNT=$( [ -f quarantine.jsonl ] && jq -s 'length' quarantine.jsonl 2>/dev/null || echo 0 )
OUTPUT_COUNT=$( [ -f final_output.jsonl ] && jq -s 'length' final_output.jsonl 2>/dev/null || echo 0 )

gum style --bold "=== {{name}} Silo ==="
echo ""

gum table --file=pipeline.json 2>/dev/null || {
    echo "THROUGHPUT:"
    gum table << EOF
Type,Count
Active,$DATA_COUNT
Quarantine,$QUARANTINE_COUNT
Output,$OUTPUT_COUNT
EOF
}
