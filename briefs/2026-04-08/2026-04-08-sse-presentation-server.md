# Brief: SSE Presentation Server — Technical Implementation

## STATUS
Draft. Ready to code.

## PURPOSE
Defines the technical implementation for pushing rendered HTML from PXY (Gemma 4) to a browser display via Server-Sent Events (SSE).

## ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────────┐
│                         LOCAL MACBOOK                               │
│                                                                     │
│   ┌──────────────┐         ┌──────────────┐         ┌────────────┐ │
│   │ PXY (Gemma 4)│────────▶│ SSE Server   │────────▶│ Browser    │ │
│   │              │  HTTP   │ localhost:   │  SSE    │ (display)  │ │
│   │ curl POST    │  POST   │ 8080         │  push   │            │ │
│   └──────────────┘         └──────────────┘         └────────────┘ │
│                                    │                    ▲         │
│                                    │                    │         │
│                              ┌─────┴─────┐              │         │
│                              │ push HTTP │◀─────────────┘         │
│                              │ POST /push│   reconnect on close   │
│                              └───────────┘                        │
└─────────────────────────────────────────────────────────────────────┘
```

**Data flow:**
1. PXY generates HTML content
2. PXY POSTs HTML to `localhost:8080/push`
3. Server stores content, fans out to all SSE clients
4. Browser receives SSE event, updates DOM
5. Projector shows rendered content

**Key property:** SSE clients auto-reconnect. If browser crashes, it resumes.

---

## FILES

### `sse-server.py`
Python HTTP server. No dependencies (stdlib only).

### `display.html`
Browser display page. Minimal HTML + SSE client.

### `push-content`
Bash helper script. PXY calls this to push HTML.

### `present`
Alias/launcher for `push-content`.

---

## SERVER: `sse-server.py`

```python
#!/usr/bin/env python3
"""
SSE Presentation Server
Pushes HTML content to connected browsers via Server-Sent Events.

Usage: python3 sse-server.py [PORT]
Default port: 8080
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import sys

# Global state
current_content = ""
clients = []
clients_lock = threading.Lock()


class SSEHandler(BaseHTTPRequestHandler):
    """Handle SSE subscriptions and content pushes."""

    def do_GET(self):
        """SSE endpoint: /present"""
        if self.path != '/present':
            self.send_error(404, "Not Found")
            return

        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Connection', 'keep-alive')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

        # Register client
        with clients_lock:
            clients.append(self.wfile)

        # Send current content immediately
        try:
            self.wfile.write(f"data: {current_content}\n\n".encode())
        except:
            pass

        # Keep connection alive (heartbeat handled by browser)

    def do_POST(self):
        """Push endpoint: /push"""
        if self.path != '/push':
            self.send_error(404, "Not Found")
            return

        global current_content
        content_length = int(self.headers.get('Content-Length', 0))

        if content_length == 0:
            self.send_error(400, "Empty content")
            return

        # Read and store content
        current_content = self.rfile.read(content_length).decode('utf-8')

        # Fan out to all SSE clients
        message = f"data: {current_content}\n\n".encode()
        dead_clients = []

        with clients_lock:
            for client in clients:
                try:
                    client.write(message)
                except:
                    dead_clients.append(client)

            # Clean up dead connections
            for dead in dead_clients:
                try:
                    clients.remove(dead)
                except:
                    pass

        # Respond
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(f"Pushed to {len(clients)} clients\n".encode())

    def log_message(self, format, *args):
        """Silence request logs."""
        pass


def run_server(port=8080):
    server = HTTPServer(('', port), SSEHandler)
    print(f"SSE server running on http://localhost:{port}")
    print(f"  SSE endpoint: http://localhost:{port}/present")
    print(f"  Push endpoint: POST http://localhost:{port}/push")
    print(f"\nCtrl+C to stop.\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    run_server(port)
```

**To run:**
```bash
python3 sse-server.py 8080
```

---

## BROWSER: `display.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Presentation Display</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
      background: #0a0a0f;
      color: #f0f0f0;
    }
    #content {
      width: 100%;
      height: 100%;
      padding: 5%;
      overflow: hidden;
    }
    #content h1 { font-size: 4em; margin-bottom: 0.5em; }
    #content h2 { font-size: 2.5em; margin-bottom: 0.4em; color: #a0a0b0; }
    #content p { font-size: 1.8em; line-height: 1.6; margin-bottom: 1em; }
    #content ul, #content ol { font-size: 1.6em; line-height: 1.8; margin-left: 1em; }
    #content li { margin-bottom: 0.5em; }
    #content table { border-collapse: collapse; width: 100%; font-size: 1.4em; }
    #content th, #content td { border: 1px solid #333; padding: 0.5em 1em; text-align: left; }
    #content th { background: #1a1a2e; }
    #content tr:nth-child(even) { background: #12121a; }
    #content code { background: #1a1a2e; padding: 0.2em 0.5em; border-radius: 4px; font-family: 'SF Mono', Monaco, monospace; }
    #content pre { background: #1a1a2e; padding: 1em; border-radius: 8px; overflow-x: auto; font-size: 1.2em; }
    #content pre code { background: none; padding: 0; }
    .footer {
      position: fixed;
      bottom: 20px;
      right: 30px;
      font-size: 1em;
      color: #555;
    }
  </style>
</head>
<body>
  <div id="content">
    <p style="color: #555;">Connecting to presentation server...</p>
  </div>
  <div class="footer" id="status"></div>

  <script>
    const content = document.getElementById('content');
    const status = document.getElementById('status');
    let retryDelay = 1000;
    let connected = false;

    function connect() {
      const es = new EventSource('/present');

      es.onopen = () => {
        connected = true;
        retryDelay = 1000;
        status.textContent = '● Live';
        status.style.color = '#4a4';
      };

      es.onmessage = (e) => {
        content.innerHTML = e.data;
      };

      es.onerror = () => {
        connected = false;
        status.textContent = '○ Reconnecting...';
        status.style.color = '#a44';
        es.close();
        setTimeout(connect, retryDelay);
        retryDelay = Math.min(retryDelay * 2, 30000);
      };
    }

    connect();
  </script>
</body>
</html>
```

**To use:** Open in browser, go to `http://localhost:8080/present` (or serve with Python: `python3 -m http.server 8081 --directory .`)

---

## HELPER: `push-content`

```bash
#!/bin/bash
# push-content — Push HTML content to SSE server
# Usage: push-content "<h1>Hello</h1>"
#   or:  push-content /path/to/file.html

SERVER="${SSE_SERVER:-localhost:8080}"

if [ -z "$1" ]; then
  echo "Usage: push-content '<html content>'" >&2
  echo "   or: push-content /path/to/file.html" >&2
  exit 1
fi

# If argument is a file, read it; otherwise use as-is
if [ -f "$1" ]; then
  CONTENT=$(cat "$1")
else
  CONTENT="$1"
fi

curl -s -X POST "http://${SERVER}/push" \
  -H "Content-Type: text/html" \
  --data-raw "$CONTENT"

echo ""  # newline after curl output
```

Make executable:
```bash
chmod +x push-content
```

**Usage examples:**
```bash
# Push raw HTML
./push-content '<h1>Grumpy</h1><p>A disposition to ill humor.</p>'

# Push from file
./push-content slide.html

# Different server
SSE_SERVER=192.168.1.100:8080 ./push-content '<p>Hello</p>'
```

---

## PXY INTEGRATION

PXY (Gemma 4) calls the helper via bash:

```
bash push-content '<h1>Definition: Grumpy</h1><p>A person disposed to ill humor or irritability.</p>'
```

Or, define `push-content` as a **pi skill** so PXY can invoke it directly without the bash wrapper:

```yaml
# In pi skills directory
skills:
  - name: present
    command: push-content
    description: Push HTML content to display
    args: html_string
```

---

## TESTING

```bash
# 1. Start server
python3 sse-server.py 8080

# 2. Open browser (separate terminal)
open http://localhost:8080/present

# 3. Push content (third terminal)
./push-content '<h1>Hello, World</h1><p>This is a test.</p>'

# 4. Push a table
./push-content '<table><tr><th>Name</th><th>Value</th></tr><tr><td>X</td><td>42</td></tr></table>'

# 5. Push definition slide
./push-content '
<h1>Grumpy</h1>
<p><em>adjective</em></p>
<p>Disposed to or marked by ill humor and irritability.</p>
<blockquote>"Don'\''t get grumpy with me."</blockquote>
'
```

---

## CHECKLIST

- [ ] `sse-server.py` created and tested
- [ ] `display.html` created and tested
- [ ] `push-content` created and made executable
- [ ] Server starts without errors
- [ ] Browser connects and receives content
- [ ] PXY can call `push-content` via bash
- [ ] Auto-reconnect works (refresh browser, content reappears)
- [ ] Multiple browsers receive content simultaneously

---

## TODO

- [ ] Add `clear` command to reset display
- [ ] Add `slide-NAME` naming convention for easy navigation
- [ ] Add CSS transitions for slide changes
- [ ] Consider adding `/status` endpoint for PXY to check client count
- [ ] Document in presentation workflow brief that PXY uses `push-content`

---

## SEE ALSO

- `briefs/2026-04-08/2026-04-08-pxy-presentation-workflow.md` — The presentation workflow this server enables
