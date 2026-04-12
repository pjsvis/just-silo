#!/usr/bin/env bun
/** SSE presentation server with Markdown rendering. */

import { marked } from 'marked';
import { readFileSync, existsSync, readdirSync } from 'fs';
import { join } from 'path';

const clients = new Set<Bun.Writer>();
const SLIDES_DIR = './slides';
let clientCount = 0;

// Default to grumpy (station identifier)
let content = marked.parse(readFileSync(join(SLIDES_DIR, '00-grumpy.md'), 'utf-8'));

// Configure marked
marked.setOptions({ gfm: true, breaks: true });

const log = (msg: string) => {
  console.log(`[${new Date().toISOString()}] ${msg}`);
};

const broadcast = () => {
  const msg = new TextEncoder().encode(`data: ${content}\n\n`);
  const dead: typeof clients extends Set<infer T> ? T[] : never = [];
  
  for (const client of clients) {
    try {
      client.enqueue(msg);
    } catch (e) {
      dead.push(client);
    }
  }
  
  dead.forEach(d => clients.delete(d));
};

const server = Bun.serve({
  port: 8080,

  async fetch(req) {
    const url = new URL(req.url);

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

    // GET /present → SSE subscription
    if (url.pathname === '/present' && req.method === 'GET') {
      const encoder = new TextEncoder();
      
      const stream = new ReadableStream({
        start(controller) {
          clients.add(controller);
          clientCount++;
          log(`Client connected. Total: ${clients.size}`);
          
          // Send current content on connect
          if (content) {
            controller.enqueue(encoder.encode(`data: ${content}\n\n`));
          }
        },
        cancel(controller) {
          clients.delete(controller);
          clientCount--;
          log(`Client disconnected. Total: ${clients.size}`);
        },
      });

      return new Response(stream, {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
        },
      });
    }

    // POST /push → push markdown, render, broadcast
    if (url.pathname === '/push' && req.method === 'POST') {
      const markdown = await req.text();
      content = await marked.parse(markdown);
      broadcast();
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
      broadcast();
      return new Response(`${clients.size}\n`, { status: 200 });
    }

    return new Response('Not found', { status: 404 });
  },
});

// Heartbeat: send comment lines every 25 seconds to keep connections alive
setInterval(() => {
  if (clients.size > 0) {
    const encoder = new TextEncoder();
    const ping = encoder.encode(`: ping\n\n`);  // SSE comment line
    const dead: typeof clients extends Set<infer T> ? T[] : never = [];
    
    for (const client of clients) {
      try {
        client.enqueue(ping);
      } catch {
        dead.push(client);
      }
    }
    
    dead.forEach(d => clients.delete(d));
    log(`Heartbeat to ${clients.size} clients`);
  }
}, 25000);

log(`Server started on port ${server.port}`);
log(`Heartbeat every 25s`);
