#!/bin/bash
# silo-log - Standard JSONL logging interface
#
# This script provides a standard interface for writing structured
# JSONL logs that are compatible with Pino/ELK/BigQuery ingestion.
#
# Usage:
#   silo-log info "Task completed"
#   silo-log warn "Threshold exceeded"
#   silo-log error "Process failed"
#   silo-log action=harvest status=success "Data ingested"
#
# Environment:
#   SILO_LOG_DIR   - Directory for log files (default: .silo/logs)
#   SILO_NAME      - Name of this silo (for correlation)

SILO_LOG_DIR="${SILO_LOG_DIR:-.silo/logs}"
SILO_NAME="${SILO_NAME:-silo}"

# Pino-compatible log levels
LEVEL_DEBUG=20
LEVEL_INFO=30
LEVEL_WARN=40
LEVEL_ERROR=50
LEVEL_FATAL=60

# Default level
LEVEL="$LEVEL_INFO"
EXTRA_PAIRS=""
MESSAGE=""

# Process arguments
for arg in "$@"; do
    case "$arg" in
        debug) LEVEL="$LEVEL_DEBUG" ;;
        info) LEVEL="$LEVEL_INFO" ;;
        warn) LEVEL="$LEVEL_WARN" ;;
        error) LEVEL="$LEVEL_ERROR" ;;
        fatal) LEVEL="$LEVEL_FATAL" ;;
        *=*)
            if [[ -n "$EXTRA_PAIRS" ]]; then
                EXTRA_PAIRS="$EXTRA_PAIRS,"
            fi
            EXTRA_PAIRS="${EXTRA_PAIRS}\"${arg%%=*}\": \"${arg#*=}\""
            ;;
        *)
            MESSAGE="$arg"
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$SILO_LOG_DIR"

# Escape a string for JSON (simple version - handles common cases)
json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    printf '%s' "$str"
}

# Build extra fields JSON
if [[ -n "$EXTRA_PAIRS" ]]; then
    EXTRA_JSON=",\"extra\": {$EXTRA_PAIRS}"
else
    EXTRA_JSON=""
fi

# Get timestamp in milliseconds
TIMESTAMP=$(python3 -c 'import time; print(int(time.time() * 1000))' 2>/dev/null || echo "$(date +%s)000")
PID=$$
HOSTNAME=$(hostname)
ISO_TS=$(date -Iseconds)
ESCAPED_MSG=$(json_escape "$MESSAGE")

# Write JSONL entry (Pino-compatible schema)
printf '{"level":%d,"time":%d,"msg":"%s","pid":%d,"hostname":"%s","silo":"%s","ts":"%s"%s}\n' \
    "$LEVEL" "$TIMESTAMP" "$ESCAPED_MSG" "$PID" "$HOSTNAME" "$SILO_NAME" "$ISO_TS" "$EXTRA_JSON" \
    >> "$SILO_LOG_DIR/telemetry.jsonl"

# Also output to stderr if DEBUG is set
if [[ "${SILO_LOG_DEBUG:-}" == "1" ]]; then
    LEVEL_NAME="INFO"
    case "$LEVEL" in
        $LEVEL_DEBUG) LEVEL_NAME="DEBUG" ;;
        $LEVEL_INFO) LEVEL_NAME="INFO" ;;
        $LEVEL_WARN) LEVEL_NAME="WARN" ;;
        $LEVEL_ERROR) LEVEL_NAME="ERROR" ;;
        $LEVEL_FATAL) LEVEL_NAME="FATAL" ;;
    esac
    echo "[$(date +%H:%M:%S)] [$LEVEL_NAME] $MESSAGE" >&2
fi
