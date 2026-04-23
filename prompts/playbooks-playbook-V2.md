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
