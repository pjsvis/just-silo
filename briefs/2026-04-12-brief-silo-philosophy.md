# Silo Philosophy

**A silo is a folder on a disk. It needs a reasoning-engine to produce output. It is a capability that has a cost profile and a production profile. It is a business thing.**

**We choose consistency over completeness.**

---

## What It Is

A **silo** is not weird. It's not a framework. It's not a philosophy (though this document explains the thinking).

**It's a folder on a disk.** That's it. Simple.

```
just-silo-dev/
├── briefs/
├── scripts/
├── justfile
└── ...
```

The magic is that it **works with a reasoning-engine** (Claude, GPT, Gemini, whatever) to produce output.

---

## The Capability Model

| Element | Description |
|---------|-------------|
| **Input** | Raw material: ideas, data, context |
| **Processing** | The silo structure + reasoning-engine |
| **Output** | Actions, documents, decisions |
| **Cost profile** | Token usage, latency, complexity |
| **Production profile** | Throughput, reliability, quality |

**A silo is a business thing.** It has inputs. It has outputs. It costs money to run. It produces value.

---

## The Invariants

A silo maintains five invariants:

| # | Invariant | Rule |
|---|-----------|------|
| 1 | **Filename uniqueness** | No duplicates within silo scope |
| 2 | **README per directory** | Every browsable dir has README.md |
| 3 | **README-checksum** | README must match directory contents |
| 4 | **Archive naming** | `FOLDERNAME_archive` pattern |
| 5 | **No recursion** | No nested silos. Ever. |

These are not philosophy. They're **operational rules** that keep the silo predictable.

---

## Fractal Similarity, Not Recursion

**The pattern repeats at every scale. The depth is bounded.**

```
RECURSION (bad):
sub-silo/
└── sub-sub-silo/
    └── sub-sub-sub-silo/  ← infinite depth

FRACTAL SIMILARITY (good):
every directory has: README.md, structure, boundary
↓
But bounded. One step at a time.
```

---

## The Watchwords

| Word | Meaning | Action |
|------|---------|--------|
| **TIDY FIRST** | Keep context lean. Archive liberally. | Archive unused. Remove clutter. |
| **CONSISTENCY** | README matches directory. Invariants hold. | Verify before proceeding. |
| **STUFF → THINGS** | Transform unstructured into structured. | Mentation: the core job. |
| **ENTROPY REDUCTION** | The goal. Less noise, more signal. | Every action aims here. |

---

## The Gamma Loop

```
DO → LEARN → DEBRIEF → IMPROVE → REPEAT
```

The loop never "completes." It stays consistent. Each cycle reduces entropy.

---

## Time Travel

**Date-prefixed briefs preserve the iteration trail.**

```
2026-04-06-brief-silo-cadence.md     ← What we thought on April 6
2026-04-07-brief-api-architecture-v2.md  ← What we thought on April 7
2026-04-12-brief-lpc-evaluation.md  ← What we thought yesterday
```

- What were we thinking last week? `ls briefs/2026-04-06*.md`
- What led to this decision? Chronological brief scan
- What did we consider but abandon? Archived briefs

The brief names are timestamps of cognition.

---

## Archive vs Origami

**Our previous archive strategy was origami: folding stuff into folders. That's complex.**

**Unique filenames make retrieval simple.**

```
ORIGAMI (complex):
old-stuff/ → archive/ → archive_archive/  ← links break with depth

UNIQUE FILENAMES (simple):
2026-04-06-brief-silo-cadence.md  ← always findable, grep-able anywhere
```

Archive structure is irrelevant. The filename IS the retrieval key.

---

## The Pinky and the Brain Model

**Two roles, one dynamic, one show.**

```
Pinky: "What are we going to do tonight, Brain?"
Brain: "Same thing we do every night, Pinky - try to take over the world!"
```

| Role | Character | Function |
|------|-----------|----------|
| **Pinky** | The reasoning-engine | Reads, acts, does the work, creates |
| **Brain** | The directive/policy | Plans the pause, checks the write |

CAW CANNY is "the Brain." The engine is "Pinky." Together they produce output.

### The Directive

**CAW CANNY:** Before any read-write action, prompt for go/no-go.

```
Is this necessary?
Should existing content be archived instead?
Does this break the invariants?
```

---

## Workflows

**Workflows are named procedures. No recursion. No nested silos.**

```
CREATE → USE → REVIEW → REVISE / DELETE
```

A workflow is useful or deleted. No complexity for complexity's sake.

---

## A Beginning Is a Delicate Thing

*"A beginning is a delicate thing, know this then..."* — Dune

Context unfolds one step at a time:

```
Level 1: "Read START-HERE.md"
Level 2: "Run just silo-help"
Level 3: "Explore briefs/"
Level 4: "Read a brief"
...
```

The entry point is crafted. The reveal is intentional. Each step is bounded.

---

## Anti-Patterns

**DON'T:**
- Nest silos (recursion)
- Use generic filenames (notes.md, draft.md)
- Act without pausing (CAW CANNY)
- Keep everything "just in case"
- Claim a system is complete

**DO:**
- Date-prefix new files: `YYYY-MM-DD-name.md`
- Verify invariants before proceeding
- Update README when directory changes
- Archive early (retrieve via filename search)
- Pause before write
- Use workflows

---

## Addendum: The Decision Loop

**This is how I operate.**

```
CONTEXT ──── CAPABILITIES ──── BRIEFS/DEBRIEFS
     ↘              ↙               ↘
      ↘          ↙               ↘
       ↘      ↙               ↘
        ↘  ↙               ↘
         ↘↓             ↘
          MAP
           │
           ▼
      ASSESS + ASSIMILATE
           │
           ▼
       NEXT ACTION
           │
           └─────▶ (loop back)
```

**The components:**

| Component | Question | Source |
|-----------|----------|--------|
| **Context** | What's happening now? | `just silo-status`, recent briefs |
| **Capabilities** | What can I do? | `just --list`, `just silo-help` |
| **Briefs/Debriefs** | What was interrupted? | `briefs/`, `debriefs/` |
| **CAW CANNY** | Check territory | `just silo-gate` |
| **Map** | Structure for assessment | Generated from above |
| **Decide** | Where next | Based on map, not driven by it |

**The map does not "decide."**

The map presents a structure to be assessed and assimilated. You assess. You assimilate. You decide.

The map is intelligence, not instruction.

**That's pretty much what I do.**

---

**A silo is a folder on a disk. It needs a reasoning-engine to produce output. It is a capability that has a cost profile and a production profile. It is a business thing.**

**Tidy first. Stay consistent. Reduce entropy.**
**Context-friendly. Progressive. Yours to power.**