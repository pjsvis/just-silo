# Brief: PXY Presentation System — Investigation Continue

**Date:** 2026-04-08
**Status:** Prototype working. Investigation continues.

---

## What We Have

A working prototype:
- PXY (Gemma 4) pushes slides via WebSocket
- Browser displays with sidebar and theme switching
- Markdown slides, server-side rendering
- Voice command ready (via iPhone session)

**Key files:** `presentation/`

---

## What We Need to Prove

### 1. Voice Control is Real
**Question:** Can PXY receive voice commands from iPhone and execute presentation commands?

**Next step:** 
- Set up iPhone voice session with PXY
- Test: "PXY, show slide 4"
- Test: "PXY, switch to dark theme"

**Success criteria:** Voice command → slide appears within 3 seconds.

---

### 2. The Performance Works
**Question:** Does the full performance flow with self-test, theme switch, and improv work in front of an audience?

**Next step:**
- Book a small audience (2-3 people)
- Run the full sequence
- Record what breaks

**Success criteria:** No presenter touches MacBook during performance.

---

### 3. Out-of-Band Generation
**Question:** Can PXY generate relevant content on-the-fly during Q&A?

**Next step:**
- Prepare scenarios: cost estimation, timeline questions, risk assessment
- PXY generates markdown, pushes to screen
- Presenter interprets

**Success criteria:** PXY generates plausible content within 10 seconds.

---

## Technical Open Questions

| Question | Priority | Notes |
|----------|----------|-------|
| iPhone voice session latency? | High | |
| Multiple browser stability? | Medium | Only one display needed |
| Slide transition animations? | Low | Nice to have |
| Auto-advance timer? | Low | Not needed |
| iPad as second display? | Medium | Could show speaker notes |

---

## Risks

1. **iPhone voice session fails mid-presentation** — Backup: Wispr Flow on Mac
2. **PXY generates wrong content** — Backup: prepared slides for common Q&As
3. **WebSocket drops** — Backup: refresh browser

---

## Resources

- `debriefs/2026-04-08-pxy-presentation-debrief.md` — This session's lessons
- `playbooks/presentation-playbook.md` — How to run the show
- `briefs/2026-04-08/2026-04-08-phone-voice-control-setup.md` — iPhone setup

---

## Status

| Component | Status |
|-----------|--------|
| Server | Working |
| Browser display | Working |
| Theme switching | Working |
| Slide navigation | Working |
| Markdown rendering | Working |
| Voice control | Untested |
| Live audience | Untested |

---

## Next Actions

1. **This week:** Test iPhone voice control
2. **This week:** Run performance for test audience
3. **Next week:** Refine based on feedback
