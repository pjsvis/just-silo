#!/bin/bash
# dev-typecheck - Type-check all tiers
# Usage: ./scripts/dev-typecheck.sh

set -euo pipefail

if command -v tsc >/dev/null 2>&1; then
    echo "=== Type Check: Production (src/) ==="
    tsc --project tsconfig.json --noEmit 2>&1 || true
    echo ""
    echo "=== Type Check: Scripts (scripts/) ==="
    tsc --project tsconfig.scripts.json --noEmit 2>&1 || true
else
    echo "TypeScript not installed. Run: npm install -g typescript"
fi
