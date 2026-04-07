# Brief: Two-Tier HTTP API Architecture

**Date:** 2026-04-07
**Status:** Draft
**Author:** Session `ses_8b3c8c`

---

## Problem Statement

Just-silo needs HTTP APIs for two distinct use cases:

1. **Local development** — Rich browser-based dashboards for monitoring and debugging
2. **Remote control** — Minimal API surface for executing silo operations from external agents or systems

These have different requirements for functionality, security, and exposure. Combining them creates risk and complexity.

---

## Proposed Architecture

### Two-Tier Design

```
┌─────────────────────────────────────────────────────────┐
│                    External (Port 3000)                 │
│                                                         │
│  /health          GET  — Liveness check                │
│  /verbs           GET  — List allowed verbs             │
│  /verbs/:verb     GET  — Help for specific verb        │
│  /exec/:verb      POST — Execute verb (SSE)            │
│  /status          GET  — Current silo state            │
│                                                         │
│  Surface: Curated, minimal, allow-listed                │
│  Security: Auth token required, all calls logged       │
│  Scope: Only what the external world needs              │
└─────────────────────────────────────────────────────────┘
                          │
                          │ Optional proxy/relay
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Internal (Port 3001)                  │
│                                                         │
│  /                    — Dashboard (HTML)                │
│  /ui/*               — Internal UI resources            │
│  /api/internal/*     — Internal API extensions         │
│  /stream/*           — SSE streams for dev             │
│  /logs               — Tailable logs (text)            │
│  /metrics            — JSON metrics for dashboards     │
│  /reports/*.md       — Markdown reports (optional)      │
│                                                         │
│  Surface: Rich, full-featured                           │
│  Security: localhost only, no auth                     │
│  Scope: Everything useful for development               │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Options

### Option A: Single Server with Namespace Routing

One `silo-api-server.ts` that routes based on path:

```typescript
// External routes
app.group('/api/v1', (api) => {
  api.use('/exec/:verb', authMiddleware)
  api.get('/health', ...)
  // ...
})

// Internal routes  
app.group('/ui', (ui) => {
  ui.get('/', dashboard)
  // ...
})
```

**Pros:** Single process, simpler deployment
**Cons:** Risk of internal routes leaking externally

---

### Option B: Two Separate Servers

Two processes, internal starts first, optional relay:

```bash
bun run src/silo-api-internal.ts  # Port 3001, localhost only
bun run src/silo-api-external.ts  # Port 3000, proxied
```

**Pros:** Clean blast radius, impossible to expose internal by mistake
**Cons:** Two processes to manage

---

### Option C: Single Binary, Config-Driven

One server binary, config determines mode:

```bash
silo-api --mode=external  # Port 3000, limited verbs
silo-api --mode=internal  # Port 3001, full access
```

**Pros:** Single binary, mode switching
**Cons:** Config complexity

---

## Recommended: Option B (Two Servers)

Rationale:
- **Blast radius isolation** — External server compromise doesn't expose internal
- **Fail-safe** — External can only do what's explicitly forwarded
- **Simplicity** — Each server has one job
- **Audit trail** — External calls logged separately

---

## Security Model

### External API

| Requirement | Detail |
|-------------|--------|
| Authentication | `X-Silo-Token` header with shared secret |
| Verb allowlist | Only verbs explicitly marked `remote: true` in justfile |
| Rate limiting | TBD (consider token bucket) |
| Logging | All calls logged to `logs/api-external.jsonl` |
| CORS | Disabled (not a browser API) |

### Example justfile annotation:

```just
# Remote-executable verb
deploy remote="true":
    ./scripts/deploy.sh
    echo "Deployed at $(date)"

# Local only
dev-test:
    bun test
```

---

## Future Considerations

### Authentication Options (if needed)

1. **Shared secret** (current proposal) — Simple, sufficient for personal use
2. **JWT tokens** — If multi-user needed
3. **mTLS** — If security-critical

### Relay Architecture

For remote access without exposing ports:

```
User → Tailscale/Cloudflare Tunnel → External API (3000) → Internal API (3001)
```

---

## Decisions Needed

1. [ ] Single or dual server process?
2. [ ] Verb allowlist mechanism (justfile annotations vs. config file)?
3. [ ] Authentication token format (simple header vs. JWT)?
4. [ ] Rate limiting implementation (yes/no, what kind)?
5. [ ] Internal API port fixed or randomized?

---

## For Next Session

- Review this brief
- Decide on Option A/B/C for server architecture
- Finalize security model
- Implement external API first (smallest surface area)
