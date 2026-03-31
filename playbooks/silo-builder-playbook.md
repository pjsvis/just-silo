# Silo Builder Playbook

**For creating new silos.**

---

## Files Required

| File | Purpose |
|------|---------|
| `.silo` | Manifest (name, version, type) |
| `README.md` | Domain description |
| `schema.json` | JSON Schema validation |
| `queries.json` | Named jq filters |
| `justfile` | CLI interface |
| `process.sh` | Domain script |

## Recipe Order

Recipes ordered by workflow:

```
1. Mount  → verify
2. Sieve  → harvest
3. Process → process
4. Check  → alerts, stats, query, report
5. Flush  → flush, compact
Maint.    → install-deps, self-test, clean
```

## justfile Template

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

## process.sh Template

```bash
#!/bin/bash
# Deductive Minimalism (COG-12)
set -euo pipefail

for line in $(cat data.jsonl); do
    echo "$line" | jq '.status = "processed"'
done >> final_output.jsonl
```

## Checklist

- [ ] `.silo` manifest with domain name
- [ ] `README.md` with workflow diagram
- [ ] `schema.json` with required fields
- [ ] `queries.json` with 2+ named filters
- [ ] `justfile` with all recipes
- [ ] `process.sh` executable
- [ ] `just verify` passes
- [ ] `just self-test` passes

## Anti-Patterns

- ❌ Don't put logic in justfile
- ❌ Don't skip schema validation
- ❌ Don't skip `just flush`
- ❌ Don't hardcode jq — use queries.json
