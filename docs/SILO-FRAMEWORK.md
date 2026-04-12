# Silo Framework — Technical Documentation

**Version:** 0.2.0  
**Date:** 2026-04-12  
**Status:** Foundation Document

---

## Overview

The **Silo Framework** is a directory-based skill and data pipeline system for AI agents. It externalizes domain knowledge into self-contained directories that can be versioned, shared, and deployed.

```
silo/
├── .silo              # Manifest (name, version, gamma-loop)
├── justfile           # Recipes (interface)
├── schema.json        # Data validation
├── queries.json       # Named jq filters
├── harvest.jsonl      # Input data
├── data.jsonl         # Active state
├── quarantine.jsonl   # Invalid entries
├── final_output.jsonl # Archived output
├── scripts/           # Domain logic
├── playbooks/         # Procedures
├── debriefs/          # Post-mortems
├── markers/           # Multi-agent coordination
└── telemetry/         # Metrics
```

---

## Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  CREATE     │───▶│  BUILD      │───▶│  DEPLOY     │───▶│  OPERATE    │
│             │    │             │    │             │    │             │
│ silo-create │    │ silo-build  │    │ silo-deploy │    │ just <cmd>  │
│             │    │             │    │             │    │             │
│ From        │    │ In dev/     │    │ To silos/   │    │ Verify      │
│ template/   │    │ workspace   │    │ for runtime │    │ Harvest     │
│             │    │             │    │             │    │ Process     │
└─────────────┘    └─────────────┘    └─────────────┘    │ Flush       │
                                                         └─────────────┘
```

---

## Components

### 1. Creation (`silo-create`)

**Purpose:** Spawn a new silo from a template.

```bash
./scripts/silo-create my-project --domain "ai-infra"
./scripts/silo-create _experiment --private    # Private silo
```

**Behavior:**
- Copies `template/` directory
- Substitutes variables (`{{name}}`, `{{domain}}`, `{{created}}`)
- Creates data files (`harvest.jsonl`, `data.jsonl`, etc.)
- Makes scripts executable

**Template Search Order:**
1. `$REGISTER_DIR/templates/<name>` (remote register)
2. `./templates/<name>` (local fallback)

### 2. Building (`silo-build.sh`)

**Purpose:** Build a silo in development workspace.

```bash
./scripts/silo-build.sh blog_writer_silo
```

**Behavior:**
- Creates `dev/<name>/` workspace
- Copies template with substitutions
- Sets up `.silo.dev_path` in manifest
- Prepares for development iteration

### 3. Deployment (`silo-deploy.sh`)

**Purpose:** Promote dev silo to runtime.

```bash
./scripts/silo-deploy.sh blog_writer_silo
```

**Behavior:**
- Copies from `dev/<name>/` to `silos/<name>/`
- Updates manifest (removes `dev_path`, sets `status: deployed`)
- Fixes relative paths for standalone operation
- Removes dev-specific markers

### 4. Provisioning (`provision.sh`)

**Purpose:** Install tools on a fresh machine.

```bash
./scripts/provision.sh
```

**Installs:**
- `just` — task runner
- `jq` — JSON processor
- `glow` — markdown renderer
- `bun` — JavaScript runtime
- `pi` — coding agent
- shellcheck — linting

**Current Limitation:** Arch Linux specific. See Gap Analysis.

---

## Phase Workflow (Justfile)

Each silo exposes standard phases via `justfile`:

| Phase | Command | Semantic | What it does |
|-------|---------|----------|--------------|
| **Gate** | `just silo-gate` | Doorway | Verify invariants before any write. Guard. |
| **Verify** | `just verify` | Pre-flight | Check prerequisites exist |
| **Harvest** | `just harvest` | Ignition | Load inbox. Commit to working. Spin up. |
| **Process** | `just process` | Transform | Do the actual work |
| **Flush** | `just flush` | Archive | Move processed to output |
| **Status** | `just status` | Dashboard | Show what's running |

### Verb Semantics

The verbs are not arbitrary. They have meaning:

```
harvest  → ignition + diagnostic + capability assessment
           Load inbox. Run failfast deterministic tests.
           Reveal capabilities. Real-time gap analysis.
           System in context within seconds.

           Before harvest: "What do we have?"
           After harvest:  "We know exactly what's ready."

verify   → pre-flight check
           Confirm prerequisites exist

process  → do the thing
           Transform input to output

flush    → archive output
           Move processed to final_output.jsonl

status   → dashboard
           Where are we in the pipeline?
```

**The diagnostic loop:**

```
just harvest
    ↓
Failfast tests run (deterministic, fast)
    ↓
Capabilities revealed
    ↓
Gap analysis: expected vs actual
    ↓
System in context
```

**Why it's fast:** Tests are deterministic. Failfast means if something breaks, you know immediately. No guessing. No waiting. Just know.

---

## Production Line Model

**A silo is a production unit. Turn it on, it costs money. Turn it off, it doesn't.**

Binary. Clean. Sellable.

```
SILO ON PRODUCTION LINE  → Cost (tokens, compute, time)
SILO OFF PRODUCTION LINE → No cost (dormant)
```

### The Value Proposition

```
INBOX (high entropy, raw)
    │
    ▼
[SILO processes]
    │
    ▼
OUTBOX (low entropy, refined)

Proof of value: Outbox entropy < Inbox entropy
```

**The question isn't "does it work?" It's "is it producing value?"**

### Who Measures What

| What we provide | What you provide |
|-----------------|------------------|
| Constant environment | Your entropy metric |
| Deterministic tests | Your measurement logic |
| Trend detection | Your comparison |
| Failfast diagnostics | Your thresholds |

**We give you the factory. You design the quality control.**

### The Deal

```
We say: "Your inbox had X. Your outbox has Y.
         The trend is [improving/degrading].
         Your silo is [working/not working]."

We don't say: "This is what low entropy means for your business."
```

How you measure entropy is up to you. We just give you:
- A constant environment
- A trend to detect
- Failfast diagnostics

### The Pitch

> "A silo is a production unit. Turn it on, it costs money. Turn it off, it doesn't. The only question is: does your outbox have less entropy than your inbox? If yes, the silo is producing value. If no, you're burning cost."

### Implementation

```bash
# Put silo on production line (costs money)
just silo-on

# Take silo off production line (no cost)
just silo-off

# Check production status
just silo-status

# Verify value (outbox entropy vs inbox entropy)
just silo-verify-value
```

The silo runs. You measure. The trend tells you if it's worth running.

---

**`silo-gate` is orthogonal to the normal flow.**

It's the guard that runs before any write, not part of the process pipeline. Think of it as a security checkpoint, not a step in the workflow.

```
                    ┌─────────────┐
                    │ silo-gate   │ ← Guard: verify before write
                    └──────┬──────┘
                           │
                           ▼
         ┌─────────────────────────────┐
         │  harvest → verify → process → flush  │
         │       The normal flow        │
         └─────────────────────────────┘
```

### The Commitment Verb

`just harvest` is the **commitment verb**. It's not just "ingest data."

It's the moment you say: "We're doing this today."

```bash
just harvest → "Loading inbox. System is live. We're working."
```

---

## Gamma Loop

The **Gamma Loop** is the self-improvement mechanism:

```
┌─────────────────────────────────────┐
│  DO → LEARN → DEBRIEF → IMPROVE     │
│                                     │
│  • playbooks/ — captured knowledge  │
│  • debriefs/  — post-mortems        │
│  • telemetry/ — metrics/logs        │
└─────────────────────────────────────┘
```

**Enabled by default in `.silo.gamma_loop`**

---

## Gap Analysis

| Gap | Severity | Status |
|-----|----------|--------|
| No generic schema template | HIGH | ✅ Created `schema-generic.json` |
| Arch-only provision.sh | MEDIUM | Pending |
| No deployment tests | MEDIUM | ✅ `silo-integration-test` exists |
| Dev→Deploy path unclear | MEDIUM | ✅ Documented here |
| CAVE CANNY enforcement | HIGH | ✅ Implemented `silo-gate` |
| Invariant 3 (README checksum) | HIGH | ✅ Implemented `invariant-3-check.sh` |

**Done:** Schema, integration test, silo-gate, invariant checks, CAW CANNY directive, production line model.  
**Pending:** Multi-platform provision, brief status tracking, workflow definitions, `silo-on`/`silo-off`/`silo-verify-value` recipes. |

---

## Quick Start

```bash
# Create
./scripts/silo-create my-silo

# Build (dev)
./scripts/silo-build.sh my-silo

# Deploy (runtime)
./scripts/silo-deploy.sh my-silo

# Operate
cd silos/my-silo
just verify
just harvest
just status
```

---

## Related

- `docs/directors-guide-silo-framework.md` — High-level overview
- `docs/user-guide.md` — End-user documentation
- `template/` — The product itself
- `briefs/` — Design briefs and proposals