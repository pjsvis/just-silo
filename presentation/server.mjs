#!/usr/bin/env node
/** Minimal SSE presentation server. */

import { createServer } from 'http';
import { readFileSync } from 'fs';

let content = '';
const clients = [];

const server = createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(readFileSync('display.html'));
  }
  else if (req.method === 'GET' && req.url === '/present') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
    });
    clients.push(res);
    if (content) res.write(`data: ${content}\n\n`);
  }
  else if (req.method === 'POST' && req.url === '/push') {
    let body = '';
    req.on('data', d => body += d);
    req.on('end', () => {
      content = body;
      const msg = `data: ${content}\n\n`;
      const dead = [];
      for (const c of clients) {
        try { c.write(msg); } catch { dead.push(c); }
      }
      dead.forEach(d => clients.splice(clients.indexOf(d), 1));
      res.writeHead(200);
      res.end('ok\n');
    });
  }
  else {
    res.writeHead(404);
    res.end();
  }
});

const port = 8080;
server.listen(port, () => console.log(`http://localhost:${port}/`));
