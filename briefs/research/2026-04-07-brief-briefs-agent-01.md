# Brief: briefs-agent — Brief Generation

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P3  

---

## Problem Statement

Brief writing is manual, repetitive, and often skipped under time pressure. The format is known; the content is derivable from td issues and git history.

---

## Proposed Solution

**briefs-agent** watches for closed issues and generates first-draft briefs:

1. Reads closed issue context (title, description, handoff)
2. Checks existing briefs for related work
3. Generates draft brief in `briefs/research/`
4. Human reviews and finalizes

---

## Requirements

### Brief Template

```markdown
# Brief: <Title from td issue>

**Date:** YYYY-MM-DD  
**Author:** ses_XXXX  
**Status:** For implementation  
**Priority:** P<1-4>  

---

## Context

What problem does this solve? Why now?

## Proposed Solution

What should be built? High-level.

## Requirements

| Requirement | Notes |
|-------------|-------|
| ... | ... |

## Acceptance Criteria

- [ ] ...
- [ ] ...

## Related

- ...
```

### Detection Logic

```typescript
interface BriefCandidate {
  issueId: string
  title: string
  description: string
  handoff: string
  labels: string[]
  // Check if brief already exists
  briefExists: boolean
}
```

### Generation Sources

| Source | Used For |
|--------|----------|
| `td show <id>` | Title, description, labels |
| `td handoff <id>` | What was done, remaining work |
| `git log --since="7 days"` | Related commits |
| Existing briefs/ | Links to related work |

---

## User Interface

### Automatic

```bash
# When td issue closed:
briefs-agent generate <issue-id>

# Creates:
briefs/research/YYYY-MM-DD-brief-<slug>-01.md
```

### Manual

```bash
briefs-agent generate --from-issue td-XXXX
briefs-agent generate --title "My Feature"
briefs-agent list --pending
```

---

## File Structure

```
just-silo/
├── agents/
│   └── briefs-agent/
│       ├── src/
│       │   ├── index.ts        # Entry point
│       │   ├── detector.ts     # Find closed issues
│       │   ├── generator.ts    # Generate brief
│       │   └── template.ts     # Brief template
│       ├── templates/
│       │   └── brief.md
│       ├── justfile
│       └── README.md
└── playbooks/
    └── briefs-agent-playbook.md
```

---

## Implementation Notes

1. **td query** — Find closed issues without briefs
2. **Template rendering** — Use Mustache or similar
3. **Slug generation** — `kebab-case` from title
4. **Incremental numbering** — `-01`, `-02` for versions

---

## Acceptance Criteria

- [ ] Detects closed issues
- [ ] Checks for existing briefs
- [ ] Generates well-formatted draft
- [ ] Saves to correct location
- [ ] Links to related briefs
- [ ] td integration (logs generation)
- [ ] Playbook documents usage

---

## Priority Rationale

P3: Valuable but not blocking. briefs-agent improves velocity but doesn't enable new capabilities.

---

## Related

- `briefs/research/2026-04-07-brief-debriefs-agent-01.md` — debriefs-agent (sister agent)
- `briefs/research/2026-04-07-brief-review-agent-01.md` — review-agent
