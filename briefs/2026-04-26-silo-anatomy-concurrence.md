---
date: 2026-04-26
tags: [brief, silo, anatomy, architecture, just, flox, bun]
---

# Brief: Silo Anatomy — Framework Concurrence

## The Agreement

A silo has four layers:

```
┌─────────────────────────────────────────┐
│  LAYER 4: Thinking                       │
│  briefs/    — What we're considering     │
│  debriefs/  — What we learned            │
│  playbooks/ — How we operate             │
├─────────────────────────────────────────┤
│  LAYER 3: Our Code                      │
│  justfile   — Task recipes               │
│  scripts/   — Shell/bash logic           │
│  src/       — TypeScript (Tier 2)        │
├─────────────────────────────────────────┤
│  LAYER 2: Runtime                       │
│  bun        — JavaScript runtime         │
│  TypeScript — Types, compilation         │
│  hono       — HTTP framework (when API) │
├─────────────────────────────────────────┤
│  LAYER 1: Environment                   │
│  flox       — Tool provisioning          │
│  jq, just, etc. — Dependencies           │
└─────────────────────────────────────────┘
```

## Layer Boundaries

| Layer | Owned By | Managed By | Changed When |
|-------|----------|------------|--------------|
| Thinking | Human + Agent | Git | Every session |
| Our Code | Agent | justfile | Every task |
| Runtime | Framework | bun + tsconfig | New features |
| Environment | System | flox.toml | New tool needs |

## Key Principle

**just is for stuff we write. flox is for stuff the silo needs from its environment.**

- just = recipes, scripts, business logic, workflow orchestration
- flox = pandoc, pdftotext, jq, watchexec — tools we invoke but did not create
- briefs/debriefs/playbooks = how we develop the silo (not part of runtime)
- bun/TS/hono = execution substrate (assumed present, not managed per-silo)

## Deployment

Not a current concern. When needed:
- just recipes can package, test, deploy
- flox environments replicate on target machines
- The silo is a filesystem; deployment is copying + activating

## Implication for ai-legislation-silo

The example silo should show all four layers:
- `briefs/` — content acquisition strategy, granularity decisions
- `playbooks/` — PDF extraction, schema validation
- `justfile` — inbox → process → outbox workflow
- `process/` — scripts that implement the workflow
- `.silo` manifest — references Flox for tools, not inline installation
