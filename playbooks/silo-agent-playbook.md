# Silo Agent Playbook

**For AI agents mounting and using silos.**

---

## The Idea

Drop into a silo. Read the rules. Do it.

**You can only do what the silo allows. That's the point.**

## Mount Protocol

When told to "mount a silo":

1. `cd silo_<domain>/`
2. Read `.silo` manifest
3. Read `README.md`
4. Run `just help`
5. Run `just status`

**You've read the rules. Now do it.**

## Pocket Universe Rules

```
When you're in, you can only do what it allows.
The rules are the rails.
Constraints create capability.
```

## Use Protocol

### Standard Workflow

```
Mount → Sieve → <verb> → Observe → Flush
```

### Mount
```bash
just help          # What can I do here?
just status        # See what's happening
```

### Sieve
```bash
just verify        # Check prerequisites
just harvest      # Ingest data
```

### Do the Thing
```bash
just <your-verb>  # Whatever the silo defines
```

### Observe
```bash
just status        # Aggregate health
just who           # Who's on what
just stuck         # Anything stalled?
```

### Flush
```bash
just flush         # Archive completed work
```

## Principles

1. **occupy the Territory** — `cd` into silo, don't install
2. **Mentational Hygiene** — Keep data.jsonl lean, flush often
3. **High-Integrity** — Recipes run with `set -euo pipefail`
4. **Constraints are Features** — You can only do what silo allows

## Commands Reference

### Observability (THE PATTERN)
```bash
just status        # Aggregate pipeline health
just who           # Agent assignments
just stuck         # Detect stalled stages
just throughput    # Processing metrics
just audit         # Completion history
```

### Core
```bash
just verify        # Check prerequisites
just harvest       # Validate → data.jsonl
just <verb>        # Do the thing
just flush         # Archive to final_output.jsonl
```

### Help
```bash
just help          # What verbs exist?
just help <verb>   # What does this verb do?
```

## Exit Protocol

After processing:
1. Run `just status` — verify state
2. Run `just flush` — archive completed work
3. Report summary

## Summary Template

```
Silo: <domain>

Status: <state>
Processed: <N> items
Alerts: <M> critical
Output: final_output.jsonl (<P> items)
Remaining: <R> in data.jsonl
```

## Remember

**The tool is called `just`. The usage is `just do it`.**

Just read the rules. Just do what it allows. Done.
