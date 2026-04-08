#!/usr/bin/env bun
/** WebSocket presentation server with Markdown rendering. */

import { marked } from 'marked';
import { readFileSync, existsSync, readdirSync } from 'fs';
import { join } from 'path';

const clients = new Set<any>();
const SLIDES_DIR = './slides';
let content = marked.parse(readFileSync(join(SLIDES_DIR, '00-grumpy.md'), 'utf-8'));

// Configure marked
marked.setOptions({ gfm: true, breaks: true });

const log = (msg: string) => {
  console.log(`[${new Date().toISOString()}] ${msg}`);
};

const broadcast = (data: string) => {
  const dead: typeof clients extends Set<infer T> ? T[] : never = [];
  
  for (const client of clients) {
    try {
      client.send(data);
    } catch {
      dead.push(client);
    }
  }
  
  dead.forEach(d => clients.delete(d));
};

Bun.serve({
  port: 8080,
  
  async fetch(req, server) {
    const url = new URL(req.url);

    // Upgrade to WebSocket
    if (url.pathname === '/ws' && server.upgrade(req)) {
      return;
    }

    // GET / → serve display.html
    if (url.pathname === '/') {
      return new Response(Bun.file('display.html'), {
        headers: { 'Content-Type': 'text/html' },
      });
    }

    // GET /slides → list available slides
    if (url.pathname === '/slides') {
      if (!existsSync(SLIDES_DIR)) {
        return Response.json({ slides: [] });
      }
      const files = readdirSync(SLIDES_DIR)
        .filter(f => f.endsWith('.md'))
        .sort();
      return Response.json({ slides: files });
    }

    // POST /push → push markdown, render, broadcast
    if (url.pathname === '/push' && req.method === 'POST') {
      const markdown = await req.text();
      content = await marked.parse(markdown);
      broadcast(content);
      return new Response(`${clients.size}\n`, { status: 200 });
    }

    // POST /slide/:name → lookup and push slide
    if (url.pathname.startsWith('/slide/') && req.method === 'POST') {
      const name = url.pathname.slice(7).replace('.md', '');
      const slidePath = join(SLIDES_DIR, `${name}.md`);

      if (!existsSync(slidePath)) {
        return new Response(`Slide not found: ${name}.md\n`, { status: 404 });
      }

      const markdown = readFileSync(slidePath, 'utf-8');
      content = await marked.parse(markdown);
      log(`Slide: ${name}`);
      broadcast(content);
      return new Response(`${clients.size}\n`, { status: 200 });
    }

    // POST /theme → switch theme
    if (url.pathname === '/theme' && req.method === 'POST') {
      const theme = await req.text();
      log(`Theme: ${theme}`);
      broadcast(JSON.stringify({ type: 'theme', theme }));
      return new Response(`${clients.size}\n`, { status: 200 });
    }

    return new Response('Not found', { status: 404 });
  },

  websocket: {
    open(ws) {
      clients.add(ws);
      log(`Client connected. Total: ${clients.size}`);
      ws.send(content);
    },
    close(ws) {
      clients.delete(ws);
      log(`Client disconnected. Total: ${clients.size}`);
    },
    message(ws, msg) {
      log(`Message: ${msg}`);
    },
  },
});

log(`Server started on port 8080`);
