#!/bin/bash
# git-status-summary - Show git status and recent commits
# Usage: ./scripts/git-status-summary.sh

set -euo pipefail

echo "=== GIT ==="
git status --short 2>/dev/null || echo "(not a git repo)"
echo ""
echo "=== COMMITS ==="
git log --oneline -3 2>/dev/null || echo "(not a git repo)"
