---
date: 2026-04-26
tags: [brief, granularity, schema, jsonl]
---

# Brief: Provision Granularity Decision

## Options

| Level | Count (EU AI Act est.) | Pros | Cons |
|-------|------------------------|------|------|
| Article | ~113 | Easy to parse | Too coarse for compliance |
| Paragraph | ~2000 | Medium detail | Structure varies |
| Provision/clause | ~5000+ | Finest detail | Requires interpretation |

## Decision

**Article-level structure, paragraph-level content.**

Each JSONL entry = one article, containing its key provisions as a nested structure.

This gives ~300-500 entries for the full Act, which is:
- Manageable for cost tracking
- Detailed enough for compliance
- Structured enough for deterministic parsing

## Schema Implication

Each entry needs:
- `article` (string)
- `provisions[]` (array of individual obligations/prohibitions)
- `risk_level` per provision, not per article
