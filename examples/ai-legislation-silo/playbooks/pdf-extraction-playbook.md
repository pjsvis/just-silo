---
date: 2026-04-26
tags: [playbook, pdf, extraction, pdftotext]
---

# PDF Extraction Playbook

## Purpose
Convert legislation PDFs to structured JSONL for the silo pipeline.

## Tools

| Tool | Source | Command |
|------|--------|---------|
| pdftotext | poppler-utils (Flox) | `pdftotext -layout input.pdf output.txt` |
| pandoc | pandoc (Flox) | `pandoc -f html -t markdown` (fallback) |
| jq | jq (Flox) | JSON processing |

## Process

```bash
# 1. Place PDF in inbox/raw/
cp eu-ai-act.pdf inbox/raw/

# 2. Extract to text
pdftotext -layout inbox/raw/eu-ai-act.pdf inbox/raw/eu-ai-act.txt

# 3. Structure detection (deterministic)
#    - Article headers: "Article [0-9]+"
#    - Paragraphs: "\([0-9]+\)" or "[0-9]+\."
#    - Sections: "CHAPTER [IVX]+"

# 4. Convert to JSONL
#    (see process/extract.sh when implemented)
```

## Validation

After extraction, verify:
- `wc -l inbox/harvest.jsonl` > 0
- `jq -c '.' inbox/harvest.jsonl | head -1` is valid JSON
- Each entry has required fields: `id`, `source`, `article`, `text`
