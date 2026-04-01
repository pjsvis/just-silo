#!/bin/bash
# Status: Plain text pipeline dashboard (fallback when gum unavailable)

MARKERS_DIR="${MARKERS_DIR:-markers}"
PIPELINE_FILE="${PIPELINE_FILE:-pipeline.json}"
DATA_FILE="${DATA_FILE:-data.jsonl}"
QUARANTINE_FILE="${QUARANTINE_FILE:-quarantine.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-final_output.jsonl}"

mkdir -p "$MARKERS_DIR"

echo "============================================================"
echo "  PIPELINE STATUS"
echo "============================================================"
echo ""

# Who
echo "  AGENTS:"
if [ -f "$PIPELINE_FILE" ]; then
    jq -r '.stages[] | "  \(.id): \(.agent)"' "$PIPELINE_FILE"
else
    echo "  (no pipeline.json - add stages)"
fi
echo ""

# Stages
echo "  STAGES:"
has_stages=0
if [ -f "$PIPELINE_FILE" ]; then
    while IFS= read -r stage; do
        has_stages=1
        if [ -f "$MARKERS_DIR/$stage.done" ]; then
            age=$(($(date +%s) - $(stat -f %m "$MARKERS_DIR/$stage.done" 2>/dev/null || stat -c %Y "$MARKERS_DIR/$stage.done" 2>/dev/null)))
            echo "  $stage: DONE ($((age/60))m ago)"
        elif [ -f "$MARKERS_DIR/$stage.lock" ]; then
            echo "  $stage: RUNNING"
        else
            echo "  $stage: PENDING"
        fi
    done < <(jq -r '.stages[].id' "$PIPELINE_FILE" 2>/dev/null)
else
    for m in "$MARKERS_DIR"/*.done "$MARKERS_DIR"/*.lock; do
        [ -f "$m" ] || continue
        has_stages=1
        stage=$(basename "$m" .done)
        stage=${stage%.lock}
        if [[ "$m" == *".done"* ]]; then
            age=$(($(date +%s) - $(stat -f %m "$m" 2>/dev/null || stat -c %Y "$m" 2>/dev/null)))
            echo "  $stage: DONE ($((age/60))m ago)"
        else
            echo "  $stage: RUNNING"
        fi
    done
fi

[ "$has_stages" -eq 0 ] && echo "  (no markers yet)"
echo ""

# Throughput
echo "  THROUGHPUT:"
active=$( ([ -f "$DATA_FILE" ] && jq -s 'length' "$DATA_FILE") || echo 0)
quarantined=$( ([ -f "$QUARANTINE_FILE" ] && jq -s 'length' "$QUARANTINE_FILE") || echo 0)
archived=$( ([ -f "$OUTPUT_FILE" ] && jq -s 'length' "$OUTPUT_FILE") || echo 0)
echo "  Active: $active"
echo "  Quarantined: $quarantined"
echo "  Archived: $archived"
echo ""

# Stuck
echo "  STUCK (> 60m):"
has_stuck=0
for m in "$MARKERS_DIR"/*.done; do
    [ -f "$m" ] || continue
    age=$(($(date +%s) - $(stat -f %m "$m" 2>/dev/null || stat -c %Y "$m" 2>/dev/null)))
    if [ "$age" -gt 3600 ]; then
        has_stuck=1
        stage=$(basename "$m" .done)
        echo "  !! $stage stalled ($((age/60))m old)"
    fi
done
[ "$has_stuck" -eq 0 ] && echo "  (none)"
echo ""
echo "============================================================"
