#!/bin/bash
# silo-gate-quiet - Non-interactive invariant gate check
# Usage: ./scripts/silo-gate-quiet.sh [path=.]

set -euo pipefail

PATH_TO_CHECK="${1:-.}"

if ./scripts/silo-verify-structure.sh "$PATH_TO_CHECK" >/dev/null 2>&1; then
    echo "✓ Invariants hold"
else
    echo "✗ Invariants broken"
    exit 1
fi
