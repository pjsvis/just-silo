# Brief: review-agent — Code Review & PR Management

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P1  

---

## Problem Statement

The current review process requires manual:
1. Reviewer to run `td review`
2. Reviewer to manually create PR
3. Handling webhook failures from server-side auto-review

This is error-prone and creates friction.

---

## Proposed Solution

**review-agent** watches td for issues entering `in_review` status, then:

1. Performs automated code review
2. Opens PR (draft by default, ready on request)
3. Handles server-side webhook events
4. Retries failed CI, closes stale PRs

---

## Requirements

### Core Behavior

| Trigger | Action |
|---------|--------|
| `td status → in_review` | review-agent activates |
| Review complete | Open PR, request human approval |
| Human approves PR | Merge to main |
| Auto-review webhook | Handle server-side events |

### Code Review Logic

```typescript
interface ReviewCriteria {
  // What review-agent checks
  hasTests: boolean        // *.test.ts exists for *.ts
  testsPass: boolean       // bun test passes
  noConsoleErrors: boolean // No console.log left in
  noSecrets: boolean       // No hardcoded secrets
  typescriptClean: boolean // tsc --noEmit passes
}
```

### PR Management

| Action | Behavior |
|--------|----------|
| Open PR | Draft by default, link to td issue |
| Request review | Tag human reviewer |
| CI failure | Retry once, then flag for human |
| Auto-review webhook | Parse event, respond appropriately |
| Stale PR (>7 days) | Ping, then close if no response |

---

## User Interface

### td Integration

```bash
# review-agent watches for:
td review <id>    # Triggers review-agent

# review-agent sets:
td log "PR opened: <url>" --result
td log "Review passed" --result

# Human then:
td approve <id>   # review-agent merges PR
```

### Commands

| Command | Purpose |
|---------|---------|
| `review-agent status` | Show active reviews, PRs |
| `review-agent retry <pr>` | Retry failed CI |
| `review-agent close <pr>` | Close stale PR |

---

## File Structure

```
just-silo/
├── agents/
│   └── review-agent/
│       ├── src/
│       │   ├── index.ts        # Entry point
│       │   ├── reviewer.ts     # Code review logic
│       │   ├── pr-manager.ts    # GitHub PR operations
│       │   └── webhook.ts      # Webhook handler
│       ├── justfile
│       └── README.md
└── playbooks/
    └── review-agent-playbook.md
```

---

## Implementation Notes

1. **Use GitHub API** — `@octokit/rest` for PR operations
2. **Watch td via file poll or webhook** — Check every 30s or use td hooks
3. **Draft PRs by default** — Human promotes to ready
4. **Webhook endpoint** — `/api/webhooks/review` for server-side events

---

## Acceptance Criteria

- [ ] review-agent activates when issue enters `in_review`
- [ ] Opens draft PR linked to td issue
- [ ] Runs basic code checks (tests, typescript)
- [ ] Handles auto-review webhook
- [ ] Retries failed CI once
- [ ] Closes PRs without activity after 7 days
- [ ] Playbook documents usage

---

## Related

- `briefs/research/2026-04-07-brief-td-api-testing-01.md` — test-agent (prerequisite)
- `playbooks/agent-ops-playbook.md` — General agent coordination
- `playbooks/td-playbook.md` — td workflow
