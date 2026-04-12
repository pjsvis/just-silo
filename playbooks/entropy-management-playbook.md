# Entropy Management Playbook

**Date:** 2026-04-12  
**Pattern:** Think Fast → Archive → Gap Fill → Repeat  
**For:** Agents and humans working with high-velocity ideation

---

## The Problem

When we think fast, we produce prolifically because:
- We don't want to miss anything
- Context switching is expensive
- Ideas are transient—capture now, sort later

**Result:** A directory full of drafts, duplicates, superseded docs, and experimental briefs.

This is *not* bad. It's the natural entropy of active cognition.

---

## The Pattern

```
THINK FAST          →   ARCHIVE          →   GAP FILL         →   REPEAT
(Prolific output)       (Remove noise)       (Fill gaps)          (Next sprint)
     ↓                      ↓                    ↓
  Drafts                Not relevant         What's missing         Continue
  Duplicates           Superseded           What's broken          learning
  Experiments          Draft/early          What's not done
```

---

## Phase 1: Think Fast (Capture)

**When:** You're in high-output mode  
**Do:** Write it, capture it, create it  
**Don't:** Judge quality or enforce structure

```
Signal: "I should save this thought"
Action: Create brief/playbook/note
```

---

## Phase 2: Archive (Triage)

**When:** Sprint ends, or before major work  
**Do:** Classify everything as ACTIVE or ARCHIVE

### Classification Rules

| Class | Criteria | Action |
|-------|----------|--------|
| **ACTIVE** | Current sprint, references elsewhere, implemented | Keep in place |
| **ARCHIVE** | Superseded, draft, experimental, rarely referenced | Move to `archive/` |

### Archive Criteria Check

```
□ Is this referenced by other files?
□ Is this implemented in code/scripts?
□ Is this from the current sprint?
□ Have I looked at this in the last 7 days?

If all NO → ARCHIVE
```

### Archive Location

```
archive/
├── briefs/              # Old briefs
│   └── 2026-04-06/
├── docs/                # Old documentation
│   └── metaphor-v01/
├── playbooks/           # Old playbooks
│   └── drafts/
└── sessions/            # Session logs
```

**Rule:** Archives are *never* deleted. They can be retrieved.

---

## Phase 3: Gap Fill

**When:** Archive is done, directory is clean  
**Do:** Identify what's missing

### Gap Analysis Checklist

```
PRIMITIVES:
□ Inbox (harvest.jsonl) exists and documented?
□ Outbox (final_output.jsonl) exists and documented?
□ Active state (data.jsonl) exists and documented?
□ Processing (justfile) exists and documented?
□ Markers/checkpoints implemented?
□ Triggers configured?

TOOLS:
□ Verification script (silo-verify-structure)?
□ Idempotency documented?
□ Restartability tested?

DOCUMENTATION:
□ README points to framework doc?
□ Framework doc has lifecycle diagram?
□ Gap analysis run?
```

### Fill Strategy

| Gap | Priority | Action |
|-----|----------|--------|
| Missing primitive | HIGH | Create immediately |
| Missing tool | HIGH | Implement before next sprint |
| Missing doc | MEDIUM | Document next session |
| Missing test | MEDIUM | Add to integration test |

---

## Phase 4: Verify

**When:** Gap fill is complete  
**Do:** Run verification

```bash
just silo-verify-structure
```

**Goal:** 0 failures, minimal warnings.

---

## Session Template

```
=== SESSION START ===
Date:
Goal:
Mode: [FAST | NORMAL | REFACTOR]

=== THINK FAST (if mode=FAST) ===
Created:
- file1.md
- file2.md
- file3.md

=== TIDY (end of sprint) ===
Archived:
- file1.md → archive/
- file2.md → archive/

Remaining (active):
- file3.md (keep - referenced by X)
- file4.md (keep - implemented in code)

=== GAP ANALYSIS ===
Missing:
- item1
- item2

=== SESSION END ===
```

---

## Anti-Patterns

**DON'T:**
- Delete archived files (archive, don't delete)
- Try to prevent fast-think phase (it's necessary)
- Force structure during capture phase
- Keep everything "just in case"

**DO:**
- Archive liberally (retrievable later)
- Update index/manifest when archiving
- Run verification after tidy
- Document the gaps found

---

## Integration with Debriefs

After each major work session, run debrief:

```bash
just debriefs-template
# Fill in:
# - What was created?
# - What should be archived?
# - What gaps were found?
```

---

## Related

- `playbooks/tidy-first-playbook.md` — Prioritizing cleanliness
- `playbooks/debriefs-playbook.md` — Post-session reflection
- `scripts/silo-verify-structure.sh` — Structure validation