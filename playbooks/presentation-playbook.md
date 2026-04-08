# Presentation Playbook

## Overview

A live demo where PXY (Gemma 4) operates the slides via voice command. The browser is pushed to via WebSocket from a local server.

---

## Setup (Before Audience Arrives)

### Terminal 1: Start Server
```bash
cd presentation
bun run server-ws.ts
```

### Terminal 2: Open Browser
```
http://localhost:8080/
```
Full screen: ⌘⇧F

### iPhone: Open PXY Voice Session
Load context:
```
Station ID: Grumpy
Slides: presentation/slides/
Commands: ./slide <name>, ./push "<markdown>", ./push --theme dark|light
```

---

## The Performance

### Opening Sequence (Before Audience)
1. USB-C → Projector ✓
2. Browser full screen ✓
3. iPhone session open ✓
4. PXY context loaded ✓
5. Self-test ✓
6. Theme switch (if doing the clinical opener) ✓

### Opening (With Audience)
```
Presenter: "Good morning. Let's start with a self-test."
         ↓
         "PXY, self-test."
         ↓
PXY: ./slide 02-selftest
         ↓
[Self-test appears on screen]
```

### Theme Switch Opener (Optional)
```
Presenter: "Hmm, this looks a bit... clinical."
         ↓
         "PXY, switch to dark theme."
         ↓
PXY: ./push --theme dark
         ↓
[Theme switches instantly. Audience sees live control.]
```

### Main Presentation
```
./slide 01-title
./slide 02-selftest
./slide 03-definition
...
```

### Q&A / Improv
```
Audience: "What about cost estimation?"
Presenter: "Good question — PXY, show costs for 50k files."
         ↓
PXY generates content and pushes
         ↓
[Out-of-band content appears]
         ↓
Presenter: "PXY, back to slides." / "PXY, show slide N."
```

---

## Commands

### Slide Navigation
```bash
./slide 01-title     # Show slide by name
./slide 03-definition
./slide grumpy       # Station ID
```

### Content Push
```bash
./push "# Hello"     # Push arbitrary markdown
./push "$(cat file.md)"  # Push from file
```

### Themes
```bash
./push --theme light  # Dieter Rams (cream, black, red)
./push --theme dark   # Developer (dark, neon)
```

### Keyboard (in browser)
```bash
t   # Toggle theme
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Browser stuck on "connecting..." | Refresh page |
| Slide not found | Check `slides/` directory |
| Server won't start | `lsof -ti :8080 \| xargs kill -9` |
| Theme not switching | Refresh browser, then try again |
| Connection drops | Use WebSocket server (server-ws.ts) |

---

## Keyboard Shortcuts (Browser)

| Key | Action |
|-----|--------|
| t | Toggle theme |

---

## Files

- `server-ws.ts` — WebSocket server (Bun)
- `display.html` — Browser display
- `push` — Push content helper
- `slide` — Show slide helper
- `slides/` — Markdown slide files

---

## Next Steps

1. Test with real audience
2. Investigate iPhone voice control
3. Add more slides for specific demos
4. Consider slide transitions
