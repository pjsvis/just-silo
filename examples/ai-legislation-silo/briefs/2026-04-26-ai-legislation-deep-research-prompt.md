---
date: 2026-04-26
tags: [brief, research, ai-legislation, prompt, acquisition]
---

# Brief: AI Legislation Research Prompt

## Goal

Produce a ranked list of AI-adjacent legislative/regulatory documents. Order by `(ease of acquisition + ease of processing) / 2` ascending, then relevance descending.

## Categories

1. **Primary AI Legislation** — EU AI Act, national AI statutes
2. **Data Protection** — GDPR, UK DPA 2018 (applies to AI by extension)
3. **Sector-Specific** — Medical devices, finance, automotive
4. **IP / Liability** — AI copyright, product liability revisions
5. **International / Soft Law** — OECD, UNESCO, G7/G20 declarations

## Prompt

> List AI-adjacent legislative and regulatory documents.
> For each: jurisdiction, name, type, status, date, format available, source URL, size estimate, ease-of-acquisition (1-5), ease-of-processing (1-5).
> Order by `(ease of acquisition + ease of processing) / 2` ascending.
> Output as markdown table + JSONL block.
> English-language sources preferred. Flag consolidated vs original versions.
