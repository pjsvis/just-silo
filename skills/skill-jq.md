# Skill: jq — JSON Query

The backbone of just-silo. Named filters prevent ad-hoc jq.

---

## Basics

```bash
# Parse JSON
echo '{"a":1}' | jq '.'

# Get value
echo '{"a":1}' | jq -r '.a'

# Compact (for JSONL)
echo '{"a":1}' | jq -c '.'
```

---

## Just-Silo Pattern

### Named Filters (queries.json)

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

### Use Named Filter

```bash
FILTER=$(jq -r '.filters.alerts.jq' queries.json)
jq -c "$FILTER" data.jsonl
```

---

## Common Patterns

### Select

```bash
jq -c 'select(.status == "pending")'
jq -c 'select(.count > 10)'
jq -c 'select(.tags | contains(["urgent"]))'
```

### Map/Transform

```bash
jq -c 'map({timestamp, value: .count * 2})'
jq -c 'map(select(.active) | {id, name})'
```

### Group

```bash
jq -s 'group_by(.category)'
jq -c 'group_by(.elevator_id) | map({id: .[0].elevator_id, count: length})'
```

### Aggregate

```bash
jq -s 'length'           # Count
jq -s 'map(.value) | add' # Sum
jq -s 'map(.count) | add/length' # Average
jq -s 'max_by(.timestamp)' # Latest
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

## Just-Silo Recipes

```bash
# stats
jq -s 'length' data.jsonl

# alerts
jq -c 'select(.moisture > 15)' data.jsonl

# by_elevator
jq -c 'group_by(.elevator_id)'
```

---

## Traps

1. **String vs number** — `'== "15"'` vs `== 15`
2. **Null handling** — `select(.field == null)` for missing fields
3. **Array output** — `jq -s` wraps in array, `jq -c` streams lines

---

## Related

- `skill-jsonl.md` — JSONL patterns
- `silo_barley/queries.json` — Working examples
