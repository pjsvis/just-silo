# SSE Presentation Server

Push HTML content to a browser display via Server-Sent Events.

## Quick Start

### Terminal 1: Start the server
```bash
cd presentation
python3 sse-server.py 8080
```

### Terminal 2: Open the browser
```bash
# Option A: Use the built-in server
open http://localhost:8080/present

# Option B: Serve display.html separately (recommended for full screen)
cd presentation
python3 -m http.server 8081
# Then open: http://localhost:8081/display.html
```

### Terminal 3: Push content
```bash
./push-content '<h1>Hello, World</h1>'
```

Watch it appear on the browser instantly.

---

## Files

```
presentation/
├── sse-server.py     # SSE server (Python, stdlib only)
├── display.html      # Browser display page (open in browser)
├── push-content      # Push HTML to server
├── present           # Alias for push-content
├── demo-run          # Run demo presentation automatically
├── slides/           # Demo slide files
│   ├── 01-title.html
│   ├── 02-selftest.html
│   ├── 03-definition.html
│   └── ...
└── demo.slides       # All slides as text
```

---

## Usage

### Push from command line
```bash
# Push raw HTML
./push-content '<h1>Hello</h1>'

# Push from file
./push-content "$(cat slides/03-definition.html)"

# Or pipe it
cat slides/03-definition.html | ./push-content -
```

### Use the demo presentation
```bash
# Run all slides automatically (3s delay between each)
./demo-run

# Faster (1s delay)
SLEEP=1 ./demo-run
```

### Manual slide navigation
```bash
# Pick any slide
./push-content "$(cat slides/03-definition.html)"
```

### Different server
```bash
SSE_SERVER=192.168.1.100:8080 ./push-content '<h1>Hello</h1>'
```

---

## Testing Checklist

### 1. Server starts
```bash
python3 sse-server.py 8080
# Expected output:
# SSE server running on http://localhost:8080
#   SSE endpoint: http://localhost:8080/present
#   Push endpoint: POST http://localhost:8080/push
```

### 2. Browser connects
Open `http://localhost:8080/present` or `http://localhost:8081/display.html`

Expected: "Connecting to presentation server..." → content appears

The green "● Live" indicator means connected.

### 3. Content pushes work
```bash
./push-content '<h1>Test Slide</h1><p>This is a test.</p>'
```
Expected: "Pushed to N clients" and content appears in browser.

### 4. Multi-client works
Open a second browser window to the same URL. Push content.

Expected: Both browsers update simultaneously.

### 5. Reconnect works
While server is running, close the browser tab, then reopen it.

Expected: Current content appears immediately.

### 6. Definition demo works
```bash
./push-content "$(cat slides/03-definition.html)"
```
Expected: "Grumpy" definition renders with italic adjective and blockquote.

---

## Browser Full Screen

For the actual presentation:

1. Open `display.html` in browser
2. Press **⌘⇧F** (or Ctrl+Shift+F) for full screen
3. Mirror to projector via **⌘F1** or System Settings

The browser becomes display-only. Push content from PXY.

---

## Server Options

### Custom port
```bash
python3 sse-server.py 9000
# Then: SSE_SERVER=localhost:9000 ./push-content '<h1>Hi</h1>'
```

### Run in background
```bash
python3 sse-server.py 8080 &
SERVER_PID=$!
echo "Server PID: $SERVER_PID"
# When done:
kill $SERVER_PID
```

### Check if server is running
```bash
curl -s http://localhost:8080/present | head -1
# If empty/timeout: server not running
```

---

## For PXY Integration

PXY (Gemma 4) pushes content via bash:

```
bash push-content '<h1>Definition: Grumpy</h1><p>A disposition to ill humor.</p>'
```

The `push-content` script must be in PXY's PATH or called with full path:

```
bash /path/to/presentation/push-content '<h1>Hello</h1>'
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Start server: `python3 sse-server.py 8080` |
| Content not appearing | Check browser console for SSE errors |
| Curl works but browser doesn't | Server may be on wrong port; check URL |
| Browser stuck on "Connecting..." | Server not running; start it |
| Multi-line HTML broken | Quote the content: `push-content 'line1\nline2'` |

---

## Architecture

```
PXY ──HTTP POST──▶ sse-server.py ──SSE──▶ Browser
  │                        │
  │                        └── Fan-out to all clients
  │
  └── curl -X POST localhost:8080/push
```

- **SSE**: Server-Sent Events (one-way push)
- **Protocol**: HTTP POST to `/push`, HTTP GET from `/present`
- **No WebSocket**: SSE is simpler for server→browser only
- **Auto-reconnect**: Browser reconnects automatically on disconnect
