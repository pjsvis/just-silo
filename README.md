# just-silo

*"just-silo it or just-forget it"*

---

## The Tone

```
We don't need a SOTA model.
We need a model that will just do it.

No framework friction.
Get stuff.
Turn it into things.
Done.

Any substrate worth its chips should be able to do it.
```

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

## The Reveal

**You don't pre-define the vocabulary. You just say what you want.**

```
"I want to monitor grain moisture and alert when it's too high"
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes"
→ just scan, just score, just flag...

"I want to triage alerts and route to on-call"
→ just triage, just route, just escalate...
```

**You say the words. Just-silo makes them executable.**

Just ask your AI: "Make the words just happen."

The tool is called *just*. The usage is *just do it*.

## What Is A Silo?

**Two things:**

**1. Something you encounter.**
Agent drops in, reads rules, does the job.

**2. Something you build.**
You have stuff. You want things. You create a silo.

```
STUFF ──→ [ SILO ] ──→ THINGS
          ┌──────────────────┐
          │ I want this stuff │
          │ turned into these │
          │ things           │
          └──────────────────┘
```

**You define the stuff. You define the things. The silo does the conversion.**

**When you're in, you can only do what it allows.**

The rules are the rails. Constraints create capability.

You want different rules? Change them. It's your pocket universe.

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

## Built On

**just** — the command runner that makes silos executable.

`just` transforms a directory into a language. Without it, silos are just files.

| | |
|---|---|
| Creator | [Casey Rodarmor](https://github.com/casey) |
| License | CC0 |
| Install | `brew install just` |
| Repo | [github.com/casey/just](https://github.com/casey/just) |

**Glow + Gum** — TUI magic from [Charm](https://charm.sh).

| | Glow | Gum |
|---|---|---|
| What | Markdown renderer | TUI components |
| Used for | Render proposals | Select, confirm, input |
| Install | `brew install glow` | `brew install gum` |
| Repo | [charm.sh/glow](https://github.com/charmbracelet/glow) | [charm.sh/gum](https://github.com/charmbracelet/gum) |

**Go thank them.** These tools make silos actually pleasant to use.

## The Pattern

```
just <verb>        → just do it
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

- [silo_barley/](silo_barley/) — Grain elevator moisture monitor (working example)

## Resources

| Document | Purpose |
|----------|---------|
| [Silo-Philosophy.md](Silo-Philosophy.md) | The why (read this first) |
| [Silo-Manual.md](Silo-Manual.md) | Technical implementation |
| [Playbooks](playbooks/) | By role |
| [Skills](skills/) | Agent instructions |
| [silo_barley/](silo_barley/) | Working silo |

## License

MIT

---

## Provision

**On a fresh machine, run:**

```bash
# Clone and provision
git clone https://github.com/pjsvis/just-silo.git
cd just-silo
./scripts/provision.sh
```

Or manually:

| Tool | Install |
|------|---------|
| `just` | `brew install just` |
| `jq` | `brew install jq` |
| `glow` | `brew install glow` |
| `gum` | `brew install gum` |
| `pi` | `npm install -g @mariozechner/pi-coding-agent` |
| `agent-browser` | `npm install -g agent-browser` |

---

## Open Source

**If just-silo is useful, star it:**

[![Star](https://img.shields.io/github/stars/pjsvis/just-silo?style=social)](https://github.com/pjsvis/just-silo)

**Links:**
- [GitHub](https://github.com/pjsvis/just-silo)
- [Silo-Manual.md](Silo-Manual.md) — Full technical docs

**Dependencies:**
- [just](https://github.com/casey/just) — Command runner
- [glow](https://github.com/charmbracelet/glow) — Markdown renderer
- [gum](https://github.com/charmbracelet/gum) — TUI components
