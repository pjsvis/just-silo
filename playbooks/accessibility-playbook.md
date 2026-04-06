Based on the **Playbook for Playbooks** and the insights regarding "normalization of deviance" from Jason Cowsill’s analysis of the *Challenger* disaster and modern AI-generated web bloat, I have structured the following protocol.

This playbook is designed to act as a "Mentation Bridge"—transforming the unstructured "stuff" of rapid AI development into the structured "thing" of an accessible-by-default environment.

---

# Accessibility Playbook

## Purpose
To institutionalize **Accessibility-First** development and counteract the "normalization of deviance" where sub-standard, inaccessible code becomes the accepted baseline due to the speed of AI generation.

## Context & Prerequisites
* **The "Challenger" Risk:** Inaccessible code is not just a "minor bug"; it is a systemic failure of the "O-rings" of the web.
* **Tooling:** Use semantic HTML5 elements as the primary structural layer.
* **Baseline:** Adherence to WCAG 2.2 Level AA is the non-negotiable floor, not the ceiling.

## The Protocol (The "How-To")
1.  **Semantic Primacy:**
    * Never use a `<div>` or `<span>` if a semantic element (e.g., `<main>`, `<nav>`, `<button>`, `<article>`) exists.
    * *Constraint:* AI-generated code often defaults to "div-soup." You must manually refactor these into semantic landmarks.
2.  **The Alt-Text Mandate:**
    * Every image must have an `alt` attribute.
    * If decorative, use `alt=""`. If functional, describe the *intent*, not just the pixels.
3.  **Keyboard Operability:**
    * Tab through every new component. If you can't reach it or see a focus state, it is "broken" and must be fixed before proceeding.
    * **Never** suppress the `:focus` outline without providing a high-contrast alternative.
4.  **Aria-Labeling (The Last Resort):**
    * Use ARIA only when semantic HTML cannot convey the name, role, or state. 
    * *Rule:* "No ARIA is better than Bad ARIA."
5.  **Contrast & Scalability:**
    * Verify color contrast ratios (minimum 4.5:1 for standard text).
    * Ensure the layout does not break when text is zoomed to 200%.

## Standards & Patterns
* **Normalization of Excellence:** We do not accept "it works for me" as a validation of success. 
* **The "Deviancy" Check:** If a shortcut (e.g., skipping labels) is taken "just this once," it must be flagged as a protocol violation.
* **Language:** Always define the document language `<html lang="en">`.

## Validation (How do I know I'm done?)
* The code passes an automated linting check (e.g., Axe-core).
* The component is fully navigable via keyboard only.
* Screen reader output (VoiceOver/NVDA) provides a coherent narrative of the interface.

---

### Maintenance
This playbook implements **OH-085 (Markdown Formatting Protocol)** and **PHI-1 (Abstract & Structure)** to ensure we are building the web "forwards." If an AI substrate consistently generates inaccessible patterns, this protocol must be updated to include specific "negative prompts" to suppress those deviances.

What specific component or project should we subject to this protocol first?