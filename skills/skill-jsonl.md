# Skill: JSONL — The Steer

JSON Lines: one JSON object per line. Not a JSON array.

---

## The Rules

### ❌ Wrong

```bash
# Trying to append JSON
echo '{"key": "value"}' >> file.jsonl
# May work but no validation

# JSON array (not JSONL)
echo '[{"a":1}, {"a":2}]' >> file.jsonl
# That's an array, not lines

# Multi-line jq output
jq '.' <<< '{"a":1}' >> file.jsonl
# Adds formatting, breaks line-per-object
```

### ✅ Right

```bash
# Use jq -c (compact) and pipe to file
jq -n '{"key": "value"}' | jq -c '.' >> file.jsonl

# Or with variables
jq -n --arg val "$VAR" '{"key": $val}' | jq -c '.' >> file.jsonl

# Append one object per line
jq -n \
    --arg ts "$(date -Iseconds)" \
    --argjson num 42 \
    '{timestamp: $ts, value: $num}' \
    | jq -c '.' >> file.jsonl
```

---

## Common Patterns

### Create (init file)

```bash
# Create empty JSONL file
> file.jsonl
```

### Append

```bash
# Append single entry
jq -n '{msg: "hello"}' | jq -c '.' >> file.jsonl

# Append with variables
jq -n \
    --arg name "$NAME" \
    --argjson count "$COUNT" \
    '{name: $name, count: $count}' \
    | jq -c '.' >> file.jsonl
```

### Read

```bash
# All entries (as array)
jq -s '.' file.jsonl

# First entry
head -1 file.jsonl | jq '.'

# Last entry  
tail -1 file.jsonl | jq '.'

# Filter entries
jq -c 'select(.status == "approved")' file.jsonl

# Count lines
wc -l < file.jsonl
```

### Query (silo_barley style)

```bash
# Named filter from queries.json
FILTER=$(jq -r '.filters.my_filter.jq' queries.json)
jq -c "$FILTER" file.jsonl
```

---

## Why jq -c '.' Matters

| Without | With |
|----------|------|
| `{"a":1}` (valid) | `{"a":1}` |
| `{ "a": 1 }` (whitespace) | `{"a":1}` (compact) |
| Multi-line objects | One line |
| Invalid JSON possible | Always valid |

---

## Validation

```bash
# Check if valid JSONL
while IFS= read -r line; do
    echo "$line" | jq '.' >/dev/null 2>&1 || echo "INVALID: $line"
done < file.jsonl
```

---

## Traps

1. **No commas between objects** — each line is independent
2. **No brackets** — not `[{...}, {...}]`, just `{...}\n{...}`
3. **Compact output** — use `jq -c` to ensure one line
4. **Escape properly** — when embedding in shell, quote variables

---

## Template Pattern

```bash
# scripts/fetch.sh
OUTPUT_FILE="data.jsonl"

mkdir -p "$(dirname "$OUTPUT_FILE")"

jq -n \
    --arg ts "$(date -Iseconds)" \
    --arg "$1" "$2" \
    '{timestamp: $ts, '"$1"': $'"$1"'}' \
    | jq -c '.' >> "$OUTPUT_FILE"
```

---

## Related

- `silo_barley/` — Working example with data.jsonl
- `silo_launch/` — JSONL for metrics and posts
- `skills/skill-jq.md` — jq patterns
