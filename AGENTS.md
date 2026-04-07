ind just-silo — AGENTS.md

---

## For Incoming Agents

**Entry point:** `cd` into a silo, `just --list`, read `README.md`

**The Reveal:** Don't pre-define the vocabulary. Say what you want. The silo emerges.

**Scout mindset:** Assess first. Don't assume. Start from what's there. Recon before you act.

**Philosophy docs:** `Silo-Philosophy.md` (why) → `Silo-Manual.md` (how)

---

## What Is This?

A **directory-based skill framework** for AI agents. Mount a silo to get domain-specific capabilities without session context.

**A silo is a scoped lexicon — vocabulary and grammar that lives in the filesystem.**

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
Mount → Sieve → Process → Observe → Flush
```

| Step | Command | Purpose |
|------|---------|---------|
| Mount | `cd my-silo/` | Agent reads rules from filesystem |
| Sieve | `just harvest` | Validate data against schema.json |
| Process | `just process` | Run domain script |
| Observe | `just status` / `just who` | Monitor pipeline |
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

## Observe the Territory (Seriously Cool)

**Your pipeline IS your dashboard.** No separate observability layer — the filesystem that runs the pipeline shows you what's happening.

```bash
cd my-silo/
just status          # What's running, stuck, done
just who             # Which agents on which stages
just stuck 60        # Stages idle > 60 minutes
just throughput      # Items/hour trend
just audit           # Full pipeline history
```

> *"Observe the territory you occupy. Don't log into a separate dashboard."*

See `briefs/2026-03-31-pipeline-observability-via-filesystem.md` for implementation plan.

## File Structure

```
just-silo/
├── README.md              # Project overview
├── Silo-Manual.md         # Full philosophy + patterns
├── Silo-Philosophy.md     # The why
├── template/             # ⭐ Start here: copy to create new silos
├── examples/silo_barley/  # Working example (grain moisture monitor)
├── playbooks/             # How-tos: user, builder, agent, operator, scout

├── briefs/                # Project briefs
└── debriefs/              # Retrospectives
```

## Playbooks

| Playbook | For |
|----------|-----|
| `playbooks/silo-user-playbook.md` | Using existing silos |
| `playbooks/silo-builder-playbook.md` | Creating new silos |
| `playbooks/silo-agent-playbook.md` | Mounting and using silos |
| `playbooks/silo-operator-playbook.md` | Multi-agent coordination |
| `playbooks/silo-scout-playbook.md` | Entering unknown silos |
| `playbooks/jsonl-playbook.md` | JSONL patterns |
| `playbooks/jq-playbook.md` | jq query patterns |

## Prerequisites

- `just` — `brew install just`
- `jq` — `brew install jq`

## Philosophy

> "More context doesn't mean better results. Past a threshold, the noise drowns the signal."

The silo externalizes domain knowledge into the filesystem. Hand an agent a silo and it acts without prior context.

---

## Agent Architecture

The project uses specialized agents for different concerns. Agents watch td for relevant statuses and act accordingly.

### Agent Overview

| Agent | Trigger | Purpose |
|-------|---------|---------|
| **test-agent** | td status → in_review | Enforce test presence + pass |
| **docs-agent** | td status → approved | Sync docs with code changes |
| **review-agent** | td status → in_review | Review code, open PR, request approval |
| **briefs-agent** | td status → closed | Generate brief drafts |
| **debriefs-agent** | git merge | Capture lessons learned |

### Agent Trigger Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      Workflow Triggers                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  File-system triggers (inotify / FSEvents):                 │
│    *.ts changed     → test-agent                            │
│    *.md changed     → docs-agent                            │
│    scripts/*        → test-agent                            │
│                                                              │
│  td status triggers:                                        │
│    in_review        → test-agent, review-agent              │
│    approved         → docs-agent                            │
│    closed           → briefs-agent                          │
│                                                              │
│  Git triggers:                                              │
│    pre-commit       → test-agent                            │
│    post-merge       → debriefs-agent                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### test-agent

**Purpose:** Ensure test presence and pass (not coverage %).

**Scope:**
- Must have `<module>.test.ts` for each `<module>.ts`
- Must pass: `bun test`
- Must cover: happy path + one edge case per exported function

**Enforces:** Presence and pass/fail, not coverage metrics.

### docs-agent

**Purpose:** Keep docs in sync with code changes.

**Scope:**
- Detect changes to source files
- Flag docs that reference changed code but weren't updated
- Optionally: Auto-update simple doc references (e.g., command output)

### review-agent

**Purpose:** Formal review and PR workflow.

**Scope:**
- Review code for issues
- Open PR (draft or ready)
- Request human review
- Handle server-side auto-review webhook events
- Retry failed CI, close stale PRs

### briefs-agent

**Purpose:** Generate brief drafts from issues.

**Scope:**
- Watch for closed issues
- Generate first-draft brief in `briefs/research/`
- Format: problem → proposed solution → status

### debriefs-agent

**Purpose:** Capture lessons post-merge.

**Scope:**
- Watch for merges to main
- Generate debrief in `debriefs/`
- Extract: what worked, what didn't, metrics

---

**Status:** Early-stage project. Template and example working. Distribution: copy template model.
