# Silo User Playbook

**For humans processing data through a silo.**

---

## Quick Start

```bash
cd silo_<domain>/
just verify          # Check ready
just harvest         # Ingest data
just process         # Run script
just alerts          # See critical items
just stats           # See counts
just flush           # Compact output
```

## Workflow

```
Mount → Sieve → Process → Check → Flush
```

### Mount
```bash
cd silo_<domain>/
just verify
just --list
```

### Sieve
```bash
just harvest
```

### Process
```bash
just process
```

### Check
```bash
just alerts          # Critical items
just stats           # File counts
just query <name>    # Named filter
just report          # Full summary
```

### Flush
```bash
just flush           # Compact to final_output.jsonl
```

## Files

| File | Created by |
|------|------------|
| `data.jsonl` | `just harvest` |
| `quarantine.jsonl` | `just harvest` (bad entries) |
| `final_output.jsonl` | `just flush` |

## Reset
```bash
just clean           # Remove state files
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No justfile" | `cd` into silo directory |
| "jq parse error" | Check JSONL validity |
| Entries in quarantine | Review failed validation |
