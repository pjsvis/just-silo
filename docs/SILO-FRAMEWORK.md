# Silo Framework — Internal Structure

**Version:** 0.2.0

---

## What a Silo Is

A directory with a contract. The agent reads the contract, does the work.

```
silo/
├── .silo              # Manifest: name, version, workflow
├── README.md          # What, why, how
├── justfile           # Task recipes (the interface)
│
├── inbox/             # Raw inputs
├── process/           # Transformation scripts
├── outbox/            # Deliverables
│
├── briefs/            # What we're considering
├── debriefs/          # What we learned
├── playbooks/         # How we operate
│
├── markers/           # Checkpoint system
└── telemetry/         # Cost/token logs
```

---

## The Three Questions

Every silo answers these:

| Question | Where |
|----------|-------|
| What do we get? | `inbox/` — raw data, documents |
| What do we do with it? | `process/` — scripts, justfile recipes |
| What is the end result? | `outbox/` — deliverables |
| How do we know we have it? | `markers/`, `telemetry/` — state, costs |

---

## Workflow

```
inbox/ ──→ process/ ──→ outbox/
   │          │            │
   │          │            │
   └─ briefs/             └─ debriefs/
      playbooks/
```

**`process/` does the work.** `briefs/` and `playbooks/` feed decisions into `process/`. `debriefs/` capture what happened.

---

## The Four Layers

| Layer | Contents | Managed By |
|-------|----------|------------|
| **Thinking** | `briefs/`, `debriefs/`, `playbooks/` | Human + Agent, via Git |
| **Our Code** | `justfile`, `process/*.sh`, `src/` | Agent, via just |
| **Runtime** | bun, TypeScript, hono | Assumed present |
| **Environment** | flox, jq, pandoc, pdftotext | `flox.toml` |

---

## Justfile

The interface. Thin recipes that delegate to `process/` scripts.

```bash
just status          # Pipeline state
just run             # Execute workflow
just <verb>          # Domain-specific action
```

**Rule:** No inline logic beyond simple delegation (`echo`, `cd`, `./scripts/foo.sh`). Logic lives in `process/`.

---

## Manifest

`.silo` — JSON manifest:

```json
{
  "name": "ai-legislation-silo",
  "version": "0.1.0",
  "workflow": "inbox → process → outbox",
  "layers": {
    "environment": { "manager": "flox", "tools": ["just", "jq"] },
    "runtime": { "languages": ["bash", "TypeScript"] },
    "code": { "engine": "justfile", "scripts_dir": "process/" },
    "thinking": { "briefs_dir": "briefs/", "playbooks_dir": "playbooks/" }
  }
}
```

---

## Observability

| System | File | Purpose |
|--------|------|---------|
| Checkpoints | `markers/*.jsonl` | Phase completion, agent assignments |
| Costs | `telemetry/costs.jsonl` | Per-phase token/cost tracking |
| State | `markers/acquisition-state.jsonl` | Document pipeline state |

---

## Example

See `examples/ai-legislation-silo/` — a working silo with inbox, process, outbox, and full documentation structure.
