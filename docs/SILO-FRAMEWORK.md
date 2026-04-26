# Silo Framework — Technical Documentation

**Version:** 0.2.0

---

## Overview

A directory-based skill and data pipeline system for AI agents. Domain knowledge externalized into self-contained, versionable directories.

```
silo/
├── .silo              # Manifest (name, version, workflow)
├── justfile           # Task recipes (interface)
├── inbox/             # Raw inputs
├── process/           # Transformation scripts
├── outbox/            # Deliverables
├── briefs/            # Active research, plans
├── debriefs/          # Session records
├── playbooks/         # Operational procedures
├── markers/           # Checkpoint system
└── telemetry/         # Cost/token logs
```

---

## Lifecycle

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ CREATE  │───▶│ BUILD   │───▶│ DEPLOY  │───▶│ OPERATE │
│         │    │         │    │         │    │         │
│ template│    │ dev/    │    │ silos/  │    │ just <cmd>│
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

| Phase | Command | Location |
|-------|---------|----------|
| Create | `silo-create <name>` | From `template/` |
| Build | `silo-build <name>` | `dev/<name>/` workspace |
| Deploy | `silo-deploy <name>` | `silos/<name>/` runtime |
| Operate | `just <verb>` | Within silo directory |

---

## Phase Workflow (Justfile)

| Phase | Command | Purpose |
|-------|---------|---------|
| **Gate** | `just silo-gate` | Verify invariants before any write |
| **Ingest** | `just ingest` (or `just get`) | Load raw data into inbox |
| **Transform** | `just transform` (or `just process`) | Apply transformations |
| **Deliver** | `just deliver` (or `just flush`) | Write outputs to outbox |
| **Status** | `just status` | Pipeline observability |

**Gate is orthogonal.** It runs before writes, not as part of the pipeline flow.

---

## Gamma Loop

Self-improvement mechanism:

```
┌─────────────────────────────────────┐
│  DO → LEARN → DEBRIEF → IMPROVE    │
│                                     │
│  • playbooks/ — captured knowledge │
│  • debriefs/  — post-mortems       │
│  • telemetry/ — metrics/logs       │
└─────────────────────────────────────┘
```

---

## Quick Start

```bash
# Create from template
./scripts/silo-create my-silo

# Build in dev workspace
./scripts/silo-build.sh my-silo

# Deploy to runtime
./scripts/silo-deploy.sh my-silo

# Operate
cd silos/my-silo
just status
just ingest
just transform
just deliver
```

---

## Related

- `template/` — The template itself
- `playbooks/silo-anatomy-playbook.md` — Four-layer model
- `examples/ai-legislation-silo/` — Working example
