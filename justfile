# just-silo — Directory-based skill framework for AI agents
# https://github.com/marcus-nicolaou/just-silo

set shell := ["bash", "-o", "pipefail", "-c"]

PROJECT_NAME := "just-silo"
VERSION := "0.1.0"

# === ENTRY POINT ===

# Running `just` with no args shows this
default:
    @just --list --justfile {{justfile()}}

# === PROJECT OVERVIEW ===

# Show project info
info:
    @echo "╔═══════════════════════════════════════════════════════════╗"
    @echo "║  {{PROJECT_NAME}} v{{VERSION}}                              ║"
    @echo "║  Directory-based skill framework for AI agents         ║"
    @echo "╚═══════════════════════════════════════════════════════════╝"
    @echo ""
    @echo "  Templates:     templates/"
    @echo "  Scripts:       scripts/"
    @echo "  Source:        src/"
    @echo "  Briefs:        briefs/"
    @echo "  Documentation: README.md, Silo-Manual.md"
    @echo ""
    @just status

# === PROJECT STATUS ===

# Git status
status:
    @echo "=== GIT ==="
    @git status --short 2>/dev/null || echo "(not a git repo)"
    @echo ""
    @echo "=== COMMITS (last 5) ==="
    @git log --oneline -5 2>/dev/null || echo "(not a git repo)"
    @echo ""
    @echo "=== TASKS ==="
    @td next 2>/dev/null || echo "(td not initialized)"

# === DEVELOPMENT ===

# Create a new silo from template
new name:
    @./scripts/silo-create {{name}}

# List available templates
templates:
    @echo "Available templates:"
    @ls -1 templates/

# Run integration test
test:
    @./scripts/silo-integration-test

# === DOCUMENTATION ===

# Show README (rendered)
readme:
    @command -v glow >/dev/null 2>&1 && glow -p README.md || cat README.md

# Show manual (rendered)
manual:
    @if command -v glow >/dev/null 2>&1; then glow -p Silo-Manual.md 2>/dev/null || cat Silo-Manual.md; else cat Silo-Manual.md 2>/dev/null || echo "No manual found"; fi

# Show philosophy (rendered)
philosophy:
    @if command -v glow >/dev/null 2>&1; then glow -p Silo-Philosophy.md 2>/dev/null || cat Silo-Philosophy.md; else cat Silo-Philosophy.md 2>/dev/null || echo "No philosophy found"; fi

# === HELP ===

help:
    @echo "{{PROJECT_NAME}} — Available commands:"
    @echo ""
    @echo "  just info       - Project overview"
    @echo "  just status     - Git and task status"
    @echo "  just new <name> - Create new silo"
    @echo "  just templates  - List available templates"
    @echo "  just test       - Run integration test"
    @echo "  just readme     - Show README (rendered)"
    @echo "  just manual     - Show Silo-Manual (rendered)"
    @echo "  just philosophy - Show philosophy (rendered)"
    @echo ""
    @echo "To mount a silo:"
    @echo "  cd templates/basic/"
    @echo "  just verify"
