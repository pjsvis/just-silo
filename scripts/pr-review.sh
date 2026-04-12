#!/bin/bash
# pr-review - Check PR reviews and summarize findings
# Usage: ./pr-review.sh [pr-number]

set -euo pipefail

PR_NUM="${1:-2}"
REPO="${REPO:-pjsvis/just-silo}"

echo "=== PR #$PR_NUM Review Status ==="
echo ""

# Check PR state
gh pr view "$PR_NUM" --json state,title 2>/dev/null | jq -r '"State: \(.state)\nTitle: \(.title)"'

echo ""
echo "=== Reviews ==="
REVIEWS=$(gh api repos/"$REPO"/pulls/"$PR_NUM"/reviews 2>/dev/null | jq -s 'length' || echo "0")
echo "Total reviews: $REVIEWS"

echo ""
echo "=== Comments ==="
COMMENTS=$(gh api repos/"$REPO"/pulls/"$PR_NUM"/comments 2>/dev/null | jq -s 'length' || echo "0")
echo "Total comments: $COMMENTS"

echo ""
echo "=== Qodo Issues ==="
QODO_ISSUES=$(gh api repos/"$REPO"/pulls/"$PR_NUM"/comments 2>/dev/null | jq '[.[] | select(.user.login | startswith("qodo"))] | length' || echo "0")
echo "Qodo comments: $QODO_ISSUES"

echo ""
echo "=== Recent Comments ==="
gh api repos/"$REPO"/pulls/"$PR_NUM"/comments 2>/dev/null | jq -r '.[] | "\(.user.login): \(.body[:200])..."' 2>/dev/null | head -10

echo ""
echo "=== Actions ==="
echo "  View PR:        gh pr view $PR_NUM"
echo "  View comments:   gh pr view $PR_NUM --comments"
echo "  List reviews:    gh pr view $PR_NUM --json reviews"
echo "  Check diff:     gh pr diff $PR_NUM"
