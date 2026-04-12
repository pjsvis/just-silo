# Workflows

**Workflows replace sub-silos. No recursion. No nesting.**

A workflow is a named procedure in `justfile` or in `workflows/*.justfile`.

---

## The Rule

**No nested silos. Ever.**

```
OLD (recursion = bad):
just-silo-dev/
└── sub-silo-1/
    ├── .silo      ← nested = complexity
    └── ...

NEW (workflows = simple):
just-silo-dev/
├── justfile        ← workflows as recipes
└── workflows/      ← optional grouping
    └── blog.justfile
```

---

## Pattern

### Inline workflow (in root justfile)

```just
# A workflow is just a recipe
workflow-blog:
    @just silo-verify
    @just silo-harvest
    @./scripts/blog-generate.sh
```

### Grouped workflow (in workflows/)

```just
# workflows/deploy.justfile

# Deploy silo to production
workflow-deploy:
    @./scripts/silo-deploy.sh {{name}}
    @echo "✓ Deployed {{name}}"
```

---

## Workflow Lifecycle

```
CREATE → USE → REVIEW → REVISE / DELETE
  ↓        ↓       ↓           ↓
 Fast    Run    Evaluate    Keep or prune
```

**A workflow is useful or deleted. No complexity for complexity's sake.**

---

## Calling Workflows

```bash
# Inline workflow
just workflow-blog

# Grouped workflow
just --justfile workflows/deploy.justfile workflow-deploy name=my-silo

# Or add to root justfile:
# @just --justfile workflows/deploy.justfile workflow-deploy name=my-silo
```

---

## Anti-Patterns

❌ Nested silos (sub-silo-1/, sub-silo-2/)
❌ Workflows that are never used
❌ Complexity for its own sake

**DO:** Keep it simple. Workflows are just named procedures.

