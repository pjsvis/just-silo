#!/bin/bash
# {{name}} - Domain Transformation Script
# Called by: just process

set -euo pipefail

DATA_FILE="${DATA_FILE:-data.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-data.jsonl}"

echo "Processing entries..."

# Read each line, transform, write back
# Replace this with your domain logic
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue
    
    # Example: add processed status
    echo "$line" | jq '.status = "processed"'
done < "$DATA_FILE" > "${DATA_FILE}.tmp"

mv "${DATA_FILE}.tmp" "$DATA_FILE"

echo "Processed $(wc -l < "$DATA_FILE") entries"
