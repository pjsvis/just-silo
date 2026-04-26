#!/bin/bash
# ingest — Read inbox/, validate, prepare for processing
# Phase 1 of inbox → process → outbox

set -euo pipefail

echo "  [ingest] Reading inbox/..."

if [ ! -f "inbox/harvest.jsonl" ]; then
    echo "  [ingest] WARNING: inbox/harvest.jsonl not found"
    echo "  [ingest] Place legislation provisions as JSONL entries in inbox/harvest.jsonl"
    exit 0
fi

COUNT=$(wc -l < "inbox/harvest.jsonl" | tr -d ' ')
echo "  [ingest] Found $COUNT provision(s)"

# Validate: each line must be valid JSON
VALID=0
INVALID=0
while IFS= read -r line; do
    if echo "$line" | jq -e '.' >/dev/null 2>&1; then
        ((VALID++))
    else
        ((INVALID++))
    fi
done < "inbox/harvest.jsonl"

echo "  [ingest] Valid: $VALID, Invalid: $INVALID"

if [ "$INVALID" -gt 0 ]; then
    echo "  [ingest] ERROR: $INVALID invalid entries in inbox/harvest.jsonl"
    exit 1
fi

echo "  [ingest] ✓ Ready for transform"
