#!/bin/bash
# silo-gate - Run invariant gate check with messaging
# Usage: ./scripts/silo-gate.sh [path=.]

set -euo pipefail

PATH_TO_CHECK="${1:-.}"

if ./scripts/silo-verify-structure.sh "$PATH_TO_CHECK"; then
    echo "✓ Gate passed - invariants hold"
else
    echo ""
    echo "⚠️ Gate failed. Fix invariants before proceeding."
    exit 1
fi
