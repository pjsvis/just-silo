# Presentation Server

Push HTML/Markdown content to a browser display for live presentations.

## Architecture

Two Bun servers available:

| Server | Protocol | Port | Use Case |
|--------|----------|------|----------|
| `server-ws.ts` | WebSocket | 8080 | **Default** — display.html connects via WS |
| `server.ts` | SSE | 8080 | Alternative — `/present` for SSE clients |

Both support Markdown rendering, slide loading, and live broadcast.

## Quick Start

```bash
# Start server
just presentation-start

# Open browser display
just presentation-display

# Push a slide
just push 01-title

# List slides
just slides
```

## Files

```
presentation/
├── server-ws.ts      # WebSocket server (primary)
├── server.ts         # SSE server (alternative)
├── display.html      # Browser display page
├── slides/           # Slide source files (.md)
├── slide             # Push slide by name/number
├── push              # Push raw markdown
├── push-content      # Push raw markdown (alias)
├── demo-run          # Auto-run demo slides
└── justfile          # Presentation recipes
```

## Server Features

- **Markdown rendering** via `marked` (GFM, line breaks)
- **Slide loading** from `slides/` directory
- **Live broadcast** to all connected clients
- **Dead client cleanup**
- **Heartbeat** (SSE server, 25s ping)

## Browser Display

Open `http://localhost:8080/` in a browser. The display:
- Connects via WebSocket to `/ws`
- Renders pushed content as HTML
- Supports dark/light themes
- Full screen: ⌘⇧F

## Pushing Content

```bash
# By slide name
just push 01-title

# Raw markdown
just push-content "# Hello\n\nSlide body text"

# From file
just push-content "$(cat slides/03-definition.md)"

# Switch theme
just theme dark
just theme light
```

## Commands

| Recipe | Action |
|--------|--------|
| `just presentation-start` | Start WebSocket server |
| `just presentation-display` | Open browser to display |
| `just push <name>` | Push a slide |
| `just push-content <md>` | Push raw markdown |
| `just theme <dark\|light>` | Switch theme |
| `just slides` | List available slides |
| `just selftest` | Push self-test slide |
| `just grumpy` | Push station ID |
| `just presentation-stop` | Stop server |
| `just presentation-status` | Check server status |
