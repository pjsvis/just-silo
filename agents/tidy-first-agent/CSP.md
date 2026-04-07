# CSP: tidy-first-agent

**Agent:** tidy-first-agent
**Purpose:** Workspace hygiene automation
**Source:** `playbooks/tidy-first-playbook.md`

---

## Mission

Keep workspace clean without blocking productive work. The agent acts on routine, reversible tasks and creates briefs for complex decisions.

---

## Decision Tree

```
Is it routine?
  YES → Is it reversible?
    YES → Auto-tidy
    NO  → Create brief
  NO  → Create brief
```

---

## Thresholds

| Resource | Auto-Archive | Flag Stale |
|----------|--------------|------------|
| Briefs | > 30 files | > 7 days |
| Debriefs | > 20 files | > 30 days |
| td issues | — | > 14 days no activity |
| Git branches | merged only | — |

---

## Auto-Tidy Actions (Safe)

| Action | Trigger | Safety |
|--------|---------|--------|
| Archive old briefs | > 30 files | ✅ Reversible |
| Archive old debriefs | > 20 files | ✅ Reversible |
| Prune merged git branches | On main branch | ✅ Standard |
| Update counts | Marker files | ✅ Metadata |

---

## Brief-Gen Actions (Human Needed)

| Action | Creates |
|--------|---------|
| Archive mid-sprint items | Decision brief |
| Close complex td issues | Resolution brief |
| Major refactor needed | Refactor brief |
| Docs drift | Flag to docs-agent |

---

## Constraints

1. Never delete — only archive/move
2. Always `git add` + `git commit` after tidy
3. Log actions to td
4. Create briefs for irreversible decisions

---

## Commands

```bash
tidy-first-agent check      # Check current state
tidy-first-agent run       # Run auto-tidy
tidy-first-agent run --full # Full tidy including brief-gen
tidy-first-agent status    # Show tidy metrics
```

---

## Integration

- **on stale docs** → docs-agent (flag)
- **on auto-tidy** → review-agent (optional)
- **on brief-gen** → briefs-agent (create brief)
- **on close issues** → review-agent (verify)
