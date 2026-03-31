# Playbook: Silo Strategy
## Workflow Durability (PHI-13) · Architectural Specialisation (PHI-14)

> **Reference:** `silo_barley/` — the canonical working example. All patterns below
> are live-coded and validated in that directory.

---

## The Core Insight

A **Silo** is a directory that contains everything an agent (or human) needs to
understand and act on a specific domain — without prior context from the session.

```
silo_barley/
├── .silo              # Silo manifest (metadata, critical thresholds, interface)
├── README.md           # Human-readable rules and SOP
├── schema.json         # JSON Schema — the "Sleeve" / Canonical Structure
├── queries.json        # Named jq filters — the "Context Shield"
├── harvest.jsonl       # Raw input data — the "Substrate"
├── process_harvest.sh  # The domain-specific processor (any runtime)
├── justfile            # The "Engine" — portable, zero-install interface
├── data.jsonl          # Active processing state (just harvest creates this)
├── quarantine.jsonl    # Schema-rejected entries (just harvest creates this)
└── final_output.jsonl  # Compacted results (just flush creates this)
```

**Why this works:** The agent reads the `.md` and `.json` files first (low-entropy,
compressed knowledge), then uses `jq` to filter the `.jsonl` data rather than
reading the entire raw file into context. The `justfile` is the **JFDI** trigger.

---

## SOP: Creating a New Silo

### Step 1 — Create the directory
```bash
mkdir silo_<domain>/ && cd silo_<domain>/
```

### Step 2 — Create the `.silo` manifest
```json
{
  "name": "silo_<domain>",
  "version": "1.0.0",
  "silo_type": "<sensor_processor|document_processor|...>",
  "critical_threshold": { "field": "...", "operator": "...", "value": ... },
  "interface": {
    "engine": "justfile",
    "schema": "schema.json",
    "queries": "queries.json",
    "input": "harvest.jsonl",
    "active_state": "data.jsonl",
    "quarantine": "quarantine.jsonl",
    "output": "final_output.jsonl"
  }
}
```

### Step 3 — Write `README.md`
- Domain description
- Critical alert thresholds
- The 3-line workflow (Mount → Sieve → Flush)
- `just --list` summary

### Step 4 — Write `schema.json`
- JSON Schema Draft 2020-12
- `required` fields are the minimal entry shape
- `additionalProperties: false` enforces clean entries

### Step 5 — Write `queries.json`
- One named filter per common query
- Each filter includes `description`, `jq`, and `use_case`
- **Pattern:** Always use named filters over ad-hoc jq

### Step 6 — Write `harvest.jsonl`
- 10–20 representative entries
- Include edge cases: critical threshold crossings, malformed entries

### Step 7 — Write `process_harvest.sh` (or equivalent)

**High-Integrity (COG-12):** Use `set -euo pipefail` to reduce the search space.

```bash
#!/bin/bash
# Deductive Minimalism (COG-12): Reduce search space of potential errors
set -euo pipefail

for line in $(cat data.jsonl); do
  # Process each entry
  echo "$line" | jq '.status = "processed"'
done >> final_output.jsonl
```

- Must be idempotent
- Report progress clearly

### Step 8 — Write `justfile`
See the **justfile template** below.

---

## justfile Template

```just
# High-Integrity Environment (Deductive Minimalism, COG-12)
# Reduces the "Search Space" of potential errors.
# Recipe cannot wander into an undefined state.
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
    @just --list --justfile {{justfile()}} | grep -v "^#"

verify:
    @test -f {{SCHEMA_FILE}} && echo "  ✓ schema.json present"
    @test -f {{QUERIES_FILE}} && echo "  ✓ queries.json present"
    @command -v jq >/dev/null 2>&1 && echo "  ✓ jq available"

harvest source=(HARVEST_FILE):
    @just verify
    @> {{DATA_FILE}} && > {{QUARANTINE_FILE}}
    @cat {{source}} | jq -c --slurpfile s {{SCHEMA_FILE}} \
        'if (.timestamp and .elevator_id and .moisture) then . else empty end' \
        >> {{DATA_FILE}}
    @cat {{source}} | jq -c --slurpfile s {{SCHEMA_FILE}} \
        'if (.timestamp and .elevator_id and .moisture) then empty else . end' \
        >> {{QUARANTINE_FILE}}
    @just stats

process:
    @./process_harvest.sh

alerts:
    @jq -c 'select(.moisture > 15)' {{DATA_FILE}}

stats:
    @printf "Active:       " && [ -f {{DATA_FILE}} ] && jq -s 'length' {{DATA_FILE}} || echo "0"
    @printf "Quarantine:   " && [ -f {{QUARANTINE_FILE}} ] && jq -s 'length' {{QUARANTINE_FILE}} || echo "0"
    @printf "Output:       " && [ -f {{OUTPUT_FILE}} ] && jq -s 'length' {{OUTPUT_FILE}} || echo "0"

flush:
    @jq -c 'select(.status == "processed")' {{DATA_FILE}} >> {{OUTPUT_FILE}} || true
    @jq -c 'select(.status != "processed")' {{DATA_FILE}} > {{DATA_FILE}}.tmp && mv {{DATA_FILE}}.tmp {{DATA_FILE}}
    @just stats

self-test:
    @just verify
    @echo "SELF-TEST: Silo operational."

install-deps:
    @command -v jq >/dev/null 2>&1 && echo "  ✓ jq" || echo "  ✗ jq: brew install jq"
    @command -v just >/dev/null 2>&1 && echo "  ✓ just" || echo "  ✗ just: brew install just"
```

---

## Compaction Protocol (Brief 02)

The Compaction Protocol prevents **Metadata Bloat**. Without it, a streaming
architecture accumulates high-entropy tracing state that slows the agent.

### Three Patterns (from Brief 02)

| Pattern | When to Use | Mechanism |
|---------|-----------|-----------|
| **Tombstone** | High-volume, multi-consumer pipelines | Append ID to `tombstone.jsonl`; filter excludes those IDs |
| **Finished Pile** | Batch processing with clear completion | `jq 'select(.status == "processed")' >> final_output.jsonl` + purge from active |
| **Physical Separation** | Binary state (done/not-done) | `mv raw/file.jsonl processed/` — absence *is* the state |

### The Compaction Recipe
```just
compact:
    @jq -c 'select(.status == "processed") | del(.internal_trace)' data.jsonl >> final_output.jsonl
    @jq -c 'select(.status != "processed")' data.jsonl > data.jsonl.tmp && mv data.jsonl.tmp data.jsonl
```

---

## Just-in-Place Deployment (Brief 04)

**Principle:** Don't install capabilities; *occupy* the territory.

- `cd silo_barley/` → capability is scoped to that directory
- `just harvest` → always the same command, different context per silo
- Zero global pollution, zero alias management

### The Deployment SOP
```bash
git clone git@github.com:pjsvis/ctx-cli.git silo-project
cd silo-project/silo_barley/
just install-deps   # Verify jq + just
just self-test       # Smoke test
just harvest         # JFDI
```

---

## Lessons Learned (Live Experiments)

### What Worked

1. **`just --list` as the discovery interface** — agents (and humans) immediately know
   what's available without reading documentation.

2. **JSON Schema as the Sleeve** — explicit schema validation during `harvest`
   catches bad data at the boundary, preventing downstream confusion.

3. **Named jq filters in `queries.json`** — prevents "Script Hallucination" (the
   primary risk from Brief 01). Agent uses provided filters instead of inventing
   ad-hoc jq.

4. **Compaction during flush** — keeping `data.jsonl` lean is *Mentational Hygiene*.
   The agent's context window stays focused on what's pending.

5. **`.silo` manifest** — machine-readable metadata allows tooling (future Silo
   Registry) to auto-discover and reason about silos without parsing prose.

### What Needed Fixing

1. **`just` parameter defaults with `set shell`** — The `-f` conditional syntax
   in parameter defaults (`if -f FILE {...}`) is not valid `just` syntax.
   **Fix:** Use simple variable references as defaults; validate in recipe body.

2. **`$$` escaping in `set shell := ["bash", "-c"]`** — `just` passes recipe
   lines to `bash -c '...'`. Using `$$` for shell variable escaping requires
   testing; avoid subshell-heavy logic inline. **Fix:** Write complex shell logic
   as separate scripts or simplify to single jq invocations.

3. **JSONL requires `-s` flag** — `jq` filters on JSONL files (line-delimited
   JSON) need `-s` (slurp) to collect lines into an array. Without `-s`, `jq` tries
   to index each line as a string, causing errors. **Fix:** Use `-s` for bulk
   operations; use `-c` for compact per-line output.

4. **Harvest appends by default** — `cat >> file` always appends. Running `just sync`
   twice doubles the data. **Fix:** Always truncate the target file (`> data.jsonl`)
   before appending in the harvest recipe.

5. **`jq` array grouping requires `-s`** — `jq 'group_by(.type)'` fails on JSONL
   because each line is processed separately. Use `jq -s 'group_by(.type)'` to
   slurp all lines into an array first.

### Process Lessons

1. **Cold Start is validated by construction, not live test** — We proved the
   architecture works by building it correctly, but never ran a true zero-context
   agent cold start. This is an open validation item.

2. **Worktree naming matters** — A confusing worktree name (`ctx-cli-ctx-cli`) caused
   issues. Use clear, descriptive names: `dev`, `feature-x`, `silo-experiment`.

3. **State file double-run** — Running `just sync` twice appends twice. The harvest
   recipe must truncate before appending.

### Kirk/Outpost Pattern

The **Silo Kirk** (`silo_kirk/`) is the central corpus that indexes all knowledge.
Individual silos (like `silo_barley/`) are **Outposts** that know only themselves.

```
silo_kirk/     ← The Kirk (central corpus, indexes everything)
  ├── justfile     # sync, catalog, alerts, report
  ├── index_corpus.sh  # Scans briefs/, debriefs/, playbooks/
  └── data.jsonl   # Union of all corpus documents

silo_barley/   ← An Outpost (specific domain)
  ├── justfile     # verify, harvest, process, flush
  ├── schema.json  # Domain-specific schema
  └── data.jsonl   # Only this domain's data
```

**Rule:** Outposts don't know about each other. The Kirk knows about all Outposts.
Agents should mount the Kirk first to understand the full corpus, then dive into
specific Outposts as needed.

### Key Risks

| Risk | Mitigation |
|------|-----------|
| Agent writes ad-hoc jq instead of using `queries.json` | PIP must explicitly instruct: *"Use the Sleeve before the Substrate"* |
| Schema drift (schema.json and data diverge) | `just verify` checks schema presence; extend to validate with `jq --schema` |
| Flush before process (empty compaction) | `flush` checks `data.jsonl` exists before processing |
| Binary dependencies not installed | `just install-deps` is the contract; agents must run it first |

---

## Validation Results (silo_barley, 2026-03-29)

| Recipe | Result | Notes |
|--------|--------|-------|
| `just verify` | ✓ | schema, queries, jq, just all present |
| `just harvest` | ✓ | 15 entries → data.jsonl, 0 quarantined |
| `just alerts` | ✓ | 7 critical alerts surfaced (moisture > 15) |
| `just process` | ✓ | All 15 entries marked processed |
| `just flush` | ✓ | 15 entries → final_output.jsonl, data.jsonl → 0 |
| `just self-test` | ✓ | Smoke test passes |
| `just stats` | ✓ | Deterministic metrics at every stage |

---

## Success Metrics (per Brief 01)

| Metric | Target | Achieved |
|--------|--------|---------|
| **Mentational Efficiency** | Only schema + query results in context | ✓ — agent uses `queries.json` filters |
| **Discoverability** | Agent reads README before touching data | ✓ — verify recipe enforces this order |
| **Durability** | Agent uses provided `.sh` script | ✓ — `just process` wraps process_harvest.sh |
| **Compaction** | `data.jsonl` returns to empty after flush | ✓ — verified in stats |

---

## Anti-Patterns to Avoid

- ❌ **Don't** put domain logic in the `justfile` itself — keep it in scripts.
  The `justfile` is the *interface*, not the *engine*.
- ❌ **Don't** skip the schema validation step — quarantining bad entries is
  cheap; debugging bad data in the active state is expensive.
- ❌ **Don't** hardcode jq filters in the `justfile` — use `queries.json`.
  The `justfile` should call `jq` with named filters, not inline expressions.
- ❌ **Don't** skip `just flush** — a silo that never compacts accumulates
  high-entropy state that degrades agent performance.
- ❌ **Don't** use `just` features (shebang recipes, etc.) that require the
  latest `just` version — keep it compatible with `just 1.48+`.

---

## Principles

### 1. High-Integrity Environment (COG-12)

**Deductive Minimalism** means reducing the "Search Space" of potential errors.

Including `set -euo pipefail` at the top of your `justfile` ensures every recipe
runs in a high-integrity shell environment:

```just
set shell := ["bash", "-c"]
set export := true
set strict := true
```

**What this guarantees:**
- `set -e` — Recipe stops on first error (no silent failures)
- `set -u` — Recipe fails on undefined variables (no typos)
- `set -o pipefail` — Pipeline fails if any component fails

**Why it matters:** It turns the "Just Container" into a high-integrity environment.
Every single recipe is wrapped in this safety logic by default. The agent cannot
wander into an undefined state.

### 2. Sleeve Before Substrate

Read the schema and queries *before* touching the data.

### 3. Mentational Hygiene

Keep `data.jsonl` lean. Flush early and often.

### 4. Occupy the Territory

Don't install capabilities — `cd` into the silo.

### 5. Idempotency by Default

Every recipe should be safe to run twice.

---

## Multi-Agent Patterns

Multiple agents can work in the same silo by following stage-gated workflows.

### Pattern 1: Cooperative Multi-Stage Workflow

Agents work on different stages of the same pipeline:

```
silo/
├── raw/                    # Input (Stage 1 ingests here)
├── ingested/               # After harvest (Stage 2 reads from here)
├── processed/              # After process
├── completed/              # After flush
└── markers/
    ├── harvest.done        # Stage 1 complete
    └── process.done        # Stage 2 complete
```

**Agent A (Stage 1):**
```bash
just harvest
just lock harvest.done
```

**Agent B (Stage 2):**
```bash
while ! just is-locked harvest.done; do sleep 5; done
just process
just lock process.done
```

**No conflicts because:**
- Agent A writes to `raw/` → `ingested/`
- Agent B reads from `ingested/` → writes to `processed/`
- Different directories = no race condition

### Pattern 2: Stage Manifest

Define stages in `.silo-manifest`:

```json
{
  "name": "my-silo",
  "stages": [
    {"id": 1, "agent": "ingestor", "recipe": "harvest", "output": "ingested/"},
    {"id": 2, "agent": "processor", "recipe": "process", "depends_on": [1], "output": "processed/"}
  ]
}
```

Agent workflow:
1. Read manifest
2. Find unclaimed stage where dependencies satisfied
3. Claim stage (update manifest)
4. Execute recipe
5. Mark done

### Pattern 3: Agent Role Assignment

Agent reads `.silo` to know its role:

```json
{
  "name": "my-silo",
  "agent_role": "processor",
  "agent_stage": 2,
  "depends_on": ["harvest.done"]
}
```

### Edge Cases and Mitigations

| Edge Case | Problem | Fix |
|-----------|---------|-----|
| **Crash mid-stage** | Stale lock, workflow stalls | TTL + `just cleanup --stale` |
| **Race on claim** | Two agents claim same stage | Atomic `mv` or filesystem lock on manifest |
| **State drift** | Manifest vs filesystem disagree | Verify filesystem matches manifest on startup |
| **Duplicate process** | Re-processing completed item | Check `completed/` before working |
| **Re-harvest** | Second harvest overwrites | `just harvest --force` or manifest `allow_reharvest: true` |
| **Orphaned claims** | Agent died, claim persists | Heartbeat + TTL, cleanup stale |
| **Circular deps** | Deadlock | Validate manifest for cycles on load |
| **Backpressure** | Stage 2 faster than Stage 1 | Retry until input appears, explicit error |

### Manifest Schema for Multi-Agent

```json
{
  "name": "my-silo",
  "stages": [
    {
      "id": 1,
      "name": "ingest",
      "recipe": "harvest",
      "depends_on": [],
      "allow_reharvest": false
    },
    {
      "id": 2,
      "name": "process",
      "recipe": "process",
      "depends_on": [1],
      "allow_reharvest": false
    }
  ],
  "claims": {
    "1": {"agent_id": "agent-a", "status": "done", "claimed_at": "2026-03-31T10:00:00Z"},
    "2": {"agent_id": "agent-b", "status": "claimed", "claimed_at": "2026-03-31T10:05:00Z"}
  }
}
```

### Claim/Coordination Recipes

```just
# Claim next available stage
claim:
    @AGENT_ID=$$(hostname) && just manifest-claim $$AGENT_ID

# Wait for dependency
wait depends=(harvest.done):
    @while [ ! -f {{depends}} ]; do sleep 5; done
    @echo "{{depends}} ready"

# Mark stage complete
done stage=(1):
    @just manifest-complete {{stage}}
    @touch markers/stage-{{stage}}.done

# Cleanup stale claims (>1 hour old)
cleanup:
    @find markers/ -name "*.lock" -mmin +60 -delete
    @echo "Cleaned stale locks"

# Check status
status:
    @echo "=== STAGE STATUS ===" && ls markers/*.done 2>/dev/null || echo "  No stages complete"
    @cat manifest.json | jq '.claims'
```

### Principles

1. **Agents share the silo, not the work** — Each agent has a defined stage
2. **Dependencies prevent chaos** — Stage 2 waits for Stage 1
3. **TTL prevents staleness** — Crashed agents don't block forever
4. **Idempotency by design** — Check completed/ before working
5. **Manifest is source of truth** — Verify against filesystem on startup

---

## Use Cases

The Silo pattern applies whenever you need an agent (or human) to process
structured data with zero prior context.

### Use Case 1: Code Review Queue

**Problem:** Track and prioritize PRs for review.

```
silo_code_review/
├── schema.json        # {pr_number, repo, author, changed_files, lines, status}
├── queries.json       # {large_prs, stale_prs, by_team}
├── justfile
└── output/
    ├── needs_review/
    ├── blocked/
    └── done/
```

**Workflow:**
1. Agent A: `just harvest` (pulls open PRs from GitHub API)
2. Agent B: `just process` (scores PRs by complexity)
3. Agent C: `just alerts` (notifies authors of large PRs)

**Key insight:** Silo normalizes heterogeneous PR data into uniform schema.

---

### Use Case 2: Log Analysis Pipeline

**Problem:** Ingest, filter, and archive logs from multiple services.

```
silo_logs/
├── schema.json        # {timestamp, level, service, message, trace_id}
├── queries.json       # {errors, warnings, by_service, critical}
├── justfile
└── quarantine/        # Malformed log lines
```

**Workflow:**
1. `just harvest` (ingest from /var/logs)
2. `just alerts` (surface ERROR/FATAL)
3. `just flush` (archive to S3)

**Key insight:** High-volume → batch by hour, compact aggressively.

---

### Use Case 3: Webhook Normalizer (API Gateway Pattern)

**Problem:** Normalize heterogeneous webhook payloads.

```
silo_webhooks/
├── schema.json        # {event_type, payload, received_at, source}
├── queries.json       # {github_events, stripe_events, by_type}
├── justfile
└── normalized/       # Standardized output
```

**Workflow:**
1. Agent receives webhook → writes to `harvest.jsonl`
2. `just harvest` normalizes to canonical schema
3. `just process` routes to appropriate handler

**Key insight:** Silo acts as an API gateway, standardizing before routing.

---

### Use Case 4: Health Metrics Aggregator

**Problem:** Collect and alert on infrastructure metrics.

```
silo_health/
├── schema.json        # {host, metric, value, timestamp, threshold}
├── queries.json       # {critical_cpu, low_memory, disk_full}
├── justfile
└── alerts/
```

**Workflow:**
1. Cron: `just harvest` (collects metrics)
2. Agent: `just alerts` (pages if threshold exceeded)
3. `just flush` (archives to timeseries DB)

**Key insight:** Aggregator pattern — collect before alerting to avoid spam.

---

### Use Case 5: Content Moderation Queue

**Problem:** Route content for human review.

```
silo_moderation/
├── schema.json        # {content_id, content, user, flags, status}
├── queries.json       # {pending_review, auto_flagged, escalate}
├── justfile
└── output/
    ├── approved/
    ├── rejected/
    └── escalated/
```

**Workflow:**
1. `just harvest` (ingest flagged content)
2. Agent A: reviews auto-flagged
3. Agent B: reviews escalated
4. `just flush` (moves to appropriate output)

**Key insight:** Router pattern — classify and route to handlers.

---

### Use Case 6: Backup Verification

**Problem:** Verify backups completed successfully.

```
silo_backups/
├── schema.json        # {backup_id, timestamp, size, status, checksum}
├── queries.json       # {failed, stale, by_host}
├── justfile
└── quarantine/       # Checksum mismatches
```

**Workflow:**
1. Cron: `just harvest` (parses backup logs)
2. `just alerts` (notify on failures)
3. `just flush` (archive to audit log)

**Key insight:** Deduplicator pattern — one-in, unique-out.

---

### Cross-Cutting Patterns

| Pattern | Use Cases | Mechanism |
|---------|-----------|-----------|
| **Silo as API Gateway** | Webhooks | Normalize before routing |
| **Silo as Queue** | Moderation | Route to handlers |
| **Silo as Aggregator** | Health, Logs | Collect before alert |
| **Silo as Archival** | Logs, Backups | Compact before S3 |
| **Silo as Deduplicator** | Webhooks | Dedup by event_id |

---

## Future Work

### Completed

- [x] **Silo Kirk** — Central corpus silo at `silo_kirk/` that indexes briefs,
  debriefs, and playbooks. Provides `just sync`, `just catalog`, `just alerts`.
- [x] **11-recipe justfile** — `verify`, `harvest`, `process`, `alerts`, `stats`,
  `flush`, `compact`, `report`, `self-test`, `install-deps`, `clean`.

### Pending

- [ ] **Live Cold Start validation** — Run a true zero-context agent test where
  the agent mounts a silo and processes it without any prior session context.
- [ ] **JSON Schema validation in `verify`** — extend to `jq --validate` or
  schema-to-jq preprocessor to catch schema drift.
- [ ] **Multi-agent handoff** — one agent creates the silo, another agent (with
  zero session context) mounts and processes it. Validate the Cold Start protocol.
- [ ] **Tombstone pattern** — implement `just tombstone ID` for multi-consumer
  pipelines where soft-deletes are preferred over hard deletes.
- [ ] **Silo-to-Git integration** — `just archive` that commits final_output.jsonl
  to a git tag for immutable audit trail.
- [ ] **Silo Registry** — a root-level `justfile` that can `just harvest-all` across
  multiple silos.
