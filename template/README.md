# {{silo-name}}

Copy this template and customize for your domain.

## Quick Start

```bash
just verify          # Check prerequisites
just harvest         # Ingest data
just process         # Run domain script
just self-test       # Smoke test
```

## Customize

Edit these files:

- `justfile` — Replace `<FIELD>` and `<THRESHOLD>` with your values
- `schema.json` — Define your data structure
- `queries.json` — Add your named jq filters
- `process.sh` — Implement your domain logic
- `harvest.jsonl` — Add your test data
- `.silo` — Update name and description

## Workflow

```
Mount → Sieve → Process → Check → Flush
```

Run `just --list` to see all recipes.
