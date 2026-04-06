#!/usr/bin/env bash
# gamma_loop.sh — Self-improvement feedback loop
# 
# Observes silo performance, detects patterns, suggests improvements.
# The silo learns from its own behavior.
#
# Usage: ./gamma_loop.sh [analyze|recommend|adjust]

set -euo pipefail

ACTION="${1:-analyze}"
AUDIT_FILE="${AUDIT_FILE:-audit.jsonl}"

# Count events from audit log
count_events() {
    grep -c "$1" "$AUDIT_FILE" 2>/dev/null || echo 0
}

# Get rate (events per hour) for an event type
get_rate() {
    local event_type="$1"
    local hours="${2:-1}"
    
    # Count events in last N hours
    local cutoff=$(date -v-${hours}H -Iseconds 2>/dev/null || date --date="-${hours} hours" -Iseconds 2>/dev/null)
    
    if [ ! -f "$AUDIT_FILE" ]; then
        echo 0
        return
    fi
    
    # Simple count for now (could be time-windowed with jq)
    grep -c "\"event\":\"$event_type\"" "$AUDIT_FILE" 2>/dev/null || echo 0
}

# Calculate throughput (items per hour)
calc_throughput() {
    local harvest_count=$(count_events "harvest_complete")
    local hours_elapsed=1
    
    if [ -f "$AUDIT_FILE" ]; then
        local first_ts=$(head -1 "$AUDIT_FILE" | jq -r '.timestamp' 2>/dev/null)
        if [ "$first_ts" != "null" ]; then
            local first_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${first_ts%%.*}" +%s 2>/dev/null || date --date="${first_ts%%.*}" +%s 2>/dev/null)
            local now_epoch=$(date +%s)
            hours_elapsed=$(( (now_epoch - first_epoch) / 3600 + 1 ))
        fi
    fi
    
    echo $(( harvest_count / hours_elapsed ))
}

# Analyze performance
analyze() {
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  GAMMA LOOP — PERFORMANCE ANALYSIS                      ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ ! -f "$AUDIT_FILE" ]; then
        echo "No audit data yet. Run some pipelines first."
        echo "  just harvest"
        echo "  just process"
        echo "  just flush"
        return
    fi
    
    # Event counts
    local harvest_total=$(count_events "harvest_complete")
    local harvest_failed=$(count_events "harvest_failed")
    local flush_total=$(count_events "flush_complete")
    local alerts=$(count_events "alert")
    local errors=$(count_events "error")
    
    echo "EVENTS:"
    echo "  harvests:     $harvest_total"
    echo "  harvest fail:  $harvest_failed"
    echo "  flushes:      $flush_total"
    echo "  alerts:       $alerts"
    echo "  errors:       $errors"
    echo ""
    
    # Failure rate
    if [ "$harvest_total" -gt 0 ]; then
        local fail_rate=$(( harvest_failed * 100 / harvest_total ))
        echo "HEALTH METRICS:"
        echo "  harvest failure rate: ${fail_rate}%"
        
        if [ "$fail_rate" -gt 10 ]; then
            echo "  ⚠ HIGH FAILURE RATE"
        elif [ "$fail_rate" -gt 5 ]; then
            echo "  ⚠ MODERATE FAILURE RATE"
        else
            echo "  ✓ HEALTHY"
        fi
    fi
    
    # Throughput
    local throughput=$(calc_throughput)
    echo "  throughput:    ${throughput}/hour"
    
    # Efficiency (flushes / harvests)
    if [ "$harvest_total" -gt 0 ]; then
        local efficiency=$(( flush_total * 100 / harvest_total ))
        echo "  flush rate:   ${efficiency}%"
        
        if [ "$efficiency" -lt 50 ]; then
            echo "  ⚠ LOW FLUSH RATE — items accumulating"
        fi
    fi
    
    echo ""
}

# Generate recommendations
recommend() {
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  GAMMA LOOP — RECOMMENDATIONS                          ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    
    local recommendations=0
    
    if [ ! -f "$AUDIT_FILE" ]; then
        echo "No data for recommendations yet."
        echo "Run pipelines to generate data."
        return
    fi
    
    # Check failure rate
    local harvest_total=$(count_events "harvest_complete")
    local harvest_failed=$(count_events "harvest_failed")
    
    if [ "$harvest_total" -gt 10 ]; then
        local fail_rate=$(( harvest_failed * 100 / harvest_total ))
        
        if [ "$fail_rate" -gt 20 ]; then
            echo "🔴 HIGH FAILURE RATE (${fail_rate}%)"
            echo "   → Review schema.json for stricter validation"
            echo "   → Check data source quality"
            echo ""
            recommendations=$((recommendations + 1))
        elif [ "$fail_rate" -gt 10 ]; then
            echo "🟡 MODERATE FAILURE RATE (${fail_rate}%)"
            echo "   → Monitor quarantine.jsonl for patterns"
            echo "   → Consider relaxing overly strict rules"
            echo ""
            recommendations=$((recommendations + 1))
        fi
    fi
    
    # Check stagnation
    local alerts=$(count_events "alert")
    if [ "$alerts" -gt 20 ]; then
        echo "🔴 PERSISTENT ALERTS ($alerts total)"
        echo "   → Review threshold settings in .silo"
        echo "   → Investigate root cause"
        echo ""
        recommendations=$((recommendations + 1))
    fi
    
    # Check throughput
    local throughput=$(calc_throughput)
    if [ "$throughput" -gt 0 ] && [ "$throughput" -lt 5 ]; then
        echo "🟡 LOW THROUGHPUT (${throughput}/hour)"
        echo "   → Consider batch processing"
        echo "   → Check if harvest source is throttled"
        echo ""
        recommendations=$((recommendations + 1))
    fi
    
    if [ "$recommendations" -eq 0 ]; then
        echo "✓ NO CRITICAL RECOMMENDATIONS"
        echo ""
        echo "Silo is performing within normal parameters."
    fi
    
    echo "Run with: just gamma-adjust to auto-tune thresholds"
}

# Auto-adjust thresholds based on observed behavior
adjust() {
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  GAMMA LOOP — AUTO-ADJUST THRESHOLDS                    ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "⚠ This is a preview. Review changes before committing."
    echo ""
    
    if [ ! -f "$AUDIT_FILE" ]; then
        echo "No data for auto-adjustment."
        return
    fi
    
    # Calculate observed failure rate
    local harvest_total=$(count_events "harvest_complete")
    local harvest_failed=$(count_events "harvest_failed")
    
    if [ "$harvest_total" -gt 10 ]; then
        local fail_rate=$(( harvest_failed * 100 / harvest_total ))
        
        echo "Based on $harvest_total harvests ($fail_rate% failure rate):"
        echo ""
        
        # Suggest threshold adjustment
        local new_threshold=$(( fail_rate * 2 ))
        if [ "$new_threshold" -gt 50 ]; then
            new_threshold=50
        fi
        
        echo "  Current threshold: $(jq -r '.thresholds.max_failure_rate // 10' .silo 2>/dev/null)%"
        echo "  Suggested threshold: ${new_threshold}%"
        echo ""
        echo "To apply:"
        echo "  jq '.thresholds.max_failure_rate = $new_threshold' .silo > .silo.tmp"
        echo "  mv .silo.tmp .silo"
    else
        echo "Insufficient data (need >10 harvests)."
        echo "Current: $harvest_total harvests"
    fi
}

# Main
case "$ACTION" in
    analyze|a)
        analyze
        ;;
    recommend|r)
        recommend
        ;;
    adjust|g)
        adjust
        ;;
    all)
        analyze
        echo ""
        recommend
        ;;
    *)
        echo "Usage: $0 [analyze|recommend|adjust|all]"
        exit 1
        ;;
esac
