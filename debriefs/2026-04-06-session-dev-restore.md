# Debrief: 2026-04-06 — Dev Session: EPIC 1.5-1.9, 2.3, 3.2-3.3

**Session:** ses_36ceb0
**Agent:** zed_5275
**Duration:** Single session (restored td, then implemented 8 EPICs)
**Branch:** dev

---

## What We Did

1. **Restored td task management** — Fixed SQLite WAL lock issue by symlinking `.todos/` → `~/.config/.todos/`
2. **Implemented 8 EPICs** across EPIC-1, EPIC-2, and EPIC-3

### Deliverables

| EPIC | Feature | Files |
|------|---------|-------|
| 1.5 | Data Stratification | `.gitignore`, `stratify` command, manifest metadata |
| 1.6 | `_silo` naming | `--private` flag, `visibility` field |
| 1.7 | JSONL Audit Trail | `audit_log.sh`, audit commands |
| 1.8 | Workspace Lock | `workspace_lock.sh`, lock/unlock/check |
| 1.9 | Markdown-as-UI | `render_status.sh`, README injection |
| 2.3 | SSE Streaming | `/stream/*` endpoints in API server |
| 3.2 | Sparklines | ASCII throughput charts |
| 3.3 | Three-Speed Monitoring | Fast/medium/slow health checks |

---

## Key Decisions

### 1. Symlink workaround for td database
**Problem:** `td init` created `db.lock` but failed to write `issues.db`

**Solution:** 
```bash
rm -rf .todos && ln -s ~/.config/.todos .todos
```

**Status:** Works, but shouldn't need this. Root cause is unclear.

### 2. Shell script isolation
**Decision:** Complex bash logic moved to separate scripts (`workspace_lock.sh`, `audit_log.sh`, etc.)

**Rationale:** Justfile is for orchestration, not computation. Scripts are testable, reusable.

### 3. Scaffold vs Throughput stratification
**Decision:** Explicit naming in `.silo["#meta"]["stratification"]`

**Rationale:** Makes the contract explicit. Agents don't guess.

---

## Lessons Learned

### 1. TD SQLite WAL Corruption is Real
**Observation:** Concurrent access (agent + GitHub sidecar) causes WAL lock failures.

**Pattern:** Works in isolation, fails under load.

**Action:** Document in td-playbook. Investigate td source for SQLite config.

### 2. Justfile Token Parsing is Strict
**Observation:** Default parameters with `.` in them (e.g., `filter=(.event)`) cause parse errors.

**Workaround:** Rename to avoid `.` or use separate scripts.

**Action:** This is a just limitation. Avoid `.` in recipe parameter names.

### 3. Templates Must Be Valid JSON/Shell
**Observation:** `.silo` template had duplicate `#meta` keys, causing parse failures.

**Action:** Always validate (`jq empty`) before committing template changes.

### 4. Root Directory UX Matters
**Observation:** Running `just` in project root did nothing.

**Decision:** Added root `justfile` with `info`, `status`, `readme`, etc.

**Principle:** The filesystem is the interface. Even the project root should be informative.

### 5. Commit Frequently, Review Infrequently
**Pattern:** Commits per EPIC, reviews batched at session end.

**Works because:** EPICs are small enough to review holistically.

---

## Unresolved Issues

| Issue | Status |
|-------|--------|
| td WAL lock during rapid `td add` | Intermittent, worked around |
| td source lacks SQLite config section | Needs investigation |
| Briefs orphaned (20+ stale) | Needs reconciliation with td backlog |
| Multi-agent handoffs untested | Infrastructure exists, not stress-tested |

---

## Retrospective Questions

**What went well?**
- td session → EPIC → review → commit rhythm was productive
- 8 EPICs in one session shows the scaffold is stable
- Shell script isolation prevented justfile bloat

**What could be better?**
- td WAL locks interrupted flow (3-4 failures during session)
- Briefs aren't synced with td backlog
- No automated validation of template changes

**What will we try next time?**
- Investigate td SQLite config (see action item below)
- Add `just validate-template` to catch JSON errors early
- Sync briefs to td or archive them

---

## Action Items

| Item | Owner | Priority |
|------|-------|----------|
| Investigate td SQLite WAL config | Agent | P2 |
| Add `just validate-template` to silo-create | Agent | P3 |
| Reconcile briefs with td backlog | Agent | P3 |
| Test multi-agent handoffs | Agent | P4 |

---

## Related

- [td-playbook.md](../playbooks/td-playbook.md) — Updated with SQLite issue
- [2026-04-06-brief-dev-cycle.md](../briefs/2026-04-06-brief-dev-cycle.md) — Dev cycle brief
