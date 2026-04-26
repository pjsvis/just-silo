---
date: 2026-04-26
tags: [brief, content, acquisition, eu-ai-act]
---

# Brief: AI Legislation Content Acquisition Strategy

## Context

We need EU AI Act + Scottish/UK AI legislation as structured input for the silo.

## Options Tested

| Source | Method | Result |
|--------|--------|--------|
| EUR-Lex HTML | curl | Blocked by AWS WAF JS challenge |
| EUR-Lex PDF | curl | Blocked |
| GitHub markdown repos | search | No raw legislation text found |
| pdftotext | local tool | Available (Poppler 26.02.0) |
| pandoc | local tool | Not installed, added to Flox |

## Decision

**Manual download + automated processing.**

1. Human downloads consolidated PDF from EU Publications Office once
2. Place in `inbox/raw/`
3. `process/extract.sh` uses `pdftotext` + structure detection
4. No scraping, no WAF battles

## Next Step

Obtain the consolidated EU AI Act PDF ( Regulation (EU) 2024/1689, OJ L, 2024, 1689 ) and place in `inbox/raw/eu-ai-act.pdf`.
