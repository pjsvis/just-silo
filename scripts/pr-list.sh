#!/bin/bash
# pr-list - List open PRs by current user
# Usage: ./scripts/pr-watch-open.sh [user]

set -euo pipefail

USER="${1:-$(gh api user -q .login)}"
REPO="${REPO:-pjsvis/just-silo}"

echo "=== Discovering open PRs by @$USER ==="
echo ""

# List open PRs by user
PRS=$(gh pr list --author "$USER" --state open --json number,title --jq '.[] | "\(.number): \(.title)"')

if [ -z "$PRS" ]; then
    echo "No open PRs found."
    exit 0
fi

echo "$PRS"
echo ""

# Extract PR numbers and start monitoring
while IFS= read -r line; do
    PR_NUM=$(echo "$line" | cut -d: -f1)
    PR_TITLE=$(echo "$line" | cut -d: -f2-)
    echo "Starting watch on PR #$PR_NUM:$PR_TITLE"
    # Note: pr_watch is a harness function; in practice, the agent
    # will call it directly. This script is for human convenience.
    echo "  (Run: pr_watch $PR_NUM in the agent harness)"
done <<< "$PRS"

echo ""
echo "=== Next steps ==="
echo "In the agent harness, run:"
echo "  pr_watch <pr-number>  # Start monitoring"
echo "  pr_status             # Check monitoring status"
echo "  pr_fix_issues         # Auto-fix review comments"
echo ""
