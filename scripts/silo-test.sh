#!/bin/bash
# silo-test - Test a silo in dev or deployed state
# Usage: ./scripts/silo-test.sh <name>

set -euo pipefail

NAME="${1:-}"

if [ -z "$NAME" ]; then
    echo "Usage: just silo-test <name>"
    exit 1
fi

if [ -d "silos/$NAME" ]; then
    (cd "silos/$NAME" && just verify)
else
    echo "Not deployed"
fi

if [ -d "dev/$NAME" ]; then
    (cd "dev/$NAME" && just verify)
else
    echo "Not in dev"
fi
