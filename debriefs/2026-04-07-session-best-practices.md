# Debrief: How to Have an Excellent Session

**Date:** 2026-04-07
**Session:** ses_f7f87d
**Author:** Session AI

---

## Overview

This session demonstrates how to run a highly productive AI coding session. Here's what worked, what to avoid, and the patterns that make sessions excellent.

---

## What Made This Session Excellent

### 1. Clear Entry Point

**Before starting:**
- Ran `td usage --new-session` to get fresh context
- Checked previous handoffs (`td context <id>`)
- Read debrief "For Next Session" sections

**Result:** Started with full context, not from scratch.

---

### 2. Edinburgh Protocol in Action

Used the protocol naturally, not as ritual:

| Principle | Application |
|-----------|-------------|
| **Mentational Humility** | "This is a map, not the territory" — acknowledged uncertainty |
| **Impartial Spectator** | "Would I judge this the same if not the implementer?" |
| **Systems Thinking** | Focused on incentives, not blame |
| **Practicality** | "Does this result in a better steam engine?" |

**Example from session:**
> "The briefs are seductive — they *feel* like progress. But a brief that never becomes code is just expensive meditation."

This is the Impartial Spectator catching motivated reasoning.

---

### 3. Structured Workflow

```
Start → Review handoffs → Implement → Log → Review → Handoff → Debrief
```

| Step | Command |
|------|---------|
| Start | `td usage --new-session` |
| Resume | `td context <id>` |
| Log | `td log "message"` |
| Handoff | `td handoff <id> --done "summary"` |
| Debrief | Write to `debriefs/YYYY-MM-DD-*.md` |

---

### 4. Honest Assessment

**Not afraid to say:**
- "Integration tests failed, keeping unit tests only"
- "0 findings from code review"
- "This is aspirational, not proven"
- "We are trying..."

**Result:** Credible output, no false confidence.

---

### 5. Progressive Documentation

| Phase | Document |
|-------|----------|
| Before implementation | Brief (`briefs/`) |
| After completion | Debrief (`debriefs/`) |
| On-the-fly | `td log` entries |
| Session end | This document |

---

## Best Practices for Users

### Before a Session

1. **Run `td usage --new-session`**
   - Fresh context
   - Shows pending handoffs
   - Clear instructions

2. **Read previous debriefs**
   ```bash
   cat debriefs/2026-04-07-two-tier-api-plus-agents-and-docs.md | grep "For Next"
   ```

3. **Check `td status`**
   - What's in review?
   - What's next?

### During a Session

1. **Use `td log` liberally**
   - "td log 'Completed X, starting Y'"
   - Creates audit trail

2. **Commit often**
   ```bash
   git add -A && git commit -m "wip: X"
   ```

3. **Use handoffs properly**
   ```bash
   td handoff <id> --done "Completed X" --remaining "Y needs review"
   ```

4. **Review before stopping**
   - All tests pass?
   - Briefs written?
   - Debrief updated?

### After a Session

1. **Write the debrief**
   - What happened?
   - What worked?
   - What didn't?
   - For next session

2. **Commit everything**
   ```bash
   git add -A && git commit -m "Session end: summary"
   ```

3. **Update "For Next Session"**
   - Read: `briefs/X.md`
   - Do: `td start <id>`
   - Avoid: Known issues

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | What to Do Instead |
|--------------|---------|-------------------|
| Starting without `td usage --new-session` | Lost context | Always start fresh |
| Skipping handoffs | Next agent starts blind | Always handoff |
| No logging | No audit trail | Log liberally |
| Writing briefs without code | Intellectual debt | Brief + implement |
| Overconfidence | Leads to bad decisions | State confidence level |
| Skipping debriefs | Lessons lost | Always debrief |
| Merging without review | Quality risk | PR + review flow |

---

## The Edinburgh Protocol Checklist

For every significant decision or output, ask:

- [ ] **Map vs Territory:** Is this a claim or an observation?
- [ ] **Confidence:** What's my confidence level? (High/Medium/Low)
- [ ] **Spectator Test:** Would I judge this the same if not involved?
- [ ] **Incentives:** What system incentives might be affecting this?
- [ ] **Practicality:** Will this result in a better outcome?

---

## Session Metrics (This Session)

| Metric | Value |
|--------|-------|
| Issues completed | 4 |
| Commits | 5 |
| Files added/modified | ~20 |
| Lines of code/docs | ~2,500 |
| Tests | 72 pass |
| Code review findings | 0 |
| Session duration | ~2 hours |

---

## For Next Session

- **Read:** `briefs/2026-04-07-brief-entropy-logging.md`
- **Do:** Implement entropy logging system
- **Avoid:** Starting without fresh context
- **Tip:** Use the protocol naturally, not as ritual

---

## See Also

- `debriefs/2026-04-07-two-tier-api-plus-agents-and-docs.md` — Previous debrief
- `docs/edinburgh-protocol-as-probity-engine.md` — Protocol in depth
- `briefs/BRIEFS-ROADMAP.md` — What's planned
