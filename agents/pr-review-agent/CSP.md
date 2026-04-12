# CSP: pr-review-agent

**Agent:** pr-review-agent
**Purpose:** Monitor PR reviews, fix issues, notify when ready
**Mode:** Trust-in-agent (auto-fix, notify human to merge)

---

## Inputs

- PR comments from AI reviewers (qodo, code-rabbit)
- GitHub API for diffs and file changes
- Rate limit status

---

## Workflow

```
POLL → PARSE → FIX → PUSH → NOTIFY
```

### 1. Poll

```
Every 5 minutes:
  GET /repos/:owner/:repo/pulls/:pr/comments
  GET /repos/:owner/:repo/pulls/:pr/reviews
```

### 2. Parse

For each new comment since last poll:

| Category | Indicators | Action |
|----------|-----------|--------|
| MUST FIX | "bug", "breaking", "security", "error", "fails" | Fix immediately |
| SHOULD FIX | "recommend", "should", "consider" | Fix if easy |
| SUGGESTION | "nit:", "style", "minor" | Fix if quick |
| NOISE | "unclear", "out of scope", "unrelated" | Skip |
| QUESTION | "?", "why not" | Evaluate, maybe fix |

### 3. Fix

- Make the minimal fix required
- Match existing code style
- Don't over-engineer
- Log reasoning for each fix

### 4. Push

- Push fixes to PR branch
- Use conventional commit format
- Include fix reason in commit message

### 5. Notify

```
td log "pr-review-agent: Fixed X issues from qodo/code-rabbit"
Console output when done
```

---

## Stop Conditions

- All MUST FIX issues resolved
- Agent ran 3 consecutive polls with no new must-fix issues
- Rate limited (back off, retry later)

---

## Constraints

1. **Never merge** — Human does that
2. **Log all decisions** — What was fixed, what was skipped, why
3. **Respect rate limits** — Back off when limited
4. **Minimal fixes** — Don't refactor, just fix the issue
5. **Match style** — Follow existing code conventions

---

## Integration

```
pr-review-agent
  → Pushes to PR branch
  → td log for tracking
  → Notifies user (console output)
  → Human reviews + merges
```

---

## Rate Limit Handling

```
If rate limited:
  Log "Rate limited, retry in N seconds"
  Sleep until reset
  Continue from last position
```
