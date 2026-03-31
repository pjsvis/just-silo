# just-silo

*"just-silo it or just-forget it"*

A directory-based skill for AI agents. Mount a silo, just harvest.

**The core insight:** Every turn, the context window is scrubbed. Give agents just enough context to act — and no more. That's what silos do.

```bash
# Quick start
cp -r template my-silo
cd my-silo
just harvest           # Ingest data
just process           # Run domain script
just alerts            # Surface critical items
just flush             # Compact to final output
```

## Why Bounded Context Matters

Agents lose their context every turn. A silo persists knowledge across sessions.

| Without Silo | With Silo |
|--------------|------------|
| Prompt every time | `cd silo && just harvest` |
| Explain domain each time | Domain embedded in filesystem |
| Inconsistent processing | Reproducible workflow |
| Ad-hoc jq | Named, validated filters |

*"just-silo it or just-forget it"* — because without structure, you'll just forget to do it right.

## Prerequisites

- [`just`](https://github.com/casey/just) — `brew install just`
- [`jq`](https://github.com/jqlang/jq) — `brew install jq`

## Installation

```bash
cp -r template my-silo
cd my-silo
just verify          # Check prerequisites
just self-test       # Run smoke test
```

## What is a Silo?

A contained workspace with everything an agent needs:

```
my-silo/
├── .silo              # Manifest (name, version)
├── README.md           # Domain rules
├── schema.json        # What valid data looks like
├── queries.json       # Named jq filters
├── justfile           # Recipes (just --list)
└── process.sh        # Domain logic
```

## Workflow

```
Mount → Sieve → Process → Observe → Flush
```

| Step | Command | Purpose |
|------|---------|---------|
| Mount | `cd my-silo/` | Agent reads rules |
| Sieve | `just harvest` | Validate data |
| Process | `just process` | Run script |
| Observe | `just status` / `just who` | Monitor pipeline |
| Flush | `just flush` | Compact output |

## Core Recipes

```
just verify      # Confirm ready
just harvest     # Ingest + validate
just process     # Run domain script
just alerts      # Critical items
just stats       # Counts
just flush       # Compact output
just self-test   # Smoke test
```

Run `just --list` for all recipes.

## Best Practices

**Give agents just enough context:**
- Read `.silo` and `README.md` first
- Follow the workflow order
- Use named queries, not ad-hoc jq

**Keep data lean:**
- Flush early, flush often
- `data.jsonl` is for work-in-progress only
- Archive completed items to `final_output.jsonl`

**Trust the schema:**
- Validation at ingestion is cheap
- Debugging bad data downstream is expensive

## Multi-Agent

Agents coordinate via marker files:

```bash
# Agent A
just harvest
just done harvest

# Agent B
just wait harvest
just process
just done process
```

## Observe the Territory

**Seriously cool:** Your pipeline IS your dashboard. No separate observability layer — the filesystem that runs the pipeline shows you what's happening.

```bash
cd my-silo/
just status          # What's running, stuck, done
just who             # Which agents on which stages
just stuck 60        # Stages idle > 60 minutes
just throughput      # Items/hour trend
just audit           # Full pipeline history
```

| Command | Purpose |
|---------|---------|
| `just status` | Aggregate pipeline health |
| `just who` | Active agents per stage |
| `just stuck` | Detect stalled stages |
| `just throughput` | Processing rate |
| `just audit` | Chronological history |

> *"Observe the territory you occupy. Don't log into a separate dashboard."*

## Examples

- [silo_barley](examples/silo_barley/) — Grain elevator moisture monitor

## Resources

| Document | Purpose |
|----------|---------|
| [Silo-Manual.md](Silo-Manual.md) | Why and how |
| [Playbooks](playbooks/) | By role |
| [Skills](skills/) | Agent instructions |
| [Examples](examples/silo_barley/) | Working silo |

## License

MIT
