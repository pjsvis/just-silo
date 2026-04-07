#!/bin/bash
# td-smoke-test.sh
# Smoke test for td RAM disk setup
# Tests full workflow: create → start → log → block → dep → handoff → review → approve

set -e

TODIR="/tmp/td-smoke-test-$$"
mkdir -p "$TODIR"
cd "$TODIR"

echo "=========================================="
echo "TD RAM Disk Smoke Test"
echo "=========================================="
echo "Working directory: $TODIR"
echo ""

# Initialize
echo "[1/12] Initializing td..."
td init > /dev/null 2>&1
echo "✓ Initialized"
echo ""

# Create issues
echo "[2/12] Creating issues..."
ID1=$(td add "Smoke test: Task 1" --priority P1 | grep CREATED | awk '{print $2}')
ID2=$(td add "Smoke test: Task 2" --priority P2 | grep CREATED | awk '{print $2}')
ID3=$(td add "Smoke test: Task 3" --priority P3 | grep CREATED | awk '{print $2}')
echo "✓ Created: $ID1, $ID2, $ID3"
echo ""

# Start work
echo "[3/12] Starting work on issues..."
td start "$ID1" > /dev/null 2>&1
td start "$ID2" > /dev/null 2>&1
echo "✓ Started: $ID1, $ID2"
echo ""

# Log progress
echo "[4/12] Logging progress..."
td log "$ID1" "Smoke test: Doing work" --result > /dev/null 2>&1
td log "$ID2" "Smoke test: Another task" --result > /dev/null 2>&1
echo "✓ Logged to $ID1 and $ID2"
echo ""

# Block an issue
echo "[5/12] Blocking an issue..."
td block "$ID3" > /dev/null 2>&1
td log "$ID3" "Smoke test: Waiting" --blocker > /dev/null 2>&1
echo "✓ Blocked: $ID3"
echo ""

# Create dependency
echo "[6/12] Creating dependency..."
td dep add "$ID2" "$ID1" > /dev/null 2>&1
echo "✓ $ID2 now depends on $ID1"
echo ""

# List issues
echo "[7/12] Listing issues..."
td list
echo ""

# Check blocked
echo "[8/12] Checking blocked..."
td blocked
echo ""

# Check dependencies
echo "[9/12] Checking dependencies..."
td dep "$ID2"
echo ""

# Status
echo "[10/12] Status check..."
td status
echo ""

# Handoff
echo "[11/12] Handoff for review..."
td handoff "$ID1" --done "Smoke test work" --remaining "Nothing" > /dev/null 2>&1
echo "✓ Handoff created for $ID1"
echo ""

# Review
echo "[12/12] Submit for review..."
td review "$ID1" > /dev/null 2>&1
echo "✓ Submitted for review: $ID1"
echo ""

# Show stats
echo ""
echo "=========================================="
echo "Final Stats"
echo "=========================================="
td info
echo ""

# Cleanup
cd /
rm -rf "$TODIR"

echo "=========================================="
echo "SMOKE TEST PASSED ✓"
echo "=========================================="
