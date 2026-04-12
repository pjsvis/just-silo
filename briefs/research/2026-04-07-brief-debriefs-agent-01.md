# Brief: debriefs-agent — Post-Merge Lessons Capture

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P3  

---

## Problem Statement

Lessons learned are lost. Session context evaporates. Future agents repeat the same mistakes because there's no institutional memory.

---

## Proposed Solution

**debriefs-agent** watches for merges to main and generates post-merge debriefs:

1. Extracts commit messages, PR body, review comments
2. Analyzes what worked, what didn't
3. Generates debrief in `debriefs/`
4. Human reviews and finalizes

---

## Debrief Template

```markdown
# Debrief: <Feature/Change>

**Date:** YYYY-MM-DD  
**Duration:** <time>  
**Merge:** <sha>  
**Author:** <pr author>  

---

## What We Did

- ...

## What Worked

| Item | Result |
|------|--------|
| ... | ... |

## What Didn't Work

| Item | Issue |
|------|-------|
| ... | ... |

## Metrics

- Issues created: N
- Commits: N  
- Lines changed: +/-N
- Time: N hours

## Lessons

1. ...
2. ...

## Related

- Brief: ...
- PR: ...
```

---

## Detection Logic

```bash
# Git webhook or polling
git log --merges --since="24 hours ago"
# For each merge to main:
debriefs-agent process <merge-sha>
```

---

## User Interface

### Automatic

```bash
# On merge to main:
debriefs-agent generate <merge-sha>

# Creates:
debriefs/YYYY-MM-DD-debrief-<slug>.md
```

### Manual

```bash
debriefs-agent generate --sha abc123
debriefs-agent list --recent
debriefs-agent search --term "sqlite"
```

---

## File Structure

```
just-silo/
├── agents/
│   └── debriefs-agent/
│       ├── src/
│       │   ├── index.ts        # Entry point
│       │   ├── detector.ts     # Find recent merges
│       │   ├── analyzer.ts     # Extract lessons
│       │   ├── generator.ts    # Generate debrief
│       │   └── template.ts     # Debrief template
│       ├── templates/
│       │   └── debrief.md
│       ├── justfile
│       └── README.md
└── playbooks/
    └── debriefs-agent-playbook.md
```

---

## Implementation Notes

1. **GitHub API** — Use `@octokit/rest` for PR data
2. **Commit analysis** — Parse conventional commits
3. **td history** — Query issues linked to merge
4. **Template** — Standardized debrief format

---

## Acceptance Criteria

- [ ] Detects merges to main
- [ ] Extracts PR body, commits, reviews
- [ ] Generates well-formatted debrief
- [ ] Saves to correct location
- [ ] Links to related briefs, PRs
- [ ] Searchable (grep-ready format)
- [ ] Playbook documents usage

---

## Priority Rationale

P3: Valuable for institutional memory but doesn't block features. Lower priority than agents that enable the workflow.

---

## Related

- `briefs/research/2026-04-07-brief-briefs-agent-01.md` — briefs-agent (sister agent)
- `briefs/research/2026-04-07-brief-review-agent-01.md` — review-agent (triggers debriefs)
