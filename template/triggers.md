# Trigger Configuration

**For:** Silo authors  
**Purpose:** Configure automated responses to events

---

## Overview

Silos can be triggered by:
1. **File changes** (watchexec)
2. **Cron schedules** (system cron)
3. **External events** (webhooks, signals)

---

## File Watch Triggers

### Setup

```bash
# Install watchexec
brew install watchexec  # macOS
# or: sudo apt install watchexec  # Linux

# Run a command on file changes
watchexec -e jsonl,sh -- just harvest
```

### Common Patterns

```bash
# Harvest on new data
watchexec -e jsonl -- just harvest

# Process on data changes
watchexec -e jsonl -- just process

# Run tests on code changes
watchexec -e ts,tsx,sh -- bun test
```

### Watch Scripts (provided)

| Script | Watches | Runs |
|--------|---------|------|
| `scripts/watch-dashboard` | `*.jsonl` | `just trend-dashboard` |
| `scripts/watch-tests` | `*.ts,*.tsx` | `bun test` |
| `scripts/watch-trend` | `*.jsonl` | `just trend` |

---

## Cron Triggers

### Setup

```bash
# Add to crontab
crontab -e

# Run every 5 minutes
*/5 * * * * cd /path/to/silo && just harvest >> logs/harvest.log 2>&1

# Run hourly
0 * * * * cd /path/to/silo && just flush >> logs/flush.log 2>&1
```

### Silo-level Cron

Add to `justfile`:

```just
# Cron: run harvest every 5 minutes
cron-harvest:
    @just harvest
```

---

## Health Checks

Combine triggers with health checks:

```bash
# Watch + verify
watchexec -e jsonl -- "just verify && just harvest"
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Watch not triggering | Wrong extension | `-e jsonl,sh` |
| Multiple triggers | File changed during run | Use markers/ |
| Cron not running | Crontab syntax | Check with `crontab -l` |