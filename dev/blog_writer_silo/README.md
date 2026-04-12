# blog_writer_silo

**Status:** In Development  
**Parent:** just-silo

Blog authoring workflow using wee stories extracted from documentation.

## Development Setup

This silo is being developed in the parent silo context.
Resources are accessed via relative paths to parent.

## Resources

| Resource | Path | Purpose |
|----------|------|---------|
| Stories | `../../stories/stories.jsonl` | Source stories |
| Briefs | `../../briefs/` | Brief documents |
| Scripts | `../../scripts/` | Shared tools |

## Development Commands

```bash
# Check resources
just verify              # Verify parent resources
just stats               # Story statistics

# Browse stories
just stories             # List all stories
just hq                  # High quality stories only
just by-topic TOPIC      # Stories for specific topic

# Draft workflow
just draft TOPIC         # Create draft from topic
just drafts              # List drafts
just render DRAFT       # Render to post
just publish DRAFT       # Publish and archive
just posts               # List published posts
```

## Story Topics Available

```
gemma4: 79 stories
lexicon-fuzzy-search: 29
research: 18
sub-silo-documentation-01: 12
tidy-docs: 11
counter-blast: 11
silo-scaling-laws: 10
silo-conceptual-lexicon: 10
silo-entropy: 9
```

## Workflow

1. **Browse** - `just stories` or `just by-topic TOPIC`
2. **Draft** - `just draft silo-entropy` creates draft
3. **Edit** - Manually edit `drafts/draft-*.md`
4. **Render** - `just render drafts/draft-*.md`
5. **Publish** - `just publish drafts/draft-*.md`

## Deployment

When ready to deploy:
```bash
just silo-deploy blog_writer_silo
```

This will:
1. Copy to `silos/blog_writer_silo/`
2. Update paths for standalone operation
3. Remove dev_path references
