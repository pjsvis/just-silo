This meta-playbook is a vital architectural component. By standardizing *how we standardize*, you effectively cap the entropy of your system. I have refined your draft to include the "Wisdom Fold" strategy we discussed, ensuring that as your Playbooks evolve, they undergo active compression rather than passive proliferation.

This version incorporates the **Edinburgh Protocol (v3.0)** standards for clarity and **Fisher-Bayesian** feedback loops to ensure the documentation remains a living prior rather than a static tombstone.

***

### Artifact: `playbooks-meta-management.md`

```markdown
---
date: 2026-04-22
tags: [playbook, meta, governance]
purpose: Codify the management, distillation, and lifecycle of all project playbooks.
---

# Playbook for Playbooks

## Purpose
This playbook defines the standard for creating, maintaining, and distilling operational playbooks. It ensures our "tribal knowledge" remains structured, actionable, and free from administrative entropy.

## 1. The Strategy: Distillation over Proliferation
We do not treat playbooks as a growing graveyard of documents. We treat them as **Lossy Compression of Wisdom**.
* **Constant Density:** If a new rule is added, an old rule must be merged, deleted, or clarified.
* **The Wisdom Fold:** Before archiving a debrief, you MUST perform a "Wisdom Fold": extract the core invariant, update the relevant Playbook, and then move the debrief to `archive/`.

## 2. When to Write a Playbook
1.  **Repeatability:** Task frequency > 2.
2.  **Criticality:** Task involves risk or high-stakes precision.
3.  **Innovation:** A novel problem is solved ("First Contact").
4.  **Style:** A consistent pattern is identified (e.g., File Naming, Design Style).

## 3. Standard Structure
Every Playbook must be machine-readable and human-navigable:

### Frontmatter
```yaml
---
date: YYYY-MM-DD
tags: [playbook, topic, subtopic]
status: [active | deprecated]
---
```

### Protocol Sections
* **H1 Title:** Operational focus.
* **Purpose:** One sentence (The "Why").
* **Prerequisites:** Tools, state, or parent playbooks required.
* **The Protocol:** Imperative, numbered steps. Use `` for internal links if applicable.
* **Standards/Patterns:** The "Style" rules (what not to do).
* **Validation:** How the agent verifies completion.

## 4. Lifecycle Management (The Bayesian Loop)
Playbooks are dynamic Bayesian Priors. They must be tuned.

| Phase | Action | Criteria |
| :--- | :--- | :--- |
| **Creation** | Initialize with standard frontmatter. | Novelty or Repeatability. |
| **Active Refinement** | Perform "Wisdom Fold" after every debrief. | Conflict or Inefficiency detected. |
| **Archival** | Move outdated/specific debriefs to `archive/`. | Event is closed; only Invariants remain. |
| **Deprecation** | Add `> **DEPRECATED**` banner; link to successor. | Pattern is obsolete. |

## 5. File System Standards
* **Location:** `playbooks/`
* **Naming:** `topic-subtopic-playbook.md`
* **Linking:** All inter-playbook references must use standard Markdown links.

## 6. Maintenance (The "Gumption" Gate)
If a playbook fails, it is a **Failure of Process**, not a failure of the agent.
* **Fail-Forward:** Update the playbook immediately.
* **Audit:** If the same error occurs twice, the playbook is missing a guardrail.
```

***

### Implementation Advice for your Current Issue
To immediately reduce your existing playbook bloat, I suggest the following **"Day Zero" Audit**:

1.  **Categorize:** Move your current files into three buckets: `CORE` (Invariants), `PROJECT` (Working memory), and `ARCHIVE` (Evidence).
2.  **The "Wisdom Fold" Sweep:** For your next three Debriefs, **do not save them.** Force yourself to synthesize their contents into the relevant Playbook and *then* delete the raw Debrief file.
3.  **Lexicon vs. Playbook:** If a definition is unclear, put it in the `conceptual-lexicon-ref-v1.79.json`. If an *action* is unclear, put it in a `Playbook`. Do not mix definitions with instructions; this is the primary cause of document bloat.

Does this structure provide the "active pruning" mechanism you need to handle the proliferation, or should we add a specific heuristic for "When to delete a playbook entirely"?