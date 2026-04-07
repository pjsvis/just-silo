# Just-Silo Dev Session

## Context

Working on just-silo framework. Project at `/Users/petersmith/Dev/GitHub/just-silo-dev`

## Status: v0.1.0 RELEASED ✅

## Quick Start

```bash
just dev-check     # Prerequisites
just dev-tests     # All tests
just silo-verify # Silo prerequisites
just lex           # Show lexicon
just --list        # Full command list
```

## Delivered in v0.1

| Component | Files | Tests |
|-----------|-------|-------|
| Template System | `templates/basic/` | ✅ |
| CLI Tools | `scripts/silo-create`, `scripts/silo-ignite` | ✅ 17 tests |
| Unit Tests | `src/*.test.ts` | ✅ 12 tests |
| API Server | `src/silo-api-server.ts` | ✅ |
| Mesh | `src/silo-mesh.ts` | ✅ |
| Dashboard | `src/silo-dashboard.ts` | ✅ |
| Justfile | Namespace-prefixed (`dev-*`, `silo-*`) | ✅ |
| Silo Lexicon | `silo-lexicon.jsonl` (12 tokens) | ✅ |
| Mentational Hygiene | `AGENTS.md` | ✅ |
| Secrets Playbook | `playbooks/secrets-playbook.md` | ✅ |

## Mentational Hygiene (CRITICAL)

**Before starting:** Read `AGENTS.md` → Mentational Hygiene section.

```
IF same command + same error = 2nd attempt → STOP
STATE: "Known issue, skipping. Reason: [brief]"
REPORT to user
```

**Nested directory signal:** `.foo/.foo/` = evidence of past attempts. Stop investigating.

**Flow preservation:** Excellent flow is fragile. Technical fixes are not worth destroying session quality.

## TD Database Issue

**Known Issue — Skip per Mentational Hygiene directive.**

SQLite WAL corruption. Do NOT attempt to fix. Flag and move on.

## v0.2 Backlog

| Priority | Task | Effort |
|----------|------|--------|
| 1 | SSE Streaming | Low |
| 2 | Sparklines | Low |
| 3 | Lexicon mount (agent reads on cd) | Low |
| 4 | User guide | Medium |

See `briefs/BRIEFS-ROADMAP.md` for full backlog.

## Instructions

1. Read `SESSION-STATE.md` for context
2. Run `just dev-check` to verify environment
3. Review `briefs/BRIEFS-ROADMAP.md` for priorities
4. Check `silo-lexicon.jsonl` for conceptual tokens
5. **Mentational Hygiene first** — prevent doom loops
6. Archive completed work to `briefs/archive/`

## Key Files

| File | Purpose |
|------|---------|
| `justfile` | Commands (`just --list`) |
| `AGENTS.md` | Agent directives |
| `SESSION-STATE.md` | Current session state |
| `silo-lexicon.jsonl` | Conceptual tokens |
| `briefs/BRIEFS-ROADMAP.md` | Project roadmap |
| `debriefs/` | Lessons learned |
| `playbooks/` | How-to guides |
