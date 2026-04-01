#!/bin/bash
# Status: Stage-by-stage pipeline status
# Uses gum for pretty output if available

MARKERS_DIR="${MARKERS_DIR:-markers}"
PIPELINE_FILE="${PIPELINE_FILE:-pipeline.json}"

# Check for gum
use_gum() {
    command -v gum >/dev/null 2>&1
}

mkdir -p "$MARKERS_DIR"

# Build stage data
stages_data=""

if [ -f "$PIPELINE_FILE" ]; then
    while IFS= read -r stage; do
        if [ -f "$MARKERS_DIR/$stage.done" ]; then
            age=$(($(date +%s) - $(stat -f %m "$MARKERS_DIR/$stage.done")))
            status="DONE"
            age_str="$((age/60))m ago"
        elif [ -f "$MARKERS_DIR/$stage.lock" ]; then
            status="RUNNING"
            age_str="-"
        else
            status="PENDING"
            age_str="-"
        fi
        stages_data="$stages_data\n$stage|$status|$age_str"
    done < <(jq -r '.stages[].id' "$PIPELINE_FILE" 2>/dev/null)
else
    for m in "$MARKERS_DIR"/*.done "$MARKERS_DIR"/*.lock; do
        [ -f "$m" ] || continue
        stage=$(basename "$m" .done)
        stage=${stage%.lock}
        if [[ "$m" == *".done"* ]]; then
            age=$(($(date +%s) - $(stat -f %m "$m")))
            status="DONE"
            age_str="$((age/60))m ago"
        else
            status="RUNNING"
            age_str="-"
        fi
        stages_data="$stages_data\n$stage|$status|$age_str"
    done
fi

if [ -z "$stages_data" ]; then
    if use_gum; then
        gum style --foreground 245 "  (no markers yet)"
    else
        echo "  (no markers yet)"
    fi
    exit 0
fi

# Output
if use_gum; then
    # Pretty output with gum
    echo "  STAGES:" | gum style --bold
    echo "$stages_data" | tail -n +2 | while IFS='|' read -r stage status age; do
        case "$status" in
            DONE)    color="green" ;;
            RUNNING) color="yellow" ;;
            PENDING) color="white" ;;
        esac
        gum style --foreground "$color" "  $stage" | tr '\n' ' '
        echo "  " | tr -d '\n'
        gum style --foreground "$color" "$status"
        if [ "$age" != "-" ]; then
            echo "     " | tr -d '\n'
            gum style --foreground 245 "($age)"
        else
            echo
        fi
    done
else
    # Plain fallback
    echo "  STAGES:"
    echo "$stages_data" | tail -n +2 | while IFS='|' read -r stage status age; do
        if [ "$age" != "-" ]; then
            echo "  $stage: $status ($age)"
        else
            echo "  $stage: $status"
        fi
    done
fi
