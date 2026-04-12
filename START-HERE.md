# START HERE

**Welcome to just-silo-dev.** This is the development workspace for the just-silo framework.

---

## What Is This?

A **silo** is a self-contained directory that:
- Externalizes domain knowledge
- Provides automation via `just`
- Maintains invariants for consistency

## First Steps

1. **Run `just silo-help`** — See entry points and directives
2. **Read `README.md`** — Get the tone and purpose
3. **Run `just silo-verify`** — Verify invariants hold

## ⚠️ CAW CANNY Directive

**Before any read-write action, prompt for go/no-go.**

```
Is this consistent? Should this be archived instead of created?
```

The directive is in `.silo`. Before you write:
- Ask: "Is this necessary?"
- Ask: "Should existing content be archived instead?"
- Ask: "Does this break the invariants?"

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `briefs/` | What we've been thinking (date-prefixed) |
| `playbooks/` | Operational knowledge |
| `scripts/` | Automation |
| `docs/` | Technical documentation |
| `template/` | The silo template |

## The Watchwords

- **TIDY FIRST** — Keep context lean
- **CONSISTENCY** — The checksum
- **STUFF → THINGS** — Mentation
- **ENTROPY REDUCTION** — The goal

## Invariants

1. Filenames unique within silo
2. README.md per browsable directory
3. README is checksum of directory
4. Archive naming: `FOLDERNAME_archive`

---

**Run `just silo-help` for commands. Run `just silo-verify` to check structure.**