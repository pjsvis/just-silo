# Silo Builder Playbook

**For creating new silos.**

---

## AI Harness: Pi

**Use [pi](https://github.com/mariozechner/pi-coding-agent) to build silos.**

Pi is a minimalistic coding agent that:
- Reads files and executes commands
- Works with any codebase
- Has built-in `skill-builder` for just-silo

### Quick Start with Pi

```bash
# Tell pi to build a silo
pi -p "Create a silo for monitoring API latency. I want alerts when response > 500ms"

# Or use the skill directly
pi -p "Use skill-builder to create a new silo"
```

### Why Pi?

| Feature | Pi | Other Agents |
|---------|-----|-------------|
| Context | Filesystem-native | Prompts |
| Recipes | Built-in just-silo | Justfile |
| Complexity | Minimal | Heavy |
| Lock-in | None | Vendor |

**Philosophy:** Like just-silo itself, pi is minimal. It reads the filesystem, not your memory.

### The Pi + Silo Pattern

```
User: "Build a silo for X"
  ↓
Pi: cd into workspace, read skill-builder
  ↓
Pi: Uses just-silo template, creates silo
  ↓
Pi: Runs just verify, confirms it works
```

---

## The Reveal

**You don't pre-define the vocabulary. You just say what you want.**

```
"I want to monitor grain moisture and alert when it's too high."
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes."
→ just scan, just score, just flag...
```

**You say the words. Just-silo makes them executable.**

The vocabulary emerges from your intent. You define the verbs, not the tool.

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

## Creating New Silos

**Policy: A new silo is a clone of just-silo, customized for a domain.**

### The Simple Path: Clone

```bash
# Clone just-silo as your new silo
git clone git@github.com:pjsvis/just-silo.git my-new-silo
cd my-new-silo

# Customize for your domain
# 1. Edit .silo (name, domain, description)
# 2. Edit justfile (your verbs)
# 3. Edit schema.json (your data types)
# 4. Edit silo-lexicon.jsonl (your vocabulary)

# Verify it works
just verify
```

### Sub-Silos

**Not needed yet.** Defer until a concrete use case emerges.

If you find yourself wanting sub-silos, ask:
- Are they really separate domains?
- Would copy-paste be simpler?
- Do we need runtime coordination?

Most "sub-silo" needs are better served by:
- Multiple independent silos
- A parent justfile that orchestrates children

### Inter-Silo Communication

**Future problem.** For now, silos are independent.

Future strategies (not implemented):
- Shared brief/debrief repository
- Event bus between silos
- "Super-silo" that spawns children

### Focus

Develop the current silo. Ship it. Learn from it.

New silos = clone + customize.
New patterns = emerge from use, don't preempt.

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
- [ ] **Test with pi:** `pi -p "Test this silo: just verify && just status"`

## Scaling Philosophy

just-silo is a **rapid prototyping tool for workflows**, not enterprise infrastructure.

**Comfortable operating range:**

| Dimension | Comfortable | Warning | Danger |
|-----------|-------------|---------|--------|
| Silo count | 5-20 | 20-50 | 50+ |
| Stages per silo | 3-7 | 7-15 | 15+ |
| Lines per skill | 50-200 | 200-500 | 500+ |
| Shared modules | 0-3 | 3-7 | 7+ |
| External dependencies | 0 | 1-3 | 3+ |

**Practical rule:** If you can't explain a silo to a colleague in 60 seconds, it's too complex.

**When to graduate to heavier tools:**
- Need distributed execution across machines → Temporal, Airflow
- Need sub-second latency → dedicated service
- Need 99.9% uptime SLA → managed workflow service
- Managing 50+ silos → you're a platform team now

**Architecture principles:**
1. **Flat is fine** — One silo folder, minimal nesting
2. **No shared modules until duplication screams** — Copy-paste is fine for silos
3. **Bash + just is enough** — Add TypeScript only when complexity demands it
4. **Zero external dependencies** — Bun stdlib is your ceiling

**The philosophy:** Make it work. Make it right. Make it fast. In that order, only when needed.

## Anti-Patterns

- ❌ Don't pre-define vocabulary — let it emerge
- ❌ Don't skip schema validation
- ❌ Don't skip `just flush`
- ❌ Don't hardcode jq — use queries.json
- ❌ Don't over-engineer — simple job, get stuff, turn into things

## Remember

**The tool is called `just`. The usage is `just do it`.**

Constraints create capability. The rules are the rails.
