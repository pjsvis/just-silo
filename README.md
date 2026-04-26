# just-silo

Filesystem-based skill framework for AI agents.

**New here?** Read [START-HERE.md](START-HERE.md) or run `just silo-help`.

---

## What It Is

A pattern for directories that define **verbs** for an agent. The agent reads the rules, does the work.

```
STUFF ──→ [ SILO ] ──→ THINGS
          ┌──────────────────┐
          │ just harvest     │
          │ just process     │
          │ just flush       │
          └──────────────────┘
```

You define the vocabulary. `harvest`, `status`, `stuck` are examples.

## Quick Start

```bash
cp -r template my-silo && cd my-silo && just help
```

## The Pattern

```bash
just <verb>        → do it
just help <verb>   → what will it do?
just help          → what verbs exist?
just status        → pipeline health
```

## What's In A Silo

Each silo is a directory with a contract. The agent reads the contract, does the work.

```
my-silo/
├── justfile           # Vocabulary (verbs you define)
├── schema.json        # Grammar (validation)
├── queries.json       # Named transforms
├── pipeline.json      # Stage definitions
├── scripts/           # Observability
├── .silo              # Manifest
└── README.md          # Domain rules (specific to this silo)
```

(The file you're reading now is the framework overview. The `README.md` inside each silo describes that silo's specific domain.)

## Core Verbs

| Verb | Purpose |
|------|---------|
| `just status` | Pipeline health (THE main command) |
| `just harvest` | Ingest data |
| `just process` | Transform data |
| `just flush` | Archive output |
| `just stuck` | Detect stalled stages |

## Workflow

```
Mount → Verify → Do → Observe → Flush
```

| Step | Command |
|------|---------|
| Mount | `cd my-silo/` |
| Verify | `just verify` |
| Do | `just <verb>` |
| Observe | `just status` |
| Flush | `just flush` |

## Environment

Tools are managed via [Flox](https://flox.dev). See [flox.toml](flox.toml) for the manifest.

```bash
flox activate          # Enter environment
flox install           # Install declared tools
```

## Examples

- [examples/ai-legislation-silo/](examples/ai-legislation-silo/) — AI legislation compliance pipeline
- [examples/silo_barley/](examples/silo_barley/) — Grain elevator moisture monitor

## Resources

| Document | Purpose |
|----------|---------|
| [START-HERE.md](START-HERE.md) | First steps |
| [Silo-Manual.md](Silo-Manual.md) | Technical implementation |
| [Silo-Philosophy.md](Silo-Philosophy.md) | The why |
| [playbooks/](playbooks/) | Operational guides |
| [AGENTS.md](AGENTS.md) | Agent operating procedures |
| [FLOX.md](FLOX.md) | Environment setup |

## License

MIT
