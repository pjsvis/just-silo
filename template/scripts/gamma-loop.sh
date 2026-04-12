#!/bin/bash
# Gamma-Loop: Observe → Measure → Learn → Adjust → Log
#
# This script implements the gamma-loop for silo agents.
# It runs automatically after workflow completion.
#
# Usage: ./gamma-loop.sh [workflow-name]
#
# Environment:
#   SILO_NAME      - Name of this silo
#   SILO_SESSION   - Current session ID
#   SILO_ROOT      - Root directory of silo

set -euo pipefail

SILO_ROOT="${SILO_ROOT:-.}"
WORKFLOW="${1:-unknown}"

# Ensure telemetry directory exists
mkdir -p "$SILO_ROOT/telemetry"

# === OBSERVE ===
observe() {
    local run_count
    run_count=$(wc -l < "$SILO_ROOT/telemetry/runs.jsonl" 2>/dev/null || echo 0)
    
    echo "OBSERVE: $WORKFLOW (run #$((run_count + 1)))"
    
    # Check for recent high-entropy events
    if [ -f "$SILO_ROOT/telemetry/events.jsonl" ]; then
        local recent_events
        recent_events=$(tail -1 "$SILO_ROOT/telemetry/events.jsonl" 2>/dev/null || echo "{}")
        if echo "$recent_events" | jq -e '.entropy > 0.5' >/dev/null 2>&1; then
            echo "  ⚠ High entropy detected"
        fi
    fi
}

# === MEASURE ===
measure() {
    local entropy=0
    
    # Calculate entropy from outcomes in runs.jsonl
    mkdir -p "$SILO_ROOT/telemetry"
    if [ -f "$SILO_ROOT/telemetry/runs.jsonl" ] && [ -s "$SILO_ROOT/telemetry/runs.jsonl" ]; then
        entropy=$(tail -10 "$SILO_ROOT/telemetry/runs.jsonl" | \
            jq -s '
                reduce .[] as $run ({"success":0,"partial":0,"failure":0};
                    .[$run.status // "unknown"] += 1) |
                to_entries |
                map(select(.value > 0)) |
                map(.value / (reduce .[].value as $t (0; . + $t))) |
                map(-(.value | log2) * .value) |
                add // 0
            ' 2>/dev/null || echo "0")
    fi
    
    echo "$entropy"
}

# === LOG ===
log_run() {
    local status="${1:-success}"
    local duration_s="${2:-0}"
    local entries="${3:-0}"
    
    jq -n \
        --arg ts "$(date +%s)" \
        --arg workflow "$WORKFLOW" \
        --arg status "$status" \
        --arg dur "$duration_s" \
        --arg entr "$ENTROPY" \
        '{
            ts: $ts | tonumber,
            workflow: $workflow,
            status: $status,
            duration_s: $dur | tonumber,
            entropy: $entr | tonumber,
            session: "'"$SILO_SESSION"'"
        }' >> "$SILO_ROOT/telemetry/runs.jsonl"
}

log_entropy() {
    jq -n \
        --arg ts "$(date +%s)" \
        --arg workflow "$WORKFLOW" \
        --arg entropy "$ENTROPY" \
        '{
            ts: $ts | tonumber,
            workflow: $workflow,
            entropy: $entropy | tonumber
        }' >> "$SILO_ROOT/telemetry/entropy.jsonl"
}

log_adjustment() {
    local type="$1"
    local field="$2"
    local old="$3"
    local new="$4"
    local reason="${5:-}"
    
    jq -n \
        --arg ts "$(date +%s)" \
        --arg type "$type" \
        --arg field "$field" \
        --arg old "$old" \
        --arg new "$new" \
        --arg reason "$reason" \
        '{
            ts: $ts | tonumber,
            type: $type,
            field: $field,
            old: $old,
            new: $new,
            reason: $reason
        }' >> "$SILO_ROOT/telemetry/adjustments.jsonl"
}

# === MAIN ===
main() {
    echo "=== GAMMA-LOOP: $WORKFLOW ==="
    
    observe
    
    ENTROPY=$(measure)
    echo "MEASURE: entropy=$ENTROPY"
    
    # Log the run and entropy
    log_run "${STATUS:-success}" "${DURATION:-0}" "${ENTRIES:-0}"
    log_entropy
    
    # Check if adjustment needed (entropy > 0.6)
    if (( $(echo "$ENTROPY > 0.6" | bc -l) )); then
        echo "LEARN: High entropy detected, consider adjusting thresholds"
        # Could trigger alerts or create td issues here
    fi
    
    echo "LOG: Recorded to telemetry/"
    echo "=== GAMMA-LOOP COMPLETE ==="
}

# Allow sourcing for functions without running main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
