---
date: 2026-05-01
tags: [refactoring, infrastructure, sse, presentation, bun, hono]
agent: claude
environment: local
---

## Task: Replace Python SSE Servers with Bun/Hono

**Objective:** Convert `presentation/server.py` and `presentation/sse-server.py` to a single TypeScript server using bun + hono, eliminating Python as a runtime dependency.

**Context:** The 4-layer anatomy model (Layer 2: bun/TypeScript/hono) is violated by two Python servers in `presentation/`. Total: 187 lines of Python, stdlib-only. The project already has `src/silo-api-server.ts` using hono — the pattern exists.

**Finding:** Upon investigation, `presentation/server.ts` (Bun SSE) and `presentation/server-ws.ts` (Bun WebSocket) already exist and are superior to the Python servers. The Python files are redundant.

- [x] Archive `presentation/server.py` and `presentation/sse-server.py` to `briefs/archive/`
- [x] Update `presentation/README.md` to reflect Bun-based architecture
- [x] Add presentation recipes to root justfile

## Completed

**Archived:**
- `briefs/archive/server.py` (was presentation/server.py)
- `briefs/archive/sse-server.py` (was presentation/sse-server.py)

**Updated:**
- `presentation/README.md` — Rewritten for Bun architecture
- `justfile` — Added 8 presentation recipes

**No new code needed** — `server.ts` (SSE) and `server-ws.ts` (WebSocket) already handle all presentation needs.

## Key Actions Checklist

- [ ] Read `presentation/sse-server.py` fully — map all routes, headers, and state management
- [ ] Implement hono SSE endpoint with `EventTargetMessageStream` or manual stream
- [ ] Implement POST `/push` endpoint for content updates
- [ ] Implement static file serving for `display.html` and slides
- [ ] Add `presentation-start` and `presentation-push` just recipes
- [ ] Test: start server, open display.html in browser, push content, verify SSE delivery
- [ ] Archive `presentation/server.py` and `presentation/sse-server.py`

## Detailed Requirements

### Current Python Server (sse-server.py) — Routes to Replicate

```
GET  /present       → SSE stream (text/event-stream), registers client
POST /push          → Update content, broadcast to all SSE clients
GET  /slides/*      → Static file serving (mimetypes-based Content-Type)
GET  /              → Serves display.html
```

### Global State
- `current_content` — latest pushed content (string)
- `clients` — list of active SSE connections (Response objects)
- Thread-safe via `threading.Lock`

### Target: Bun + Hono Implementation

```
src/silo-presentation-server.ts
├── Hono app with hono/static for file serving
├── SSE endpoint using stream responses
├── POST /push to update + broadcast
└── Port configurable via env or CLI arg (default 8080)
```

### Just Recipes (replace python3 invocations)

```just
[group("presentation")]
presentation-start port=8080:
    @bun run src/silo-presentation-server.ts --port {{port}}

[group("presentation")]
presentation-push content:
    @curl -X POST http://localhost:8080/push -d '{{content}}'
```

### Acceptance Criteria
- `just presentation-start` starts server on port 8080
- Browser at `http://localhost:8080/` receives display.html
- Browser at `http://localhost:8080/present` receives SSE stream
- `curl -X POST http://localhost:8080/push -d "test"` updates all connected browsers
- Static files (slides/*.md, slides/*.html) served correctly
- Python files archived, documentation updated

## Architecture

```
PXY ──HTTP POST──▶ silo-presentation-server.ts (bun/hono, :8080) ──SSE──▶ Browser
                                              │
                                              └── Serves display.html + slides/*
```
