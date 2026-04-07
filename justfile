# just-silo — Directory-based skill framework for AI agents
# https://github.com/marcus-nicolaou/just-silo

set shell := ["bash", "-o", "pipefail", "-c"]
set positional-arguments := true

PROJECT_NAME := "just-silo"
VERSION := "0.2.0"

# ============================================================
# ENTRY POINT
# ============================================================

default:
    @just help

version:
    @echo "{{PROJECT_NAME}} v{{VERSION}}"

help:
    @echo "{{PROJECT_NAME}} v{{VERSION}}"
    @echo ""
    @echo "Quick Start:"
    @echo "  just silo       # Silo operations"
    @echo "  just td         # Task management"
    @echo "  just lex        # Lexicon"
    @echo "  just agents     # Sub-agents"
    @echo "  just help       # This help"
    @echo ""
    @echo "Full list: just --list"

# ============================================================
# SECTION: SILO (silo operations)
# ============================================================

# Show silo sub-commands
silo:
    @echo "Silo Commands:"
    @echo "  silo-verify    - Verify prerequisites"
    @echo "  silo-harvest   - Harvest data"
    @echo "  silo-process   - Process data"
    @echo "  silo-flush     - Flush to archive"
    @echo "  silo-status    - Show status"

silo-verify:
    @cd templates/basic && just verify

silo-harvest:
    @cd templates/basic && just harvest

silo-process:
    @cd templates/basic && just process

silo-flush:
    @cd templates/basic && just flush

silo-status:
    @cd templates/basic && just status

# ============================================================
# SECTION: TD (task management)
# ============================================================

# Show td sub-commands
td:
    @echo "TD Commands:"
    @echo "  td-ramdisk    - Setup RAM disk"
    @echo "  td-status     - Show status"
    @echo "  td-reset      - Reset database"
    @echo "  td-test       - Run smoke test"
    @echo "  td-report     - Markdown report"

td-ramdisk:
    @./scripts/td-ramdisk-setup.sh .

td-status:
    @td status
    @echo ""
    @echo "RAM disk:"
    @df -h /Volumes/TD-RAMDisk 2>/dev/null | tail -1 || echo "  Not mounted"

td-reset:
    @echo "Resetting td database..."
    @rm -rf .todos
    @./scripts/td-ramdisk-setup.sh .
    @td usage --new-session

td-test:
    @./scripts/td-smoke-test.sh

td-report:
    @./scripts/td-markdown-report.sh
    @echo ""
    @cat td-report.md

# ============================================================
# SECTION: LEX (lexicon)
# ============================================================

# Show lexicon sub-commands
lex:
    @echo "Lexicon Commands:"
    @echo "  lex           - Show this help"
    @echo "  lex-all      - Show full lexicon"
    @echo "  lex-short    - Compact format"
    @echo "  lex-find X   - Find term X"
    @echo "  lex-export   - Export JSON"
    @echo "  lex-help     - Help"

lex-all:
    @./scripts/silo-lexicon

lex-short:
    @./scripts/silo-lexicon --short

lex-find term:
    @./scripts/silo-lexicon "{{term}}"

lex-export:
    @./scripts/silo-lexicon --json > lexicon.json
    @echo "Exported to lexicon.json"

lex-help:
    @./scripts/silo-lexicon --help

lex-show: lex-all

# ============================================================
# SECTION: AGENTS (sub-agents)
# ============================================================

# Show agents sub-commands
agents:
    @echo "Agents Commands:"
    @echo "  agents           - List all agents"
    @echo "  agents-show X   - Show agent X"
    @echo "  agents-run X Y  - Run agent X command Y"
    @echo ""
    @echo "Available agents:"
    @./scripts/list-agents.sh

agents-list: agents

agents-show name:
    @./scripts/show-agent.sh {{name}}

agents-run name cmd:
    @./scripts/run-agent.sh {{name}} {{cmd}}

agents-help:
    @cat agents/README.md

# Convenience aliases
agents-tidy cmd:
    @./scripts/run-agent.sh tidy {{cmd}}

agents-cr cmd:
    @./scripts/run-agent.sh cr {{cmd}}

# ============================================================
# SECTION: DOCS (documentation)
# ============================================================

# Show docs sub-commands
docs:
    @echo "Docs Commands:"
    @echo "  docs           - Browse docs folder"
    @echo "  docs-readme    - Show README"
    @echo "  docs-manual    - Show Silo Manual"
    @echo "  docs-philosophy - Show Philosophy"
    @echo "  docs-agents   - Show AGENTS.md"

docs-readme:
    @command -v glow >/dev/null 2>&1 && glow -p README.md || cat README.md

docs-manual:
    @command -v glow >/dev/null 2>&1 && glow -p Silo-Manual.md || cat Silo-Manual.md

docs-philosophy:
    @command -v glow >/dev/null 2>&1 && glow -p Silo-Philosophy.md || cat Silo-Philosophy.md

docs-agents:
    @command -v glow >/dev/null 2>&1 && glow -p AGENTS.md || cat AGENTS.md

browse:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow docs/; else ls -la docs/; fi

# Browse sub-commands
briefs:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow briefs/; else ls -la briefs/; fi

playbooks:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow playbooks/; else ls -la playbooks/; fi

debriefs:
    @if command -v glow >/dev/null 2>&1 && [ -t 0 ]; then glow debriefs/; else ls -la debriefs/; fi

debrief-template:
    @echo "# DeBrief Template"
    @echo ""
    @grep -A 30 "^#" debriefs/2026-04-07-td-ramdisk-sparklines.md 2>/dev/null | head -20

# ============================================================
# SECTION: API (API server)
# ============================================================

# Show API sub-commands
api:
    @echo "API Commands:"
    @echo "  api           - Start server (port 3000)"
    @echo "  api-port X   - Start on port X"

api-start:
    @bun run src/silo-api-server.ts

api-port port:
    @SILO_API_PORT={{port}} bun run src/silo-api-server.ts

# ============================================================
# SECTION: TREND (sparklines)
# ============================================================

# Show trend sub-commands
trend:
    @echo "Trend Commands:"
    @echo "  trend           - ASCII sparklines in terminal"
    @echo "  trend-dashboard - Generate HTML dashboard"

trend-show:
    @./scripts/silo-trend 2>/dev/null || echo "No silos found"

trend-dashboard:
    @bun run src/silo-dashboard.ts

trend-all: trend-show
    @bun run src/silo-dashboard.ts
    @echo "Dashboard: dashboard.html"

# ============================================================
# SECTION: WATCH (file watchers)
# ============================================================

# Show watch sub-commands
watch:
    @echo "Watch Commands:"
    @echo "  watch-tests      - Run tests on changes"
    @echo "  watch-trend     - Show trends on changes"
    @echo "  watch-dashboard - Dashboard on changes"

watch-tests:
    @watchexec -e ts,tsx,js,jsx -- bun test

watch-trend:
    @watchexec -e jsonl -- just trend-show

watch-dashboard:
    @watchexec -e jsonl -- just trend-dashboard

# ============================================================
# SECTION: DEV (development)
# ============================================================

# Show dev sub-commands
dev:
    @echo "Dev Commands:"
    @echo "  dev-check      - Check prerequisites"
    @echo "  dev-tests     - Run tests"
    @echo "  dev-new X     - Create silo X"

dev-check:
    @echo "=== {{PROJECT_NAME}} Prerequisites ==="
    @echo ""
    @echo "Core Dependencies:"
    @command -v just >/dev/null 2>&1 && echo "  ✓ just" || echo "  ✗ just MISSING"
    @command -v bun >/dev/null 2>&1 && echo "  ✓ bun" || echo "  ✗ bun MISSING"
    @command -v jq >/dev/null 2>&1 && echo "  ✓ jq" || echo "  ✗ jq MISSING"
    @command -v td >/dev/null 2>&1 && echo "  ✓ td" || echo "  ✗ td MISSING"
    @command -v watchexec >/dev/null 2>&1 && echo "  ✓ watchexec" || echo "  ✗ watchexec MISSING"
    @echo ""
    @echo "Optional:"
    @command -v glow >/dev/null 2>&1 && echo "  ✓ glow" || echo "  ○ glow (optional)"
    @command -v gum >/dev/null 2>&1 && echo "  ✓ gum" || echo "  ○ gum (optional)"
    @echo ""
    @echo "Install: brew install just bun jq marcus/tap/td watchexec"

dev-tests:
    @echo "=== Integration Tests ===" && ./scripts/silo-integration-test
    @echo ""
    @echo "=== Unit Tests ===" && bun test

dev-new name:
    @./scripts/silo-create {{name}}

dev-templates:
    @echo "Templates:"
    @ls -1 templates/ | sed 's/^/  /'

# ============================================================
# SECTION: HOUSEKEEPING
# ============================================================

tidy:
    @./scripts/tidy.sh 2>/dev/null || echo "No tidy script"

archive-briefs:
    @echo "Archiving briefs from previous sprints..."
    @cd briefs && ls -t *.md | tail -n +10 | xargs -I{} mv {} archive/ 2>/dev/null; echo "Done"

status:
    @echo "=== GIT ==="
    @git status --short 2>/dev/null || echo "(not a git repo)"
    @echo ""
    @echo "=== COMMITS ==="
    @git log --oneline -3 2>/dev/null || echo "(not a git repo)"

# ============================================================
# AGENT OPERATIONS
# ============================================================

agent-ops:
    @command -v glow >/dev/null 2>&1 && glow -p playbooks/agent-ops-playbook.md || cat playbooks/agent-ops-playbook.md


