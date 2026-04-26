#!/bin/bash
# just-agent-help - Curated agent-facing recipe list
# Usage: ./scripts/just-agent-help.sh

set -euo pipefail

cat << 'EOF'
═══════════════════════════════════════════
  just-silo — Agent Commands
═══════════════════════════════════════════

AGENT MANAGEMENT:
  just agent-status [name]   — Show agent status
  just agent-create <n> [t]  — Create agent from template
  just agents-run <n> <cmd>  — Run agent command

PREFLIGHT & HYGIENE:
  just silo-gate             — Invariant gate (interactive)
  just silo-gate-quiet       — Invariant gate (silent)
  just silo-verify-structure — Structure check
  just tidy                  — Workspace tidy check

MONITORING:
  just watch-tests           — Watch tests
  just watch-trend           — Watch entropy trends
  just watch-qmd             — Watch volatile markdown

ENTROPY & LOGS:
  just trend-show            — ASCII sparklines
  just log-query             — Query telemetry
  just log-trend             — Entropy trend analysis

MAINTENANCE:
  just briefs-maintain       — Full briefs maintenance
  just archive-briefs        — Archive old briefs
  just status                — Git status summary

HARNESS INTEGRATED:
  pr_watch <n>               — Monitor PR reviews
  pr_fix_issues              — Auto-fix review comments
  pr_escalate                — Escalate to human
  pr_status                  — Check monitoring status

═══════════════════════════════════════════
  User help: just (no args)
═══════════════════════════════════════════
EOF
