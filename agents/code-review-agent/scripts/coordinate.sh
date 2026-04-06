#!/usr/bin/env bash
# coordinate.sh — Parent/agent communication protocol
# Usage: ./coordinate.sh <command>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(dirname "$SCRIPT_DIR")"
MARKERS_DIR="$AGENT_DIR/markers"
REQUEST_DIR="$MARKERS_DIR/request"
DONE_DIR="$MARKERS_DIR/done"
ERROR_DIR="$MARKERS_DIR/error"
STATE_DIR="$MARKERS_DIR/state"

mkdir -p "$REQUEST_DIR" "$DONE_DIR" "$ERROR_DIR" "$STATE_DIR"

log() { echo "[$(date -Iseconds)] $*" >&2; }

case "${1:-poll}" in
    poll)
        # Check for new request
        if [ -f "$REQUEST_DIR/payload.jsonl" ]; then
            log "Request found"
            cat "$REQUEST_DIR/payload.jsonl"
            exit 0
        else
            log "No pending requests"
            exit 1
        fi
        ;;

    running)
        echo "RUNNING" > "$STATE_DIR/current"
        log "Marked as RUNNING"
        ;;

    complete)
        # Write completion marker
        echo "DONE" > "$STATE_DIR/current"
        echo "{\"completed\":\"$(date -Iseconds)\"}" > "$DONE_DIR/status.jsonl"
        log "Marked as DONE"
        ;;

    error)
        msg="${2:-Unknown error}"
        echo "{\"error\":\"$msg\",\"timestamp\":\"$(date -Iseconds)\"}" > "$ERROR_DIR/last.jsonl"
        echo "ERROR" > "$STATE_DIR/current"
        log "Marked as ERROR: $msg"
        ;;

    idle)
        rm -f "$REQUEST_DIR/payload.jsonl"
        echo "IDLE" > "$STATE_DIR/current"
        log "Marked as IDLE"
        ;;

    reset)
        rm -rf "$DONE_DIR"/* "$ERROR_DIR"/* "$STATE_DIR"/*
        echo "IDLE" > "$STATE_DIR/current"
        log "State reset"
        ;;

    status)
        if [ -f "$STATE_DIR/current" ]; then
            cat "$STATE_DIR/current"
        else
            echo "IDLE"
        fi
        ;;

    *)
        echo "Usage: coordinate.sh <poll|running|complete|error|idle|reset|status>" >&2
        exit 1
        ;;
esac
