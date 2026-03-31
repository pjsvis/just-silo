#!/usr/bin/env bash
# process_harvest.sh — Mark all entries in data.jsonl as "processed"
# Part of the Silo Barley engine. Run after `just harvest`.

set -euo pipefail

DATA_FILE="${DATA_FILE:-data.jsonl}"

if [[ ! -f "$DATA_FILE" ]]; then
    echo "ERROR: $DATA_FILE not found. Run 'just harvest' first."
    exit 1
fi

echo "PROCESSING: Marking all entries as processed..."

# Append status:processed to each line without status, update existing status fields
if command -v jq &>/dev/null; then
    # Create temp file to avoid read/write conflict
    TEMP=$(mktemp)
    jq -c 'if .status then .status = "processed" else .status = "processed" end' "$DATA_FILE" > "$TEMP" && mv "$TEMP" "$DATA_FILE"
    echo "DONE: All entries marked as processed."
else
    echo "ERROR: jq not found. Cannot process harvest."
    exit 1
fi
