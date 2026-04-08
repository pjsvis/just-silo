# Brief: PXY Presentation Workflow — Live AI-Operated Slideshow

## WHAT
A real-time presentation workflow where PXY (Gemma 4, voice-controlled) operates the slides and artefacts via a browser display surface, while the presenter uses an iPhone as the voice interface. The browser is pushed to via an SSE feed from a local server on the MacBook. The MacBook connects to the projector via USB-C.

## THE SETUP

```
┌─────────────────────────────────────────────────────────┐
│  iPhone                                          │
│  Voice session with PXY                           │
│  "PXY, self-test" / "PXY, show slide 4"         │
└────────────────┬────────────────────────────────────┘
                   │ voice
                   ↓
┌─────────────────────────────────────────────────────────┐
│  MacBook                                               │
│  ┌─────────────────────────────────────────────────┐  │
│  │ PXY (Gemma 4)                                   │  │
│  │ - Knows slides, scenario, company, objectives     │  │
│  │ - Pushes to SSE feed                            │  │
│  │ - Remembers what you've covered                 │  │
│  │ - Flags missed content on request                │  │
│  └────────────────────┬────────────────────────────┘  │
│                       │ SSE push                    │
│  ┌────────────────────▼────────────────────────────┐  │
│  │ Local server (SSE endpoint)                    │  │
│  │ localhost:PORT/present                         │  │
│  └────────────────────┬────────────────────────────┘  │
│  ┌────────────────────▼────────────────────────────┐  │
│  │ Browser (full screen)                          │  │
│  │ Renders whatever PXY pushes                     │  │
│  │ No mouse, no keyboard needed                    │  │
│  └─────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────┘
                   │ USB-C
                   ↓
┌──────────────────────────┐
│  Projector              │
│  Full screen display    │
│  USB-C connected        │
│  (not bluetooth —      │
│  bluetooth too laggy)   │
└──────────────────────────┘
```

**The presenter never touches the MacBook.**

## WHY THIS WORKS

**The presentation IS the demo.**

Most AI demos are videos, screenshots, or hand-waved. This is live. The audience sees:
- A voice command issued from the iPhone
- PXY receiving and processing it
- Content appearing on the projector

No "and then what would happen is..." No claims. Evidence on screen.

**The self-test opener grabs the room immediately.**

> Presenter: "PXY, self-test."
> PXY: [affirmative] "All systems nominal. Slide 1 ready."

The audience watches a voice command produce an immediate, visible result. The room is paying attention before the first slide appears.

**The aesthetic contrast carries the room.**

| Phase | Content | Effect |
|-------|---------|--------|
| Opening | AI remote control magic | Grab attention, show it's real |
| Middle | Rules, regulations, cost, benefits, risks | Substance, credibility |
| Close | Consulting offer | The ask |

Start with the magic. People are paying attention for the boring stuff.

## PXY's ROLE

PXY is the operator, not the presenter:

- Advance/retreat slides on voice command
- Pull up artefacts by name or number
- Render brief sections, ledger entries, code snippets
- Flag what you haven't covered: "PXY, have we covered #16?"
- Confirm what's been covered: "PXY, self-check — what's left?"
- Cost estimates on request: "PXY, what's the cost estimate for that approach?"

PXY does not lead. PXY serves.

## THE BRIEF AS PXY's KNOWLEDGE BASE

PXY's context is loaded with:

- The consulting brief (services, process, engagement structure)
- The bestiary (18 named tendencies)
- The ops-mode checklist (#16)
- The model tiering table (#18)
- The session cost figures
- The scenario: company name, objectives, audience

During Q&A:
> "PXY, show the Ops-Before-Governance checklist." → #16 appears
> "PXY, pull up the engagement process." → Brief section appears
> "PXY, what's the cost estimate for 10,000 files?" → Ledger figure appears

## SLIDE MANAGEMENT

Slides are rendered as HTML/CSS in the browser. PXY knows each slide by name and number.

**Commands:**
- "PXY, advance" → next slide
- "PXY, back" → previous slide
- "PXY, show slide 7" → jump to slide 7
- "PXY, show agenda" → list of slides
- "PXY, show #17" → pull up bestiary entry 17

**Slide types PXY can render:**
- Text slides (headings, bullet points)
- Tables (model tiering, services, engagement process)
- Code blocks (cost ledger entries, ledger output)
- Images (diagrams, screenshots)
- Artefact pull-ups (bestiary entries, brief sections)

## THE SSE FEED

**Server:** A simple local HTTP server on the MacBook. One endpoint: `GET /present`.

**PXY → Server:** PXY POSTs rendered HTML/JSON to the server.

**Server → Browser:** SSE push to all connected browsers.

**Implementation:** See `presentation/sse-server.py`, `presentation/push-content`, `presentation/display.html`.

**Quick start:**
```bash
cd presentation
python3 sse-server.py 8080  # Terminal 1: start server
open http://localhost:8080/present  # Terminal 2: open browser
./push-content '<h1>Hello</h1>'  # Terminal 3: push content
```

**Why SSE:**
- One-way push: much simpler than WebSocket
- Browser receives and renders — no DOM manipulation needed
- Decoupled: display surface is independent of PXY's control surface
- If the browser crashes, it reconnects automatically

**Server options (simple, no dependencies):**
```bash
# Option 1: Node.js (already installed on Mac)
node -e "
const http = require('http');
const { spawn } = require('child_process');
http.createServer((req, res) => {
  if (req.url === '/present') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    });
    // pipe PXY output here
  }
}).listen(8080);
"

# Option 2: Python
python3 -m http.server 8080
```

## THE BROWSER

**Display:** Any browser on the MacBook, full screen (⌘F).

**URL:** `http://localhost:8080/present`

**No interaction needed** — the browser is display only. It renders whatever PXY pushes.

## PROJECTOR CONNECTION

**USB-C only.** Bluetooth audio/video is too laggy for a presentation environment.

```
MacBook → USB-C cable → Projector
```

Test in advance:
- [ ] USB-C cable connected and projector detected
- [ ] Display set to mirror or extend (⌘F1 or System Preferences)
- [ ] Resolution correct (1080p / 4K as appropriate)
- [ ] Audio routed correctly if used
- [ ] Bluetooth disabled on MacBook (avoids interference)

**Pre-room checklist:**
- [ ] USB-C connected before walking in
- [ ] Projector powered on
- [ ] Display confirmed on projector
- [ ] Self-test complete before audience arrives

## VOICE INTERFACE

**Primary:** iPhone voice session with PXY. Already open before starting.

**Safety:** iPhone session stays open throughout. If the main voice session fails, PXY is still reachable.

**PXY context load before the room:**
```
"Here is the presentation context:
- Company: [name]
- Audience: [description]
- Objectives: [what you want them to understand]
- Slides: [list of slide names and numbers]
- Artefacts: [list of retrievable content]
- Self-test: confirm all systems nominal, slide 1 ready"
```

## PREPARATION CHECKLIST

### Before the room
- [ ] Server running with SSE endpoint confirmed
- [ ] Browser opened on MacBook, full screen (⌘F), pointing to `localhost:8080/present`
- [ ] USB-C connected: MacBook to projector
- [ ] Projector powered on, display confirmed on projector
- [ ] iPhone session open with PXY
- [ ] PXY context loaded with scenario, company, objectives, slides
- [ ] Self-test completed and confirmed

### During the room
- [ ] Open with: "PXY, self-test"
- [ ] Wait for PXY affirmative before starting
- [ ] PXY, confirm what's been covered as you go
- [ ] PXY, flag missed content if requested

### Safety
- [ ] Bluetooth off on MacBook
- [ ] Backup slides in Keynote/PowerPoint if PXY unavailable
- [ ] iPhone session already open (safety if voice fails)
- [ ] USB-C cable accessible (don't trap under desk)

## WHAT NOT TO DO

- Do not let PXY answer questions autonomously — PXY retrieves, the presenter interprets
- Do not demo a failure live — if something might break, have a backup slide ready
- Do not over-rely on voice — key points should also be on slides as backup
- Do not skip the self-test — it establishes confidence before the audience
- Do not use bluetooth for display — lag makes the demo look broken

## THE OPENING SEQUENCE

```
1. Presenter walks in, connects USB-C, powers projector
2. Opens browser, goes to localhost:8080/present, full screen
3. Opens iPhone voice session with PXY
4. Says: "PXY, load context: [scenario brief]"
5. PXY confirms: context loaded
6. Says: "PXY, self-test"
7. PXY: "All systems nominal. Slide 1 ready."
8. PXY pushes Slide 1 to browser → appears on projector
9. Presenter: "Good morning. Today I'm going to show you what an AI agent workflow actually looks like. This is running now."
```

Steps 1-8 happen before the audience arrives or as they settle. By the time you say "good morning," everything is working.

## DRAFT STATUS

Ready to test. Run the setup at home with the projector. Iterate on the brief based on what works.
