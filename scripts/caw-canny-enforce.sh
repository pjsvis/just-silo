#!/usr/bin/env bash
# caw-canny-enforce.sh - Non-interactive gate for CI/scripts
# Exits 0 if passes, 1 if fails

set -euo pipefail

SILO_DIR="${1:-.}"

# Run invariant checks
"$SILO_DIR/scripts/silo-verify-structure.sh" "$SILO_DIR" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    exit 0
else
    echo "⚠️ CAW CANNY: Invariants broken. Fix before write."
    exit 1
fi
