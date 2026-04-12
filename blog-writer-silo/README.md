# Blog-Writer Silo

Transforms wee stories into polished blog posts.

## Domain Rules

### Story Selection
1. **Quality first** — Only use stories with quality ≥ 0.2
2. **Type balance** — Aim for 1 origin, 2-3 insights, 1 lesson minimum
3. **Topic coherence** — All stories should relate to the post topic
4. **Tag alignment** — Match story tags to post topic

### Draft Process
1. **Create** — Generate draft from template + stories
2. **Review** — Read draft, identify weak sections
3. **Swap** — Replace stories that don't fit
4. **Render** — Convert to final markdown
5. **Publish** — Move to posts/

### Template Syntax
```
{{section_name:type:count}}

Examples:
{{origin:1}}          - 1 origin story
{{insights:3}}         - 3 insights
{{lesson:1}}           - 1 lesson
{{tag:gemma4:3}}       - 3 stories tagged gemma4
```

### Draft Format
Drafts store embedded story text with metadata:
```markdown
---
title: "Post Title"
topic: gemma4
date: 2026-04-12
---

# {{title}}

## How It Started
<!-- STORY: id=abc123 type=origin quality=0.35 -->
We discovered that...

## What We Learned
<!-- STORY: id=def456 type=insight quality=0.25 -->
The thing about...
```

## Commands

```bash
just draft --topic gemma4 --stories 6    # Create draft
just render drafts/output.md              # Render draft
just publish drafts/output.md            # Publish
just stats                               # Story availability
```

## Anti-Patterns

- **Don't** include low-quality stories (< 0.2) just to fill space
- **Don't** force stories that don't relate to the topic
- **Don't** skip the review step — drafts are meant to be edited
