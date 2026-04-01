---
date: 2026-04-01
tags: [playbook, brief, process]
---

# Briefs Playbook

## Purpose
A brief is a concise document that outlines the objective, requirements, and plan for a specific task or feature. It serves as a contract between the user and the agent, ensuring alignment before work begins.

## File Naming
- **Format:** `YYYY-MM-DD-[slug].md`
- **Location:** `briefs/` directory
- **Example:** `briefs/2026-04-01-just-silo-ui-demo.md`

## Frontmatter

```yaml
---
date: YYYY-MM-DD
tags: [brief]
---
```

## Template

```markdown
## Task: [Task Name]

**Objective:** [Concise description of the main goal]

- [ ] [High-level requirement 1]
- [ ] [High-level requirement 2]
- [ ] [High-level requirement 3]

## Key Actions Checklist:

- [ ] [Actionable step 1]
- [ ] [Actionable step 2]
- [ ] [Actionable step 3]

## Detailed Requirements / Visuals

[Optional: Add detailed descriptions, ASCII art layouts, or specific constraints here]

```

## Best Practices
- **Keep it focused:** One brief per distinct task.
- **Use checklists:** Checklists allow for tracking progress within the brief itself.
- **Be visual:** Use ASCII art or diagrams to explain layout changes.
