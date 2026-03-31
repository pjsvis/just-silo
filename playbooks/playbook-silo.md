# Playbook: Silo

**Quick reference for agents building and using silos.**

---

## Build a Silo

### Files Required

| File | Purpose |
|------|---------|
| `.silo` | Manifest (name, version, type) |
| `README.md` | Domain description, workflow |
| `schema.json` | JSON Schema for validation |
| `queries.json` | Named jq filters |
| `justfile` | CLI interface |
| `process.sh` | Domain script |

### Recipe Order

Recipes are ordered by workflow:

```
1. Mount  → verify
2. Sieve  → harvest
3. Process → process
4. Check  → alerts, stats, query, report
5. Flush  → flush, compact
Maint.    → install-deps, self-test, clean
```

### justfile Template

```just
# High-Integrity Environment (COG-12)
set shell := ["bash", "-o", "pipefail", "-c"]
set export := true
set -euo pipefail

DATA_FILE      := "data.jsonl"
HARVEST_FILE   := "harvest.jsonl"
QUARANTINE_FILE := "quarantine.jsonl"
OUTPUT_FILE    := "final_output.jsonl"
SCHEMA_FILE    := "schema.json"
QUERIES_FILE   := "queries.json"

default:
    @just --list

verify:
    @test -f {{SCHEMA_FILE}} && echo "  schema ok"
    @test -f {{QUERIES_FILE}} && echo "  queries ok"
    @command -v jq >/dev/null 2>&1 && echo "  jq ok"

harvest source=(HARVEST_FILE):
    @> {{DATA_FILE}} && > {{QUARANTINE_FILE}}
    @cat {{source}} | jq -c ... >> {{DATA_FILE}}
    @just stats

process:
    @./process.sh

alerts:
    @jq -c 'select(.<field> > <threshold>)' {{DATA_FILE}}

stats:
    @echo "Active: $(jq -s 'length' {{DATA_FILE}})"

flush:
    @jq -c 'select(.status == "processed")' {{DATA_FILE}} >> {{OUTPUT_FILE}}
    @jq -c 'select(.status != "processed")' {{DATA_FILE}} > {{DATA_FILE}}.tmp
    @mv {{DATA_FILE}}.tmp {{DATA_FILE}}
```

---

## Use a Silo

### Standard Workflow

```
Mount → Sieve → Process → Check → Flush
```

```bash
cd silo_<domain>/
just verify                    # Confirm ready
just harvest                   # Ingest data
just process                   # Run domain script
just alerts                    # Surface critical items
just stats                     # Show counts
just flush                     # Compact to output
```

### Commands Reference

| Command | What it does |
|---------|--------------|
| `just verify` | Check schema, queries, jq |
| `just harvest` | Validate input → data.jsonl |
| `just process` | Run domain script |
| `just alerts` | Extract critical items |
| `just stats` | Show file counts |
| `just query <name>` | Run named filter |
| `just report` | Human-readable summary |
| `just flush` | Compact processed items |
| `just self-test` | Smoke test |
| `just clean` | Reset state files |

---

## Anti-Patterns

- ❌ Don't put logic in the justfile — use scripts
- ❌ Don't skip schema validation
- ❌ Don't skip `just flush`
- ❌ Don't hardcode jq in justfile — use queries.json

---

## Principles

1. **Sleeve Before Substrate** — Read schema/queries before data
2. **Mentational Hygiene** — Keep data.jsonl lean
3. **High-Integrity** — Use `set -euo pipefail`
4. **occupy the Territory** — `cd` into the silo
5. **Idempotency** — Safe to run twice
