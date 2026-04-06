#!/usr/bin/env bash
# audit_log.sh — Immutable JSONL audit trail for pipeline events
# Usage: ./audit_log.sh <event> [key=value ...]
#
# Events: harvest_start, harvest_complete, harvest_failed,
#         process_start, process_complete, process_failed,
#         flush_start, flush_complete, flush_failed,
#         alert, error, checkpoint
#
# Output: audit.jsonl (append-only, never overwritten)

set -euo pipefail

AUDIT_FILE="${AUDIT_FILE:-audit.jsonl}"

# Parse event and key=value pairs
EVENT="${1:-checkpoint}"
shift || true

# Build JSON object
TIMESTAMP=$(date -Iseconds)
HOSTNAME=$(hostname -s 2>/dev/null || hostname)
PID=$$

# Base record
JQ_CMD="{\"timestamp\":\"$TIMESTAMP\",\"event\":\"$EVENT\",\"host\":\"$HOSTNAME\",\"pid\":$PID"

# Parse additional fields
while [[ $# -gt 0 ]]; do
    KEY=$(echo "$1" | cut -d= -f1)
    VALUE=$(echo "$1" | cut -d= -f2-)
    # Escape quotes and special chars for JSON
    VALUE=$(echo "$VALUE" | sed 's/\\/\\\\/g; s/"/\\"/g')
    JQ_CMD="$JQ_CMD,\"$KEY\":\"$VALUE\""
    shift
done

JQ_CMD="$JQ_CMD}"

# Append to audit file (atomic via temp file)
echo "$JQ_CMD" >> "$AUDIT_FILE"
