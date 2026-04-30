#!/usr/bin/env bash
# Silo help - entry point for new agents
set -euo pipefail

echo "=== SILO ENTRY POINTS ==="
echo ""
echo "START HERE:"
echo "  1. Read: START-HERE.md"
echo "  2. Read: README.md"
echo "  3. Run: just silo-help"
echo ""
echo "KEY COMMANDS:"
echo "  just silo-help       - This help"
echo "  just silo-verify     - Check invariants"
echo "  just silo-status     - Show silo health"
echo "  just td status       - Show tasks"
echo "  just --list          - All recipes"
echo ""
echo "SILO STRUCTURE:"
echo "  briefs/    - What we've been thinking"
echo "  playbooks/ - Operational knowledge"
echo "  scripts/   - Automation"
echo "  template/  - Silo template"
echo "  workflows/ - Named procedures (no recursion)"
echo ""
echo "INVARIANTS:"
echo "  1. Filename uniqueness within silo"
echo "  2. README.md per browsable directory"
echo "  3. README is checksum of directory"
echo "  4. Archive naming: FOLDERNAME_archive"
echo "  5. No recursion: no nested silos"
echo ""
echo "═══════════════════════════════════════════"
echo "⚠️  CAW CANNY: Before read-write, prompt for go/no-go."
if [ -f .silo ]; then
    directive=$(jq -r '.directive' .silo 2>/dev/null || echo "unknown")
    echo "   Directive: $directive"
fi
echo "═══════════════════════════════════════════"
