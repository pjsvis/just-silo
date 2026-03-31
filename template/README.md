# {{silo-name}}

{{description}}

## Quick Start

```bash
just verify          # Check prerequisites
just harvest         # Ingest data
just process         # Run domain script
just self-test       # Smoke test
```

## Prerequisites

- [`just`](https://github.com/casey/just) — `brew install just`
- [`jq`](https://github.com/jqlang/jq) — `brew install jq`

## Workflow

1. **Mount** — `cd {{silo-name}}/`
2. **Sieve** — `just harvest`
3. **Process** — `just process`
4. **Check** — `just alerts`, `just stats`
5. **Flush** — `just flush`

## Recipes

Run `just --list` to see all recipes.

## Customization

Edit these files for your domain:

- `schema.json` — Define expected data structure
- `queries.json` — Add named jq filters
- `process.sh` — Implement domain logic
- `harvest.jsonl` — Add your test data

## Files

| File | Purpose |
|------|---------|
| `.silo` | Silo manifest |
| `schema.json` | Data schema |
| `queries.json` | Named filters |
| `justfile` | CLI interface |
| `process.sh` | Domain script |
| `harvest.jsonl` | Test data |
