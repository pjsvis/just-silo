# Silo Agent Playbook

**For AI agents mounting and using silos.**

---

## Mount Protocol

When told to "mount a silo":

1. `cd silo_<domain>/`
2. Read `.silo` manifest
3. Read `README.md`
4. Run `just verify`
5. Run `just --list`

## Use Protocol

### Standard Workflow

```
Mount → Sieve → Process → Check → Flush
```

### Top (Ingest)
```bash
just verify
just harvest
```

### Middle (Process)
```bash
just process
just alerts
just stats
```

### Tail (Compact)
```bash
just flush
```

## Principles

1. **Sleeve Before Substrate** — Read schema/queries before data
2. **Mentational Hygiene** — Keep data.jsonl lean
3. **High-Integrity** — Recipes run with `set -euo pipefail`
4. **occupy the Territory** — `cd` into silo, don't install

## Commands Reference

| Command | Purpose |
|---------|---------|
| `just verify` | Check schema, queries, jq |
| `just harvest` | Validate → data.jsonl |
| `just process` | Run domain script |
| `just alerts` | Extract critical items |
| `just stats` | Show file counts |
| `just query <name>` | Run named filter |
| `just report` | Human-readable summary |
| `just flush` | Compact processed items |
| `just self-test` | Smoke test |
| `just clean` | Reset state files |

## Exit Protocol

After processing:
1. Verify `just flush` ran
2. Report counts (active, alerts, output)
3. Confirm if silo is clean and ready

## Summary Template

```
Silo: <domain>

Processed: <N> items
Alerts: <M> critical
Output: final_output.jsonl (<P> items)
Remaining: <R> in data.jsonl
```
