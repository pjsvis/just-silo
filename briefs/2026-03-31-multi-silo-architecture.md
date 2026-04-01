---
date: 2026-03-31
tags: [just-silo, architecture, multi-silo, blast-radius]
---

# Brief: Multi-Silo Architecture

## Context

Single silos are great. But what about multiple silos? What happens when you have silos that know about each other, discover each other, coordinate?

## Core Concepts

### 1. Silos Are Self-Announcing

Every silo has a manifest (`.silo`) that declares:

```json
{
  "id": "uuid-v4-here",
  "name": "silo_barley",
  "version": "1.0.0",
  "revision": "abc123f",
  "origin": "https://github.com/pjsvis/silo_barley",
  "runtime": "local",
  "bounds": {
    "network": "isolated",
    "filesystem": "self",
    "memory_mb": 512
  },
  "interface": {
    "in": "in/",
    "out": "out/",
    "work": "work/",
    "archive": "archive/"
  }
}
```

### 2. Unique Identity

- **UUID v4** — every silo gets one at creation
- **Revision hash** — current git commit
- **Origin URL** — back to dev repo

The silo knows where it came from and can sync back.

### 3. Revisioning

```
Silo is a git repo.

silo_barley/
├── .git/
├── .silo          # Manifest with revision
├── justfile
├── in/            # Stuff comes in
├── out/           # Things go out
├── work/          # Working state
├── archive/       # Historical
└── README.md
```

- Branches for experiments
- Tags for versions
- Fork to try something risky
- Merge back when stable

### 4. The Blast Radius

**This is the killer feature.**

> "Just do it here. Not anywhere else."

```
┌─────────────────────────────────────────────────────────────┐
│                         WORLD                               │
│                                                              │
│    ┌──────────┐         ┌──────────┐         ┌──────────┐    │
│    │  Silo A │         │  Silo B  │         │  Silo C  │    │
│    │ blast=1 │         │ blast=1  │         │ blast=1  │    │
│    └──────────┘         └──────────┘         └──────────┘    │
│         │                    │                    │         │
└─────────┼────────────────────┼────────────────────┼─────────┘
          │                    │                    │
    ┌─────┴─────┐         ┌────┴────┐          ┌───┴────┐
    │  If A     │         │  B is   │          │  C     │
    │  explodes │         │  fine   │          │  fine  │
    │  B & C    │         │         │          │        │
    │  unaffected│         │         │          │        │
    └───────────┘         └─────────┘          └────────┘
```

**Blast radius = 1 means the damage stays contained.**

#### Blast Radius Modes

| Mode | Network | Filesystem | Process |
|------|---------|-----------|---------|
| `isolated` | None | Self only | Capped |
| `local` | localhost | ~/Dev | Capped |
| `networked` | Any | Self + tmp | Capped |
| `open` | Any | Any | Uncapped |

#### Why This Matters

Traditional security: "You *shouldn't* access that."
Blast radius security: "You *can't* access that."

- Silos run in restricted environments
- Network calls blocked or proxied
- Filesystem writes sandboxed
- Memory/CPU limits enforced

**If it blows up, it only blows up here.**

### 5. Stuff In, Things Out

```
in/              # Input queue
├── pending/     # Not yet processed
├── processing/  # Currently working
└── done/        # Successfully processed

out/             # Output
├── results/     # Successful outputs
├── alerts/      # Critical items surfaced
└── errors/      # Failures (for review)

work/            # Active state
├── data.jsonl   # Current working set
├── quarantine/  # Failed validation
└── markers/     # Coordination locks

archive/         # Historical
└── YYYY-MM/    # Organized by date
```

**In and out are just sub-folders.** The workflow is explicit.

## Multi-Silo Patterns

### 1. Discovery

```bash
# List all silos in ~/Dev/
ls ~/Dev/silo_*/

# Or use a registry
just silo-registry list

# Silos announce themselves
just announce  # Registers with local registry
```

### 2. Coordination

```bash
# Agent in Silo A
just lock process.done
just work
just done process

# Agent in Silo B waits
just wait silo_barley/process.done
just relay
```

### 3. Relay (Cross-Silo)

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ silo_input  │ ──── │ silo_barley │ ──── │ silo_alerts │
│ (source)    │      │ (processor) │      │ (output)    │
└─────────────┘      └─────────────┘      └─────────────┘
```

Silo A outputs → becomes Silo B input.

## Questions

1. **Registry vs discovery?** Static list (~/Dev/silos/) or dynamic announcement?

2. **Sync strategy?** 
   - Push: silo pushes to origin
   - Pull: dev pulls from silos
   - Hybrid: both

3. **Blast radius enforcement?**
   - OS-level sandboxing (containers, VMs)
   - Language-level (syscall filtering)
   - Convention-only (trust)

4. **Cross-silo communication?**
   - File-based (out/ → in/)
   - Message queue
   - Direct (if networked)

## Open Questions

- How do silos find each other?
- What's the security model for cross-silo data?
- Do silos have owners? Groups?
- How does versioning work in practice?

## Status

- [x] Concept sketched
- [ ] Requirements gathering
- [ ] Architecture design
- [ ] Implementation plan
