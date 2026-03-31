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

## The Rule: Enough Is Enough

**More context doesn't mean better results.** Past a threshold, the noise drowns the signal.

### What We Learned (The Hard Way)

We tried unbounded context. Here's what broke:

| Failure Mode | What Happened |
|--------------|---------------|
| **Context accumulates** | After 50 turns, agent performance degrades |
| **Ad-hoc jq proliferates** | "I'll just grep for this" → inconsistent results |
| **Data rots** | Unprocessed entries pile up, nobody knows what's done |
| **Agents get confused** | "Which data should I process?" |
| **Handoffs break** | Agent A doesn't know what Agent B did |

### The Fix

**Enough context for the task. No context when the task is done.**

```bash
# Spin up agent for task
just harvest       # Get data
just process       # Do work
just flush        # Archive, clear active state

# Task done, context clean
# Next task: spin up fresh
just harvest       # Fresh context
just process       # Clean slate
```

### The Principle

> "Enough is enough. Too much is too much."

For a summarization job, you might want the full history.
For a data processing job, you need the current working set.

**The silo decides:**
- What gets ingested (schema validation)
- What stays active (data.jsonl)
- What gets archived (final_output.jsonl)

### How to Apply It

| Task Type | Context Strategy |
|----------|----------------|
| **Data processing** | Lean: flush after each batch |
| **Code review** | Focused: just the PR, not the whole repo history |
| **Log investigation** | Bounded: query by time window, not all logs |
| **Summarization** | Full: keep context until done, then archive |

**The rule doesn't change:** Enough is enough. Too much is too much.

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
6. **Observe the Territory** — The filesystem IS your dashboard

---

## Observe the Territory

**The filesystem that runs your pipeline IS your observability layer.** No dashboards. No metrics APIs. No separate monitoring infrastructure.

```bash
cd pipeline_silo/
just status          # What's running, stuck, done
just who             # Which agents on which stages
just stuck 60        # Stages idle > 60 minutes
just throughput      # Items/hour trend
just audit           # Full pipeline history
```

### Why This Is Seriously Cool

| Traditional Monitoring | Silo-Native |
|------------------------|-------------|
| Login to dashboard | `cd pipeline_silo/` |
| Click through menus | `just --list` |
| Query metrics API | `just stats` |
| Check logs per service | `just who` |
| Alerts in separate system | `just alerts` |

**The insight:** Your agents already read and write this filesystem. Why query a separate system when the territory shows you everything?

### The Principle

> *"Observe the territory you occupy. Don't log into a separate dashboard."*

### What You Need

- **`markers/`** — Agent coordination (already exists)
- **`pipeline.json`** — Stage definitions
- **Status recipes** — Aggregate from markers

See [briefs/2026-03-31-pipeline-observability-via-filesystem.md](briefs/2026-03-31-pipeline-observability-via-filesystem.md) for implementation details.

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

**What we learned:** Without bounded context, agents start conflating old PRs with new ones. "This looks like the auth refactor from last month" → bad advice. With the silo, each PR gets fresh context. Done is done. Next is next.

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

**What we learned:** Without the silo, agents accumulate alert history. After 1000 alerts, they start treating everything as critical. The silo keeps only the current batch. When it's flushed, it's gone. Fresh eyes every time.

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

**What we learned:** Without bounded batches, validation drifts. After 5000 records, you start accepting records you rejected at the start. The silo batches by 100. Flush after 100. Next batch starts fresh. Consistent all the way through.

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

**What we learned:** Without named filters, each grep is ad-hoc. "I'll just search for this pattern" → different results each time. The silo has named queries. `just query suspicious_users` is always the same filter. Reproducible, shareable, testable.

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
