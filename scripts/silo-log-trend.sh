#!/bin/bash
# silo-log-trend - Analyze entropy trends over time
#
# Usage:
#   silo-log-trend                    # Show trend summary
#   silo-log-trend --trend            # Show directional trend
#   silo-log-trend --alerts          # Show high entropy alerts
#   silo-log-trend --predict         # Predict next entropy
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
TREND=false
ALERTS=false
PREDICT=false
WINDOW=10

while [[ $# -gt 0 ]]; do
    case "$1" in
        --trend) TREND=true; shift ;;
        --alerts) ALERTS=true; shift ;;
        --predict) PREDICT=true; shift ;;
        --window) WINDOW="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Get entropy entries (checks both top-level and .extra.entropy)
get_entropy_entries() {
    jq -c 'select(.entropy != null or (.extra != null and .extra.entropy != null))' "$LOG_FILE" 2>/dev/null || echo ""
}

# Calculate simple moving average
calculate_sma() {
    local window=$1
    get_entropy_entries | tail -"$window" | jq -s 'map(.entropy // .extra.entropy) | add / length'
}

# Calculate trend direction (positive = increasing entropy, negative = decreasing)
calculate_trend() {
    local window=${1:-10}
    local entries
    entries=$(get_entropy_entries | tail -"$window" | jq -s 'map(.entropy)')
    
    if [[ -z "$entries" ]] || [[ "$entries" == "[]" ]]; then
        echo "no-data"
        return
    fi
    
    local count
    count=$(echo "$entries" | jq 'length')
    
    if [[ "$count" -lt 3 ]]; then
        echo "insufficient-data"
        return
    fi
    
    # Simple linear regression to find slope
    local slope
    slope=$(echo "$entries" | jq -s --argjson n "$count" '
        . as $vals |
        range($n) as $i |
        { x: $i, y: ($vals[$i].entropy // $vals[$i].extra.entropy) } |
        [.x, .y] |
        @tsv' | awk '
        BEGIN { sum_x=0; sum_y=0; sum_xy=0; sum_xx=0; n=0 }
        {
            x=$1; y=$2
            sum_x+=x; sum_y+=y; sum_xy+=x*y; sum_xx+=x*x; n++
        }
        END {
            if (n < 2) { print "0" }
            else {
                denom = n*sum_xx - sum_x*sum_x
                if (denom == 0) { print "0" }
                else { print (n*sum_xy - sum_x*sum_y) / denom }
            }
        }')
    
    # Determine direction
    local threshold=0.02
    if (( $(echo "$slope > $threshold" | bc -l) )); then
        echo "increasing"
    elif (( $(echo "$slope < -$threshold" | bc -l) )); then
        echo "decreasing"
    else
        echo "stable"
    fi
}

# Generate alert if entropy exceeds threshold
generate_alerts() {
    local threshold=0.6
    echo "=== HIGH ENTROPY ALERTS ==="
    echo ""
    
    local count
    count=$(get_entropy_entries | jq -c 'select((.entropy // .extra.entropy) > 0.6)' 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ "$count" == "0" ]]; then
        echo "  ✓ No high entropy events (>60%)"
    else
        echo "  ⚠ Found $count high entropy event(s):"
        echo ""
        get_entropy_entries | jq -c 'select((.entropy // .extra.entropy) > 0.6)' 2>/dev/null | while read -r line; do
            local ts=$(echo "$line" | jq -r '.time')
            local action=$(echo "$line" | jq -r '.action // .extra.action // "unknown"')
            local entropy=$(echo "$line" | jq -r '.entropy // .extra.entropy')
            local date=$(date -r $((ts / 1000)) +"%Y-%m-%d %H:%M" 2>/dev/null || echo "$ts")
            printf "  %s  %-15s  %.1f%%\n" "$date" "$action" "$(echo "$entropy * 100" | bc)"
        done
    fi
    
    echo ""
    echo "  Threshold guide:"
    echo "    0-30%  Low   — process is stable"
    echo "    30-60% Moderate — some variability"
    echo "    60-100% High   — needs attention"
}

# Predict next entropy value
predict_next() {
    local window=${1:-10}
    local entries
    entries=$(get_entropy_entries | tail -"$window" | jq -s 'map(.entropy)')
    
    if [[ -z "$entries" ]] || [[ "$entries" == "[]" ]]; then
        echo "Insufficient data for prediction"
        return
    fi
    
    local count
    count=$(echo "$entries" | jq 'length')
    
    if [[ "$count" -lt 5 ]]; then
        echo "Need at least 5 entries for prediction (have $count)"
        return
    fi
    
    # Calculate trend
    local trend
    trend=$(calculate_trend "$window")
    
    # Calculate moving average
    local sma
    sma=$(calculate_sma "$window" 2>/dev/null || echo "N/A")
    
    echo "=== ENTROPY PREDICTION ==="
    echo ""
    echo "  Based on last $count entries:"
    echo "    Moving average: $(echo "$sma * 100" | bc)%"
    echo "    Trend: $trend"
    
    if [[ "$trend" == "increasing" ]]; then
        echo ""
        echo "  ⚠ Entropy is INCREASING"
        echo "    Recommendation: Review process for sources of variability"
    elif [[ "$trend" == "decreasing" ]]; then
        echo ""
        echo "  ✓ Entropy is DECREASING"
        echo "    Process is stabilizing"
    else
        echo ""
        echo "  → Entropy is STABLE"
    fi
}

# Main display
show_summary() {
    local total
    total=$(get_entropy_entries | wc -l | tr -d ' ')
    local trend
    trend=$(calculate_trend "$WINDOW")
    local sma
    sma=$(calculate_sma "$WINDOW" 2>/dev/null || echo "N/A")
    
    echo "=== ENTROPY TREND SUMMARY ==="
    echo ""
    echo "  Entries analyzed: $total"
    echo "  Window size: $WINDOW"
    echo ""
    
    if [[ "$sma" != "N/A" ]]; then
        echo "  Moving average: $(echo "$sma * 100" | bc)%"
    fi
    
    echo "  Trend: $trend"
    
    echo ""
    echo "  Interpretation:"
    case "$trend" in
        increasing)
            echo "    ⚠ Entropy increasing — process becoming less predictable"
            ;;
        decreasing)
            echo "    ✓ Entropy decreasing — process stabilizing"
            ;;
        stable)
            echo "    → Entropy stable — process is consistent"
            ;;
        *)
            echo "    ? Unable to determine trend"
            ;;
    esac
    
    echo ""
    echo "  Use --alerts to see high entropy events"
    echo "  Use --trend for detailed analysis"
    echo "  Use --predict for predictions"
}

# Run requested analysis
if [[ "$ALERTS" == "true" ]]; then
    generate_alerts
elif [[ "$PREDICT" == "true" ]]; then
    predict_next "$WINDOW"
elif [[ "$TREND" == "true" ]]; then
    calculate_trend "$WINDOW"
else
    show_summary
fi
