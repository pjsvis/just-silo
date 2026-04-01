---
date: 2026-04-01
tags: [playbook, data, jq]
---

# jq Playbook

**Purpose:** Query and transform JSON data using jq for just-silo workflows.

---

## Context & Prerequisites

- `jq` installed (`brew install jq`)
- JSON or JSONL data files

## The Protocol

### Basics

```bash
# Parse JSON
echo '{"a":1}' | jq '.'

# Get value
echo '{"a":1}' | jq -r '.a'

# Compact (for JSONL)
echo '{"a":1}' | jq -c '.'
```

---

### Select (Filter)

```bash
# By field value
jq -c 'select(.status == "pending")'

# Numeric comparison
jq -c 'select(.count > 10)'

# String contains
jq -c 'select(.name | contains("foo"))'
```

---

### Map/Transform

```bash
# Extract specific fields
jq -c 'map({timestamp, value: .count})'

# Add computed field
jq -c 'map(. + {processed: true})'
```

---

### Group & Aggregate

```bash
# Group by field
jq -s 'group_by(.category)'

# Count
jq -s 'length'

# Sum
jq -s 'map(.value) | add'

# Latest by timestamp
jq -s 'max_by(.timestamp)'
```

---

## Named Filters Pattern

Define reusable queries in `queries.json`:

```json
{
  "filters": {
    "alerts": {
      "description": "Critical entries",
      "jq": "select(.moisture > 15)"
    }
  }
}
```

Use them:

```bash
FILTER=$(jq -r '.filters.alerts.jq' queries.json)
jq -c "$FILTER" data.jsonl
```

---

## With Shell Variables

```bash
THRESHOLD=15
jq -c --argjson thresh "$THRESHOLD" 'select(.moisture > $thresh)'

NAME="foo"
jq -c --arg name "$NAME" 'select(.name == $name)'
```

---

## Common Traps

| Trap | Fix |
|------|-----|
| String vs number | `'== "15"'` vs `== 15` |
| Null fields | `select(.field == null)` |
| Array vs stream | `jq -s` wraps in array |

---

## Standards

1. **Use named filters** over ad-hoc jq in justfiles
2. **Compact output** (`jq -c`) for JSONL
3. **Quote variables** in shell scripts
4. **Document filters** in `queries.json`

---

## Examples

### silo_barley queries.json

```json
"high_moisture": {
  "description": "Readings over threshold",
  "jq": "select(.moisture > 15)"
}
```

### Usage

```bash
# Run named filter
jq -c -f <(jq '.filters.high_moisture.jq' queries.json) data.jsonl
```

---

## Related

- [jsonl-playbook.md](jsonl-playbook.md) — JSONL patterns
- [silo-barley](../silo_barley/) — Working example
