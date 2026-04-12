#!/usr/bin/env bash
# caw-canny.sh - Gate check before read-write actions
# Usage: source caw-canny.sh && caw_canny_check

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CAW_CANNY_ENABLED="${CAW_CANNY_ENABLED:-true}"

# Check if CAW CANNY is enabled
if [ "$CAW_CANNY_ENABLED" != "true" ]; then
    exit 0
fi

# Load directive from .silo
DIRECTIVE=$(cat .silo 2>/dev/null | jq -r '.directive // "No directive set"' 2>/dev/null || echo "CAW CANNY: Prompt for go/no-go before read-write")

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  CAW CANNY CHECK${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo ""
echo -e "Directive: ${BLUE}$DIRECTIVE${NC}"
echo ""
echo -e "${YELLOW}You are about to perform a read-write action.${NC}"
echo ""
read -p "Continue? (yes/no): " -n 4 -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${RED}✗ Aborted. No changes made.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Proceeding.${NC}"
echo ""
