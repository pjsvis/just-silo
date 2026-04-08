#!/usr/bin/env python3
"""Minimal SSE presentation server."""

from http.server import HTTPServer, BaseHTTPRequestHandler

content = ""
clients = []

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            with open("display.html") as f:
                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                self.wfile.write(f.read().encode())
        elif self.path == "/present":
            global clients
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()
            clients.append(self.wfile)
            if content:
                self.wfile.write(f"data: {content}\n\n".encode())
        else:
            self.send_error(404)

    def do_POST(self):
        global content, clients
        if self.path == "/push":
            n = int(self.headers.get("Content-Length", 0))
            content = self.rfile.read(n).decode()
            msg = f"data: {content}\n\n".encode()
            dead = []
            for c in clients:
                try:
                    c.write(msg)
                except:
                    dead.append(c)
            for d in dead:
                clients.remove(d)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(f"ok\n".encode())
        else:
            self.send_error(404)

    def log_message(self, *args): pass

HTTPServer(('', 8080), Handler).serve_forever()
