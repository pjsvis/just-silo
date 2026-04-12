#!/bin/bash
# audit.sh — Audit logging for blog-writer-silo
# Usage: ./audit.sh [EVENT] [DATA...]

set -euo pipefail

SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_FILE="$SILO_DIR/audit.jsonl"

# Audit events
EVENT_DRAFT_CREATED="draft_created"
EVENT_DRAFT_RENDERED="draft_rendered"
EVENT_DRAFT_PUBLISHED="draft_published"
EVENT_DRAFT_ARCHIVED="draft_archived"
EVENT_STORIES_SCANNED="stories_scanned"
EVENT_ERROR="error"

# Log an audit event
log_event() {
    local event="$1"
    shift
    local data="$*"
    
    local timestamp=$(date -Iseconds)
    local machine_id="${MACHINE_ID:-$(hostname)}"
    
    cat >> "$AUDIT_FILE" << EOF
{"timestamp":"$timestamp","event":"$event","machine_id":"$machine_id","data":$data}
EOF
}

# Quick audit with just event name
audit() {
    local event="${1:-}"
    local data="${2:-{}}"
    
    if [ -z "$event" ]; then
        echo "Usage: audit EVENT [DATA]"
        echo "Events: draft_created, draft_rendered, draft_published, error"
        return 1
    fi
    
    log_event "$event" "$data"
    echo "Audited: $event"
}

# Read audit log
read_log() {
    local event="${1:-}"
    local limit="${2:-20}"
    
    if [ ! -f "$AUDIT_FILE" ]; then
        echo "No audit log found"
        return
    fi
    
    if [ -n "$event" ]; then
        grep "\"event\":\"$event\"" "$AUDIT_FILE" | tail -"$limit"
    else
        tail -"$limit" "$AUDIT_FILE"
    fi
}

# Stats from audit
stats() {
    if [ ! -f "$AUDIT_FILE" ]; then
        echo "No audit log found"
        return
    fi
    
    echo "=== Audit Stats ==="
    echo ""
    echo "Total events: $(wc -l < "$AUDIT_FILE")"
    echo ""
    echo "By event:"
    jq -r '.event' "$AUDIT_FILE" 2>/dev/null | sort | uniq -c | sort -rn
}

# If called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-stats}" in
        log)
            log_event "${2:-unknown}" "${3:-{}}"
            ;;
        stats)
            stats
            ;;
        read)
            read_log "${2:-}" "${3:-20}"
            ;;
        *)
            audit "$@"
            ;;
    esac
fi
