---
date: 2026-04-26
tags: [debrief, silo-structure, workflow, dot-diagram]
---

# Debrief: AI Legislation Silo — Structure Session

## What We Did

Built the filesystem skeleton for `examples/ai-legislation-silo/`: a working example of the silo framework with:

- `inbox/` — raw provisions (8 sample entries)
- `process/` — transformation scripts (ingest, transform, deliver, status)
- `outbox/` — deliverable stubs
- `briefs/`, `debriefs/`, `playbooks/` — documentation folders
- `markers/`, `telemetry/` — observability

## Key Decisions

1. **Silo = inbox → process → outbox.** Every silo answers: what do we get, what do we do with it, what's the end result.
2. **Documentation is part of the silo.** `briefs/`, `debriefs/`, `playbooks/` are not optional. They're where thinking persists across sessions.
3. **Tools are Flox-managed.** Added `pandoc` and `poppler-utils` to root `flox.toml`. No ad-hoc `brew install`.
4. **Content acquisition = manual download + automated processing.** EUR-Lex blocks curl. Human downloads PDF once, scripts do the rest.
5. **Granularity = article-level structure, paragraph-level content.** ~300-500 provisions total, manageable for cost tracking.

## What We Didn't Do

- Did not implement `process/extract.sh` (PDF→JSONL)
- Did not implement `process/tag.sh` (deterministic risk tagging)
- Did not implement `process/evaluate.sh` (LLM-based domain analysis)
- Did not obtain real EU AI Act PDF

These are the next briefs.

## Lessons

- Structure before logic. The DOT diagram in README.md makes the contract visible.
- The `justfile` is a strict facade. All logic is in `process/*.sh` scripts.
- Status script (`process/status.sh`) is not optional. It's how you know the silo state at a glance.
