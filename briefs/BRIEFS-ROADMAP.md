# Just-Silo Roadmap — v0.1 (2026-04-06)

## Status: RELEASED ✅

v0.1.0 is released. Core infrastructure complete and tested.

---

## Delivered in v0.1

| Deliverable | File | Tests |
|------------|------|-------|
| Template system | `templates/basic/` | ✅ |
| Silo create/ignite | `scripts/silo-*` | ✅ 17 tests |
| Unit tests | `src/*.test.ts` | ✅ 12 tests |
| API server | `src/silo-api-server.ts` | ✅ |
| Mesh | `src/silo-mesh.ts` | ✅ |
| Dashboard | `src/silo-dashboard.ts` | ✅ |
| Justfile | `justfile` | ✅ Namespace-prefixed |
| Silo Lexicon | `silo-lexicon.jsonl` | ✅ 12 tokens |
| Mentational Hygiene | `AGENTS.md` | ✅ |
| Secrets playbook | `playbooks/secrets-playbook.md` | ✅ |

---

## v0.2 Backlog

### High Priority

| Brief | Description | Effort |
|-------|-------------|--------|
| `briefs/2026-04-04-brief-silo-streaming.md` | SSE for real-time telemetry | Low |
| `briefs/2026-04-04-brief-sparklines.md` | ASCII throughput graphs | Low |
| `briefs/2026-04-06-brief-silo-conceptual-lexicon.md` | Lexicon integration | Low |

### Medium Priority

| Brief | Description | Effort |
|-------|-------------|--------|
| EPIC-4: Gamma Loops | Self-modifying silos | Medium |
| EPIC-6: Documentation | User guide, developer guide | Medium |

### Lower Priority (Future)

| Epic | Briefs | Notes |
|------|--------|-------|
| EPIC-5: Isolation | 9 briefs | When needed |
| EPIC-7: Blog | 2 briefs | After EPIC-6 |
| EPIC-8: Strategy | 20+ briefs | Long-term |

---

## Archived (Not Needed for v0.1)

Moved to `briefs/archive/`:

- `2026-04-04-nrief-silo-local-remote.md` (typo)
- `2026-04-02-brief-edinburgh-eval.md.md` (double extension)
- PDF markdown briefs (12 files)
- Various outdated briefs

---

## Quick Commands

```bash
just dev-check     # Prerequisites
just dev-tests     # All tests
just silo-verify  # Silo prerequisites
just lex           # Show lexicon
```

---

## Next Steps

1. [ ] **SSE Streaming** — Real-time status
2. [ ] **Sparklines** — ASCII graphs
3. [ ] **Lexicon mount** — Agent reads on `cd`
4. [ ] **User guide** — `docs/user-guide.md`

---

## Deprecated Statuses

These brief statuses are now outdated:
- PLANNING → CONCEPT (many were never planned)
- IMPLEMENTATION → DONE or ARCHIVED

The roadmap is now simplified: **v0.1 delivered, v0.2 backlog above.**
