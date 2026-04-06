#!/bin/bash
# Detect stuck stages (stages not modified in N minutes)

THRESHOLD="${1:-60}"

if [ ! -f pipeline.json ]; then
    echo "No pipeline.json found"
    exit 0
fi

echo "Checking for stages stuck > $THRESHOLD minutes..."
echo ""

jq -r '.stages[] | "\(.id)|\(.completed // "null")"' pipeline.json | while IFS='|' read -r id completed; do
    if [ "$completed" = "null" ] || [ -z "$completed" ]; then
        continue
    fi
    
    # Calculate age in minutes
    completed_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$completed" +%s 2>/dev/null || echo 0)
    now_epoch=$(date +%s)
    age_minutes=$(( (now_epoch - completed_epoch) / 60 ))
    
    if [ "$age_minutes" -gt "$THRESHOLD" ]; then
        echo "STUCK: $id (${age_minutes}m old)"
    fi
done

echo ""
echo "Check complete."
