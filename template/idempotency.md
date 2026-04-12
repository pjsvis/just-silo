# Idempotency Guide

**For:** Silo authors  
**Purpose:** Ensure processing is safe to re-run

---

## Principle

A silo operation is **idempotent** if running it multiple times produces the same result as running it once.

```
first run:  harvest.jsonl → data.jsonl ✓
second run: data.jsonl → data.jsonl (no change) ✓
```

---

## Rules

### 1. CREATE directories with `mkdir -p`

```bash
mkdir -p markers logs output
# Safe to run twice - second run is no-op
```

### 2. DEDUP before write

```bash
# BEFORE: Append without dedup
cat new_data.jsonl >> data.jsonl

# AFTER: Dedup by ID
jq -s 'unique_by(.id)' data.jsonl new_data.jsonl > data.jsonl.tmp
mv data.jsonl.tmp data.jsonl
```

### 3. CHECK before create

```bash
# BEFORE: Touch without check
touch marker.done

# AFTER: Check then touch
if [ ! -f marker.done ]; then
    do_work
    touch marker.done
fi
```

### 4. USE checkpoints for long operations

```bash
# Checkpoint pattern
if [ -f markers/process.done ]; then
    echo "Already processed, skipping..."
    exit 0
fi

do_work

# Only mark done if successful
if [ $? -eq 0 ]; then
    touch markers/process.done
fi
```

---

## Quick Reference

| Pattern | Idempotent | Safe to retry |
|---------|------------|---------------|
| `mkdir -p dir` | ✅ | ✅ |
| `echo "x" >> file` | ❌ | ❌ |
| `jq -s '...' > out` | ✅ | ✅ |
| `touch marker.done` | ✅ | ⚠️ |
| `if [ -f x ]; then...` | ✅ | ✅ |

---

## Testing

Run your script twice. If output is identical, it's idempotent:

```bash
./process.sh && ./process.sh
diff <(wc -l data.jsonl) <(wc -l data.jsonl)  # Should be 0
```