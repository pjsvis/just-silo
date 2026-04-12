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
    @just --list

version:
    @echo "{{ PROJECT_NAME }} v{{ VERSION }}"

# ============================================================
# HELP
# ============================================================

help topic:
    @if [ -z "{{ topic }}" ]; then ./scripts/help.sh; else ./scripts/help.sh "{{ topic }}"; fi

# ============================================================
# CONTENT (glow or cat)
# ============================================================

about:
    @./scripts/about.sh

about-file file:
    @./scripts/about.sh {{ file }}

# ============================================================
# SILO (delegated to template)
# ============================================================

# Verify prerequisites
[group("silo")]
silo-verify:
    @cd templates/basic && just verify

# Harvest data
[group("silo")]
silo-harvest:
    @cd templates/basic && just harvest

# Process data
[group("silo")]
silo-process:
    @cd templates/basic && just process

# Flush to archive
[group("silo")]
silo-flush:
    @cd templates/basic && just flush

# Show status
[group("silo")]
silo-status:
    @cd templates/basic && just status

# Silo help - entry point for new agents
[group("silo")]
silo-help:
    @echo "=== SILO ENTRY POINTS ==="
    @echo ""
    @echo "START HERE:"
    @echo "  1. Read: START-HERE.md"
    @echo "  2. Read: README.md"
    @echo "  3. Run: just silo-help"
    @echo ""
    @echo "KEY COMMANDS:"
    @echo "  just silo-help       - This help"
    @echo "  just silo-verify     - Check invariants"
    @echo "  just silo-status     - Show silo health"
    @echo "  just td status       - Show tasks"
    @echo "  just --list          - All recipes"
    @echo ""
    @echo "SILO STRUCTURE:"
    @echo "  briefs/    - What we've been thinking"
    @echo "  playbooks/ - Operational knowledge"
    @echo "  scripts/   - Automation"
    @echo "  template/  - Silo template"
    @echo "  workflows/ - Named procedures (no recursion)"
    @echo ""
    @echo "INVARIANTS:"
    @echo "  1. Filename uniqueness within silo"
    @echo "  2. README.md per browsable directory"
    @echo "  3. README is checksum of directory"
    @echo "  4. Archive naming: FOLDERNAME_archive"
    @echo "  5. No recursion: no nested silos"
    @echo ""
    @echo "═══════════════════════════════════════════"
    @echo "⚠️  CAW CANNY: Before read-write, prompt for go/no-go."
    @echo "   Directive: $(jq -r '.directive' .silo)"
    @echo "═══════════════════════════════════════════"

# Verify silo structure
[group("silo")]
silo-verify-structure:
    @./scripts/silo-verify-structure.sh templates/basic

# Watch mode (requires watchexec)
[group("silo")]
silo-watch:
    @command -v watchexec >/dev/null 2>&1 && \
        watchexec -e jsonl,sh -- just harvest || \
        echo "watchexec not installed (brew install watchexec)"

# Gate: Run before any write action
[group("silo")]
silo-gate:
    @./scripts/silo-verify-structure.sh . || \
        (echo "" && echo "⚠️ Gate failed. Fix invariants before proceeding." && exit 1)
    @echo "✓ Gate passed - invariants hold"

# Gate: Non-interactive (for scripts/CI)
[group("silo")]
silo-gate-quiet:
    @./scripts/silo-verify-structure.sh . >/dev/null 2>&1 && \
        echo "✓ Invariants hold" || \
        (echo "✗ Invariants broken" && exit 1)


# Production line: Put silo ON (costs money)
[group("silo")]
silo-on:
    @echo "=== Silo ON Production Line ==="
    @echo "Status: Active"
    @echo "Cost: Tokens, compute, time"
    @echo ""
    @echo "To verify value: just silo-verify-value"
    @echo "To take off: just silo-off"

# Production line: Take silo OFF (no cost)
[group("silo")]
silo-off:
    @echo "=== Silo OFF Production Line ==="
    @echo "Status: Dormant"
    @echo "Cost: None"
    @echo ""
    @echo "To put on: just silo-on"

# Production line: Verify value (outbox entropy vs inbox entropy)
[group("silo")]
silo-verify-value:
    @echo "=== Entropy Verification ==="
    @echo ""
    @echo "PROBLEM: No entropy metric defined."
    @echo "You must implement your own measurement logic."
    @echo ""
    @echo "We provide: Constant environment, trend detection"
    @echo "You provide: Entropy metric, thresholds"
    @echo ""
    @echo "To define your metric: Edit scripts/entropy-measure.sh"
# ============================================================
# TD (task database)
# ============================================================

# Setup RAM disk for td
[group("td")]
td-ramdisk:
    @./scripts/td-ramdisk-setup.sh .

# Show td status
[group("td")]
td-status:
    @td status
    @echo ""
    @echo "RAM disk:"
    @df -h /Volumes/TD-RAMDisk 2>/dev/null | tail -1 || echo "  Not mounted"

# Reset td database
[group("td")]
td-reset:
    @echo "Resetting td database..."
    @rm -rf .todos
    @./scripts/td-ramdisk-setup.sh .
    @td usage --new-session

# Run td smoke test
[group("td")]
td-test:
    @./scripts/td-smoke-test.sh

# Generate td report
[group("td")]
td-report:
    @./scripts/td-markdown-report.sh
    @echo ""
    @cat td-report.md

# ============================================================
# LEX (lexicon)
# ============================================================

# Show full lexicon
[group("lex")]
lex-all:
    @./scripts/silo-lexicon

# Show compact lexicon
[group("lex")]
lex-short:
    @./scripts/silo-lexicon --short

# Find term in lexicon
[group("lex")]
lex-find term:
    @./scripts/silo-lexicon "{{ term }}"

# Export lexicon to JSON
[group("lex")]
lex-export:
    @./scripts/silo-lexicon --json > lexicon.json
    @echo "Exported to lexicon.json"

# ============================================================
# AGENTS (sub-agent management)
# ============================================================

# Show agents status
[group("agents")]
agent-status name="":
    @./scripts/agent-status.sh {{ name }}

# Create new agent from template
[group("agents")]
agent-create name type="mounted":
    @./scripts/agent-create.sh {{ name }} {{ type }}

# Invoke an agent with input
[group("agents")]
agent-invoke name input="-":
    @./scripts/agent-invoke.sh {{ name }} {{ input }}

# Show agent info
[group("agents")]
agents-show name:
    @./scripts/show-agent.sh {{ name }}

# Run agent command
[group("agents")]
agents-run name cmd:
    @./scripts/run-agent.sh {{ name }} {{ cmd }}

# Run tidy agent
[group("agents")]
agents-tidy cmd:
    @./scripts/run-agent.sh tidy {{ cmd }}

# Run code review agent
[group("agents")]
agents-cr cmd:
    @./scripts/run-agent.sh cr {{ cmd }}

# ============================================================
# DOCS (documentation)
# ============================================================

# Show README
[group("docs")]
docs-readme:
    @./scripts/about.sh README.md

# Show Silo Manual
[group("docs")]
docs-manual:
    @./scripts/about.sh Silo-Manual.md

# Show Silo Philosophy
[group("docs")]
docs-philosophy:
    @./scripts/about.sh Silo-Philosophy.md

# Show AGENTS.md
[group("docs")]
docs-agents:
    @./scripts/about.sh AGENTS.md

# ============================================================
# BROWSE (glow folders)
# ============================================================

# Browse docs folder
[group("browse")]
browse:
    @./scripts/about.sh docs/

# Browse briefs folder
[group("browse")]
browse-briefs:
    @./scripts/about.sh briefs/

# Browse playbooks folder
[group("browse")]
playbooks:
    @./scripts/about.sh playbooks/

# Browse debriefs folder
[group("browse")]
debriefs:
    @./scripts/about.sh debriefs/

# Show debrief template
[group("browse")]
debrief-template:
    @grep -A 30 "^#" debriefs/2026-04-07-td-ramdisk-sparklines.md 2>/dev/null | head -20

# ============================================================
# BRIEFS (brief management) - scripts/briefs.sh
# ============================================================

# Briefs entry point - shows help
[group("briefs")]
briefs:
    @./scripts/briefs.sh help

# Catalog all briefs
[group("briefs")]
briefs-catalog:
    @./scripts/briefs.sh catalog

# Archive old briefs
[group("briefs")]
briefs-archive:
    @./scripts/briefs.sh archive

# Process debriefs (extract lessons, archive)
[group("briefs")]
briefs-debriefs:
    @./scripts/briefs.sh debriefs

# Sync BRIEFS-ROADMAP from index
[group("briefs")]
briefs-sync:
    @./scripts/briefs.sh sync

# Generate workplan (sorted by epic + date)
[group("briefs")]
briefs-plan:
    @./scripts/briefs.sh plan

# Find briefs (interactive with fzf)
[group("briefs")]
briefs-find query="":
    @./scripts/briefs.sh find "{{ query }}"

# Full briefs maintenance
[group("briefs")]
briefs-maintain:
    @SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh info "Starting briefs maintenance" action=briefs-maintain
    @./scripts/briefs.sh catalog && ./scripts/briefs.sh debriefs && ./scripts/briefs.sh sync
    @SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh info "Briefs maintenance complete" action=briefs-maintain status=success

# Show briefs status
[group("briefs")]
briefs-status:
    @./scripts/briefs.sh status

# ============================================================
# API (server) - Two-Tier Architecture
# ============================================================

# Start internal API (dev dashboard, port 3001)
[group("api")]
api-internal:
    @echo "Starting internal API on http://127.0.0.1:3001"
    @SILO_API_PORT=3001 bun run src/silo-api-internal.ts

# Start external API (remote control, port 3000)
[group("api")]
api-external:
    @echo "Starting external API on http://0.0.0.0:3000"
    @SILO_API_PORT=3000 bun run src/silo-api-external.ts

# Start both APIs (internal first, then external)
# Uses subshell with trap to clean up background process on exit
[group("api")]
api-start:
	@echo "Starting two-tier API..."
	@(\
		SILO_API_PORT=3001 bun run src/silo-api-internal.ts &\
		INTERNAL_PID=$$!\
		trap "kill $$INTERNAL_PID 2>/dev/null" EXIT INT TERM\
		sleep 1\
		SILO_API_PORT=3000 bun run src/silo-api-external.ts\
	)

# Start API on custom port (legacy, uses internal)
[group("api")]
api-port port:
    @SILO_API_PORT={{ port }} bun run src/silo-api-internal.ts

# Show API status
[group("api")]
api-status:
    @echo "=== API Status ==="
    @curl -s http://127.0.0.1:3001/health 2>/dev/null && echo " (internal OK)" || echo " (internal down)"
    @curl -s http://127.0.0.1:3000/health 2>/dev/null && echo " (external OK)" || echo " (external down)"

# ============================================================
# TREND (sparklines)
# ============================================================

# Show ASCII sparklines
[group("trend")]
trend-show:
    @./scripts/silo-trend 2>/dev/null || echo "No silos found"

# Generate HTML dashboard
[group("trend")]
trend-dashboard:
    @bun run src/silo-dashboard.ts

# ============================================================
# WATCH (file watchers)
# ============================================================

# Watch and run tests
[group("watch")]
watch-tests:
    @watchexec -e ts,tsx,js,jsx -- bun test

# Watch and show trends
[group("watch")]
watch-trend:
    @watchexec -e jsonl -- just trend-show

# Watch and update dashboard
[group("watch")]
watch-dashboard:
    @watchexec -e jsonl -- just trend-dashboard

# ============================================================
# DEV (development)
# ============================================================

# Check prerequisites
[group("dev")]
dev-check:
    @./scripts/dev-check.sh

# Type-check all tiers (requires: npm install -g typescript)
[group("dev")]
dev-typecheck:
    @if command -v tsc >/dev/null 2>&1; then \
        echo "=== Type Check: Production (src/) ===" && \
        tsc --project tsconfig.json --noEmit 2>&1 || true && \
        echo "" && \
        echo "=== Type Check: Scripts (scripts/) ===" && \
        tsc --project tsconfig.scripts.json --noEmit 2>&1 || true; \
    else \
        echo "TypeScript not installed. Run: npm install -g typescript"; \
    fi

# Run tests (integration + unit)
[group("dev")]
dev-tests:
    @echo "=== Integration Tests ===" && ./scripts/silo-integration-test
    @INT_EXIT=$$?
    @echo ""
    @echo "=== Unit Tests ===" && bun test
    @TEST_EXIT=$$?
    @if [ "$$TEST_EXIT" = "0" ] && [ "$$INT_EXIT" = "0" ]; then \
        SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh info "Tests passed" action=dev-tests status=success; \
    else \
        SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh error "Tests failed" action=dev-tests status=failure exit_code="$$TEST_EXIT"; \
    fi

# Full quality check (type + test)
[group("dev")]
dev-checkall: dev-typecheck dev-tests
    @echo "=== Full Quality Check Complete ==="

# Create new silo
[group("dev")]
dev-new name:
    @./scripts/silo-create {{ name }}

# List templates
[group("dev")]
dev-templates:
    @echo "Templates:"
    @ls -1 templates/ | sed 's/^/  /'

# ============================================================
# OPS (housekeeping)
# ============================================================

# Quick tidy check
[group("ops")]
tidy:
    @./scripts/tidy.sh 2>/dev/null || echo "No tidy script"

# Archive old briefs
[group("ops")]
archive-briefs:
    @echo "Archiving briefs from previous sprints..."
    @cd briefs && ls -t *.md | tail -n +10 | xargs -I{} mv {} archive/ 2>/dev/null; echo "Done"

# Show git status
[group("ops")]
status:
    @echo "=== GIT ==="
    @git status --short 2>/dev/null || echo "(not a git repo)"
    @echo ""
    @echo "=== COMMITS ==="
    @git log --oneline -3 2>/dev/null || echo "(not a git repo)"

# Show agent ops playbook
[group("ops")]
agent-ops:
    @./scripts/about.sh playbooks/agent-ops-playbook.md

# ============================================================
# BLOG (Wee Stories)
# ============================================================

# Scan docs for stories (wee stories)
# Usage: just blog-scan [path=briefs]
[group("blog")]
blog-scan path=("briefs"):
    @echo "=== Scanning for stories ==="
    @bash scripts/story-scan.sh "{{path}}"
    @echo ""
    @bash scripts/story-list.sh

# List all stories
# Usage: just blog-list
[group("blog")]
blog-list:
    @bash scripts/story-list.sh --all

# Search stories by tag
# Usage: just blog-search [tag=gamma-loop]
[group("blog")]
blog-search tag=(""):
    @if [ -z "{{tag}}" ]; then \
        echo "Usage: just blog-search <tag>"; \
    else \
        bash scripts/story-list.sh --tag "{{tag}}"; \
    fi

# Generate blog post from stories
# Usage: just blog-generate [--tag TAG] [--type TYPE] [--count N]
[group("blog")]
blog-generate *args:
    @bash scripts/blog-generate.sh {{args}}

# ============================================================
# REVIEW (PR Review Workflow)
# ============================================================

# Check PR review status
# Usage: just pr-review [pr-number=2]
[group("review")]
pr-review pr="2":
    @bash scripts/pr-review.sh {{pr}}

# View PR comments
# Usage: just pr-comments [pr-number=2]
[group("review")]
pr-comments pr="2":
    @gh pr view {{pr}} --comments

# View PR diff
# Usage: just pr-diff [pr-number=2]
[group("review")]
pr-diff pr="2":
    @gh pr diff {{pr}}

# View PR reviews
# Usage: just pr-reviews [pr-number=2]
[group("review")]
pr-reviews pr="2":
    @gh pr view {{pr}} --json reviews

# ============================================================
# ALIASES
# ============================================================



# Write a log entry (Pino-compatible JSONL)
# Usage: just log-info "Task completed"
#        just log-info "Task completed" --action harvest --status success
[group("ops")]
log-info msg *args:
    @SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh info "{{msg}}" {{args}}

# Write a warn log entry
[group("ops")]
log-warn msg *args:
    @SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh warn "{{msg}}" {{args}}

# Write an error log entry
[group("ops")]
log-error msg *args:
    @SILO_LOG_DIR=".silo/logs" SILO_NAME="{{PROJECT_NAME}}" bash scripts/silo-log.sh error "{{msg}}" {{args}}

# Query telemetry logs
# Usage: just log-query              # Recent entries
#        just log-query --errors     # Errors only
#        just log-query --stats      # Statistics
[group("ops")]
log-query *args:
    @bash scripts/silo-log-query.sh {{args}}

# Initialize logging directory
[group("ops")]
log-init:
    @mkdir -p .silo/logs
    @echo "Logging directory initialized: .silo/logs"

# ============================================================
# SILO BUILD (development workflow)
# ============================================================

# Start building a new silo
# Usage: just silo-build blog_writer_silo
[group("silo-build")]
silo-build name:
    @echo "=== Building Silo: {{name}} ==="
    @bash scripts/silo-build.sh {{name}}
    @echo ""
    @echo "Next: cd dev/{{name}} && just dev"

# Deploy silo from dev to silos/
# Usage: just silo-deploy blog_writer_silo
[group("silo-build")]
silo-deploy name:
    @echo "=== Deploying Silo: {{name}} ==="
    @bash scripts/silo-deploy.sh {{name}}

# Clean up dev workspace
# Usage: just silo-clean blog_writer_silo
[group("silo-build")]
silo-clean name:
    @echo "=== Cleaning Dev Workspace ==="
    @bash scripts/silo-clean.sh {{name}}

# List all silos (dev + deployed)
[group("silo-build")]
silo-list:
    @echo "=== Silo Workspaces ==="
    @echo ""
    @echo "Development:"
    @ls -la dev/*_silo 2>/dev/null || echo "  (none)"
    @echo ""
    @echo "Deployed:"
    @ls -la silos/*_silo 2>/dev/null || echo "  (none)"
    @echo ""
    @echo "Templates:"
    @ls -la dev/_template 2>/dev/null || echo "  (none)"

# Test a silo
# Usage: just silo-test blog_writer_silo
[group("silo-build")]
silo-test name:
    @echo "=== Testing Silo: {{name}} ==="
    @test -d "silos/{{name}}" && (cd "silos/{{name}}" && just verify) || echo "Not deployed"
    @test -d "dev/{{name}}" && (cd "dev/{{name}}" && just verify) || echo "Not in dev"

# Entropy trend analysis
# Usage: just log-trend           # Summary
#        just log-trend --alerts  # High entropy alerts
#        just log-trend --predict # Predictions
[group("ops")]
log-trend *args:
    @bash scripts/silo-log-trend.sh {{args}}
