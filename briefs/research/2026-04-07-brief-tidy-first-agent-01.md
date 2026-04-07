# Brief: tidy-first-agent — Workspace Hygiene Automation

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P2  

---

## Problem Statement

Tidy-first is a good practice but requires manual discipline. Agents and humans forget. The workspace accumulates noise over time:
- Old briefs that should be archived
- Stale td issues left open
- Git branches that should be pruned
- Playbooks that drift from code

We identified the pattern, documented it in `playbooks/tidy-first-playbook.md`, and now need an agent to enforce it.

---

## Pattern: Playbook → Agent

```
Identify practice → Document in playbook → Provision agent with CSP
```

**The playbook IS the CSP spec.** The agent reads the playbook and executes it.

---

## Proposed Solution

**tidy-first-agent** watches for tidiness triggers and acts:

1. **Auto-tidy:** Routine, reversible cleanup
2. **Brief-gen:** Complex decisions need human input

---

## Trigger Architecture

### File-System Triggers

| Pattern | Trigger | Action |
|---------|---------|--------|
| `briefs/*.md` > 30 files | Archive check | Auto-archive pre-sprint |
| `debriefs/*.md` > 20 files | Archive check | Archive old debriefs |
| `playbooks/*.md` modified | Doc drift | Flag for docs-agent |
| `src/*.ts` modified | Code change | Increment dirty flag |

### Cron Schedules

| Schedule | Purpose |
|----------|---------|
| Every morning (8am) | Daily tidy check |
| Every Monday (9am) | Weekly deep clean |
| On push to main | Post-deploy tidy |

### On-Demand

```bash
# Human requests tidy
tidy-first-agent run --full

# Agent recommends
tidy-first-agent recommend
```

---

## Auto-Tidy Actions

These are routine, reversible, safe to automate:

| Action | Condition | Safety |
|--------|-----------|--------|
| Archive old briefs | Date < current sprint | ✅ Reversible (git) |
| Archive old debriefs | Date < current sprint | ✅ Reversible |
| Close stale td issues | No activity > 14 days, status=closed | ✅ Documented |
| Prune merged git branches | Already on main | ✅ Standard practice |
| Update file counts | Marker files | ✅ Metadata only |

---

## Brief-Gen Actions

These need human judgment:

| Action | Condition | Creates Brief |
|--------|-----------|---------------|
| Archive mid-sprint items | Human decision needed | "Archive decision: X" |
| Close complex td issues | Blocked, uncertain | "Resolve: td-XXX" |
| Major refactor | Significant change | "Refactor: X" |
| Docs update needed | Complex drift | Triggers docs-agent |

---

## CSP Specification

The CSP reads `playbooks/tidy-first-playbook.md` and follows its rules:

```markdown
## tidy-first-agent CSP

### Mission
Keep workspace clean without blocking productive work.

### Decision Tree

```
Is it routine?
  YES → Is it reversible?
    YES → Auto-tidy
    NO  → Create brief
  NO  → Create brief
```

### Thresholds
- Briefs: Archive when > 30 files or pre-sprint
- Debriefs: Archive when > 20 files or > 30 days old
- td issues: Flag when stale > 7 days
- Git branches: Prune when merged

### Constraints
- Never delete, only archive/move
- Always git add + commit after tidy
- Log all actions to td
- Create briefs for irreversible decisions
```

---

## File Structure

```
agents/
└── tidy-first-agent/
    ├── CSP.md              # Agent specification (this brief refined)
    ├── src/
    │   ├── index.ts        # Entry point
    │   ├── archiver.ts     # Brief/debrief archiving
    │   ├── td-cleaner.ts   # Stale issue management
    │   ├── branch-pruner.ts # Git branch cleanup
    │   └── brief-maker.ts   # Generate decision briefs
    ├── schedules/
    │   ├── daily.tidy      # Cron: 0 8 * * *
    │   ├── weekly.tidy     # Cron: 0 9 * * 1
    │   └── on-push.tidy    # Git hook
    ├── justfile
    └── README.md
```

---

## User Interface

### Commands

```bash
tidy-first-agent check          # Check current state
tidy-first-agent run            # Run auto-tidy
tidy-first-agent run --full    # Run full tidy (including brief-gen)
tidy-first-agent recommend      # Show recommendations
tidy-first-agent status         # Show tidy metrics
```

### td Integration

```bash
# On auto-tidy:
td log "tidy-first: Archived 12 old briefs" --result

# On brief needed:
td add "Decision: Archive mid-sprint items?" --priority P3
td log "tidy-first: Needs human decision" --blocker
```

---

## Integration with Other Agents

```
tidy-first-agent
    │
    ├── on stale docs → docs-agent (flag)
    ├── on auto-tidy → review-agent (optional review)
    ├── on brief-gen → briefs-agent (create brief)
    └── on close issues → review-agent (verify)
```

---

## Acceptance Criteria

- [ ] Reads `playbooks/tidy-first-playbook.md` as CSP
- [ ] Archives old briefs when threshold exceeded
- [ ] Archives old debriefs when threshold exceeded
- [ ] Flags stale td issues (> 7 days)
- [ ] Creates briefs for complex decisions
- [ ] Runs on cron schedule
- [ ] Logs actions to td
- [ ] Commits changes to git
- [ ] Playbook documents usage

---

## Priority Rationale

P2: Valuable quality-of-life improvement but doesn't block feature delivery. Lower than test-agent and review-agent which affect code quality.

---

## Related

- `playbooks/tidy-first-playbook.md` — CSP specification source
- `briefs/research/2026-04-07-brief-briefs-agent-01.md` — briefs-agent (generates briefs)
- `briefs/research/2026-04-07-brief-test-agent-01.md` — test-agent
- `briefs/research/2026-04-07-brief-review-agent-01.md` — review-agent
