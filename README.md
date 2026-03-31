# just-silo

*"just-silo it or just-forget it"*

A directory-based skill for AI agents. Mount a silo, just harvest.

**A silo is a scoped lexicon — vocabulary and grammar that lives in the filesystem.** See [Silo-Philosophy.md](Silo-Philosophy.md) for the why.

**The core insight:** Every turn, the context window is scrubbed. Give agents just enough context to act — and no more. That's what silos do.

```bash
# Quick start
cp -r template my-silo
cd my-silo
just <verb>            # Do the thing (you choose the verb!)
just status            # See what's happening
just help              # What can I do here?
```

**Note:** `harvest`, `process`, `flush` are just example verbs. You define YOUR vocabulary.

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
Mount → Sieve → <verb> → Observe → Flush
```

**You define the verbs.** Example workflow:

| Step | Example Command | Purpose |
|------|-----------------|---------|
| Mount | `cd my-silo/` | Agent reads rules |
| Sieve | `just harvest` | Validate data |
| Do | `just <your-verb>` | Run your script |
| Observe | `just status` | Monitor pipeline |
| Flush | `just flush` | Compact output |

## Core Recipes

**You choose the verbs.** These are recommended:

```
# Do the thing (you define these!)
just harvest     # Example: ingest data
just process     # Example: run script
just flush       # Example: archive output

# See what's happening (recommended)
just status      # Aggregate pipeline health (THE main command)
just who         # Which agents on which stages
just stages      # Stage-by-stage status
just stuck       # Detect stalled stages
just throughput  # Processing metrics
just audit       # Completion history
just alerts      # Surface critical items

# Coordination (multi-agent)
just claim       # Own a stage
just wait        # Block until ready
just done        # Mark complete

# Safety rail
just help        # What verbs exist?
just help <verb> # What does this verb do?
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
| [Silo-Philosophy.md](Silo-Philosophy.md) | The why and what (read this first) |
| [Silo-Manual.md](Silo-Manual.md) | Technical implementation |
| [Playbooks](playbooks/) | By role |
| [Skills](skills/) | Agent instructions |
| [Examples](examples/silo_barley/) | Working silo |

## License

MIT
