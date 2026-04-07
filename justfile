# just-silo — Directory-based skill framework for AI agents
# https://github.com/marcus-nicolaou/just-silo
#
# COMMANDS ARE NAMESPACE-PREFIXED (git model)
#   silo-*   — Silo operations (what users run)
#   dev-*    — Development on just-silo itself
#   docs-*   — Documentation
#   tests-*  — Testing
#   lex-*    — Conceptual lexicon
#
# TWO CONTEXTS:
#   1. Project (this file) — Develop just-silo
#   2. Silo (template/) — Use just-silo

set shell := ["bash", "-o", "pipefail", "-c"]
set positional-arguments := true

PROJECT_NAME := "just-silo"
VERSION := "0.1.0"

# === ENTRY POINT ===

# Show help with curated commands
default:
    @just help

# Show version
version:
    @echo "{{PROJECT_NAME}} v{{VERSION}}"

# === HELP ===

# Curated help for users
help:
    @echo "{{PROJECT_NAME}} v{{VERSION}}"
    @echo ""
    @echo "TWO CONTEXTS:"
    @echo "  Project: just dev-* (develop just-silo)"
    @echo "  Silo:    just silo-* (operate a silo)"
    @echo ""
    @echo "PROJECT (develop just-silo):"
    @echo "  just dev-check      — Check prerequisites"
    @echo "  just dev-tests      — Run all tests"
    @echo "  just dev-new        — Create new silo"
    @echo ""
    @echo "SILO (operate a silo):"
    @echo "  just silo-verify   — Check silo prerequisites"
    @echo "  just silo-harvest   — Ingest data"
    @echo "  just silo-flush    — Archive output"
    @echo ""
    @echo "DOCS:"
    @echo "  just docs           — Browse docs/"
    @echo "  just lex            — Show lexicon"
    @echo ""
    @echo "Full list: just --list"

# === NAMESPACE: silo-* (user operations) ===

# Verify silo prerequisites
silo-verify:
    @cd templates/basic && just verify

# Harvest data into silo
silo-harvest:
    @cd templates/basic && just harvest

# Process silo data
silo-process:
    @cd templates/basic && just process

# Flush processed data to archive
silo-flush:
    @cd templates/basic && just flush

# Show silo status
silo-status:
    @cd templates/basic && just status

# === NAMESPACE: td-* (task database) ===

# Set up td database on RAM disk
td-ramdisk:
    @./scripts/td-ramdisk-setup.sh .

# Show td database status
td-status:
    @td status
    @echo ""
    @echo "RAM disk usage:"
    @df -h /Volumes/TD-RAMDisk 2>/dev/null | tail -1 || echo "  (RAM disk not mounted)"

# Restart td with fresh database
td-reset:
    @echo "Resetting td database..."
    @rm -rf .todos
    @./scripts/td-ramdisk-setup.sh .
    @td usage --new-session

# Run td smoke test
td-test:
    @./scripts/td-smoke-test.sh

# Generate markdown report of td tasks
td-report:
    @./scripts/td-markdown-report.sh
    @echo ""
    @cat td-report.md

# === NAMESPACE: dev-* (project development) ===

# Check project prerequisites
dev-check:
    @echo "=== {{PROJECT_NAME}} Prerequisites ==="
    @command -v just >/dev/null 2>&1 && echo "  just ok" || echo "  just MISSING"
    @command -v jq >/dev/null 2>&1 && echo "  jq ok" || echo "  jq MISSING"
    @command -v bun >/dev/null 2>&1 && echo "  bun ok" || echo "  bun MISSING"
    @command -v glow >/dev/null 2>&1 && echo "  glow ok (optional)" || echo "  glow (optional)"
    @command -v gum >/dev/null 2>&1 && echo "  gum ok (optional)" || echo "  gum (optional)"
    @echo ""
    @echo "=== Project Files ==="
    @test -f justfile && echo "  justfile ok" || echo "  justfile MISSING"
    @test -f template/justfile && echo "  template/justfile ok" || echo "  template/justfile MISSING"
    @test -f scripts/silo-create && echo "  scripts/silo-create ok" || echo "  scripts/silo-create MISSING"
    @test -d src && echo "  src/ ok" || echo "  src/ MISSING"
    @test -f silo-lexicon.jsonl && echo "  silo-lexicon.jsonl ok" || echo "  silo-lexicon.jsonl MISSING"

# Run all tests (integration + unit)
dev-tests:
    @echo "=== Integration Tests ===" && ./scripts/silo-integration-test
    @echo ""
    @echo "=== Unit Tests ===" && bun test

# Create a new silo from template
dev-new name:
    @./scripts/silo-create {{name}}

# List available templates
dev-templates:
    @echo "Available templates:"
    @ls -1 templates/

# === NAMESPACE: docs-* (documentation) ===

# Browse docs folder with glow
docs:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow docs/; else ls -la docs/; fi

# Show README
docs-readme:
    @command -v glow >/dev/null 2>&1 && glow -p README.md || cat README.md

# Show Silo Manual
docs-manual:
    @if command -v glow >/dev/null 2>&1; then glow -p Silo-Manual.md 2>/dev/null || cat Silo-Manual.md; else cat Silo-Manual.md; fi

# Show Silo Philosophy
docs-philosophy:
    @if command -v glow >/dev/null 2>&1; then glow -p Silo-Philosophy.md 2>/dev/null || cat Silo-Philosophy.md; else cat Silo-Philosophy.md; fi

# Show AGENTS.md
docs-agents:
    @command -v glow >/dev/null 2>&1 && glow -p AGENTS.md || cat AGENTS.md

# === NAMESPACE: lex-* (lexicon) ===

# Show lexicon as markdown table
lex:
    @echo "# Silo Lexicon"
    @echo ""
    @echo "| Token | Heuristic |"
    @echo "|-------|------------|"
    @jq -r '.token + " | " + .heuristic' silo-lexicon.jsonl

# Show lexicon as JSON
lex-json:
    @if [ -f silo-lexicon.jsonl ]; then cat silo-lexicon.jsonl | jq .; else echo "No lexicon"; fi

# Check if term exists in lexicon
lex-check term:
    @test -f silo-lexicon.jsonl && echo "Checking: {{term}}"
    @jq -c 'select(.token | contains("{{term}}"))' silo-lexicon.jsonl | jq . || echo "'{{term}}' not found"

# === NAMESPACE: browse-* (glow TUI for folders) ===

# Browse docs folder
browse:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow docs/; else ls -la docs/; fi

# Browse briefs folder
briefs:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow briefs/; else ls -la briefs/; fi

# Browse playbooks folder
playbooks:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow playbooks/; else ls -la playbooks/; fi

# Browse debriefs folder
debriefs:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow debriefs/; else ls -la debriefs/; fi

# === STATUS ===

# Show git status and recent commits
status:
    @echo "=== GIT ==="
    @git status --short 2>/dev/null || echo "(not a git repo)"
    @echo ""
    @echo "=== COMMITS (last 5) ==="
    @git log --oneline -5 2>/dev/null || echo "(not a git repo)"

# === ALIASES (backward compat) ===

verify: dev-check
test: dev-tests
templates: dev-templates
readme: docs-readme
manual: docs-manual
philosophy: docs-philosophy
lexicon: lex-json
lex-show: lex
unit-test: dev-tests

# === NAMESPACE: debrief-* (retrospectives) ===

# Show agent ops playbook
agent-ops:
    @command -v glow >/dev/null 2>&1 && glow -p playbooks/agent-ops-playbook.md || cat playbooks/agent-ops-playbook.md

# Show debrief template
debrief-template:
    @echo "# Debrief Template"
    @echo ""
    @echo "Location: debriefs/YYYY-MM-DD-session.md"
    @echo ""
    @grep -A 50 "^#" debriefs/2026-04-07-td-ramdisk-setup.md | head -30


# === NAMESPACE: trend-* (sparklines) ===

# Show ASCII sparklines in terminal
trend:
    @./scripts/silo-trend 2>/dev/null || echo "No silos found. Run from mesh directory."

# Generate HTML dashboard with sparklines
trend-dashboard:
    @bun run src/silo-dashboard.ts

# Both trend and dashboard
trend-all: trend
    @./src/silo-dashboard.ts
    @echo "Dashboard generated: dashboard.html"
