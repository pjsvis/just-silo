# Speculative Design: Multi-Silo Architecture

**Status: Speculative | Version: 0.1.0 | Date: 2026-03-31**

---

## Executive Summary

Just-silo started as a pattern for bounded, agent-friendly directories. This document explores what happens when silos know about each other, coordinate, and—most importantly—**contain their blast radius**.

> *"Just do it here. Not anywhere else."*

The silo is a runtime. The git repo is the development environment. They sync. The agent works. The blast radius is one.

---

## 1. The Silo Is a Runtime

A silo is not just files. It's a **runtime environment** for AI agents.

```
┌─────────────────────────────────────────────────────────────────┐
│                          SILO RUNTIME                            │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Filesystem                            │   │
│   │   in/  out/  work/  archive/  justfile  schema.json      │   │
│   └─────────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Interface                            │   │
│   │   just harvest | just process | just flush | just status│  │
│   └─────────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Agent                                 │   │
│   │   Reads .silo manifest, executes recipes, produces      │   │
│   └─────────────────────────────────────────────────────────┘   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Blast Radius                          │   │
│   │   Isolated. Contained. Owns only its space.            │   │
│   └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

The silo contains everything needed to complete its domain:
- Data (in, work, archive)
- Logic (justfile, scripts)
- Schema (schema.json, queries.json)
- Prompts (domain context)
- State (markers, locks)

**Stuff comes in. Things go out. The blast radius is one.**

---

## 2. The Dev Repo Is the Source of Truth

The silo runtime knows its origin.

```
┌──────────────────┐         ┌──────────────────┐
│   Dev Repo       │ ←────── │   Silo Runtime   │
│   (silo_barley)  │  sync   │   ~/Dev/silo_bar │
│                  │         │                  │
│   .git/          │         │   .silo (rev)    │
│   justfile       │ ──────→ │   justfile       │
│   schema.json    │         │   schema.json    │
│   README.md      │         │   ...            │
└──────────────────┘         └──────────────────┘
```

### Sync Model

| Direction | Trigger | What Syncs |
|-----------|---------|------------|
| Dev → Silo | `just pull` | Recipes, schema, prompts |
| Silo → Dev | `just push` | Data outputs, state |
| Both | `just sync` | Bidirectional merge |

### Why This Matters

1. **Reproducibility** — The git history IS the audit trail
2. **Experiment** — Branch to try risky changes, merge when stable
3. **Recovery** — Blow up the silo, pull fresh from dev
4. **Collaboration** — Multiple agents can work from the same dev repo

---

## 3. Unique Identity

Every silo has:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "silo_barley",
  "version": "1.0.0",
  "revision": "abc123f",
  "origin": "https://github.com/pjsvis/silo_barley",
  "created": "2026-03-31T12:00:00Z",
  "owner": "pjsvis"
}
```

- **UUID v4** — Guaranteed unique, no central registry needed
- **Revision** — Current git commit hash
- **Origin** — URL to sync back to

The silo can always find its source and knows exactly what version it's running.

---

## 4. The Blast Radius Model

### The Problem with Traditional Security

> "Don't access production data."
> "Don't write outside your directory."
> "Don't make network calls to external APIs."

**Agents are stubborn.** They will find ways around policies. They will follow instructions that lead somewhere unexpected. They will make mistakes.

### The Insight

> **Physical isolation > Policy enforcement.**

Instead of "you *shouldn't*," make it "you *can't*."

```
┌────────────────────────────────────────────────────────────┐
│                         WORLD                               │
│                                                             │
│    ┌──────────┐        ┌──────────┐        ┌──────────┐     │
│    │  Silo A  │        │  Silo B  │        │  Silo C  │     │
│    │ blast=1  │        │ blast=1  │        │ blast=1  │     │
│    └──────────┘        └──────────┘        └──────────┘     │
│         │                     │                     │        │
└─────────┼─────────────────────┼─────────────────────┼──────┘
          │                     │                     │
          │    If A explodes:   │                     │
          ▼                     ▼                     ▼
    ┌───────────┐        ┌───────────┐         ┌───────────┐
    │   BOOM    │        │   FINE    │         │   FINE    │
    │  (A only) │        │           │         │           │
    └───────────┘        └───────────┘         └───────────┘
```

### Blast Radius Levels

| Level | Name | Network | Filesystem | Memory | Use Case |
|-------|------|---------|-----------|--------|----------|
| 0 | **Void** | None | Self only | 64MB | Throwaway tests |
| 1 | **Lab** | Allowlist | Self + tmp | 512MB | Experimentation |
| 2 | **Dev** | localhost+ | ~/Dev | 2GB | Development work |
| 3 | **Prod** | Any | Any | 8GB | Production access |

### Enforcement

**Level 0-1 (Lab/Void):**
- Container or chroot
- Strict network allowlist
- Read-only filesystem (except tmp)

**Level 2 (Dev):**
- User namespace isolation
- Relaxed network (localhost services)
- Write access to silo directory only

**Level 3 (Prod):**
- Full access
- Human oversight required
- Audit logging enabled

### The Blast Radius Promise

> **"Just do it here. Not anywhere else."**

When a silo has `blast_radius = 1`:
- It can only hurt itself
- The rest of the system is safe
- Agents can experiment freely
- Mistakes are contained

---

## 5. Multi-Silo Patterns

### 5.1 Discovery

Silos announce themselves to a local registry.

```bash
# On silo startup:
just announce

# Queries local registry:
just silo-list
# silo_barley    abc123f  lab    /Users/pjsvis/Dev/silo_barley
# silo_alerts   def456a  lab    /Users/pjsvis/Dev/silo_alerts
```

Registry file: `~/.config/just-silo/registry.json`

### 5.2 Coordination

Silos coordinate via marker files.

```
silo_barley/
├── work/
│   └── markers/
│       ├── harvest.done
│       └── process.done
└── out/
    └── results/
```

```bash
# Agent in silo_barley:
just lock process
just process
just done process

# Agent in silo_alerts (waiting):
just wait silo_barley/work/markers/process.done
just alert
```

### 5.3 Relay (Cross-Silo Pipeline)

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ silo_input  │ ──── │ silo_barley │ ──── │ silo_alerts │
│ (source)    │      │ (processor) │      │ (output)    │
└─────────────┘      └─────────────┘      └─────────────┘
     in/                  work/                 out/
```

```bash
# In silo_barley, after processing:
just relay silo_alerts
# Copies out/results/* → silo_alerts/in/pending/
```

---

## 6. Directory Structure

### The Silo Runtime

```
silo_barley/
├── .silo              # Manifest (id, version, revision, blast_radius)
├── .git/              # Git repo (origin, branches, history)
├── justfile           # Vocabulary (verbs you define)
├── schema.json        # Grammar (what valid data looks like)
├── queries.json       # Named jq filters
├── README.md          # Domain context
│
├── in/                # Stuff comes in
│   ├── pending/       # Not yet processed
│   ├── processing/    # Currently working
│   └── done/          # Successfully ingested
│
├── work/              # Active state
│   ├── data.jsonl     # Current working set
│   ├── quarantine/    # Failed validation
│   └── markers/       # Coordination locks
│       ├── harvest.done
│       └── process.done
│
├── out/               # Things go out
│   ├── results/       # Successful outputs
│   ├── alerts/        # Critical items surfaced
│   └── errors/        # Failures for review
│
├── archive/           # Historical
│   └── YYYY-MM/
│       ├── harvest-2026-03.jsonl
│       └── process-2026-03.jsonl
│
└── .siloignore        # Files not synced to dev
```

**Key insight:** `in` and `out` are just sub-folders. The workflow is explicit. There is no magic.

### The Dev Repo

```
silo_barley (dev repo)/
├── .git/
├── justfile           # Recipes
├── schema.json        # Schema
├── queries.json       # Filters
├── README.md          # Domain context
├── .silo              # Manifest template
├── .siloignore        # Don't sync these
│
└── templates/        # Optional: starter data
    └── harvest.jsonl
```

Differences from runtime:
- No `in/`, `work/`, `out/` (data)
- No `.git/` (it's the dev repo itself)
- Has `.siloignore` to exclude data from sync

---

## 7. Workflow Examples

### 7.1 Basic Silo Lifecycle

```bash
# 1. Clone dev repo
git clone https://github.com/pjsvis/silo_barley.git ~/Dev/silo_barley
cd ~/Dev/silo_barley

# 2. Initialize runtime
just init
# Creates: in/, work/, out/, archive/
# Reads: .silo for manifest

# 3. Work
just harvest           # Ingest data
just process           # Transform data
just status            # Observe state
just flush             # Archive to out/

# 4. Sync back
just push              # Push data outputs to origin
```

### 7.2 Multi-Agent Pipeline

```bash
# Terminal 1: Agent A (harvester)
cd ~/Dev/silo_barley
just lock harvest
just harvest
just done harvest

# Terminal 2: Agent B (processor)
cd ~/Dev/silo_barley
just wait harvest.done
just lock process
just process
just done process

# Terminal 3: Agent C (alerter)
cd ~/Dev/silo_alerts
just wait silo_barley/work/markers/process.done
just alert
```

### 7.3 Blast Radius Experiment

```bash
# Create a sandbox silo with level 1 (lab)
just new silo_experiment --blast-radius 1

cd silo_experiment

# Try something risky
just risky-thing

# If it blows up:
# - Only this silo affected
# - Other silos fine
# - Just pull fresh: just pull

# If it works:
# - Merge back to dev: just push
# - Merge to main silo: git merge experiment
```

---

## 8. Questions & Open Items

### Identity
- [ ] UUID generation: use existing tool or embed in just-silo?
- [ ] Should silos have human-readable names beyond the directory?

### Discovery
- [ ] Registry-based or pure filesystem discovery?
- [ ] Should silos announce to a network service?

### Sync
- [ ] Push-only, pull-only, or bidirectional?
- [ ] Conflict resolution for bidirectional sync?
- [ ] How to handle large data files?

### Blast Radius
- [ ] What's the minimum viable enforcement? (Container? Landlock? Trust?)
- [ ] Should blast radius be per-silo or per-task?
- [ ] How to audit boundary crossings?

### Coordination
- [ ] File-based markers sufficient?
- [ ] Need a message queue for async?
- [ ] How to handle silo failures gracefully?

---

## 9. Implementation Phases

### Phase 1: Manifest & Identity
- [ ] Add `id` and `revision` to `.silo`
- [ ] `just init` creates runtime directories
- [ ] `just pull` / `just push` commands

### Phase 2: Discovery
- [ ] Registry file at `~/.config/just-silo/registry.json`
- [ ] `just announce` to register
- [ ] `just silo-list` to show all silos

### Phase 3: Blast Radius (Lab)
- [ ] Containerized execution option
- [ ] Network allowlist
- [ ] Filesystem sandbox

### Phase 4: Coordination
- [ ] `just lock` / `just wait` / `just done`
- [ ] Cross-silo references
- [ ] `just relay` for pipeline mode

### Phase 5: Full Implementation
- [ ] All blast radius levels
- [ ] Bidirectional sync
- [ ] Audit logging
- [ ] Conflict resolution

---

## 10. Related Documents

- [Silo-Manual.md](../Silo-Manual.md) — Current implementation
- [Brief: Multi-Silo Architecture](../briefs/2026-03-31-multi-silo-architecture.md)
- [Brief: Blast Radius Security](../briefs/2026-03-31-blast-radius-security.md)
- [td Playbook](../playbooks/td-playbook.md) — Task management

---

## Appendix A: Manifest Schema

```json
{
  "$schema": "https://just-silo.dev/schemas/silo.json",
  "type": "object",
  "required": ["id", "name", "version"],
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique silo identifier"
    },
    "name": {
      "type": "string",
      "pattern": "^silo_[a-z0-9_]+$",
      "description": "Human-readable name (directory name)"
    },
    "version": {
      "type": "string",
      "description": "Silo version (semver)"
    },
    "revision": {
      "type": "string",
      "description": "Current git commit hash"
    },
    "origin": {
      "type": "string",
      "format": "uri",
      "description": "Git remote URL"
    },
    "owner": {
      "type": "string",
      "description": "Username or team"
    },
    "created": {
      "type": "string",
      "format": "date-time"
    },
    "blast_radius": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3,
      "default": 2,
      "description": "Isolation level (0=void, 1=lab, 2=dev, 3=prod)"
    },
    "interface": {
      "type": "object",
      "properties": {
        "in": { "type": "string", "default": "in/" },
        "out": { "type": "string", "default": "out/" },
        "work": { "type": "string", "default": "work/" },
        "archive": { "type": "string", "default": "archive/" }
      }
    }
  }
}
```

---

## Appendix B: .siloignore Example

```
# Data (runtime only)
in/
work/
out/
archive/

# OS
.DS_Store
*.swp

# IDE
.vscode/
.idea/

# Temporary
*.tmp
*.bak
```

---

*This is speculative design. Implementation will follow.*
