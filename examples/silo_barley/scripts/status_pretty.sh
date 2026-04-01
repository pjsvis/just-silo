#!/bin/bash
# Status: Pretty pipeline dashboard using gum
# Falls back to plain text if no TTY available

MARKERS_DIR="${MARKERS_DIR:-markers}"

# Check if we can use gum (TTY required)
if ! tty -s 2>/dev/null; then
    exec ./"${0%/*}"/status_plain.sh "$@"
fi
PIPELINE_FILE="${PIPELINE_FILE:-pipeline.json}"
DATA_FILE="${DATA_FILE:-data.jsonl}"
QUARANTINE_FILE="${QUARANTINE_FILE:-quarantine.jsonl}"
OUTPUT_FILE="${OUTPUT_FILE:-final_output.jsonl}"

mkdir -p "$MARKERS_DIR"

# Build stages data
stages_output=""
has_stages=0

if [ -f "$PIPELINE_FILE" ]; then
    while IFS= read -r stage; do
        has_stages=1
        if [ -f "$MARKERS_DIR/$stage.done" ]; then
            age=$(($(date +%s) - $(stat -f %m "$MARKERS_DIR/$stage.done" 2>/dev/null || stat -c %Y "$MARKERS_DIR/$stage.done" 2>/dev/null)))
            status="DONE"
            age_str="$((age/60))m ago"
        elif [ -f "$MARKERS_DIR/$stage.lock" ]; then
            status="RUNNING"
            age_str="now"
        else
            status="PENDING"
            age_str="-"
        fi
        stages_output="${stages_output}${stage}|${status}|${age_str}\n"
    done < <(jq -r '.stages[].id' "$PIPELINE_FILE" 2>/dev/null)
else
    for m in "$MARKERS_DIR"/*.done "$MARKERS_DIR"/*.lock; do
        [ -f "$m" ] || continue
        has_stages=1
        stage=$(basename "$m" .done)
        stage=${stage%.lock}
        if [[ "$m" == *".done"* ]]; then
            age=$(($(date +%s) - $(stat -f %m "$m" 2>/dev/null || stat -c %Y "$m" 2>/dev/null)))
            status="DONE"
            age_str="$((age/60))m ago"
        else
            status="RUNNING"
            age_str="now"
        fi
        stages_output="${stages_output}${stage}|${status}|${age_str}\n"
    done
fi

# Build throughput data
active=$( ([ -f "$DATA_FILE" ] && jq -s 'length' "$DATA_FILE") || echo 0)
quarantined=$( ([ -f "$QUARANTINE_FILE" ] && jq -s 'length' "$QUARANTINE_FILE") || echo 0)
archived=$( ([ -f "$OUTPUT_FILE" ] && jq -s 'length' "$OUTPUT_FILE") || echo 0)

# Build stuck data
stuck_output=""
has_stuck=0
for m in "$MARKERS_DIR"/*.done; do
    [ -f "$m" ] || continue
    age=$(($(date +%s) - $(stat -f %m "$m" 2>/dev/null || stat -c %Y "$m" 2>/dev/null)))
    if [ "$age" -gt 3600 ]; then
        has_stuck=1
        stage=$(basename "$m" .done)
        stuck_output="${stuck_output}${stage}|${age}\n"
    fi
done

# Output with gum
gum style --bold "  PIPELINE STATUS  "
echo ""

# Who
echo "  AGENTS:" | gum style --foreground 245
if [ -f "$PIPELINE_FILE" ]; then
    jq -r '.stages[] | "  \(.id): \(.agent)"' "$PIPELINE_FILE" | gum style --foreground 240
else
    echo "    (no pipeline.json)" | gum style --foreground 245
fi
echo ""

# Stages
echo "  STAGES:" | gum style --bold
if [ "$has_stages" -eq 1 ]; then
    echo -e "$stages_output" | while IFS='|' read -r stage status age; do
        [ -z "$stage" ] && continue
        case "$status" in
            DONE)    color="green" ;;
            RUNNING) color="yellow" ;;
            PENDING) color="white" ;;
        esac
        printf "  %-12s" "$stage" | gum style --foreground "$color"
        printf "  " 
        gum style --foreground "$color" "$status"
        if [ "$age" != "-" ]; then
            printf "    " 
            gum style --foreground 245 "($age)"
        else
            echo
        fi
    done
else
    echo "    (no markers yet)" | gum style --foreground 245
fi
echo ""

# Throughput
echo "  THROUGHPUT:" | gum style --bold
gum table << TABLEEOF
Metric|Count
Active|$active
Quarantined|$quarantined
Archived|$archived
TABLEEOF
echo ""

# Stuck
echo "  STUCK (> 60m):" | gum style --bold
if [ "$has_stuck" -eq 1 ]; then
    echo -e "$stuck_output" | while IFS='|' read -r stage age; do
        [ -z "$stage" ] && continue
        echo "    $stage stalled ($((age/60))m ago)" | gum style --foreground red
    done
else
    echo "    (none)" | gum style --foreground green
fi
