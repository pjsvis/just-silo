---
date: 2026-04-26
tags: [playbook, silo, anatomy, layers, just, flox]
---

# Silo Anatomy Playbook

> **Note:** This playbook supersedes earlier documentation that referenced an `engage` toolbelt concept. `engage` was never implemented. `flox` (declarative environment management) provides the same capability: scoped tool provisioning, reproducible environments, and auditability via manifest. See `briefs/2026-04-26-engage-to-flox-pivot.md`.

## The Four Layers

Every silo has four layers. Know which layer you're touching before you write code.

### Layer 1: Environment (flox)

**Question:** What does this silo need that isn't already here?

| Tool | Flox Package | Purpose |
|------|-------------|---------|
| jq | `jq` | JSON processing |
| just | `just` | Task runner |
| pdftotext | `poppler-utils` | PDF extraction |
| pandoc | `pandoc` | Document conversion |
| bun | `nodejs` or system | JavaScript runtime |

**Rule:** If the silo needs a new tool, add it to `flox.toml`. Never `brew install` inside a silo.

```toml
# In root flox.toml or silo's .silo manifest reference
[install]
pandoc.pkg-path = "pandoc"
pandoc.optional = true
```

### Layer 2: Runtime (bun / TypeScript / hono)

**Question:** What executes our code?

- **bun** — Runs scripts, tests, API servers
- **TypeScript** — Types for Tier 2 code in `src/`
- **hono** — HTTP framework when the silo exposes an API

**Rule:** Runtime is assumed present. Don't install it per-silo. Configure it (tsconfig, package.json) but don't vendor it.

### Layer 3: Our Code (just / scripts / src)

**Question:** What does this silo actually do?

| File Type | Location | Purpose |
|-----------|----------|---------|
| justfile | root | Task facade: thin recipes that delegate |
| scripts/*.sh | `scripts/` or `process/` | Deterministic logic: validate, transform, extract |
| src/*.ts | `src/` | Tier 2 code: APIs, typed libraries, tests |

**Rule:** The justfile is a facade. Logic lives in scripts or src. No inline bash beyond simple delegation (`cd x && just y`, `echo`, `./scripts/foo.sh`).

### Layer 4: Thinking (briefs / debriefs / playbooks)

**Question:** How did we decide this? What did we learn?

| Folder | Contains | Written When |
|--------|----------|--------------|
| `briefs/` | Open questions, options, decisions pending | During exploration |
| `debriefs/` | Retrospectives, lessons, what worked | After each session |
| `playbooks/` | Operational procedures, how-to guides | When patterns stabilize |

**Rule:** Every silo has these folders. They persist thinking across sessions. Without them, context dies with the agent's context window.

## Directory Structure

```
silo-name/
├── .silo                    # Manifest (layer 1-3 references)
├── README.md                # Entry point: what, why, how
├── justfile                 # Layer 3: task facade
│
├── inbox/                   # Layer 3: raw inputs
├── process/                 # Layer 3: transformation scripts
├── outbox/                  # Layer 3: deliverables
│
├── src/                     # Layer 3: Tier 2 code (optional)
├── scripts/                 # Layer 3: supporting scripts (optional)
│
├── briefs/                  # Layer 4: active thinking
├── debriefs/                # Layer 4: session records
├── playbooks/               # Layer 4: operational knowledge
│
├── markers/                 # Layer 3: checkpoint system
├── telemetry/               # Layer 3: cost/token logs
│
└── (runtime: bun, ts, hono) # Layer 2: assumed present
    └── (environment: flox)  # Layer 1: declared in manifest
```

## Decision Tree

Before adding a file, ask:

1. **Is this a tool we need?** → flox.toml (Layer 1)
2. **Is this execution logic?** → justfile recipe or script (Layer 3)
3. **Is this typed code?** → src/*.ts (Layer 3)
4. **Is this a decision record?** → briefs/ (Layer 4)
5. **Is this a lesson learned?** → debriefs/ (Layer 4)
6. **Is this a procedure?** → playbooks/ (Layer 4)

## Anti-Patterns

| Don't Do | Do Instead | Layer |
|----------|-----------|-------|
| `brew install pandoc` inside a silo | Add `pandoc` to flox.toml | 1 |
| Inline 20-line bash in justfile | Extract to `scripts/foo.sh` | 3 |
| Write logic in `debriefs/` | Put code in `scripts/`, record decision in `briefs/` | 3 vs 4 |
| Track costs in `README.md` | Write to `telemetry/costs.jsonl` | 3 |
| Document schema in a comment | Write to `playbooks/schema-validation.md` | 4 |
