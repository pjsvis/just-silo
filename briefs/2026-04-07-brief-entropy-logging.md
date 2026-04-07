# Brief: Entropy Logging System

**Date:** 2026-04-07
**Status:** Proposed
**Priority:** P1

---

## Problem Statement

just-silo claims to reduce entropy. Without instrumentation, this is aspiration. We need to **measure entropy** to **prove entropy reduction**.

---

## Philosophy

> "Log everything, figure things out later. Try to find trends. Correlate trends with events. Entropy fluctuates. We're measuring at a distance, but we're trying..."

This is **empirical, not theoretical**. Don't over-engineer the schema. Just log and observe.

---

## Design Principles

### 1. Industry Standard
Use common logging conventions. Keep it familiar.

### 2. JSONL Format
One JSON object per line. Machine-readable. Unix-friendly.

### 3. Log Everything First
Don't optimize prematurely. Capture the signal *and* the noise. We'll filter later.

### 4. Trend Over Level
Don't focus on absolute entropy values. Focus on **direction**: increasing or decreasing.

---

## Proposed Schema

```jsonl
{"ts": "ISO8601", "level": "info|warn|error", "source": "component", "event": "event-name", "msg": "human message", "meta": {}}
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `ts` | Yes | ISO8601 timestamp |
| `level` | Yes | info, warn, error |
| `source` | Yes | Component/script name |
| `event` | No | Categorized event type |
| `msg` | Yes | Human-readable message |
| `meta` | No | Additional structured data |

### Examples

```jsonl
{"ts": "2026-04-07T16:00:00Z", "level": "info", "source": "silo-harvest", "event": "validation", "msg": "42 items validated", "meta": {"items": 42, "errors": 0}}
{"ts": "2026-04-07T16:00:01Z", "level": "warn", "source": "silo-process", "event": "anomaly", "msg": "Unusual value detected", "meta": {"field": "temperature", "value": 999}}
{"ts": "2026-04-07T16:00:02Z", "level": "error", "source": "silo-flush", "event": "write-fail", "msg": "Disk full", "meta": {"path": "/tmp/silo/data.jsonl"}}
```

---

## File Structure

```
silo/
├── logs/
│   ├── silo.log.jsonl           # All logs
│   ├── silo-entropy.log.jsonl   # Entropy-related only (future)
│   └── silo-errors.log.jsonl    # Errors only (future)
└── scripts/
    └── log.sh                   # Standard logging interface
```

---

## Standard Interface

### `log.sh` Script

```bash
#!/bin/bash
# log.sh - Standard logging interface

LEVEL="${1:-info}"
SOURCE="${2:-unknown}"
MSG="${3:-}"
META="${4:-{}}"

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF
{"ts": "$TS", "level": "$LEVEL", "source": "$SOURCE", "msg": "$MSG", "meta": $META}
EOF
```

### Usage in Recipes

```just
silo-harvest:
    @echo '{"ts":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","level":"info","source":"silo-harvest","msg":"Starting harvest","meta":{}}' >> logs/silo.log.jsonl
    @cd templates/basic && just harvest
    @echo '{"ts":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","level":"info","source":"silo-harvest","msg":"Harvest complete","meta":{}}' >> logs/silo.log.jsonl
```

Or via helper:

```bash
./scripts/log.sh info "silo-harvest" "Starting harvest" '{}'
```

---

## Trend Detection

### Simple Trend Commands

```bash
# Count events by level over time
just log-trend

# Show error frequency
just log-errors --since "24h"

# Show entropy score trend
just log-entropy --window "7d"

# Find anomalies
just log-anomalies --threshold 3
```

### Trend Algorithm (Simple)

```bash
# Count events per hour, compare windows
jq -c '.ts[0:13]' logs/silo.log.jsonl | sort | uniq -c | awk '{print $2, $1}'
```

---

## Correlation

Later, we can correlate log trends with:
- Brief creation events
- Agent runs
- API calls
- Gamma-loop executions

But first, **just log**.

---

## Implementation Plan

1. **Create `scripts/log.sh`** — Standard logging interface
2. **Create `logs/` directory** — Log storage
3. **Wire into existing recipes** — Add logging to core commands
4. **Create trend commands** — `just log-trend`, `just log-errors`
5. **Test the pipeline** — Run some workflows, observe logs

---

## Decisions

- [x] JSONL format
- [x] ISO8601 timestamps
- [x] level/source/msg fields
- [ ] Log rotation strategy (defer)
- [ ] Aggregation storage (defer)

---

## For Next Session

- Implement `scripts/log.sh`
- Add logging to core recipes
- Observe initial logs
