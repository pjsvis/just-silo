#!/bin/bash
# silo-watch - Watch mode for silo (requires watchexec)
# Usage: ./scripts/silo-watch.sh

set -euo pipefail

if command -v watchexec >/dev/null 2>&1; then
    watchexec -e jsonl,sh -- just harvest
else
    echo "watchexec not installed (brew install watchexec)"
    exit 1
fi
