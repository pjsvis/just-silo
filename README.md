# just-silo

*"just-silo it or just-forget it"*

---

## The Problem

**Too little context:**
- Agents don't know what to do
- Every turn requires re-explanation
- Context injection becomes ritual

**Too much context:**
- Context window fills with noise
- Signal gets drowned
- Performance degrades

## The Insight

> *"More context doesn't mean better results. Past a threshold, the noise drowns the signal."*

**The sweet spot:** Bounded context. Enough to act, no more.

**A silo is a scoped lexicon** — vocabulary and grammar that lives in the filesystem.

Agents lose their context every turn. A silo persists knowledge across sessions.

## What Is A Silo?

A contained workspace with its own language:

```
my-silo/
├── justfile        # Vocabulary (verbs)
├── schema.json     # Grammar (what's valid)
├── queries.json    # Named transforms
├── pipeline.json   # Stage definitions
└── scripts/       # Observability
```

**You define the vocabulary.** `harvest`, `status`, `stuck` are just examples.

## Quick Start

```bash
cp -r template my-silo && cd my-silo && just help
```

## The Pattern

```
just <verb>        → just f*cking do it
just help <verb>   → what will it do?
just help          → what verbs exist?
just status        → pipeline observability
```

## Recommended Verbs

**Observability (see what happened):**
```
just status      → aggregate pipeline health (THE main command)
just who         → which agents on which stages
just stuck       → detect stalled stages
just throughput  → processing metrics
just audit       → completion history
```

**Core (do the thing):**
```
just harvest     → ingest data
just process     → transform data
just flush       → archive output
```

**Coordination (multi-agent):**
```
just claim       → own a stage
just wait        → block until ready
just done        → mark complete
```

## Observe the Territory

**Your pipeline IS your dashboard.** No separate observability layer.

```bash
just status          # Everything at once
just who             # Agent assignments
just stuck 60        # Stages idle > 60 minutes
just audit           # Completion history
```

> *"Observe the territory you occupy. Don't log into a separate dashboard."*

## Workflow

```
Mount → Sieve → <verb> → Observe → Flush
```

| Step | What |
|------|-------|
| Mount | `cd my-silo/` |
| Sieve | `just verify` |
| Do | `just <your-verb>` |
| Observe | `just status` |
| Flush | `just flush` |

## Anatomy

```
my-silo/
├── justfile           # Vocabulary (verbs you define)
├── schema.json        # What valid data looks like
├── queries.json        # Named jq filters
├── pipeline.json      # Stage definitions
├── scripts/           # Observability scripts
├── .silo              # Manifest
└── README.md          # Domain rules
```

## Best Practices

**Bounded context:**
- Flush early, flush often
- Keep `data.jsonl` lean
- Archive to `final_output.jsonl`

**Trust the schema:**
- Validation at ingestion is cheap
- Debugging downstream is expensive

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

## Examples

- [silo_barley](examples/silo_barley/) — Grain elevator moisture monitor

## Resources

| Document | Purpose |
|----------|---------|
| [Silo-Philosophy.md](Silo-Philosophy.md) | The why (read this first) |
| [Silo-Manual.md](Silo-Manual.md) | Technical implementation |
| [Playbooks](playbooks/) | By role |
| [Skills](skills/) | Agent instructions |
| [Examples](examples/silo_barley/) | Working silo |

## License

MIT
