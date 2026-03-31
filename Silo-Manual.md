# Manual: Silo Strategy

**Detailed guide: Why we do things this way, and how to extend them.**

---

## Naming Convention

**Naming and cache expiry are the two hard problems in computing.**

We follow a simple convention to keep things predictable:

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
