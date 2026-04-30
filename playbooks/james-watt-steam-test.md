# James Watt Steam Test

## Purpose

A framework for evaluating tools, libraries, and process changes with the rigour of the Scottish Enlightenment. Named in homage to James Watt—not merely for his steam engine, but for his relentless questioning of whether an innovation truly improved upon what existed before.

## When to Use

Apply this test when considering:

- Adopting a new library or framework
- Installing global tools
- Changing project structure or process
- Any decision that introduces overhead or commitment

## The Test

### Step 1: Diagnose the Problem

*Before all else, understand the ailment.*

- Is there a **real** problem that needs solving?
- Is this problem affecting **us**, specifically?
- Or are we adopting a solution in search of a problem?

> Watt asked: "Does this improve upon the existing state?" Not "Does this impress?" Not "Is this novel?" — but "Does it actually help?"

### Step 2: Evaluate the Solution

*Examine the instrument itself.*

- Is the design sound? (Not novel—sound.)
- Does it solve the problem without creating new ones?
- What are its failure modes?

### Step 3: Count the Cost

*All improvement has a price.*

- What is the **setup cost**? (Time, configuration, learning)
- What is the **ongoing maintenance**? (Dependencies, updates, compatibility)
- What is the **cognitive overhead**? (Mental models, rules, constraints)
- What breaks when this breaks?

### Step 4: Assess Philosophical Alignment

*The most technical tool fails if it conflicts with your spirit.*

- Does this fit our **values**?
- Does this match our **project scale**?
- Does this serve our **working style**?

> A lathe is a magnificent instrument. It is wrong for buttering bread.

### Step 5: Compare Alternatives

*Including the option of doing nothing.*

- Best for what scale?
- What are the alternatives?
- What happens if we do nothing?

### Step 6: Render a Verdict

*Adopt. Defer. Or Reject.*

- The verdict must be grounded in the above analysis
- "It looks cool" is not a verdict
- "Everyone uses it" is not a verdict
- "It solves a real problem for us, at our scale, in our style" is a verdict

---

## Decision Matrix Template

When evaluating a specific tool, populate this matrix:

```
┌─────────────────────────────────────────────────────────────┐
│  TOOL EVALUATION: [Name]                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PROBLEM: [What problem does it solve?]                     │
│  Is the problem real for us? [✓/✗/~]                        │
│                                                             │
│  SOLUTION: [How does it work?]                              │
│  Is the design sound? [✓/✗/~]                               │
│                                                             │
│  COSTS:                                                     │
│  ├─ Setup: [Low/Medium/High]                                │
│  ├─ Maintenance: [Low/Medium/High]                          │
│  ├─ Cognitive overhead: [Low/Medium/High]                   │
│  └─ Dependency risk: [Low/Medium/High]                      │
│                                                             │
│  PHILOSOPHICAL ALIGNMENT:                                   │
│  ├─ Our values? [✓/✗/~]                                     │
│  ├─ Our scale? [✓/✗/~]                                     │
│  └─ Our style? [✓/✗/~]                                     │
│                                                             │
│  ALTERNATIVES:                                              │
│  ├─ [Alternative 1]                                        │
│  ├─ [Alternative 2]                                         │
│  └─ Doing nothing                                           │
│                                                             │
│  VERDICT: [Adopt / Defer / Reject]                         │
│  Rationale: [Grounded in above]                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Example: lat.md

See `debriefs/2026-03-30-lat-md-investigation.md` for a full worked example.

**Summary verdict:** Reject.

**Rationale:** lat.md is technically sound—bidirectional links, enforced consistency, semantic search. However:

- Its overhead (link maintenance, section structure rules, mandatory pre/post doc updates) conflicts with our minimalist philosophy
- It solves a scaling problem we don't have (small, intentional team)
- Its enforcement model assumes agent understanding that cannot be guaranteed
- A well-maintained `README.md` serves us better than a rigid knowledge graph

The tool is good. It is wrong for us.

---

## Principles

### 1. The Butter-Spreading Principle

A tool may be magnificent without being appropriate. Evaluate fit, not merely quality.

### 2. The Watt Question

> "Does this improve upon the existing state—materially, not merely aesthetically?"

### 3. The Slacker's Heuristic

> If it requires ceremony to maintain, and ceremony isn't our thing, the ceremony will be neglected—and then the tool.

### 4. The Small-Project Principle

> Complex tooling solves scaling problems. If you don't scale, you don't need the solution.

### 5. The Uninstall Test

> If you haven't used a tool in 30 days, uninstall it. Its presence is overhead, not safety.

---

## Related

- `playbooks/change-management-protocol.md` — for the full decision cycle
- `debriefs/2026-03-30-lat-md-investigation.md` — worked example
- `playbooks/tool-audits.md` — periodic review of installed tools

---

## Changelog

| Date | Change |
|------|--------|
| 2026-03-30 | Created from lat.md investigation debrief |
