#!/bin/bash
# status — Show pipeline state: inbox → process → outbox

set -euo pipefail

echo "=== Pipeline Status ==="
echo ""

if [ -f "inbox/harvest.jsonl" ]; then
    COUNT=$(wc -l < "inbox/harvest.jsonl" | tr -d ' ')
    echo "  [inbox]  harvest.jsonl: $COUNT entries"
else
    echo "  [inbox]  harvest.jsonl: MISSING"
fi

PROC_COUNT=$(ls process/*.sh 2>/dev/null | wc -l | tr -d ' ')
echo "  [process] scripts: $PROC_COUNT"

if [ -f "outbox/core-directives.md" ]; then
    LINES=$(wc -l < "outbox/core-directives.md" | tr -d ' ')
    echo "  [outbox] core-directives.md: $LINES lines"
else
    echo "  [outbox] core-directives.md: PENDING"
fi

if [ -f "outbox/conceptual-lexicon.md" ]; then
    LINES=$(wc -l < "outbox/conceptual-lexicon.md" | tr -d ' ')
    echo "  [outbox] conceptual-lexicon.md: $LINES lines"
else
    echo "  [outbox] conceptual-lexicon.md: PENDING"
fi
