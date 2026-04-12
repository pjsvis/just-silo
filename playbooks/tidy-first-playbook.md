# Playbook: Tidy-First

**Principle:** Reduce context noise before adding new work. A clean workspace is a productive workspace.

---

## Core Idea

Before starting new work, clean up the working directory:

1. **Archive old docs** — Move completed/archived work out of sight
2. **Close stale issues** — Don't let dead items pollute td
3. **Commit cleanup commits** — Separate tidy from feature work

*Rule: New work in clean space. Archaeology is deliberate, not ambient.*

---

## When to Tidy

| Situation | Action |
|-----------|--------|
| Start of session | Quick `ls` check, tidy if needed |
| Before major work | Full tidy + archive |
| After delivery | Archive completed items |
| Quarterly review | Deep archive + consolidation |

---

## Directory Tidy Pattern

### Briefs & Debriefs

```
# Before (70+ files, noisy)
briefs/
├── 2026-03-31-*.md   # Old
├── 2026-04-02-*.md   # Older
├── 2026-04-04-*.md   # Old
└── 2026-04-06-*.md   # Current

# After (lean, navigable)
briefs/
├── 2026-04-06-*.md   # Current
└── research/         # Active briefs only

archive/
├── briefs/            # 48 archived briefs
└── debriefs/         # 7 archived debriefs
```

### Archive Commands

```bash
# Archive old briefs (pre-current sprint)
mv briefs/2026-03-*.md archive/briefs/
mv briefs/2026-04-0[2-4]-*.md archive/briefs/

# Archive old debriefs
mv debriefs/2026-04-0[1-5]-*.md archive/debriefs/

# Commit the archive
git add -A && git commit -m "chore: archive pre-April briefs"
```

### Tidy Command Alias

Add to `justfile`:

```just
# Quick tidy check
tidy:
    @echo "=== Tidy Check ==="
    @echo "Briefs: $(ls briefs/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    @echo "Archive briefs: $(ls archive/briefs/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    @echo ""
    @echo "Debriefs: $(ls debriefs/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    @echo "Archive debriefs: $(ls archive/debriefs/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    @echo ""
    @td list --count
    @td reviewable && echo "Reviews pending" || echo "All clear"
```

---

## td Tidy Pattern

### Close Stale Issues

```bash
# Find stale issues (no activity in 7 days)
td list --stale 7

# Close won't-fix items
td close <id> --reason "superseded"

# Archive completed sprints
td archive --sprint <sprint-id>
```

### Session Hygiene

```bash
# New session = fresh start
td usage --new-session

# But first: check for pending handoffs
td check-handoff
```

---

## Lessons Learned

### What Works

| Pattern | Why |
|---------|-----|
| Date-prefixed files | Easy to sort, easy to archive by date |
| Top-level archive | Single place for all historical docs |
| TUI-first directories | `glow briefs/` is navigable, not overwhelming |
| Separate tidy commits | Keeps history clean, bisectable |

### What Doesn't Work

| Anti-pattern | Problem |
|-------------|---------|
| Everything in root | Context noise kills productivity |
| No archive strategy | Old files blend with new |
| Mixed tidy + feature commits | Hard to revert, messy history |
| Auto-archive everything | Loses recent context |

---

## Quick Tidy Checklist

Before starting new work:

- [ ] `just tidy` — Check file counts
- [ ] Archive briefs/debriefs older than current sprint
- [ ] `td list` — Check for stale issues
- [ ] Close or reprioritize stale items
- [ ] `git status` — No uncommitted cleanup
- [ ] `just verify` — Prerequisites still met

---

## Tidy Code Too

The same discipline applies to code:

| Before | After |
|--------|-------|
| 200-line justfile with jq pipelines | Thin justfile + `scripts/*.sh` |
| Complex shell in recipes | Extract to scripts |
| Mega-recipes doing everything | Small, composable pieces |

### The Rule

> **If a recipe line is longer than 80 chars or has nested quotes, extract to a script.**

See: `playbooks/justfile-design-playbook.md` for details.

---

## Related

- [Briefs Pattern](briefs-playbook.md) — How to write briefs
- [td Playbook](td-playbook.md) — Task management
- [Agent Ops Playbook](agent-ops-playbook.md) — Agent coordination
- [Justfile Design Playbook](justfile-design-playbook.md) — Recipe design rules
- [Lessons Learned](lessons-learned.md) — Collected wisdom
