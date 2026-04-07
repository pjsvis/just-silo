#!/usr/bin/env bash
# Contextual help navigator
# Usage: ./scripts/help.sh [topic]
#   no args    → show topics
#   with topic → show help for that topic

set -euo pipefail

TOPIC="${HELP_TOPIC:-${1:-}}"

show_topics() {
    cat << 'EOF'
just-silo v0.2.0

Topics: silo td lex agents docs browse api trend watch dev ops
Usage: just help <topic>

PROJECT (develop just-silo):
  just dev-check      — Check prerequisites
  just dev-tests      — Run all tests
  just dev-new <name> — Create new silo

SILO (operate a silo):
  just silo-verify   — Check silo prerequisites
  just silo-harvest   — Ingest data
  just silo-process   — Process data
  just silo-flush    — Archive output

DOCS:
  just about          — Orientation (RECOMMENDED)
  just docs-*         — View documentation

Full list: just --list
EOF
}

show_help() {
    case "$1" in
        silo)    echo "silo: verify, harvest, process, flush, status" ;;
        td)      echo "td: ramdisk, status, reset, test, report" ;;
        lex)     echo "lex: all, short, find <term>, export" ;;
        agents)  ./scripts/list-agents.sh ;;
        docs)    echo "docs: readme, manual, philosophy, agents" ;;
        browse)  echo "browse: briefs, playbooks, debriefs, docs" ;;
        api)     echo "api: start, port <n>" ;;
        trend)   echo "trend: show, dashboard" ;;
        watch)   echo "watch: tests, trend, dashboard" ;;
        dev)     echo "dev: check, tests, new <name>, templates" ;;
        ops)     echo "ops: tidy, archive-briefs, status" ;;
        *)       echo "Unknown topic: $1" && show_topics ;;
    esac
}

if [ -z "$TOPIC" ]; then
    show_topics
else
    show_help "$TOPIC"
fi
