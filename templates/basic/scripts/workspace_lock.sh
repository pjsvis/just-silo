#!/usr/bin/env bash
# workspace_lock.sh — Machine-specific silo locking
# Usage: ./workspace_lock.sh [lock|unlock|check]

set -euo pipefail

ACTION="${1:-check}"
SILO_FILE="${2:-.silo}"

MACHINE_ID="$(hostname -s)-$(whoami)"

case "$ACTION" in
    lock)
        if [ ! -f "$SILO_FILE" ]; then
            echo "ERROR: No .silo file found"
            exit 1
        fi
        jq ".workspace.machine_id = \"$MACHINE_ID\" | .workspace.locked = true" "$SILO_FILE" > "${SILO_FILE}.tmp"
        mv "${SILO_FILE}.tmp" "$SILO_FILE"
        echo "Locked to: $MACHINE_ID"
        ;;
    unlock)
        if [ ! -f "$SILO_FILE" ]; then
            echo "ERROR: No .silo file found"
            exit 1
        fi
        jq ".workspace.machine_id = null | .workspace.locked = false" "$SILO_FILE" > "${SILO_FILE}.tmp"
        mv "${SILO_FILE}.tmp" "$SILO_FILE"
        echo "Unlocked"
        ;;
    check)
        if [ ! -f "$SILO_FILE" ]; then
            echo "No .silo file"
            exit 0
        fi
        LOCKED_TO=$(jq -r '.workspace.machine_id // null' "$SILO_FILE")
        if [ "$LOCKED_TO" = "$MACHINE_ID" ]; then
            echo "Locked to THIS machine: $MACHINE_ID"
        elif [ "$LOCKED_TO" != "null" ]; then
            echo "Locked to OTHER machine: $LOCKED_TO"
            echo "This machine: $MACHINE_ID"
            exit 1
        else
            echo "Unlocked"
        fi
        ;;
    *)
        echo "Usage: $0 [lock|unlock|check]"
        exit 1
        ;;
esac
