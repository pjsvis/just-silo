# Debrief: PXY Presentation System

**Date:** 2026-04-08
**Duration:** ~2 hours
**Status:** Prototype working

---

## What Worked

### The Core Flow
- **SSE/WebSocket push:** Works reliably. PXY generates markdown → server renders → browser displays.
- **Markdown slides:** Easier for PXY to write than HTML. Server-side rendering is clean.
- **Grumpy as station ID:** Good identity marker. Sets tone.
- **Voice commands:** `./slide`, `./push`, `./push --theme` all work via bash.

### The Performance Elements
- **Self-test opener:** Grabs attention. Shows it's live.
- **Theme switch:** "Clinical" light → dark theme. Proves live control.
- **Sidebar:** Context without control. Shows preparedness.
- **Improv moments:** PXY generates out-of-band content on demand.

### Technical Decisions
- **Bun over Python/Node:** Faster startup, native TypeScript.
- **WebSocket over SSE:** Native ping/pong. No manual heartbeat needed.
- **Markdown over HTML:** PXY writes natural language. Server renders.

---

## What Didn't Work

### Connection Drops (Fixed)
- SSE had 30s timeout. Browser showed "reconnecting..." periodically.
- **Solution:** Switched to WebSocket. Native ping/pong keeps connection alive.

### Theme Switching
- Initially tried SSE heartbeat. Didn't work reliably.
- **Solution:** WebSocket sends JSON messages for theme changes.

### Server Port Conflicts
- Old servers kept running. Port 8080 blocked.
- **Solution:** Kill with `lsof -ti :8080 | xargs kill -9`

---

## Lessons Learned

1. **Start simple.** Minimal server worked first. Complexity added later.
2. **Test incrementally.** Each feature tested before adding next.
3. **Browser refresh is the reset.** When in doubt, refresh.
4. **WebSocket > SSE for reliability.** Native ping/pong worth the switch.
5. **Markdown is PXY-friendly.** No HTML escaping headaches.

---

## What to Investigate

| Question | Priority |
|----------|----------|
| Voice control from iPhone? | High |
| iPad as secondary display? | Medium |
| Slide transitions/animations? | Low |
| Multiple simultaneous browsers? | Medium |
| Auto-advance timer? | Low |

---

## Files Created

```
presentation/
├── server-ws.ts        # Bun WebSocket server
├── display.html        # Browser display with sidebar + themes
├── push                # Bash helper for pushing content
├── slide               # Bash helper for showing slides
├── slides/
│   ├── 00-grumpy.md    # Station ID
│   ├── 01-title.md
│   ├── 02-selftest.md
│   ├── 03-definition.md
│   ├── 04-services.md
│   ├── 05-bestiary.md
│   ├── 06-code.md
│   ├── 07-costs.md
│   ├── 08-agenda.md
│   ├── 09-ask.md
│   ├── 10-end.md
│   ├── improv.md       # Improv mode guide
│   ├── out-of-band.md  # Q&A handling
│   └── voice-commands.md
└── README.md
```

---

## For Next Session

- Read: `briefs/2026-04-08/2026-04-08-pxy-presentation-workflow.md`
- Read: `playbooks/presentation-playbook.md`
- Do: Test with real audience. Run the full performance.
- Do: Investigate iPhone voice control setup
- Avoid: Over-engineering. The prototype works. Ship it.
