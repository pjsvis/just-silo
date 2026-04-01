#!/bin/bash
# Render help using glow if available, else plain text

HELP_MARKDOWN='
# Silo - Help

\`\`\`
just help          -> this overview
just help <verb>   -> help for specific command
just <cmd>         -> just do it
\`\`\`

## Workflow

Mount > Sieve > Process > Observe > Flush

## Core Commands

| Command | Description |
| Command | Description |
| --- | --- |
| just verify | Check prerequisites |
| just harvest | Ingest and validate data |
| just process | Run domain processing |
| just status | **Aggregate pipeline health (MAIN)** |
| just flush | Archive processed data |

## Monitoring

| Command | Description |
| --- | --- |
| just who | Who owns which stage |
| just stages | Stage-by-stage status |
| just stuck min | Detect stalled stages |
| just throughput | Processing metrics |
| just audit | Completion history |
| just alerts | Surface critical items |
| just stats | Entry counts |
| just report | Human-readable summary |

## Multi-Agent Coordination

| Command | Description |
| --- | --- |
| just claim stage | Own a stage |
| just wait marker | Block until ready |
| just done marker | Mark stage complete |
| just heartbeat | Keep claims alive |
| just lock marker | Claim via marker file |
| just is-locked m | Check claim status |
| just cleanup | Remove stale locks |

## Maintenance

| Command | Description |
| --- | --- |
| just self-test | Smoke test |
| just clean | Reset state files |
| just compact | Deep compaction |

---

Run `just help cmd` for detailed usage.
'

if command -v glow >/dev/null 2>&1; then
    echo "$HELP_MARKDOWN" | glow -s dark
else
    cat << 'PLAIN'
============================================================
  SILO - HELP
============================================================

  just help          -> this overview
  just help <verb>   -> help for specific command
  just <cmd>         -> just do it

============================================================
WORKFLOW: Mount > Sieve > Process > Observe > Flush
============================================================

CORE:
  just verify    Check prerequisites
  just harvest  Ingest and validate data
  just process  Run domain processing
  just status   Aggregate pipeline health (MAIN)
  just flush    Archive processed data

MONITORING:
  just who, stages, stuck, throughput, audit, alerts, stats, report

COORDINATION:
  just claim, wait, done, heartbeat, lock, is-locked, cleanup

MAINTENANCE:
  just self-test, clean, compact

============================================================
Run 'just help cmd' for detailed usage
============================================================
PLAIN
fi
