# pr-review-agent

Monitor PR reviews from AI tools (qodo, code-rabbit), fix issues, notify when ready.

---

## Purpose

The PR is open. AI reviewers (qodo, code-rabbit) are slow and rate-limited. This agent:
1. Polls for new review comments
2. Fixes what it deems necessary
3. Pushes fixes
4. Notifies you when ready to merge

---

## Setup

```bash
# GitHub PAT is fetched from skate automatically
skate set github_pat your_token  # If not already set

# Default PR number (optional)
export PR_NUMBER=2
```

---

## Usage

```bash
cd agents/pr-review-agent

# Check status once
just status 2

# Poll once
just poll 2

# Watch continuously (every 5 minutes)
just watch 2
```

---

## Workflow

```
Agent polls → Parses qodo/code-rabbit comments → Fixes → Pushes → Notifies
                                                           ↓
                                                    Human reviews + merges
```

---

## Categorization

| Category | Keywords | Action |
|----------|----------|--------|
| MUST FIX | bug, breaking, security, error | Fix immediately |
| SHOULD FIX | recommend, should, consider | Fix if easy |
| SUGGESTION | nit:, style, minor | Fix if quick |
| NOISE | unclear, out of scope | Skip |

---

## Stop Conditions

- All MUST FIX issues resolved
- 3 consecutive polls with no new must-fix issues
- Rate limited (backs off, retries later)

---

## Constraints

- Never merges — human does that
- Logs all decisions
- Respects rate limits
- Minimal fixes only

---

## CSP

See `CSP.md` for full specification.
