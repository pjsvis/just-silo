#!/usr/bin/env bash
# silo-verify-structure - Validate silo structure and primitives
# Usage: ./silo-verify-structure [silo_dir=.]

set -euo pipefail

SILO_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
    local name="$1"
    local result="$2"
    local message="${3:-}"
    
    if [ "$result" = "pass" ]; then
        echo -e "  ${GREEN}✓${NC} $name"
        PASS=$((PASS + 1))
    elif [ "$result" = "warn" ]; then
        echo -e "  ${YELLOW}⚠${NC} $name"
        WARN=$((WARN + 1))
        [ -n "$message" ] && echo "       $message"
    else
        echo -e "  ${RED}✗${NC} $name"
        FAIL=$((FAIL + 1))
        [ -n "$message" ] && echo "       $message"
    fi
}

echo "=== Silo Structure Verification ==="
echo "Path: $SILO_DIR"
echo ""

# Manifest
SILO_MANIFEST=""
if [ -f "$SILO_DIR/.silo" ]; then
    SILO_MANIFEST="$SILO_DIR/.silo"
elif [ -f "$SILO_DIR/.silo/manifest.json" ]; then
    SILO_MANIFEST="$SILO_DIR/.silo/manifest.json"
fi

if [ -n "$SILO_MANIFEST" ]; then
    check "Manifest (.silo)" "pass"
    if jq -e '.phases' "$SILO_MANIFEST" >/dev/null 2>&1; then
        PHASES=$(jq -r '.phases | length' "$SILO_MANIFEST")
        check "  Phases defined ($PHASES)" "pass"
    fi
else
    check "Manifest (.silo)" "fail" "Required for silo identity"
fi

# Core files
for file in justfile schema.json queries.json; do
    if [ -f "$SILO_DIR/$file" ]; then
        check "Core: $file" "pass"
    else
        check "Core: $file" "fail" "Required interface file"
    fi
done

# Data files (inbox/outbox)
echo ""
echo "Primitives:"
for file in harvest.jsonl data.jsonl quarantine.jsonl final_output.jsonl; do
    if [ -f "$SILO_DIR/$file" ]; then
        check "  $file" "pass"
    else
        check "  $file" "warn" "Will be created on first run"
        touch "$SILO_DIR/$file" 2>/dev/null || true
    fi
done

# Checkpoints
echo ""
echo "Restartability:"
if [ -d "$SILO_DIR/markers" ]; then
    check "  Markers directory" "pass"
    if [ -f "$SILO_DIR/markers/.gitkeep" ]; then
        check "    .gitkeep present" "pass"
    else
        check "    .gitkeep present" "warn" "Prevents marker dir deletion on clone"
    fi
else
    check "  Markers directory" "warn" "No restartability checkpoints"
    mkdir -p "$SILO_DIR/markers" && touch "$SILO_DIR/markers/.gitkeep"
fi

# Scripts
echo ""
echo "Processing:"
if [ -f "$SILO_DIR/process.sh" ]; then
    check "  process.sh" "pass"
elif [ -f "$SILO_DIR/scripts/process.sh" ]; then
    check "  scripts/process.sh" "pass"
else
    check "  process script" "warn" "No process.sh found - silo may be read-only"
fi

# Justfile phases
echo ""
echo "Phase recipes:"
REQUIRED_PHASES="verify harvest process flush status"
for phase in $REQUIRED_PHASES; do
    if grep -qE "^${phase}(:|\(| )" "$SILO_DIR/justfile" 2>/dev/null; then
        check "  just $phase" "pass"
    else
        check "  just $phase" "warn" "Missing from justfile"
    fi
done

# Documentation
echo ""
echo "Documentation:"
DOC_FILES="idempotency.md triggers.md README.md"
for doc in $DOC_FILES; do
    if [ -f "$SILO_DIR/$doc" ]; then
        check "  $doc" "pass"
    else
        check "  $doc" "warn" "Not present"
    fi
done

# Schema validation
echo ""
echo "Validation:"
if [ -f "$SILO_DIR/schema.json" ]; then
    if jq . "$SILO_DIR/schema.json" >/dev/null 2>&1; then
        check "  schema.json is valid JSON" "pass"
    else
        check "  schema.json is valid JSON" "fail" "Invalid JSON"
    fi
fi

# Invariant 2: README.md per directory (checksum)
echo ""
echo "Invariant Checks (README-Checksum):"
MISSING_README=0
WARN_README=0
for subdir in "$SILO_DIR"/*/; do
    if [ -d "$subdir" ] && [ "$(basename "$subdir")" != "node_modules" ]; then
        if [ ! -f "${subdir}README.md" ]; then
            check "  README in $(basename "$subdir")/" "fail" "Missing - directory needs context"
            MISSING_README=$((MISSING_README + 1))
        else
            # Basic checksum: README exists and mentions key items
            README_SIZE=$(wc -c < "${subdir}README.md" 2>/dev/null || echo 0)
            if [ "$README_SIZE" -lt 20 ]; then
                check "  README in $(basename "$subdir")/" "warn" "README seems empty"
                WARN_README=$((WARN_README + 1))
            fi
        fi
    fi
done
if [ $MISSING_README -eq 0 ] && [ $WARN_README -eq 0 ]; then
    check "  README.md in all directories" "pass"
fi

# Summary
echo ""
echo "=== Summary ==="
echo -e "${GREEN}✓${NC} Passed: $PASS"
echo -e "${YELLOW}⚠${NC} Warnings: $WARN"
echo -e "${RED}✗${NC} Failed: $FAIL"
echo ""

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}Silo structure has critical gaps${NC}"
    exit 1
elif [ $WARN -gt 0 ]; then
    echo -e "${YELLOW}Silo is functional but could be improved${NC}"
    exit 0
else
    echo -e "${GREEN}Silo structure is complete${NC}"
    exit 0
fi