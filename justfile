# just-silo — Directory-based skill framework for AI agents
# https://github.com/marcus-nicolaou/just-silo
#
# COMMANDS ARE NAMESPACE-PREFIXED (git model)
#   silo-*   — Silo operations (what users run)
#   dev-*    — Development on just-silo itself
#   docs-*   — Documentation
#   lex-*    — Conceptual lexicon
#   agents-* — Sub-agent management
#   td-*     — Task database

set shell := ["bash", "-o", "pipefail", "-c"]
set positional-arguments := true

PROJECT_NAME := "just-silo"
VERSION := "0.2.0"

# ============================================================
# ENTRY POINT
# ============================================================

default:
    @just --list

version:
    @echo "{{PROJECT_NAME}} v{{VERSION}}"

# ============================================================
# HELP
# ============================================================

help topic:
    @if [ -z "{{topic}}" ]; then ./scripts/help.sh; else ./scripts/help.sh "{{topic}}"; fi

# ============================================================
# CONTENT (glow or cat)
# ============================================================

about:
    @./scripts/about.sh

about-file file:
    @./scripts/about.sh {{file}}

# ============================================================
# SILO (delegated to template)
# ============================================================

# Verify prerequisites
silo-verify:
    @cd templates/basic && just verify

# Harvest data
silo-harvest:
    @cd templates/basic && just harvest

# Process data
silo-process:
    @cd templates/basic && just process

# Flush to archive
silo-flush:
    @cd templates/basic && just flush

# Show status
silo-status:
    @cd templates/basic && just status

# ============================================================
# TD (task database)
# ============================================================


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
# LEX (lexicon)
# ============================================================


lex-all:
    @./scripts/silo-lexicon

lex-short:
    @./scripts/silo-lexicon --short

lex-find term:
    @./scripts/silo-lexicon "{{term}}"

lex-export:
    @./scripts/silo-lexicon --json > lexicon.json
    @echo "Exported to lexicon.json"

# ============================================================
# AGENTS (sub-agent management)
# ============================================================


agents-show name:
    @./scripts/show-agent.sh {{name}}

agents-run name cmd:
    @./scripts/run-agent.sh {{name}} {{cmd}}

agents-tidy cmd:
    @./scripts/run-agent.sh tidy {{cmd}}

agents-cr cmd:
    @./scripts/run-agent.sh cr {{cmd}}

# ============================================================
# DOCS (documentation)
# ============================================================


docs-readme:
    @./scripts/about.sh README.md

docs-manual:
    @./scripts/about.sh Silo-Manual.md

docs-philosophy:
    @./scripts/about.sh Silo-Philosophy.md

docs-agents:
    @./scripts/about.sh AGENTS.md

# ============================================================
# BROWSE (glow folders)
# ============================================================


browse:
    @./scripts/about.sh docs/

briefs:
    @./scripts/about.sh briefs/

playbooks:
    @./scripts/about.sh playbooks/

debriefs:
    @./scripts/about.sh debriefs/

debrief-template:
    @grep -A 30 "^#" debriefs/2026-04-07-td-ramdisk-sparklines.md 2>/dev/null | head -20

# ============================================================
# API (server)
# ============================================================


api-start:
    @bun run src/silo-api-server.ts

api-port port:
    @SILO_API_PORT={{port}} bun run src/silo-api-server.ts

# ============================================================
# TREND (sparklines)
# ============================================================


trend-show:
    @./scripts/silo-trend 2>/dev/null || echo "No silos found"

trend-dashboard:
    @bun run src/silo-dashboard.ts

# ============================================================
# WATCH (file watchers)
# ============================================================


watch-tests:
    @watchexec -e ts,tsx,js,jsx -- bun test

watch-trend:
    @watchexec -e jsonl -- just trend-show

watch-dashboard:
    @watchexec -e jsonl -- just trend-dashboard

# ============================================================
# DEV (development)
# ============================================================


dev-check:
    @./scripts/dev-check.sh

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
# OPS (housekeeping)
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

agent-ops:
    @./scripts/about.sh playbooks/agent-ops-playbook.md

# ============================================================
# ALIASES
# ============================================================

alias s := status
alias t := dev-tests
alias d := dev-check
alias v := dev-check
alias a := about
