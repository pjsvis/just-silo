# just-silo — AGENTS.md

## What Is This?

A **directory-based skill framework** for AI agents. Mount a silo to get domain-specific capabilities without session context.

**Tagline:** *"just-silo it or just-forget it"*

**Core insight:** Agents lose context every turn. A "silo" persists domain knowledge in the filesystem.

## Quick Start

```bash
# Create a new silo from template
cp -r template my-silo
cd my-silo

# Standard workflow
just verify      # Check prerequisites
just harvest     # Validate and ingest data
just process     # Run domain script
just alerts      # Surface critical items
just flush       # Compact to final output
```

## Core Workflow

```
Mount → Sieve → Process → Check → Flush
```

| Step | Command | Purpose |
|------|---------|---------|
| Mount | `cd my-silo/` | Agent reads rules from filesystem |
| Sieve | `just harvest` | Validate data against schema.json |
| Process | `just process` | Run domain script |
| Check | `just alerts` / `just stats` | Surface critical items |
| Flush | `just flush` | Compact processed items to output |

## Anatomy of a Silo

```
my-silo/
├── .silo              # Manifest (name, version, thresholds)
├── README.md          # Domain rules and thresholds
├── schema.json        # JSON Schema for validation
├── queries.json       # Named jq filters (prevents ad-hoc jq)
├── justfile           # Recipes (just --list)
├── harvest.jsonl      # Raw input data
├── data.jsonl         # Validated working set
└── process.sh         # Domain logic script
```

## Key Commands

| Command | Purpose |
|---------|---------|
| `just verify` | Check prerequisites and schema |
| `just harvest` | Ingest + validate against schema |
| `just process` | Run domain script |
| `just alerts` | Surface critical items |
| `just stats` | Show entry counts |
| `just query <name>` | Run named filter from queries.json |
| `just flush` | Move processed items to final_output.jsonl |
| `just clean` | Reset state files |
| `just self-test` | Smoke test |

## Principles

1. **Enough is enough.** Keep data lean. Flush often.
2. **Trust the schema.** Validation at ingestion is cheap; debugging downstream is expensive.
3. **Named filters over ad-hoc jq.** Use queries.json, not shell pipes.
4. **Occupy the territory.** `cd` into the silo, don't install.

## Multi-Agent Coordination

Agents coordinate via marker files in `markers/`:

```bash
# Agent A
just harvest
just done harvest

# Agent B  
just wait harvest
just process
just done process
```

## File Structure

```
just-silo-dev/
├── README.md              # Project overview
├── Silo-Manual.md         # Full philosophy + patterns
├── HN-ANNOUNCEMENT.md     # Public positioning
├── template/              # ⭐ Start here: copy to create new silos
├── examples/silo_barley/  # Working example (grain moisture monitor)
├── playbooks/             # By role: user, builder, agent, operator
├── skills/                # Agent instructions
├── briefs/                # Project briefs
└── debriefs/              # Retrospectives
```

## Key Files for Reference

| File | Purpose |
|------|---------|
| `Silo-Manual.md` | Full documentation, philosophy, patterns |
| `template/justfile` | All recipes, copy to new silos |
| `skills/skill-use-silo.md` | How to use an existing silo |
| `skills/skill-build-silo.md` | How to create a new silo |
| `examples/silo_barley/` | Complete working example |

## Prerequisites

- `just` — `brew install just`
- `jq` — `brew install jq`

## Philosophy

> "More context doesn't mean better results. Past a threshold, the noise drowns the signal."

The silo externalizes domain knowledge into the filesystem. Hand an agent a silo and it acts without prior context.

---

**Status:** Early-stage project. Template and example working. Distribution: copy template model.
