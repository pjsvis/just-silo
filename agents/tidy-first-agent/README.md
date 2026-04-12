# tidy-first-agent

Workspace hygiene automation for just-silo.

---

## Purpose

Keeps the workspace clean without blocking productive work:
- Archives old briefs/debriefs when thresholds exceeded
- Flags stale td issues
- Prunes merged git branches

---

## Quick Start

```bash
cd agents/tidy-first-agent

just check      # Quick tidy check
just status     # Detailed status
just run        # Run auto-tidy
```

---

## Thresholds

| Resource | Archive When |
|----------|--------------|
| Briefs | > 30 files |
| Debriefs | > 20 files |
| td issues | stale > 14 days |

---

## Cron Setup

```bash
# Daily tidy (8am)
0 8 * * * cd /path/to/just-silo && ./agents/tidy-first-agent/src/tidy-first-agent run

# Weekly deep-clean (Monday 9am)  
0 9 * * 1 cd /path/to/just-silo && ./agents/tidy-first-agent/src/tidy-first-agent run --full
```

---

## Behavior

**Auto-tidy (safe, reversible):**
- Archives oldest briefs/debriefs when threshold exceeded
- Prunes merged branches (when on main)

**Brief-gen (needs human):**
- Flags stale td issues for human review
- Creates briefs for complex decisions

**Constraint:** Never deletes, only archives/moves.

---

## CSP

See `CSP.md` for full specification.
