---
name: use-silo
description: Use an existing just-silo to process data
keywords: [silo, data, process, harvest, just]
version: 1.0.0
author: just-silo
---

# Skill: Use Silo

Mount and use an existing just-silo to process data through the harvest → process → flush workflow.

## When to Use

Use this skill when asked to:
- "Process the data in this silo"
- "Run the harvest pipeline"
- "Check the alerts in this silo"
- "Compact the processed data"

## Prerequisites

- `just` installed
- `jq` installed
- You're in a silo directory (has `justfile`)

## Standard Workflow

### 1. Mount the silo

```bash
cd silo_<domain>/
just verify
just --list
```

Read `README.md` to understand:
- Domain purpose
- Critical thresholds
- Expected data format

### 2. Sieve (Ingest)

```bash
just harvest
```

This:
- Validates `harvest.jsonl` against `schema.json`
- Writes valid entries to `data.jsonl`
- Shunts invalid entries to `quarantine.jsonl`

### 3. Process

```bash
just process
```

Runs the domain script to transform data.

### 4. Check

```bash
just alerts      # Surface critical items
just stats       # Show counts
just query <name> # Run named filter from queries.json
```

### 5. Flush (Compact)

```bash
just flush
```

This:
- Moves `processed` items to `final_output.jsonl`
- Removes processed items from `data.jsonl`
- Keeps `data.jsonl` lean

### 6. Hygiene

```bash
just clean       # Reset for fresh run
just self-test   # Verify silo integrity
```

## Quick Commands

| Command | Purpose |
|---------|---------|
| `just verify` | Check prerequisites and schema |
| `just harvest` | Ingest data |
| `just process` | Run domain script |
| `just alerts` | Show critical items |
| `just stats` | Show metrics |
| `just flush` | Compact processed items |
| `just clean` | Reset state files |
| `just self-test` | Smoke test |

## Understanding Output

### Files created by harvest

| File | Content |
|------|---------|
| `data.jsonl` | Valid entries for processing |
| `quarantine.jsonl` | Invalid entries (failed schema) |
| `final_output.jsonl` | Compacted completed items |

### Status values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet processed |
| `processed` | Completed, ready for flush |
| `quarantined` | Failed validation |

## Error Handling

### "No justfile found"
```bash
pwd   # Confirm you're in the silo directory
ls -la   # Should show justfile, README.md, etc.
```

### "MISSING schema.json"
The directory is not a valid silo. Verify it has:
```bash
ls .silo schema.json queries.json justfile
```

### "jq: parse error"
Check JSONL validity:
```bash
jq empty harvest.jsonl
```

### Entries in quarantine
Check why entries failed validation:
```bash
cat quarantine.jsonl | jq .
```

Compare with expected schema:
```bash
cat schema.json | jq .required
```

## Multi-Agent Usage

If multiple agents are processing:

```bash
# Agent A: Stage 1
just claim 1
just harvest
just done 1

# Agent B: Stage 2
just wait harvest.done
just claim 2
just process
just done 2
```

See `playbooks/playbook-silo.md` for multi-agent patterns.

## Exit Checklist

- [ ] `just harvest` ran without errors
- [ ] `data.jsonl` has expected entries
- [ ] `quarantine.jsonl` is empty (or entries reviewed)
- [ ] `just process` completed
- [ ] `just flush` moved processed items to output
- [ ] `data.jsonl` is lean (only pending items)

## Summary Template

When done, report:

```
Silo: <domain>

Processed: <N> items
Alerts: <M> critical items
Output: final_output.jsonl (<P> items)
Remaining: <R> items in data.jsonl

## Related Skills

- [skill-jsonl.md](skill-jsonl.md) — JSONL patterns and traps
- [skill-jq.md](skill-jq.md) — jq query patterns
```
