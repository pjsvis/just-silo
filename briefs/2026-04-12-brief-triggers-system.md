# Brief: Trigger System for Silos

**Date:** 2026-04-12  
**Status:** IMPLEMENTED (in template/triggers.md)

---

## Problem

Silos need automated trigger mechanisms for:
- File-based events (new data, code changes)
- Time-based schedules (cron)
- External events (webhooks)

Currently no documented way to configure this.

---

## Solution

Created `template/triggers.md` with:

1. **Watchexec integration** — File change detection
2. **Cron recipes** — Time-based triggers
3. **Common patterns** — Harvest on new data, test on code changes

### Example: Auto-harvest

```bash
# Watch for new JSONL files, trigger harvest
watchexec -e jsonl -- just harvest
```

### Example: Cron trigger

```bash
# crontab entry
*/5 * * * * cd /path/to/silo && just harvest
```

---

## Files

- `template/triggers.md` — Trigger documentation (✅)
- `scripts/watch-*` — Pre-built watch scripts (✅)
- `watchexec` — Required tool (documented in provision.sh)

---

## Gap

No `just watch` recipe in justfile. Could add:

```just
# Watch mode
[group("silo")]
silo-watch:
    @watchexec -e jsonl,sh -- just harvest
```

**Priority:** MEDIUM  
**Est:** 15min