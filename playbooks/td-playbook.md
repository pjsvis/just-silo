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
Use `--minor` for trivial changes: `td add "Fix typo" --minor`

### Session diverged from reality
```bash
td usage --new-session
td context <issue-id>   # Restore context for an issue
```

---

## Related

- [Edinburgh Protocol Playbook](edinburgh-protocol-playbook.md) — Decision framework
- [Briefs/Debriefs Pattern](briefs-playbook.md) — Pre/post work documentation
