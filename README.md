# just-silo

*"just-silo it or just-forget it"*

**New here?** Start with [START-HERE.md](START-HERE.md) or run `just silo-help`.

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

## Multi-Agent (Deprecated)

Agent orchestration has been removed. Use direct terminal instead.

- **Local:** Zed + terminal
- **Remote:** Monitoring only

## Examples

- [silo_barley/](silo_barley/) — Grain elevator moisture monitor (working example)

## Resources

| Document | Purpose |
|----------|---------|
| [Silo-Philosophy.md](Silo-Philosophy.md) | The why (read this first) |
| [Silo-Manual.md](Silo-Manual.md) | Technical implementation |
| [Playbooks](playbooks/) | Role-based guides |
| [td Playbook](playbooks/td-playbook.md) | Local-first task management |
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

**On Arch Linux with Flox (recommended):**

```bash
flox init
flox install
curl -fsSL https://raw.githubusercontent.com/marcus/sidecar/main/scripts/setup.sh | bash
curl -fsSL https://bun.sh/install | bash
npm install -g @mariozechner/pi-coding-agent
flox run -- just verify
```

See [FLOX.md](FLOX.md) for the full tool inventory and platform availability map.

**Or manually:**

| Tool | Install |
|------|---------|
| `just` | `brew install just` |
| `jq` | `brew install jq` |
| `glow` | `brew install glow` |
| `gum` | `brew install gum` |
| `td` + `sidecar` | `curl -fsSL https://raw.githubusercontent.com/marcus/sidecar/main/scripts/setup.sh \| bash` |
| `pi` | `npm install -g @mariozechner/pi-coding-agent` |

---

## Attribution

**Essential tools we couldn't work without:**

| Tool | Author | Why We Use It |
|------|--------|---------------|
| [td](https://github.com/Swatto/td) | [@Swatto](https://github.com/Swatto) | Local-first task management. Sessions, issues, handoffs, reviews. We miss it when it's not there. It's context, process, and agent coordination. |
| [pi](https://github.com/badlogic/pi-mono) | [@badlogic](https://github.com/badlogic) (Mario Zechner) | Coding agent harness. Adapts to workflows, not the other way around. [pi.dev](https://pi.dev) |
| [just](https://github.com/casey/just) | [@casey](https://github.com/casey) (Casey Rodarmor) | Command runner that makes silos executable. CC0 license. |
| [glow](https://github.com/charmbracelet/glow) | [Charm](https://charm.sh) | Markdown renderer for the TUI |
| [gum](https://github.com/charmbracelet/gum) | [Charm](https://charm.sh) | TUI components for scripts |

### Sidecar Pattern

The **sidecar** pattern is how we coordinate multiple agents:

```
session: explicit_sidecar-ws-just-silo-dev
```

- `explicit_sidecar` — marks this as a supporting session
- `ws-just-silo` — workspace identifier
- `dev` — current branch/context

Multiple agents can work the same workspace. Handoffs pass context between sessions.

See [td Playbook](playbooks/td-playbook.md) for the full workflow.

---

## Optional Dev Environment

**Tools we use but don't require:**

| Tool | Install | Purpose |
|------|---------|---------|
| `bun` | `curl -fsSL https://bun.sh/install` | Fast JS runtime |
| `uv` | `curl -LsSf https://astral.sh/uv/install.sh | sh` | Fast Python package manager |
| `fish` | `brew install fish` | Shell with better completions |
| `fisher` | `curl -sL https://git.io/fisher | fish -c "source - | fish"` | Fish plugin manager |
| `neovim` | `brew install neovim` | Editor (we use it over helix) |
| `lazygit` | `brew install lazygit` | TUI git interface |
| `aichat` | `brew install aichat` | CLI ChatGPT/Claude interface |
| `aider` | `pip install aider-chat` | AI pair programming |
| `ripgrep` | `brew install ripgrep` | Faster grep |
| `fd` | `brew install fd` | Faster find |
| `bat` | `brew install bat` | Cat with syntax highlighting |
| `eza` | `brew install eza` | Better ls with git info |
| `fzf` | `brew install fzf` | Fuzzy finder |
| `gh` | `brew install gh` | GitHub CLI |
| `yazi` | `brew install yazi` | File picker |
| `zoxide` | `brew install zoxide` | Smarter cd |
| `hledger` | `brew install hledger` | Accounting |

See `scripts/provision-arch-omarchy.sh` for Arch Linux equivalents.

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

---

## Philosophy

**Gödel showed: completeness is unreachable. Consistency is achievable.**
We choose consistency.

### The Watchwords

| Word | Meaning |
|------|---------|
| **TIDY FIRST** | Keep context lean. Archive liberally. |
| **CONSISTENCY** | README matches directory. Invariants hold. |
| **STUFF → THINGS** | Transform unstructured into structured. |
| **ENTROPY REDUCTION** | The goal. Less noise, more signal. |

### The Invariants

1. **Filenames unique** within silo scope
2. **README.md** in every browsable directory
3. **README is checksum** of directory contents

See [briefs/2026-04-12-brief-silo-philosophy.md](briefs/2026-04-12-brief-silo-philosophy.md) for full treatment.
