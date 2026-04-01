# Silo Builder Playbook

**For creating new silos.**

---

## The Idea

**You have stuff. You want things. You create a silo.**

```
STUFF ──→ [ SILO ] ──→ THINGS
```

**You define the stuff. You define the things. The silo does the conversion.**

```
"I have grain moisture readings. I want alerts when it's too high."
→ silo_barley created
→ stuff: moisture readings
→ things: alerts
→ verbs: harvest, alert, threshold
```

## Pocket Universe

```
input ──→ [ SILO ] ──→ output
          ┌─────────┐
          │ vocab   │  ← You define these
          │ grammar │  ← What data looks like
          │ rules   │  ← What you can do
          │ state   │  ← Working memory
          └─────────┘
```

**When they're in, they can only do what you allow. That's the point.**

## Files Required

| File | Purpose |
|------|---------|
| `.silo` | Manifest (name, version, type) |
| `README.md` | Domain description |
| `schema.json` | JSON Schema validation |
| `queries.json` | Named jq filters |
| `justfile` | Vocabulary (your verbs) |
| `process.sh` | Domain script |

## Recipe Order

Recipes ordered by workflow:

```
Mount  → verify
Sieve  → harvest
Do     → <your-verb>
Observe → status, who, stuck, throughput, audit, alerts
Flush  → flush
Help   → help, help <verb>
```

## The Pattern

```
just <verb>        → just do it
just help <verb>  → what will it do?
just help          → what verbs exist?
just status        → aggregate health
```

## justfile Template

```just
set shell := ["bash", "-o", "pipefail", "-c"]
set export := true

DATA_FILE      := "data.jsonl"
HARVEST_FILE   := "harvest.jsonl"
SCHEMA_FILE    := "schema.json"
QUERIES_FILE   := "queries.json"
PIPELINE_FILE  := "pipeline.json"
MARKERS_DIR    := "markers"
SCRIPTS_DIR    := "scripts"

default:
    @just --list

# Help
help target="":
    @if [ "{{target}}" = "" ]; then \
        echo "Just do it."; \
        echo "just help <verb> for command help"; \
    fi

# Core
verify:
    @test -f {{SCHEMA_FILE}} && echo "  schema ok"

harvest source=(HARVEST_FILE):
    @just verify
    @cat {{source}} | jq -c ... >> {{DATA_FILE}}

# Observability
status:
    @echo "=== PIPELINE STATUS ==="
    @./{{SCRIPTS_DIR}}/status_stages.sh
    @./{{SCRIPTS_DIR}}/status_throughput.sh
    @./{{SCRIPTS_DIR}}/status_stuck.sh

# Your verbs
<your-verb>:
    @./<your-script>.sh
```

## Checklist

- [ ] `.silo` manifest with domain name
- [ ] `README.md` with pocket universe framing
- [ ] `schema.json` with required fields
- [ ] `queries.json` with named filters
- [ ] `justfile` with your verbs
- [ ] `pipeline.json` with stage definitions
- [ ] `scripts/` with observability helpers
- [ ] `just help` works
- [ ] `just status` works

## Anti-Patterns

- ❌ Don't pre-define vocabulary — let it emerge
- ❌ Don't skip schema validation
- ❌ Don't skip `just flush`
- ❌ Don't hardcode jq — use queries.json
- ❌ Don't over-engineer — simple job, get stuff, turn into things

## Remember

**The tool is called `just`. The usage is `just do it`.**

Constraints create capability. The rules are the rails.
