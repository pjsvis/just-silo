# Playbook: td — Local-First Task Management

**Essential context, process, and agent coordination tool.**

---

## Why td?

We use `td` because:

1. **Context preservation** — Sessions track work across agent invocations. No "where was I?"
2. **Process visibility** — Issues, handoffs, and reviews make the workflow explicit
3. **Agent coordination** — Multiple agents can work in the same issue space without collision
4. **Local-first** — SQLite in `~/.config/.todos/`. No server, no sync, no vendor lock-in

> We miss it when it's not there. It's that fundamental.

---

## Core Concepts

| Concept | Purpose |
|---------|---------|
| **Issue** | A unit of work. Has ID, title, tags, priority, status |
| **Session** | A work context. Tracks who did what, when |
| **Workspace** | Groups issues for a project or sprint |
| **Handoff** | Captures state when transitioning between agents |
| **Review** | Formal approval before closing |

---

## Essential Commands

```bash
# Start a new session (do this at conversation start)
td usage --new-session

# Create an issue
td add "Implement user auth" --tags auth,backend --priority P1

# Start working
td start <issue-id>

# Log progress
td log "Implemented login endpoint" --result

# Blocked on something?
td log "Waiting for API spec" --blocker

# Mark a decision
td log "Using JWT for auth tokens" --decision

# Done with your part, need review
td handoff <issue-id>
td review <issue-id>

# Someone else reviews and approves
td approve <issue-id>   # Complete
# or
td reject <issue-id>     # Send back
```

---

## Multi-Agent Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ Agent A (Builder)                                               │
│   td add "Build user service" --priority P1                    │
│   td start td-123                                              │
│   ... builds ...                                                │
│   td log "Service complete" --result                            │
│   td handoff td-123                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Agent B (Operator) — reviews, tests, deploys                    │
│   td review td-123        # Agent A's handoff                   │
│   ... tests ...                                                  │
│   td approve td-123       # Complete the issue                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Session Management

```bash
# New session (clears context tracking)
td usage --new-session

# Label current session
td session "sprint-42"

# View current state
td ws current

# Handoff entire workspace
td ws handoff

# Next priority issue
td next

# Critical path analysis
td critical-path
```

---

## Issue Lifecycle

```
     ┌─────────┐
     │  TODO   │ ← td add
     └────┬────┘
          │ td start
          ↓
     ┌─────────┐
     │ IN PROG │ ← td log (progress, blockers, decisions)
     └────┬────┘
          │ td handoff
          ↓
     ┌─────────┐
     │ REVIEW  │ ← td review
     └────┬────┘
          │ td approve / td reject
          ↓
     ┌─────────┐
     │ DONE    │ ← Complete
     └─────────┘
```

---

## Priority Levels

| Priority | Use |
|----------|-----|
| `P0` | Blocker — everything stops |
| `P1` | This sprint — critical path |
| `P2` | Next — important but can wait |
| `P3` | Backlog — nice to have |

---

## Tags

Tags are free-form. Conventions we use:

- `just-silo` — Just-silo related work
- `infra` — Infrastructure
- `docs` — Documentation
- `bug` — Bug fix
- `feat` — New feature
- `refactor` — Code improvement
- `review` — Needs review

---

## Tips

### Start every session fresh
```
td usage --new-session
```
This establishes session identity for review tracking.

### Log decisions, not just progress
```bash
td log "Chose PostgreSQL over MySQL" --decision
```
Later agents know *why*, not just *what*.

### Use blockers sparingly but honestly
```bash
td log "API spec not ready" --blocker
```
Blocks surface early, before they cascade.

### Handoff with context
```
td handoff <issue-id>
```
Include: what was done, what's left, known unknowns.

---

## Integration with just-silo

```
td-issue/
├── justfile          # td integration recipes
├── issues/           # Issue state (gitignored)
│   └── td-123.jsonl  # Handoffs and logs
└── .silo             # Silo manifest
```

### Example justfile integration

```just
# Start working on an issue
start id:
    @td start {{id}}
    @echo "Started: $(td show {{id}} --title)"

# Log progress
log msg:
    @td log "{{msg}}" --result

# Hand off for review
handoff id:
    @td handoff {{id}}

# Check status
status:
    @td current
    @td ws current
```

---

## Troubleshooting

### "No focused issue"
```bash
td start <issue-id>
# or
td ws start "my-workspace"
```

### "Cannot approve issue I implemented"
Correct. External review prevents self-review bias.
Close with self-close exception: `td close <issue-id> --self-close-exception "Reason"`

### Session diverged from reality
```bash
td usage --new-session
td context <issue-id>   # Restore context for an issue
```

### "database is locked" or "database malformed"

**Root Cause:** SQLite WAL corruption.

**Solution:** RAM disk (see above). If not using RAM disk:

1. **Reset database:**
```bash
just td-reset
```

2. **Or manually:**
```bash
rm -rf .todos
./scripts/td-ramdisk-setup.sh .
```

---

## Testing

### Smoke Test

Run the full workflow test:
```bash
just td-test
```

This tests 12 steps:
1. Initialize
2. Create issues
3. Start work
4. Log progress
5. Block issues
6. Create dependencies
7. List issues
8. Check blocked
9. Check dependencies
10. Status check
11. Handoff
12. Review submission

**Status:** ✅ Passed — all 12 steps verified working.

---

## RAM Disk Strategy: Eliminating SQLite Corruption

**Problem:** SQLite WAL corruption under concurrent access. Database breaks periodically.

**Solution:** Mount td database directory as a RAM disk.

**Rationale:** We use td for operations but do not require persistence. The database is a runtime index, not a source of truth.

### Quick Setup

```bash
# Use the setup script (recommended)
just td-ramdisk

# Or manually:
./scripts/td-ramdisk-setup.sh .
```

### Recovery Commands

```bash
just td-reset    # Reset and reinitialize td database
just td-status   # Check td status + RAM disk usage
```

---

## Mid-Workflow Failure Analysis

### What Happens If RAM Disk Goes Down

| Failure Mode | Impact | Recovery |
|-------------|--------|----------|
| **Reboot** | All state lost | `just td-ramdisk` to reinitialize |
| **RAM pressure** | OS may evict RAM disk | Same as reboot |
| **Panic/crash** | Partial writes may corrupt | `td init` fails, use backup or reset |

### What Survives the Failure

| Source | Survives RAM Disk Loss? |
|--------|-------------------------|
| Git history | ✅ Yes — commit messages, diffs |
| `command_usage.jsonl` | ❌ No — on RAM disk |
| Issues database | ❌ No — on RAM disk |
| Sessions | ❌ No — on RAM disk |
| Briefs/debriefs | ✅ Yes — in project directory |
| Playbooks | ✅ Yes — in project directory |

### Agent/Sub-Agent Workflow Impact

Since we use td to manage agent and sub-agent progress:

```
Agent A: starts td-123 → works → td handoff
Agent B: td review → works → td approve
```

**If RAM disk dies mid-workflow:**
- Agent A's progress is lost (but work exists in git)
- Agent B cannot see the handoff (must ask or infer)
- Session IDs are reset

**Mitigation:** Briefs and debriefs. Agents document state there.

### Our Stance

**Acceptable.** The database is operational (coordination), not archival (history).

- Work exists in git
- Decisions exist in briefs/debriefs
- td gives us "in the moment" coordination

If we need persistence, we can snapshot to disk (see below).

---

## Persistence Option (Optional)

If you want to snapshot the database periodically:

```bash
#!/bin/bash
# ~/.local/bin/td-snapshot.sh
BACKUP_DIR="$HOME/.local/share/td-backups"
mkdir -p "$BACKUP_DIR"
cp .todos/issues.db "$BACKUP_DIR/td-$(date +%Y%m%d-%H%M%S).db"
# Keep last 10 snapshots
ls -t "$BACKUP_DIR"/td-*.db | tail -n +11 | xargs rm -
```

Run via cron or login script if you want history.

---

## Assessment: Potential Uses of td Database

### Current Usage (Ops Layer)

| Use | Value | Persistence Required? |
|-----|-------|------------------------|
| Issue tracking | High — coordination tool | No |
| Session management | Medium — context continuity | No |
| Review workflow | High — prevents self-review bias | No |
| Agent coordination | High — prevents collision | No |

### Potential Future Uses (If We Chose to Persist)

| Use Case | Effort | Opinion |
|----------|--------|---------|
| **Time tracking** — log hours per issue | Low | Valuable. We already log progress; add `--hours` flag. |
| **Sprint velocity** — issues completed per week | Low | Useful for retrospectives. |
| **Review turnaround** — handoff → approve latency | Low | Good ops metric. |
| **Agent performance** — error rates, retry counts | Medium | Interesting but requires td schema changes. |
| **Knowledge graph** — issue relationships | High | Overkill. Git + briefs already cover this. |
| **Cross-session continuity** — resume after reboot | Medium | Nice-to-have, but RAM disk makes this moot. |

### Recommendation

**Keep td ephemeral for now.** The potential uses above are "nice to have" but not essential. The current RAM disk setup gives us:

- Zero corruption risk
- Fast I/O
- Clean state on reboot

If we later want persistence for time tracking or velocity metrics, we can:

1. Add a `td snapshot` command that exports to `~/.local/share/td-history/`
2. Parse `command_usage.jsonl` for metrics (already persists to disk)
3. Keep runtime ops in RAM, archive analytics separately

**Principle:** The database should do one thing well (coordination) without carrying the weight of historical analytics.

---

## Lessons Learned: The Database Is Ephemeral

> **TL;DR:** td is restartable and idempotent. The SQLite database is a convenience, not the source of truth.

### The Insight

```
Without td: Hard to automate coordination
With td:    Can do things
```

td is a **runtime orchestration tool** — it enables agents to self-organize tasks, track progress, and hand off work. It has value *because it exists*, not because it persists.

### What We Lose When the DB Corrupts

| Loss | Impact |
|------|--------|
| Review workflow state machine | Can work around: `td review` → `td approve` chain breaks |
| Session → Issue linkage | Can work around: git blame is noisier but complete |
| Priority ordering | Can work around: implicit in git log order |
| Structured queries | Can work around: `git log`, grep, manual search |

### What Survives

| Source | What It Contains |
|--------|------------------|
| `~/.config/.todos/command_usage.jsonl` | Every command executed (entropy signals) |
| `~/.config/.todos/agent_errors.jsonl` | Failures, dead ends, recovery paths |
| `git history` | What changed, when, commit messages |
| Pipeline audit logs | Events, decisions, state transitions |

**The logs ARE the audit trail.** The SQLite database adds "who to credit/blame" — valuable for social coordination, not essential for entropy quantification.

### The Idempotency Property

```bash
# Fresh start
td init
td usage --new-session

# Or symlink to global DB (if exists)
ln -sf ~/.config/.todos .todos
```

If `.todos/` corrupts:
1. `rm -rf .todos` (local symlink)
2. `td init` (recreates fresh DB)
3. Continue

**No work is lost** — the work exists in git and logs. We just lose the *index* into it.

### Decision Framework

```
Is td working?          → Use it
Is td failing often?    → Consider alternatives
Is td completely gone?  → Use git + logs as fallback
```

**Rule:** td serves the work. The work does not depend on td.

### Practical Guideline

| Situation | Action |
|-----------|--------|
| td works | Use it normally |
| "database locked" | Retry, or symlink to `~/.config/.todos/` |
| "database malformed" | `td init` fresh, continue |
| td completely unavailable | Work in git + logs, re-index later if needed |

---

## Related

- [Edinburgh Protocol Playbook](edinburgh-protocol-playbook.md) — Decision framework
- [Briefs/Debriefs Pattern](briefs-playbook.md) — Pre/post work documentation
- [Debrief: td RAM disk setup](../debriefs/2026-04-07-td-ramdisk-setup.md) — Session debrief with lessons learned
- [Agent Ops Playbook](agent-ops-playbook.md) — Human/agent coordination
