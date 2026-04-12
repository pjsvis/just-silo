# Silo Invariants

**Date:** 2026-04-12  
**Pattern:** Foundational properties of a silo  
**Status:** Invariant set established

---

## Invariant 1: Filename Uniqueness

**Within a silo, all filenames are unique.**

This is a foundational property that enables:
- **Safe reorganization** — Move files without breaking internal references
- **Archive by default** — New ideas → archive later, not clutter now
- **Clean context** — Active workspace stays lean

### Why Unique Filenames?

Traditional file systems use paths as identity, breaking on move. Silo uses unique filenames with search-based references:

```markdown
# References are grep-friendly, not path-dependent
See `entropy-management-playbook.md` for the pattern.
```

### Naming Convention

```
# Use: date + kebab-case
2026-04-12-brief-something.md

# Avoid: generic names
notes.md      # collision-prone
draft.md      # ambiguous
todo.md       # who owns this?
```

### Archive Naming Convention

**Rule:** Archive folders use `*_archive` pattern.

```bash
# Correct: FOLDERNAME_archive
mv archive archive_archive
mv debriefs/archive debriefs_archive

# Wrong: nested archive/
# debriefs/archive/    ← forbidden
```

**Invariant 4: Archive Folder Naming**

| Pattern | Example | Status |
|---------|---------|--------|
| `*_archive` | `briefs_archive/` | ✅ Valid |
| `*/archive` | `briefs/archive/` | ❌ Forbidden |

**Why:** Keeps folder names unique within silo. Prevents nested confusion.

---

## Invariant 2: README.md Per Directory

**Every browsable directory has a README.md.**

This serves as the "stop and read" point — the context layer when entering a directory.

### Purpose

- **Browser landing page** — GitHub, file explorers show README.md automatically
- **Context provision** — Human entering directory gets immediate understanding
- **Navigation aid** — README.md in `/docs/` explains what docs are for

### The Hierarchy

```
silo/
├── README.md         # Root: What is this silo?
├── docs/
│   └── README.md     # What is in docs/?
├── scripts/
│   └── README.md     # What scripts exist?
└── archive/
    └── README.md     # What is archived here?
```

### Cross-Silo Exception

Different silos may each have a `README.md`. This is **acceptable** — each silo is self-contained scope.

```
template/         # Silo A
├── README.md     # ok
└── .silo

silos/my-silo/   # Silo B  
├── README.md     # ok - different silo scope
└── .silo
```

---

## Invariant 3: README-Checksum Consistency

**The README.md and its directory must be consistent.**

This is a checksum-style invariant: the README.md is a claim about the directory's contents. If the claim doesn't match reality, something is wrong.

### The Checksum

```
┌─────────────────────────────────────────┐
│  README.md ←→ Directory Contents        │
│                                         │
│  README says: "This dir has A, B, C"   │
│  Directory has:  A, B, C, D             │
│                                         │
│  ⚠ MISMATCH: STOP AND RESOLVE          │
└─────────────────────────────────────────┘
```

### Why This Matters

The README.md is not decorative — it's a **contract**:

| README claims | Reality | Action |
|---------------|---------|--------|
| "Contains scripts" | Scripts exist | ✅ OK |
| "Contains briefs" | Briefs exist | ✅ OK |
| "Contains archived docs" | Docs are archived | ✅ OK |
| "Contains agents" | No agents dir | ❌ MISMATCH |

A mismatch means:
- Someone moved something without updating the README
- The README is stale and provides false context
- Something is broken and needs repair

### Resolution Protocol

When mismatch is detected:

```
1. STOP — Do not continue until resolved
2. AUDIT — What's there vs. what README says
3. DECIDE — Update README or restore content
4. DOCUMENT — Note what changed and why
```

---

## Enforcement

### Validation Checks

```bash
# Check 1: Filename collisions within silo
find . -type f | xargs -I{} basename {} | sort | uniq -c | grep -v " 1 "

# Check 2: README.md exists in every directory
find . -type d -not -path "*/.git/*" -not -name ".git" | \
  while read dir; do 
    [ ! -f "$dir/README.md" ] && echo "MISSING: $dir/README.md"
  done

# Check 3: README content matches directory
# (manual review or custom script per directory)
```

### Integration with silo-verify-structure.sh

```bash
# Add to verify script:
echo ""
echo "=== Invariant Checks ==="

# README.md per directory
MISSING_README=$(find . -type d -not -path "*/.git/*" | while read d; do
    [ ! -f "$d/README.md" ] && echo "$d"
done | wc -l)

if [ $MISSING_README -eq 0 ]; then
    echo "  ✓ README.md in all directories"
else
    echo "  ✗ $MISSING_README directories missing README.md"
fi
```

---

## The Archive Pattern

### When to Archive

```
□ File created in fast-think mode
□ Not referenced by other files
□ Not from current sprint
□ Not opened in last 7 days
→ ARCHIVE
```

### How to Archive

```bash
# Safe because filename is unique within silo
mv drafts/entropy-idea-01.md archive/drafts/

# Git history preserved - soft retention
```

### Archive Structure

```
archive/
├── drafts/           # Incomplete, superseded
├── superseded/       # Replaced by newer versions
├── experimental/     # Untested patterns
└── README.md         # Always has README
```

---

## Slow Change Document Retention

| Age | Action |
|-----|--------|
| Creation | Keep in active workspace |
| 7+ days unused | Archive to `archive/` |
| 30+ days archived | Review: keep / deprecate |
| Deprecated | Git history preserved (not deleted) |

---

## Anti-Patterns

**DON'T:**
- Use generic names like `notes.md`, `draft.md` (Invariant 1)
- Have directories without `README.md` (Invariant 2)
- Ignore README-directory mismatch (Invariant 3)
- Keep everything "just in case"

**DO:**
- Date-prefix new files: `YYYY-MM-DD-name.md`
- Ensure every directory has README.md
- Update README when directory changes
- Archive aggressively (git has history)

---

## Related

- `playbooks/entropy-management-playbook.md` — Think Fast → Archive → Gap Fill
- `scripts/silo-verify-structure.sh` — Structure validation
- `playbooks/debriefs-playbook.md` — Post-session reflection