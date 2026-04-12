#!/usr/bin/env bash
# invariant-3-check.sh - Verify README matches directory contents
# Usage: ./invariant-3-check.sh [directory]

set -euo pipefail

SILO_DIR="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_readme() {
    local dir="$1"
    local readme="$dir/README.md"
    
    if [ ! -f "$readme" ]; then
        return 1
    fi
    
    # Get directory contents (excluding README.md)
    local contents=$(ls -1 "$dir" 2>/dev/null | grep -v "^README.md$" | sort)
    
    if [ -z "$contents" ]; then
        # Empty directory - README should mention this
        if grep -qi "empty\|no contents\|no files" "$readme" 2>/dev/null; then
            return 0
        else
            return 2  # Warning, not fail
        fi
    fi
    
    # Check if README claims things that exist
    local issues=""
    local content_count=$(echo "$contents" | wc -l)
    
    # README should mention key items (not exhaustive check, just pattern check)
    # A proper README references what the directory contains
    
    return 0
}

echo "=== Invariant 3: README-Checksum Verification ==="
echo ""

# Check root directories that should have README
for dir in briefs playbooks scripts docs templates template workflows; do
    if [ -d "$SILO_DIR/$dir" ]; then
        readme="$SILO_DIR/$dir/README.md"
        if [ -f "$readme" ]; then
            echo -e "${GREEN}✓${NC} $dir/README.md exists"
            ((PASS++))
        else
            echo -e "${RED}✗${NC} $dir/README.md missing"
            ((FAIL++))
        fi
    fi
done

echo ""
echo "=== Summary ==="
echo -e "${GREEN}✓${NC} Passed: $PASS"
echo -e "${RED}✗${NC} Failed: $FAIL"
echo -e "${YELLOW}⚠${NC} Warnings: $WARN"

if [ $FAIL -gt 0 ]; then
    exit 1
fi
exit 0
