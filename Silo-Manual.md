# Manual: Silo Strategy

**Detailed guide: Why we do things this way, and how to extend them.**

---

## Naming Convention

**Naming and cache expiry are the two hard problems in computing.**

We follow a simple naming convention to keep things predictable, and possibly enable cache expiry, who knows?:

| Pattern | Example | Purpose |
|---------|---------|---------|
| **Directories** | `silo_<domain>` | Lowercase, underscores, descriptive |
| **Playbooks** | `silo-<role>-playbook.md` | Kebab-case, describes audience |
| **Briefs** | `YYYY-MM-DD-topic.md` | Date-first, searchable |
| **Debriefs** | `YYYY-MM-DD-topic.md` | Date-first, matches brief |
| **Skills** | `skill-<name>.md` | Kebab-case, action verb |
| **Recipes** | `just <verb>` | Imperative, action verb |

**Principles:**

1. **Flat is better than nested** — `Silo-Manual.md` not `manual/silo-manual.md`
2. **Date-first for chronology** — `2026-03-31-just-silo.md` sorts naturally
3. **Role-prefix for playbooks** — `silo-builder-playbook.md` shows audience
4. **Underscores for directories** — `silo_barley/` not `siloBarley`
5. **Lowercase generally** — except title-case for docs like `Silo-Manual.md`

---

## Why Bounded Context Matters

Every turn, the context window is scrubbed. But there are two problems:

| Problem | Symptom | Agent Experience |
|---------|---------|------------------|
| **Agent forgets** | Reinvention, inconsistency | "What was I doing?"
| **Agent remembers too much** | Bloat, degraded performance | "There's too much here..."

### The U-Shaped Curve

**Determinism is not linear with context size.**

```
Determinism
     ^
     |        /\
     |       /  \
     |      /    \
     |     /      \
     |----/--------\------------------>
          Small   Optimal   Large
                  Context
```

| Range | Agent Behavior |
|-------|----------------|
| **Too small** | Guessing, non-deterministic — missing critical info |
| **Optimal** | Clear signal, deterministic — just enough |
| **Too large** | Confused, non-deterministic — noise dominates |

**The insight:** More context doesn't mean more clarity. Past a threshold, signal decays.

### Example: The Growing data.jsonl

```
Turn 1: data.jsonl has 10 entries → Agent processes cleanly
Turn 50: data.jsonl has 500 entries → Agent starts slow, confused
Turn 100: data.jsonl has 5000 entries → Agent performance degrades
```

**Without compaction:** Context bloat → non-determinism
**With `just flush`:** Active state stays lean → deterministic

```bash
just harvest       # 100 entries
just process       # All marked processed
just flush         # 100 → final_output.jsonl
just stats         # Active: 0

# Turn 2: Clean slate
just harvest       # 50 new entries
just process       # Clean processing
just flush         # Done
```

### The Silo Principle

> "The silo decides what's worth keeping."

Two mechanisms:
1. **Bounded ingestion** — Schema validation keeps data clean
2. **Compaction** — `just flush` archives, not accumulates

**The silo maintains determinism by:**
- Letting the agent forget (context resets each turn)
- Controlling what gets remembered (schema + queries)
- Keeping active state lean (flush, don't accumulate)

See also: **Mentational Efficiency (PHI-10)** — Reduce cognitive load by bounding context.
See also: **Mentational Hygiene (PHI-11)** — Keep context lean to maintain performance.

---

## Why Silo?

### The Cold Start Problem

Agents need extensive prompting to understand a domain. The Silo pattern externalizes that knowledge into the filesystem.

**Before Silo:**
```
User: "Process this data about grain moisture, I need alerts when > 15%, validate against schema, mark processed, compact to output"
Agent: "I'll try to..."
```

**After Silo:**
```
User: "cd silo_barley && just harvest"
Agent: (reads .silo, schema.json, queries.json, justfile)
      "Running harvest, 15 entries, 7 critical alerts, flush complete"
```

---

## Best Practices

### Give Agents Just Enough Context

| Do | Don't |
|-----|--------|
| Read `.silo` and `README.md` first | Prompt every detail |
| Use named queries from `queries.json` | Write ad-hoc jq |
| Trust the schema | Skip validation |
| Follow workflow order | Skip steps |

### Keep Data Lean

| Do | Don't |
|-----|--------|
| Flush early, flush often | Let `data.jsonl` grow unbounded |
| Archive to `final_output.jsonl` | Keep everything in active state |
| Compact after processing | Accumulate processing metadata |

### Trust the Schema

Validation at ingestion is cheap. Debugging bad data downstream is expensive.

```bash
just harvest    # Validates, routes bad to quarantine
just alerts    # Operates on clean data
just flush    # Archives, doesn't accumulate
```

### Multi-Agent: Share the Silo, Not the Work

Each agent owns a stage. Stages coordinate via markers.

```bash
# Agent A: harvest stage
just lock harvest.done
just harvest
just done harvest.done

# Agent B: process stage
just wait harvest.done
just lock process.done
just process
just done process.done
```

### Lessons from Experience

1. **Cold Start** — Agents can mount a silo and act without prior context
2. **Named Filters** — Prevents "Script Hallucination" (ad-hoc jq)
3. **Mentational Hygiene** — Lean data keeps agents fast
4. **occupy the Territory** — `cd` into the silo, don't install
5. **Idempotency** — Safe to run twice

---

## So What? Real Use Cases

The simple grain elevator example is easy to understand. Here's where it gets interesting.

---

**Imagine you had to review 50 pull requests a day.**

You could open each one manually. Or you could have a silo that:
```bash
just harvest    # Pulls all open PRs from GitHub API
just process    # Scores complexity, flags risky changes
just alerts    # Notifies authors of large PRs
just flush     # Archives to review queue
```

*With just-silo, you hand an agent "silo_code_review" and it knows the workflow.*

---

**Imagine you had to triage 200 production alerts before lunch.**

Most are noise. You want the signal. A silo does:
```bash
just harvest    # Ingests alerts from monitoring systems
just alerts     # Surfaces critical (CPU > 90%, error rate > 5%)
just process    # Categorizes by service, routes to on-call
just flush     # Archives to incident tracker
```

*Multiple agents can work the silo — one harvests, one triages, one notifies.*

---

**Imagine you had to migrate 10,000 customer records from legacy to new system.**

You need validation, rollback capability, and audit trail. A silo provides:
```bash
just harvest    # Reads legacy records
just alerts     # Flags incomplete or suspicious records
just process    # Transforms and loads to new system
just flush     # Commits to audit log
just cleanup   # Rolls back failed migrations
```

*Schema validation prevents bad data from entering the new system.*

---

**Imagine you had to find one suspicious API call in 2 million log entries.**

You can't grep 2M lines. A silo does:
```bash
just harvest    # Batch-ingests logs by hour
just alerts     # Surfaces ERROR and WARNING patterns
just query suspicious_users  # Filters by threat indicators
just flush     # Archives to S3
```

*Named jq filters turn ad-hoc grep into reproducible queries.*

---

**The common thread:** You have structured data, you need repeatable processing, you want agents that know what to do without being told every time.

---

### Deductive Minimalism (COG-12)

`set -euo pipefail` reduces the "Search Space" of potential errors. The script cannot wander into an undefined state.

```just
set shell := ["bash", "-o", "pipefail", "-c"]
set -euo pipefail
```

Every recipe runs in a high-integrity environment.

---

## File Structure

### .silo Manifest

```json
{
  "name": "silo_<domain>",
  "version": "1.0.0",
  "silo_type": "<sensor_processor|document_processor|...>",
  "critical_threshold": { "field": "moisture", "operator": ">", "value": 15 }
}
```

### schema.json

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["timestamp", "elevator_id", "moisture"],
  "additionalProperties": false,
  "properties": {
    "timestamp": { "type": "string" },
    "elevator_id": { "type": "string" },
    "moisture": { "type": "number" }
  }
}
```

### queries.json

```json
{
  "filters": {
    "get_alerts": {
      "description": "Critical moisture levels",
      "jq": "select(.moisture > 15)"
    },
    "get_pending": {
      "description": "Not yet processed",
      "jq": "select(.status != \"processed\")"
    }
  }
}
```

---

## Workflows

### Single Agent

```
Mount → Sieve → Process → Check → Flush
```

**Top:**
```bash
just verify
just harvest
```

**Middle:**
```bash
just process
just alerts
just stats
```

**Tail:**
```bash
just flush
just clean
```

### Multi-Stage (Cooperative)

```
Agent A: harvest → creates harvest.done
Agent B: waits for harvest.done → process → creates process.done
```

**Top:**
```bash
# Agent A
just harvest
touch markers/harvest.done
```

**Middle:**
```bash
# Agent B
while [ ! -f markers/harvest.done ]; do sleep 5; done
just process
touch markers/process.done
```

**Tail:**
```bash
just flush
```

---

## Use Cases

### Code Review Queue
Normalize heterogeneous PR data into uniform schema.

### Log Analysis
Batch high-volume logs by hour, surface errors, archive to S3.

### Webhook Normalizer
Standardize heterogeneous webhook payloads before routing.

### Health Metrics
Collect before alerting to avoid spam.

### Content Moderation
Classify and route to human reviewers.

### Backup Verification
Dedup by checksum, alert on failures.

---

## Patterns

### API Gateway
Normalize inputs before routing to handlers.

### Queue
Route to appropriate handlers based on classification.

### Aggregator
Collect before alerting to reduce noise.

### Archival
Compact before long-term storage.

### Deduplicator
One-in, unique-out by ID.

---

## Polyglot Pipeline

Replace Airflow/Makefiles with simple directories.

### Structure

```
silo_polyglot/
├── scripts/
│   ├── fetch.ts
│   ├── transform.py
│   └── enrich.ts
└── stages/
    ├── raw/
    ├── fetched/
    ├── transformed/
    └── enriched/
```

### Top

```just
stage1_fetch:
    @npx tsx scripts/fetch.ts > stages/fetched/data.jsonl
```

### Middle

```just
stage2_transform:
    @python scripts/transform.py < stages/fetched/data.jsonl > stages/transformed/data.jsonl
```

### Tail

```just
pipeline:
    @just stage1_fetch
    @just stage2_transform
    @just stage3_enrich
    @just flush
```

---

## Multi-Agent Coordination

### Aspirational Recipes

These patterns are documented but not yet in the template:

```just
# Claim a stage
claim:
    @AGENT_ID=$$(hostname) && ...

# Wait for dependency
wait marker:
    @while [ ! -f {{marker}} ]; do sleep 5; done

# Mark complete
done:
    @touch markers/stage-1.done

# Cleanup stale locks
cleanup:
    @find markers/ -name "*.lock" -mmin +60 -delete
```

### Edge Cases

| Edge Case | Fix |
|-----------|-----|
| Crash mid-stage | TTL + cleanup |
| Race on claim | Atomic mv |
| State drift | Verify on startup |
| Duplicate process | Check completed/ |
| Re-harvest | Force flag |

---

## Comparison

| | Heavyweight Harness | Silo |
|--|--|--|
| Setup | Complex | `cp -r template` |
| Agents | Limited | Native |
| Portability | Docker/K8s | Git clone |
| Readability | Config files | README + justfile |
| Debugging | Logs | Human-readable |

---

## Resources

- [README](README.md) — Project overview
- [Playbooks](playbooks/) — By role: user, builder, agent, operator
- [Skills](skills/) — Agent instructions
- [Examples](examples/silo_barley/) — Working silo
- [Briefs](briefs/) — Project briefs
- [Debriefs](debriefs/) — Retrospectives
