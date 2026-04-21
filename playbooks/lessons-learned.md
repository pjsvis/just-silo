# Lessons Learned

Collected wisdom from debriefs.

## Debrief: TD RAM Disk Setup Session

*Source: 2026-04-07-td-ramdisk-setup.md (2026-04-07)*

## Lessons for Future Sessions
1. **Read the source, Luke.** Don't guess at behavior. Clone the repo.
2. **Smoke tests pay off.** Better to discover issues in a script than in production.
3. **RAM disks are underused.** Ephemeral data (cache, indexes, runtime state) belongs in RAM.
4. **Document as you go.** The playbook and debrief serve the next session.
5. **Ephemeral is a feature.** Not everything needs to persist. Design for loss.
---

## Debrief: TD RAM Disk + Sparklines Implementation

*Source: 2026-04-07-td-ramdisk-sparklines.md (2026-04-07)*

## Lessons Learned
- **RAM disks are underutilized:** Ephemeral data (cache, indexes, runtime state) belongs in RAM. Eliminates corruption failure modes entirely.
- **Read the source:** When behavior is unclear, clone the repo and grep. Faster than guessing.
- **Smoke tests catch issues early:** Better to discover command syntax issues in a script than in production.
- **Briefs are research cache, not backlog:** 85 briefs with 21 archived. Most were exploratory, not actionable.
- **Ephemeral is a feature:** Not everything needs persistence. Design for loss. Work survives in git, briefs document decisions.
- **Separation of concerns:** CLI tools (`silo-trend`) vs library (`sparkline.ts`) vs UI (`silo-dashboard.ts`)

## Debrief: PXY Presentation System

*Source: 2026-04-08-pxy-presentation-debrief.md (2026-04-08)*

## Lessons Learned
1. **Start simple.** Minimal server worked first. Complexity added later.
2. **Test incrementally.** Each feature tested before adding next.
3. **Browser refresh is the reset.** When in doubt, refresh.
4. **WebSocket > SSE for reliability.** Native ping/pong worth the switch.
5. **Markdown is PXY-friendly.** No HTML escaping headaches.

---

## Lesson: Justfile Shell Escaping

*Source: 2026-04-11 — Integration test failures in templates/basic/justfile*

### The Problem

`just` uses `$$` to escape `$` for shell interpolation. When recipes have complex shell commands, escaping degrades through edits:

```
justfile:  @COUNT=$$(jq -s ...)
becomes:   @COUNT=$(jq -s ...)   # correct in shell

justfile:  @COUNT=$$(jq -s ...) >> {{OUTPUT_FILE}} 2>/dev/null && ...
becomes:   @COUNT=$(...) >> ... && ...       # ERROR: syntax error
```

### Why It Happens

1. **Copy-paste degradation** — templates get modified, escaping gets corrupted
2. **Multi-line confusion** — `\` continuation + variable interpolation = subtle bugs
3. **Test gap** — templates rarely tested end-to-end

### The Fix

**Extract complex shell to scripts.** Keep justfile recipes thin:

```justfile
# BAD: Complex shell in justfile
flush:
    @jq -c 'select(.status == "processed")' {{DATA}} >> {{OUT}} 2>/dev/null || true
    @jq -c 'select(.status != "processed")' {{DATA}} > {{DATA}}.tmp

# GOOD: Thin recipe calls script
flush:
    @./scripts/flush.sh
```

### Rule of Thumb

> If a recipe line is longer than 80 chars or has nested quotes, extract to a script.

### Prevention

1. **Test templates end-to-end** — `scripts/silo-integration-test` catches these
2. **Keep recipes thin** — just orchestrate, scripts do the work
3. **Use `$(...)` not backticks** — clearer, nestable
4. **No `$$` in multi-line recipes** — use separate statements

---

## Lesson: GUI Tools That Hold Git Locks

*Source: 2026-04-10 — GitHub Desktop causing persistent `index.lock` in worktree*

### The Problem

`git add` and `git commit` fail with exit code 137 (SIGKILL) or `fatal: Unable to create index.lock: File exists`. Deleting the lock file doesn't help — it reappears within seconds.

### Why It Happens

GitHub Desktop runs a file watcher that continuously indexes git repos. When it holds `index.lock`, any CLI git command gets blocked or killed. The lock file reappears immediately after deletion because the watcher recreates it.

This is worse with **worktrees** — GUI tools don't always understand worktree semantics, so they may lock the parent repo's index too.

### The Fix

1. Quit the GUI tool
2. `rm -f .git/worktrees/<name>/index.lock`
3. Use `git` from the terminal

Better yet: don't run GUI git watchers alongside CLI git workflows.

### The Deeper Lesson

> **Tools that silently consume resources are the worst kind of problem.** They don't crash — they just make everything else slightly intolerable until you snap.

This is not new. The author once fled to Prague after a VS Code SQL Server add-in silently consumed all available RAM, making the entire development experience progressively worse over days. The add-in didn't error — it just made life unbearable.

These problems share a pattern:
- **Silent resource consumption** — RAM, file locks, CPU, file descriptors
- **Gradual degradation** — not a crash, just slowly worse
- **Blame misdirection** — you blame your code, your tools, your OS — not the quiet background process
- **Relief on removal** — everything works again and you feel slightly foolish

### Rule of Thumb

> If a tool runs a background watcher on your project, it has to coexist with your terminal workflow. If it can't, it has to go.

### Prevention

1. **Don't install GUI git tools on dev machines** — terminal git is sufficient
2. **Check `ps aux | grep git`** when locks appear — something's watching
3. **Add large binaries to `.gitignore`** — GUI indexers choke on 77MB files and get kill-happy
4. **Prague is lovely in spring** — but preferably as a choice, not an escape

---

