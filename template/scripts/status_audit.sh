#!/bin/bash
# Status: Audit trail

MARKERS_DIR="${MARKERS_DIR:-markers}"

echo "  AUDIT LOG:"
mkdir -p "$MARKERS_DIR"

count=0

for m in "$MARKERS_DIR"/*.done; do
    if [ -f "$m" ]; then
        stage=$(basename "$m" .done)
        at=$(date -r "$m" "+%Y-%m-%d %H:%M:%S")
        echo "  $at | $stage | DONE"
        count=$((count+1))
    fi
done

for m in "$MARKERS_DIR"/*.lock; do
    if [ -f "$m" ]; then
        stage=$(basename "$m" .lock)
        at=$(date -r "$m" "+%Y-%m-%d %H:%M:%S")
        echo "  $at | $stage | RUNNING"
        count=$((count+1))
    fi
done

if [ "$count" -eq 0 ]; then
    echo "  (no markers yet)"
fi
