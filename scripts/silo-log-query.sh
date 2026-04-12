#!/bin/bash
# silo-log-query - Query and analyze silo telemetry logs
#
# Usage:
#   silo-log-query                    # Show recent entries
#   silo-log-query --errors           # Show only errors
#   silo-log-query --action harvest   # Filter by action
#   silo-log-query --stats            # Show summary stats
#   silo-log-query --entropy          # Show entropy trend
#
# Environment:
#   SILO_LOG_DIR   - Directory for log files (default: .silo/logs)

set -euo pipefail

SILO_LOG_DIR="${SILO_LOG_DIR:-.silo/logs}"
LOG_FILE="$SILO_LOG_DIR/telemetry.jsonl"

# Check if logs exist
if [[ ! -f "$LOG_FILE" ]]; then
    echo "No telemetry logs found at: $LOG_FILE"
    echo "Run 'silo-log' to generate logs"
    exit 1
fi

# Parse arguments
ACTION="cat"
FILTER=""
STATS=false
ENTROPY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --errors) FILTER='select(.level >= 50)'; shift ;;
        --warn) FILTER='select(.level >= 40)'; shift ;;
        --action)
            FILTER="select(.action == \"$2\")"
            shift 2 ;;
        --stats) STATS=true; shift ;;
        --entropy) ENTROPY=true; shift ;;
        *) shift ;;
    esac
done

if [[ "$STATS" == "true" ]]; then
    echo "=== LOG STATISTICS ==="
    echo ""
    echo "Total entries: $(wc -l < "$LOG_FILE")"
    echo ""
    echo "By level:"
    jq -r '.level' "$LOG_FILE" 2>/dev/null | sort | uniq -c | while read -r count level; do
        case "$level" in
            20) label="DEBUG" ;;
            30) label="INFO" ;;
            40) label="WARN" ;;
            50) label="ERROR" ;;
            60) label="FATAL" ;;
            *) label="LEVEL_$level" ;;
        esac
        printf "  %-8s %s\n" "$count" "$label"
    done
    echo ""
    echo "By action:"
    jq -r '.action // "no-action"' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -10
    echo ""
    echo "By status:"
    jq -r '.status // "no-status"' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn

elif [[ "$ENTROPY" == "true" ]]; then
    echo "=== ENTROPY TREND ==="
    echo ""
    jq -c 'select(.entropy != null)' "$LOG_FILE" 2>/dev/null | while read -r line; do
        ts=$(echo "$line" | jq -r '.time')
        action=$(echo "$line" | jq -r '.action')
        entropy=$(echo "$line" | jq -r '.entropy')
        date=$(date -r $((ts / 1000)) +%H:%M:%S 2>/dev/null || echo "$ts")
        printf "%s  %-15s  %s\n" "$date" "$action" "$(printf '%*s' $((entropy * 20 | floor)) '' | tr ' ' '█')$(printf '%*s' $((20 - (entropy * 20 | floor))) '' | tr ' ' '░') $(echo "$entropy * 100" | bc)%"
    done

else
    # Default: show recent entries with formatting
    CMD="tail -20"
    if [[ -n "$FILTER" ]]; then
        CMD="jq -c '$FILTER'"
    fi
    
    echo "=== RECENT LOG ENTRIES ==="
    echo ""
    
    if [[ -n "$FILTER" ]]; then
        jq -c "$FILTER" "$LOG_FILE" 2>/dev/null | while read -r line; do
            ts=$(echo "$line" | jq -r '.time')
            level=$(echo "$line" | jq -r '.level')
            msg=$(echo "$line" | jq -r '.msg')
            action=$(echo "$line" | jq -r '.action // ""')
            status=$(echo "$line" | jq -r '.status // ""')
            
            case "$level" in
                20) icon="🔍" ;;
                30) icon="ℹ" ;;
                40) icon="⚠" ;;
                50) icon="❌" ;;
                60) icon="💥" ;;
                *) icon="?" ;;
            esac
            
            date=$(date -r $((ts / 1000)) +%H:%M:%S 2>/dev/null || echo "$ts")
            echo "$icon $date  $msg"
            [[ -n "$action" ]] && echo "   └─ $action $status"
        done
    else
        tail -20 "$LOG_FILE" | jq -c '.' 2>/dev/null | while read -r line; do
            ts=$(echo "$line" | jq -r '.time')
            level=$(echo "$line" | jq -r '.level')
            msg=$(echo "$line" | jq -r '.msg')
            
            case "$level" in
                20) icon="🔍" ;;
                30) icon="ℹ" ;;
                40) icon="⚠" ;;
                50) icon="❌" ;;
                60) icon="💥" ;;
                *) icon="?" ;;
            esac
            
            date=$(date -r $((ts / 1000)) +%H:%M:%S 2>/dev/null || echo "$ts")
            echo "$icon $date  $msg"
        done
    fi
fi
