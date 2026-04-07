# Playbook: Agent & User Operations

**How humans and AI agents should work together using td.**

---

## Core Principle

> **td is for coordination, not archival.** Work lives in git. Briefs are the authoritative record. td helps us not step on each other.

---

## User Operations

### First-Time Setup

```bash
# 1. Verify prerequisites
just dev-check

# 2. Set up td on RAM disk
just td-ramdisk

# 3. Start a session
td usage --new-session

# 4. Verify it's working
just td-status
```

### Daily Workflow

```bash
# Morning: Start fresh session
td usage --new-session

# Check what's on your plate
td status
td next        # Highest priority issue

# Work on an issue
td start <id>
# ... do work ...
td log "Did the thing" --result

# Blocked?
td log "Waiting on API spec" --blocker

# Need review?
td handoff <id> --done "Work done" --remaining "Testing"

# Check others' work
td in-review
td review <id>

# Generate report for standup
just td-report
```

### Closing Your Session

```bash
# Check for pending reviews
td check-handoff  # Returns error if handoffs pending

# Commit your work
git add -A
git commit -m "feat: ..."

# Done
```

---

## Agent Operations

### Agent Entry Point

Every agent should start with:

```bash
cd /path/to/project
td usage --new-session  # Mandatory first command
```

This establishes session identity for review tracking.

### Agent Workflow

```
1. Entry:     td usage --new-session
2. Status:    td status (read SESSION-STATE.md first)
3. Assign:    td start <issue-id>
4. Work:      td log progress --result
5. Blocked:   td log "waiting on..." --blocker
6. Handoff:   td handoff <id> --done X --remaining Y
7. Exit:      git commit && td check-handoff
```

### Multi-Agent Coordination

```
┌─────────────────────────────────────────┐
│ Agent A (Builder)                       │
│   td start td-123                       │
│   ... builds ...                        │
│   td log "Implemented feature"          │
│   td handoff td-123                     │
└─────────────────────────────────────────┘
                  ↓ Handoff created
┌─────────────────────────────────────────┐
│ Agent B (Reviewer)                      │
│   td review td-123                      │
│   ... tests ...                         │
│   td approve td-123   OR  td reject     │
└─────────────────────────────────────────┘
```

### Agent Session Identity

Agents are identified by session ID. This prevents self-review:

```bash
td whoami          # Shows current session
td show <id>       # Shows who implemented/reviewed
```

**Rule:** You cannot approve your own work. Get a second pair of eyes.

### Sub-Agent Pattern

For complex work, spawn sub-agents:

```bash
# Parent agent
td start td-456
td log "Spawning sub-agent for auth module" --result

# Sub-agent
td start td-456
td log "Working on auth..." --result
td handoff td-456

# Parent resumes
td review td-456
td log "Approved sub-agent work" --decision
```

### Agent Failure Recovery

If the agent crashes or RAM disk is lost:

```bash
# 1. Check git — work is there
git status
git diff

# 2. Re-read brief/debrief for context
ls briefs/
cat briefs/latest.md

# 3. Re-establish session
td usage --new-session

# 4. Continue work
td start <id>  # or create new issue
```

---

## Shared Patterns

### Pattern: Log Decisions

```bash
# When you make a choice
td log "Chose PostgreSQL over MongoDB for ACID compliance" --decision
```

Later agents know **why**, not just **what**.

### Pattern: Document Blockers

```bash
# Don't just be blocked, document why
td log "API vendor hasn't responded in 3 days" --blocker
```

Blockers surface early, before they cascade.

### Pattern: Structured Handoffs

```bash
td handoff <id> \
  --done "API client implemented" \
  --remaining "Integration tests" \
  --decision "Using REST over gRPC for simplicity" \
  --uncertain "Error handling edge cases"
```

---

## Quick Reference

| Situation | Command |
|-----------|---------|
| Start session | `td usage --new-session` |
| What's on my plate | `td status` |
| Start an issue | `td start <id>` |
| Log progress | `td log "Did X" --result` |
| Log decision | `td log "Chose Y" --decision` |
| Log blocker | `td log "Waiting on Z" --blocker` |
| Hand off | `td handoff <id>` |
| Check reviews | `td in-review` |
| Review | `td review <id>` |
| Approve | `td approve <id>` |
| Close own work | `td close <id> --self-close-exception "reason"` |
| Generate report | `just td-report` |

---

## Troubleshooting

### "No focused issue"
```bash
td start <id>
# or
td next
```

### "Cannot approve issue I implemented"
Get someone else to review, or use:
```bash
td close <id> --self-close-exception "reason"
```

### "RAM disk gone" (after reboot)
```bash
just td-ramdisk
td usage --new-session
```

### "td database corrupted"
```bash
just td-reset
td usage --new-session
```

### Session diverged from reality
```bash
td usage --new-session
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | Instead |
|-------------|---------|---------|
| Skip `td usage --new-session` | No session identity | Always run it |
| Self-approve | Defeats review purpose | Get review |
| Log only results | No context for others | Log decisions, blockers |
| Close without handoff | Others don't know status | Always handoff |
| Work without td | Collision risk | Use td from start |

---

## Related

- [TD Playbook](td-playbook.md) — Full td operations
- [Edinburgh Protocol](edinburgh-protocol-playbook.md) — Decision framework
- [Briefs/Debriefs Pattern](briefs-playbook.md) — Pre/post work docs
