# Brief: Pipeline Observability via Filesystem

**Date:** 2026-03-31
**Status:** Proposed
**Type:** Feature Extension
**Priority:** High

---

## Problem Statement

Multi-agent pipelines lack lightweight, human-readable observability. Traditional solutions require dashboards, metrics APIs, or separate monitoring infrastructure. This creates:

- **Cognitive fragmentation** — monitor is separate from execution
- **Tool proliferation** — agents + monitoring + alerting = 3 systems
- **Poor DX** — "cd into the pipeline" doesn't tell you anything

## Vision

**The pipeline IS the dashboard.** No separate observability layer — the filesystem that runs the pipeline shows you what's happening.

```
cd pipeline_silo/
just status          # What's running, stuck, done
just who             # Which agents on which stages
just throughput      # Items/hour trend
just latency         # Stage-to-stage timing
just stuck           # Markers older than threshold
just alerts          # Critical items from any stage
just audit           # Full pipeline history
```

## Core Insight

> "Observe the territory you occupy. Don't log into a separate dashboard."

The filesystem-as-observability-layer is **seriously cool** because:
1. **Zero setup** — `cd` in and you know everything
2. **Agent-native** — agents already read/write this filesystem
3. **Human-readable** — no API calls, no dashboards, no magic
4. **Composable** — `just` recipes chain naturally
5. **Audit trail** — history is just... files

## Proposed Implementation

### 1. Pipeline Manifest (`pipeline.json`)

```json
{
  "name": "grain_processing",
  "stages": [
    { "id": "harvest", "agent": "sensor_agent", "marker": "harvest.done" },
    { "id": "validate", "agent": "validator_agent", "marker": "validate.done" },
    { "id": "process", "agent": "processor_agent", "marker": "process.done" },
    { "id": "flush", "agent": "archiver_agent", "marker": "flush.done" }
  ],
  "critical_threshold": { "field": "moisture", "value": 15 }
}
```

### 2. Stage Recipes (`justfile` additions)

```just
# Aggregate status
status:
	@echo "=== PIPELINE STATUS ==="
	@just stages
	@just who
	@just stuck 60
	@echo ""
	@just alerts

# List all stages and their state
stages:
	@echo "STAGE          STATE    AGE"
	@for s in harvest validate process flush; do \
		just _stage_state $$s; \
	done

# Who's on what
who:
	@echo "=== AGENT ASSIGNMENTS ==="
	@jq -r '.stages[] | "\(.id)\t\(.agent)"' pipeline.json

# Detect stalled stages (age > threshold in minutes)
stuck threshold=60:
	@echo "=== STUCK STAGES (>{}{{threshold}}min) ==="
	@for m in markers/*.done; do \
		age=$$($$(date +%s) - $$(stat -f %m "$$m")); \
		if [ $$age -gt $$(({{threshold}} * 60)) ]; then \
			echo "STALE: $$m ($$(($age/60))m old)"; \
		fi; \
	done

# Throughput metrics
throughput:
	@echo "=== THROUGHPUT ==="
	@echo "Processed (last hour): $$(just _count_recent final_output.jsonl 3600)"
	@echo "Active: $$(jq -s 'length' data.jsonl)"
	@echo "Quarantined: $$(jq -s 'length' quarantine.jsonl)"

# Audit trail
audit:
	@echo "=== AUDIT LOG ==="
	@cat markers/*.done | jq -s '.'
```

### 3. Agent heartbeat pattern

```just
# Agent claims a stage
claim stage:
	@AGENT_ID=$$(hostname -s)_$$(date +%s)
	@echo $$AGENT_ID > markers/{{stage}}.lock
	@echo "CLAIMED: {{stage}} by $$AGENT_ID"

# Agent heartbeats
heartbeat:
	@for l in markers/*.lock; do \
		touch "$$l"; \
	done
	@echo "Heartbeat recorded"
```

## Files to Create

| File | Purpose |
|------|---------|
| `pipeline.json` | Stage definitions and dependencies |
| `metrics/` | Historical throughput data |
| `audit/` | Timestamped completion records |

## Files to Modify

| File | Changes |
|------|---------|
| `template/justfile` | Add `status`, `who`, `stuck`, `throughput`, `audit` recipes |
| `Silo-Manual.md` | Document filesystem-as-dashboard pattern |
| `README.md` | Add "Observe" step to workflow |

## Success Criteria

- [ ] `cd pipeline_silo && just status` shows complete pipeline health
- [ ] `just who` correctly identifies active agent per stage
- [ ] `just stuck 30` detects stages idle > 30 minutes
- [ ] `just audit` shows chronological pipeline history
- [ ] No external dependencies (dashboards, APIs, databases)

## Open Questions

1. Should heartbeats be required or markers-only?
2. Historical metrics — how far back? Rolling window or unlimited?
3. Multi-pipeline view — a meta-silo that monitors multiple silos?
4. Alert routing — slack, email, or just `just alerts`?

## Related

- `briefs/2026-03-31-multi-agent-coordination.md` — marker coordination patterns
- `Silo-Manual.md` — Polyglot Pipeline section

---

**TL;DR:** Your pipeline filesystem IS your observability layer. No dashboards. Just `cd` and `just`.
