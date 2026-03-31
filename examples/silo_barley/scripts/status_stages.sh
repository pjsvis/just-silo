#!/bin/bash
# Status: Stage-by-stage pipeline status
set -euo pipefail

MARKERS_DIR="${MARKERS_DIR:-markers}"
PIPELINE_FILE="${PIPELINE_FILE:-pipeline.json}"

echo "  STAGES:"
mkdir -p "$MARKERS_DIR"

if [ -f "$PIPELINE_FILE" ]; then
    stages=$(jq -r '.stages[].id' "$PIPELINE_FILE" 2>/dev/null)
    if [ -n "$stages" ]; then
        echo "$stages" | while IFS= read -r stage; do
            if [ -f "$MARKERS_DIR/$stage.done" ]; then
                age=$(($(date +%s) - $(stat -f %m "$MARKERS_DIR/$stage.done")))
                echo "  $stage: DONE ($((age/60))m ago)"
            elif [ -f "$MARKERS_DIR/$stage.lock" ]; then
                echo "  $stage: RUNNING"
            else
                echo "  $stage: PENDING"
            fi
        done
    fi
else
    found=0
    for m in "$MARKERS_DIR"/*.done "$MARKERS_DIR"/*.lock; do
        if [ -f "$m" ] 2>/dev/null; then
            found=1
            stage=$(basename "$m" .done)
            stage=${stage%.lock}
            if [[ "$m" == *".done"* ]]; then
                age=$(($(date +%s) - $(stat -f %m "$m")))
                echo "  $stage: DONE ($((age/60))m ago)"
            else
                echo "  $stage: RUNNING"
            fi
        fi
    done
    [ "$found" -eq 0 ] && echo "  (no markers yet)"
fi
