# Debrief: TD RAM Disk Setup Session

**Date:** 2026-04-07  
**Duration:** ~1.5 hours  
**Participants:** Human + AI Agent  
**Branch:** dev

---

## What We Did

1. **Identified the problem** — SQLite WAL corruption in td database
2. **Proposed solution** — RAM disk for ephemeral td database
3. **Investigated td architecture** — Discovered it uses `.todos/` directory with `issues.db`
4. **Set up RAM disk** — Created `/Volumes/TD-RAMDisk` (512MB)
5. **Integrated with sidecar** — Created `td-root` file pointing to RAM disk
6. **Created tooling** — Setup script, smoke test, markdown reporter
7. **Documented everything** — Playbook, repos doc, justfile commands

---

## What Worked

| Item | Result |
|------|--------|
| RAM disk creation | ✅ Immediate |
| Symlink strategy | ✅ Clean separation |
| Smoke test | ✅ Passed all 12 steps |
| Sidecar integration | ✅ `td-root` file works |
| Markdown report | ✅ Functional |

---

## What Was Tricky

### 1. TD Init Failure Mode

**Problem:** `td init` created `db.lock` but not `issues.db`. No error visible.

**Discovery:** The SQLite database was being created with 0 bytes — silent failure.

**Lesson:** When `td init` "succeeds" but no `issues.db` appears, something is wrong. Check with `sqlite3 .todos/issues.db "SELECT 1"`.

### 2. TD Command Syntax

**Problem:** Initial smoke test used wrong syntax (`td <id> log` instead of `td log <id>`).

**Discovery:** td uses positional args differently than expected:
- `td log <id> "message"` — log to specific issue
- `td log "message"` — log to focused issue

**Lesson:** Read the help carefully. The pattern is `td <command> [target] [args]`, not `<target> <command>`.

### 3. Dependencies Are Hard

**Problem:** We didn't initially know where td stores its database or how sidecar finds it.

**Discovery:** 
- td uses `ResolveTDRoot()` to find database
- Reads `td-root` or `.td-root` file
- Falls back to local `.todos/` directory

**Lesson:** Clone and read the source. It's faster than guessing.

### 4. Self-Review Prevention

**Problem:** Couldn't approve our own smoke test issues.

**Discovery:** td prevents self-review. Use `--self-close-exception "reason"` to bypass.

**Lesson:** This is a feature, not a bug. But useful for test cleanup.

---

## Key Decisions Made

| Decision | Rationale |
|----------|-----------|
| 512MB RAM disk | Ample for td workload (~12MB observed) |
| Project-level symlink | Each project has own .todos on RAM disk |
| Ephemeral by default | We use td for ops, not archival |
| Sidecar `td-root` | Needed for sidecar to find database |

---

## What Survives RAM Disk Loss

| Source | Survives? | Notes |
|--------|-----------|-------|
| Git history | ✅ Yes | Commit messages, diffs |
| Briefs/debriefs | ✅ Yes | Project directory |
| Playbooks | ✅ Yes | Project directory |
| td issues | ❌ No | On RAM disk |
| td sessions | ❌ No | On RAM disk |
| Handoffs | ❌ No | On RAM disk |

**Acceptable trade-off.** Work exists in git. Briefs are the authoritative record.

---

## Future Considerations

1. **Persistence** — Snapshot `issues.db` to disk periodically if analytics needed
2. **LaunchAgent** — Auto-mount RAM disk on login (`--install-launchd`)
3. **Cross-session continuity** — Restore previous session state after reboot

---

## Metrics

- **Issues created:** 6 (smoke test + cleanup)
- **Commands run:** ~40
- **Scripts created:** 3
- **Lines changed:** ~567
- **Time to stable:** ~1 hour

---

## Lessons for Future Sessions

1. **Read the source, Luke.** Don't guess at behavior. Clone the repo.
2. **Smoke tests pay off.** Better to discover issues in a script than in production.
3. **RAM disks are underused.** Ephemeral data (cache, indexes, runtime state) belongs in RAM.
4. **Document as you go.** The playbook and debrief serve the next session.
5. **Ephemeral is a feature.** Not everything needs to persist. Design for loss.

---

## Related

- `playbooks/td-playbook.md` — Full td operations guide
- `playbooks/agent-ops-playbook.md` — Agent coordination guide
- `REPOS.md` — External dependencies
- `scripts/td-ramdisk-setup.sh` — Setup script
