# Silo User Playbook

**For humans who want the AI to just do it.**

---

## The Reveal

**You don't pre-define the vocabulary. You just say what you want.**

```
"I want to monitor grain moisture and alert when it's too high"
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes"
→ just scan, just score, just flag...
```

**You say the words. Just-silo makes them executable.**

The tool is called `just`. The usage is `just do it`.

## Quick Start

```bash
cp -r template my-silo && cd my-silo && just help
```

## The Pattern

```
just <verb>        → just do it
just help <verb>  → what will it do?
just help          → what verbs exist?
just status        → pipeline observability
```

## Workflow

```
Mount → Sieve → <verb> → Observe → Flush
```

### Mount
```bash
cd my-silo/
just help          # What can I do here?
```

### Sieve
```bash
just verify        # Check prerequisites
just harvest       # Ingest data
```

### Do the Thing
```bash
just <your-verb>  # Whatever verbs you defined
```

### Observe
```bash
just status        # Everything at once
just who           # Who's doing what
just stuck         # Anything stalled?
```

### Flush
```bash
just flush         # Archive completed work
```

## Pocket Universe Rules

**When you're in, you can only do what the silo allows.**

The rules are the rails. Constraints create capability.

## Files

| File | Purpose |
|------|---------|
| `justfile` | Your vocabulary (verbs you define) |
| `schema.json` | What valid data looks like |
| `data.jsonl` | Working state |
| `final_output.jsonl` | Archived results |

## Observability Commands

```bash
just status        # Aggregate pipeline health (THE main command)
just who           # Agent assignments
just stages        # Stage-by-stage
just stuck         # Detect stalled stages
just throughput    # Processing metrics
just audit         # Completion history
```

## Reset
```bash
just clean         # Remove state files
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No justfile" | `cd` into silo directory |
| "jq parse error" | Check JSONL validity |
| Entries in quarantine | Review failed validation |

## Remember

**Just ask your AI:** "Make the words just happen."

The tool is called `just`. The usage is `just do it`.
