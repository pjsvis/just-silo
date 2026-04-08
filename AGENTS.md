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

## See Also

- `playbooks/bestiary-human-tendencies.md` — Known failure modes
- `briefs/` — Project briefs and research
- `presentation/` — SSE presentation server

---

**Status:** Simplified. Local dev is direct. Remote is monitoring.
