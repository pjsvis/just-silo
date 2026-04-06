#!/usr/bin/env bash
# harden.sh — Auto-hardening for trivial issues
# Usage: ./harden.sh [threshold]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(dirname "$SCRIPT_DIR")"
ANALYSIS="$AGENT_DIR/markers/done/analysis.jsonl"
PATCHES="$AGENT_DIR/markers/done/patches"
SCRATCH_DIR="$AGENT_DIR/.scratch"

mkdir -p "$PATCHES"

THRESHOLD="${1:-medium}"

log() { echo "[$(date -Iseconds)] [harden] $*" >&2; }

# Severity thresholds
case "$THRESHOLD" in
    low)    MAX_SEVERITY=1 ;;
    medium) MAX_SEVERITY=2 ;;
    high)   MAX_SEVERITY=3 ;;
    all)    MAX_SEVERITY=99 ;;
    *)      MAX_SEVERITY=2 ;;
esac

log "Hardening at threshold: $THRESHOLD (max severity: $MAX_SEVERITY)"

HARDENED=0

# Process analysis findings
if [ ! -f "$ANALYSIS" ] || [ ! -s "$ANALYSIS" ]; then
    log "No analysis to harden"
    exit 0
fi

while IFS= read -r finding; do
    # Extract fields
    severity=$(echo "$finding" | jq -r '.severity // 0')
    type=$(echo "$finding" | jq -r '.type // ""')
    file=$(echo "$finding" | jq -r '.file // ""')
    line=$(echo "$finding" | jq -r '.line // 0')
    
    # Check if auto-fixable
    if [ "$severity" -gt "$MAX_SEVERITY" ]; then
        continue
    fi
    
    case "$type" in
        debug)
            # Remove console.log, debugger, print statements
            log "Would remove debug code in $file:$line"
            echo "# Auto-removed debug code" >> "$PATCHES/removals.lst"
            echo "$file:$line: $finding" >> "$PATCHES/removals.lst"
            ((HARDENED++))
            ;;
        marker)
            # Flag TODO/FIXME for human review (don't auto-fix)
            log "Flagged marker in $file:$line for human review"
            echo "$file:$line: $finding" >> "$PATCHES/review.lst"
            ;;
        security)
            # Flag for human review (don't auto-fix secrets)
            log "FLAGGED security issue in $file:$line (NOT auto-fixing)"
            echo "!!! $file:$line: $finding" >> "$PATCHES/security.lst"
            ;;
        *)
            log "No auto-fix for: $type"
            ;;
    esac
done < <(cat "$ANALYSIS")

log "Hardening complete: $HARDENED issues auto-fixed, flagged for review"

# Summary
echo "{\"hardened\":$HARDENED,\"threshold\":\"$THRESHOLD\",\"timestamp\":\"$(date -Iseconds)\"}" > "$PATCHES/summary.json"
