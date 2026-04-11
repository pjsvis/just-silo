# just-silo — AGENTS.md

---

## Workflow

### Local Development

Direct. No agents, no multiplexers.

- **Editor:** Zed
- **Terminal:** Built-in or standalone
- **Run:** `bun run`, `just`, `bash`
- **Test:** `bun test`

### Remote Development

Monitoring only.

- Watch: `git log`, `td status`, `bun test`
- Act: Only when necessary

---

## What Was Here

This project previously had an agent orchestration layer. It's been decommissioned.

**Removed:**
- Sub-agent spawn governance
- Agent trigger architecture
- Multi-agent coordination via markers
- test-agent, docs-agent, review-agent, etc.

**Reason:** For local dev, direct terminal + editor is faster. Agents add complexity without value.

---

## The Silo Framework (Still Active)

The **silo** framework for externalizing domain knowledge is still useful:

```
my-silo/
├── .silo              # Manifest
├── README.md          # Domain rules
├── schema.json        # Validation
├── queries.json       # Named jq filters
├── justfile           # Recipes
├── harvest.jsonl      # Raw data
└── process.sh        # Domain logic
```

**When to use silos:**
- Persisting domain knowledge across sessions
- Structured data pipelines
- Named query reuse

**When not to use silos:**
- One-off scripts → just write the script
- Simple tasks → direct terminal
- Real-time interaction → direct terminal

---

## Prerequisites

- `bun` — runtime
- `just` — task runner (`brew install just`)
- `jq` — JSON processing (`brew install jq`)
- `zed` — editor (optional)

---

## Quick Reference

```bash
# Run a script
bun run server.ts

# Test
bun test

# Watch mode
bun --watch run server.ts

# Task runner
just --list

# Watch tests
bun test --watch
```

---

## Experimental Tiers

Scripts evolve through tiers as they mature:

```
@scripts/lab/     → scripts/  → src/
  ↑                 ↑           ↑
  Tier 0            Tier 1      Tier 2
  (experimental)    (stable)   (production)
```

| Tier | Location | Rules |
|------|----------|-------|
| 0 | `@scripts/lab/` | Experimental. No review. Promote when stable. |
| 1 | `scripts/` | Stable. Reviewed. Production-ready. |
| 2 | `src/` | Full rigor. Types, tests, documentation. |

### Tier 0: @scripts/lab/

Experimental scripts with `@` prefix. Agents try ideas here:

```bash
scripts/lab/
├── @entropy-viz.sh    # Trying visualization
├── @jq-playground.sh  # Testing jq patterns
└── @experiment.sh     # Wild idea
```

**Rules:**
- No review required
- Promote to `scripts/` when stable
- Gamma-loop archives stale experiments

### Tier 1: scripts/

Stable, production scripts. Reviewed before promotion:

```bash
scripts/
├── silo-create.sh       # Stable
├── silo-ignite.sh      # Stable
└── silo-log.sh        # Stable
```

### Tier 2: src/

TypeScript/Production code. Full rigor:

```bash
src/
├── silo-api-server.ts  # Types, tests, docs
└── lib/
    └── silo-logger.ts  # Full quality

**TypeScript config tiers:**
```json
tsconfig.json          // Tier 2: strict, no implicit any
tsconfig.scripts.json // Tier 1: relaxed, allowJs
```

**Commands:**
```bash
just dev-typecheck   # Check all tiers
just dev-checkall   # Type + tests
```


---

## Agent Scratchpad

The **scratch/** directory is the agent's private workspace:

```bash
scratch/          # NOT COMMITTED
├── draft-*.md     # Thinking out loud
├── test-*.jsonl   # Playground data
└── exploration/   # Free-form
```

**Rules:**
- Never committed (in `.gitignore`)
- Agent's private workspace
- Gamma-loop archives stale scratch

---

## The Simplicity Rule

> **Extract to scripts. Keep justfiles thin.**

| Situation | Don't Do | Do |
|-----------|----------|----|
| Recipe > 80 chars | Inline jq | `scripts/process.sh` |
| Data transformation | `jq` in justfile | `scripts/transform.sh` |
| Multi-step logic | Long recipe with `\` | Call scripts |

See: `playbooks/justfile-design-playbook.md`

---

## See Also

- `playbooks/bestiary-human-tendencies.md` — Known failure modes
- `playbooks/justfile-design-playbook.md` — Recipe design rules
- `playbooks/gamma-loop-playbook.md` — Gamma-loop pattern
- `briefs/` — Project briefs and research
- `presentation/` — SSE presentation server

---

**Status:** Simplified. Local dev is direct. Remote is monitoring.
