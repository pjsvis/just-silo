#!/usr/bin/env bash
# orient.sh - Session startup: current state + canon consistency check
# Usage: ./orient.sh
#
# Delegated from the justfile `orient` recipe to keep justfile lines short
# (house rule: extract multi-step logic to scripts).

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }

# ─────────────────────────────────────────────────────────────
# Current state
# ─────────────────────────────────────────────────────────────
echo "=== Branch ==="
git branch --show-current

echo "=== Git status ==="
git status --short

echo "=== Last commit ==="
git log -1 --oneline 2>/dev/null || echo "(no commits)"

# ─────────────────────────────────────────────────────────────
# Canon (delegated to canon.sh)
# ─────────────────────────────────────────────────────────────
echo "=== Canon ==="
if [[ -x scripts/canon.sh ]]; then
  ./scripts/canon.sh list 2>/dev/null || warn "(canon list failed)"
else
  warn "(canon bundle missing or empty)"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# Canon consistency check — the gating last step
# ─────────────────────────────────────────────────────────────
echo "=== Canon consistency check ==="
if [[ -x scripts/canon.sh ]]; then
  ./scripts/canon.sh check
else
  err "canon.sh missing — cannot verify consistency"
  exit 1
fi
