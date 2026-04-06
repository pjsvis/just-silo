#!/bin/bash
# Review Phase: Glow + Gum HITL

SCRATCH_DIR="scratchpad"
SCRATCH_FILE="drafts.md"
APPROVED_DIR="approved"
PROPOSAL_FILE="proposal.md"
AUDIT_LOG="logs/audit.log"

TIMESTAMP=$(date -Iseconds)

mkdir -p "$APPROVED_DIR"
mkdir -p "logs"

log() {
    echo "[$TIMESTAMP] $1" >> "$AUDIT_LOG"
}

# Check if drafts exist
if [ ! -f "$SCRATCH_DIR/$SCRATCH_FILE" ]; then
    echo "✗ No drafts found. Run 'just plan' first."
    exit 1
fi

echo "=== REVIEW PHASE ==="
echo ""

# Render drafts via glow
echo "Rendering proposals via glow..."
if command -v glow >/dev/null 2>&1; then
    glow -s dark "$SCRATCH_DIR/$SCRATCH_FILE"
else
    cat "$SCRATCH_DIR/$SCRATCH_FILE"
fi

echo ""

# Select draft via gum
echo "Select a draft:"
DRAFT=$(gum choose "Draft A (Hacker News)" "Draft B (X/Twitter)" "Draft C (Reddit)" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DRAFT" ]; then
    echo "✗ No draft selected."
    log "REJECTED: No draft selected"
    exit 0
fi

log "SELECTED: $DRAFT"

# Extract channel
case "$DRAFT" in
    *"HN"*|*Hacker*) CHANNEL="HN" ;;
    *"X"*) CHANNEL="X" ;;
    *"Reddit"*) CHANNEL="Reddit" ;;
esac

# Extract draft content
case "$DRAFT" in
    *"A"*) 
        DRAFT_CONTENT=$(sed -n '/Draft A/,/---/p' "$SCRATCH_DIR/$SCRATCH_FILE" | head -n -1)
        ;;
    *"B"*) 
        DRAFT_CONTENT=$(sed -n '/Draft B/,/---/p' "$SCRATCH_DIR/$SCRATCH_FILE" | head -n -1)
        ;;
    *"C"*) 
        DRAFT_CONTENT=$(sed -n '/Draft C/,/---/p' "$SCRATCH_DIR/$SCRATCH_FILE" | head -n -1)
        ;;
esac

# Write proposal to approved
cat > "$APPROVED_DIR/$PROPOSAL_FILE" << EOF
# Selected Proposal

Channel: $CHANNEL

$DRAFT_CONTENT

Selected: $TIMESTAMP
EOF

echo ""
echo "Selected: $DRAFT (via $CHANNEL)"

# Get optional vibe/tag
echo ""
VIBE=$(gum input --prompt "Add a vibe/tag (optional): " 2>/dev/null || echo "")

# Final confirmation
echo ""
READY=$(gum confirm "Ready to execute?" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✓ Approved!"
    log "APPROVED: $DRAFT | channel: $CHANNEL | vibe: $VIBE"
    
    # Write approval marker
    echo "$TIMESTAMP | $DRAFT | $CHANNEL | $VIBE" > "$APPROVED_DIR/.approved"
else
    echo "✗ Rejected."
    log "REJECTED: $DRAFT | human declined"
    exit 0
fi
