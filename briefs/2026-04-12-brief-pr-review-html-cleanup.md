# Brief: PR Review HTML Text Extraction

**Date:** 2026-04-12
**Tags:** [brief, improvement, pr-review, html]

---

## Problem

`scripts/pr-review.sh` outputs raw HTML from GitHub comments:

```
qodo-code-review[bot]: <img src="https://...">1\. <b><i>createauthmiddleware()</i></b> lacks edge tests...
```

This renders poorly in Glow/markdown viewers.

---

## Desired Behavior

Clean text extraction from HTML:

```
Qodo: createAuthMiddleware() lacks edge tests [Rule violation, Reliability]
- Exported functions have no happy-path and edge-case tests
- Violates PR Compliance ID 5
```

---

## Approaches

### 1. sed pipeline (Simple)
```bash
echo "$html" | sed -e 's/<[^>]*>//g' | sed -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g'
```

### 2. html2text (Robust)
```bash
echo "$html" | html2text
```

### 3. Custom parser (Precise)
Extract specific fields: author, severity, description, code snippets.

---

## Recommendation

**Approach 3: Custom parser**

Extract structured data for better formatting:

```json
{
  "author": "qodo-code-review[bot]",
  "severity": "Bug",
  "title": "createAuthMiddleware() lacks edge tests",
  "description": "...",
  "files": ["src/lib/auth.ts"],
  "lines": "13-59"
}
```

Then render as clean markdown.

---

## Tasks

- [ ] Update `scripts/pr-review.sh` with HTML cleaning
- [ ] Handle code blocks specially (preserve formatting)
- [ ] Extract severity badges (🐞 Bug, 📘 Rule violation, etc.)
- [ ] Test with Glow rendering

---

## Priority

**P3** — Nice to have. Current output is functional.

---

## Related

- `scripts/pr-review.sh` — Current implementation
- `playbooks/justfile-design-playbook.md` — Shell escaping lessons
