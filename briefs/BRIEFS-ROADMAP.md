# Just-Silo Roadmap

## Status

- **v0.1** — RELEASED ✅
- **v0.2** — RELEASED ✅ (2026-04-07)
- **v0.3** — Planned (Gamma Loops)
- **v1.0** — Future

---

## Internal Agents

| Agent | Task | Status |
|-------|------|--------|
| `tidy-first-agent` | Workspace hygiene | ✅ Implemented |
| `pr-review-agent` | AI PR review monitoring | ✅ Implemented |

---

## v0.1 — Released (2026-04-06)

| Deliverable | File | Tests |
|------------|------|-------|
| Template system | `templates/basic/` | ✅ |
| Silo create/ignite | `scripts/silo-*` | ✅ 17 tests |
| Unit tests | `src/*.test.ts` | ✅ 12 tests |
| Mentational Hygiene | `AGENTS.md` | ✅ |
| Secrets playbook | `playbooks/secrets-playbook.md` | ✅ |
| TD RAM disk | `scripts/td-ramdisk-setup.sh` | ✅ Smoke test passed |

---

## v0.2 — Released (2026-04-07)

**Focus:** UX improvements — streaming, visualization, lexicon.

### Deliverables

| # | Brief | Description | Tests | Status |
|---|-------|-------------|-------|--------|
| 1 | `brief-silo-streaming.md` | SSE for real-time telemetry | ✅ `src/silo-api-server.test.ts` | ✅ Released |
| 2 | `brief-sparklines.md` | ASCII throughput graphs | ✅ `src/sparkline.test.ts` | ✅ Released |
| 3 | `brief-silo-conceptual-lexicon.md` | Lexicon mount on `cd` | ✅ `src/silo-lexicon.test.ts` | ✅ Released |

**Test coverage:** 68 tests across 3 test files

### After High Priority

| # | Brief | Description | Effort | Status |
|---|-------|-------------|--------|--------|
| 4 | User guide | `docs/user-guide.md` | Medium | TODO |

---

## v0.3 — Planned

**Focus:** Self-modifying silos.

| Epic | Briefs | Effort |
|------|--------|--------|
| EPIC-4: Gamma Loops | `brief-silo-gamma-loop.md`, `brief-gamma-loop-01.md`, `brief-gamma-loop-02.md`, `brief-gamma-loop-03.md` | Medium |

---

## Future (v1.0+)

| Epic | Briefs | Notes |
|------|--------|-------|
| EPIC-5: Isolation | 9 briefs | Multi-tenant, security |
| EPIC-6: Documentation | User + dev guides | After v0.2 |
| EPIC-7: Blog | 2 briefs | After EPIC-6 |
| EPIC-8: Strategy | 20+ briefs | Long-term |

---

## Agent Briefs

Briefs for agent implementation in `briefs/research/`:

| Brief | Agent | Purpose |
|-------|-------|---------|
| `brief-tidy-first-01-ansi-cleanup.md` | tidy-first-agent | ASCII cleanup task |

---

## Archived Research

These briefs are **research artifacts**, not deliverables. Archived to `briefs/archive/`:

### Register Silo (19 briefs)
Research on how silos register themselves. Mostly exploratory.

### Blog Content (2 briefs)
Content strategy, not implementation.

### Strategy (20+ briefs)
Long-term vision, reference only.

---

## Quick Commands

```bash
# Development
just dev-check     # Prerequisites
just dev-tests     # All tests
just silo-verify  # Silo prerequisites
just lex           # Show lexicon

# TD
just td-ramdisk    # Setup RAM disk
just td-status     # Check status
just td-test       # Smoke test
just td-report     # Markdown report

# Docs
just agent-ops     # Agent ops playbook
just docs          # Browse docs
```

---

## Issue Tracking

Active issues tracked in `td`:
```bash
td list        # All issues
td in-review   # Awaiting review
td status      # Dashboard
```
