---
date: 2026-04-01
tags: [playbook, data, jsonl]
---

# JSONL Playbook

**Purpose:** Append and query JSON Lines (one JSON object per line) for just-silo data pipelines.

---

## Context & Prerequisites

- `jq` installed (`brew install jq`)
- `bash` with pipefail enabled
- Basic understanding of JSON

## The Protocol

### Append to JSONL

**Rule: Use `jq -c '.'` for compact single-line output.**

```bash
# Append single entry
jq -n '{"key": "value"}' | jq -c '.' >> file.jsonl

# With variables
jq -n \
    --arg ts "$(date -Iseconds)" \
    --argjson num 42 \
    '{timestamp: $ts, value: $num}' \
    | jq -c '.' >> file.jsonl
```

### Read JSONL

```bash
# All entries as array
jq -s '.' file.jsonl

# First/last entry
head -1 file.jsonl | jq '.'
tail -1 file.jsonl | jq '.'

# Count lines
wc -l < file.jsonl
```

### Filter Entries

```bash
# Select by field
jq -c 'select(.status == "approved")' file.jsonl

# Multiple conditions
jq -c 'select(.active == true and .count > 0)' file.jsonl
```

---

## Validation

```bash
# Check valid JSONL
while IFS= read -r line; do
    echo "$line" | jq '.' >/dev/null 2>&1 || echo "INVALID: $line"
done < file.jsonl
```

---

## Common Traps

| Trap | Wrong | Right |
|------|-------|-------|
| No commas between objects | `{...}, {...}` | `{...}\n{...}` |
| No brackets | `[{...}]` | `{...}\n{...}` |
| Multi-line JSON | `jq '.'` | `jq -c '.'` |

---

## Standards

1. **Always use `jq -c '.'`** when appending to ensure one line
2. **No commas between objects** — each line is independent
3. **Quote variables** when embedding in shell
4. **Compact output** — no whitespace

---

## Examples

### From silo_launch

```bash
# Append metrics
jq -n \
    --arg ts "$(date -Iseconds)" \
    --argjson stars "$STARS" \
    '{timestamp: $ts, stars: $stars}' \
    | jq -c '.' >> api_metrics.jsonl
```

### From silo_barley

```bash
# Query alerts
jq -c 'select(.moisture > 15)' data.jsonl

# Count entries
jq -s 'length' data.jsonl
```

---

## Related

- [jq-playbook.md](jq-playbook.md) — jq query patterns
- [silo-barley playbook](../silo_barley/) — Working example
