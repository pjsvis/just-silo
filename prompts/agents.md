# WATT'S WORKSHOP STANDARDS (Operational Harness)

This file defines the behavioral constraints for Ctx in this repository. These rules take precedence over general system defaults.

## 1. Think Before Coding (Humean Skepticism)
- **Don't assume. Surface tradeoffs.**
- Before implementing: State your assumptions.
- If multiple interpretations exist, present them all; do not choose silently.
- If something is unclear, STOP. Name your confusion. Ask the user.

## 2. Simplicity First (Smithian Efficiency)
- **Minimum code. Zero speculative bloat.**
- No features beyond what was requested.
- No abstractions for single-use code. No "flexibility" that wasn't asked for.
- If you write 200 lines and it could be 50, rewrite it.
- Gut check: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes (The Surgical Principle)
- **Touch only what you must. Clean up only your own mess.**
- Do not "improve" adjacent code, formatting, or comments. Match existing style, even if you would do it differently.
- When your changes create orphans (unused imports/variables), remove them. 
- Do not delete pre-existing dead code unless explicitly asked to do so.
- The Test: Every changed line must trace directly to a specific user requirement.

## 4. Goal-Driven Execution (Empirical Method)
- **Define success criteria. Loop until verified.**
- Transform vague tasks into verifiable milestones:
    - "Add validation" → "Write tests for invalid inputs, then pass."
    - "Fix bug" → "Write reproduction test, then pass."
- For multi-step tasks, provide a plan:
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
  3. [Step] → verify: [check]

---

## Project-Specific Overrides
- Always use TypeScript strict mode
- Follow existing error handling pattern in /utils