#!/bin/bash
# Status: Detect stalled stages

THRESHOLD="${1:-60}"
MARKERS_DIR="${MARKERS_DIR:-markers}"

echo "  STUCK (> ${THRESHOLD}m):"
mkdir -p "$MARKERS_DIR"

stale=0
for m in "$MARKERS_DIR"/*.done; do
    if [ -f "$m" ]; then
        age=$(($(date +%s) - $(stat -f %m "$m")))
        if [ "$age" -gt $((THRESHOLD * 60)) ]; then
            stage=$(basename "$m" .done)
            echo "  !! $stage stalled ($((age/60))m old)"
            stale=$((stale+1))
        fi
    fi
done

if [ "$stale" -eq 0 ]; then
    echo "  (none)"
fi
