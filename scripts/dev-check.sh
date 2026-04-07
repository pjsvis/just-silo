#!/usr/bin/env bash
# Check project prerequisites
set -euo pipefail

echo "=== just-silo Prerequisites ==="
echo ""
echo "Core Dependencies:"
command -v just >/dev/null 2>&1 && echo "  ✓ just" || echo "  ✗ just MISSING"
command -v bun >/dev/null 2>&1 && echo "  ✓ bun" || echo "  ✗ bun MISSING"
command -v jq >/dev/null 2>&1 && echo "  ✓ jq" || echo "  ✗ jq MISSING"
command -v td >/dev/null 2>&1 && echo "  ✓ td" || echo "  ✗ td MISSING"
command -v watchexec >/dev/null 2>&1 && echo "  ✓ watchexec" || echo "  ✗ watchexec MISSING"
echo ""
echo "Optional:"
command -v glow >/dev/null 2>&1 && echo "  ✓ glow" || echo "  ○ glow (optional)"
command -v gum >/dev/null 2>&1 && echo "  ✓ gum" || echo "  ○ gum (optional)"
command -v skate >/dev/null 2>&1 && echo "  ✓ skate" || echo "  ○ skate (optional)"
echo ""
echo "Install: brew install just bun jq marcus/tap/td watchexec"
