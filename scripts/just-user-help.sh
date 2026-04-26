#!/bin/bash
# just-user-help - Curated user-facing recipe list
# Usage: ./scripts/just-user-help.sh

set -euo pipefail

cat << 'EOF'
═══════════════════════════════════════════
  just-silo — User Commands
═══════════════════════════════════════════

START HERE:
  just about              — Project overview
  just version            — Show version
  just silo-help          — Full silo orientation

WORKFLOW:
  just silo-verify        — Check invariants
  just silo-gate          — Pre-flight check
  just td-status          — Task board
  just briefs             — Briefs management
  just dev-check          — Dev prerequisites
  just dev-tests          — Run tests
  just dev-typecheck      — Type check

DISCOVER:
  just browse             — Browse docs
  just playbooks          — Browse playbooks
  just debriefs           — Browse debriefs
  just lex-all            — Full lexicon

API & PRESENTATION:
  just api-internal       — Start dev API (3001)
  just api-external       — Start public API (3000)
  just presentation-serve — Presentation server

PR WORKFLOW:
  just pr-list            — List your open PRs
  just pr-review <n>      — Review PR status
  just pr-watch <n>       — Monitor PR (via harness)

MORE:
  just --list             — All recipes (with groups)
  just agent              — Agent commands

═══════════════════════════════════════════
  Agent help: just agent
═══════════════════════════════════════════
EOF
