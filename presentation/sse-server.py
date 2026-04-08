#!/usr/bin/env python3
"""
SSE Presentation Server
Pushes HTML content to connected browsers via Server-Sent Events.
Also serves static files including display.html.

Usage: python3 sse-server.py [PORT]
Default port: 8080
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import sys
import os
import mimetypes

# Global state
current_content = ""
clients = []
clients_lock = threading.Lock()

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


class SSEHandler(BaseHTTPRequestHandler):
    """Handle SSE subscriptions, content pushes, and static files."""

    def do_GET(self):
        if self.path == '/present':
            # SSE endpoint
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

        elif self.path == '/' or self.path == '/display.html':
            # Serve display.html
            file_path = os.path.join(SCRIPT_DIR, 'display.html')
            if os.path.exists(file_path):
                with open(file_path, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'text/html')
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "display.html not found")

        else:
            # Serve other static files
            file_path = os.path.join(SCRIPT_DIR, self.path.lstrip('/'))
            if os.path.exists(file_path) and os.path.isfile(file_path):
                mime_type, _ = mimetypes.guess_type(file_path)
                mime_type = mime_type or 'application/octet-stream'
                with open(file_path, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', mime_type)
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "Not Found")

    def do_POST(self):
        if self.path == '/push':
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
        else:
            self.send_error(404, "Not Found")

    def log_message(self, format, *args):
        """Silence request logs."""
        pass


def run_server(port=8080):
    server = HTTPServer(('', port), SSEHandler)
    print(f"SSE server running on http://localhost:{port}")
    print(f"  Display:    http://localhost:{port}/display.html")
    print(f"  SSE:        http://localhost:{port}/present")
    print(f"  Push:       POST http://localhost:{port}/push")
    print(f"\nCtrl+C to stop.\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    run_server(port)
