# Brief: Two-Tier API Implementation

**Date:** 2026-04-07
**Status:** Implemented
**Issue:** td-524961

## Summary

Implemented the two-tier HTTP API architecture from `brief-api-architecture-v2.md`.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 External API (Port 3000)                │
│                                                         │
│  /health       GET  — Liveness (no auth)               │
│  /status       GET  — Silo state                        │
│  /verbs        GET  — Allowed verbs only               │
│  /verbs/:verb  GET  — Verb help                         │
│  /exec/:verb   POST — Execute (SSE streaming)           │
│  /exec-sync/:verb POST — Execute (sync response)        │
│                                                         │
│  Security: Auth token required (X-Silo-Token)          │
└─────────────────────────────────────────────────────────┘
                          │
                          │ (can be proxied)
                          ▼
┌─────────────────────────────────────────────────────────┐
│                 Internal API (Port 3001)               │
│                                                         │
│  Full feature set:                                      │
│  /health, /capabilities, /manifest                     │
│  /verbs, /verbs/:verb                                  │
│  /stream/status, /stream/heartbeat, /stream/logs        │
│  /stream/all, /rpc/:verb, /exec/:verb                  │
│                                                         │
│  Security: localhost only, no auth                     │
└─────────────────────────────────────────────────────────┘
```

## Files Created

| File | Purpose |
|------|---------|
| `src/silo-api-internal.ts` | Internal API server |
| `src/silo-api-external.ts` | External API server |
| `src/lib/auth.ts` | Auth middleware |
| `src/lib/verb-allowlist.ts` | Verb allowlist parser |
| `src/silo-api-two-tier.test.ts` | Unit tests |

## Files Modified

| File | Change |
|------|--------|
| `justfile` | Added `api-internal`, `api-external`, `api-start`, `api-status` commands |

## Security Model

### External API
- **Auth:** `X-Silo-Token` header (set via `SILO_API_TOKEN` env var)
- **Allowlist:** Verbs marked `[remote="true"]` in justfile
- **Health:** Exempt from auth (for liveness probes)

### Internal API
- **Auth:** None
- **Bind:** `127.0.0.1` only
- **Scope:** Full feature access

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SILO_API_PORT` | 3000/3001 | Server port |
| `SILO_API_HOST` | 0.0.0.0/127.0.0.1 | Server bind |
| `SILO_API_TOKEN` | - | External API auth token |
| `SILO_AUTH_HEADER` | X-Silo-Token | Auth header name |
| `SILO_ALLOW_ALL` | false | Allow all verbs externally |

## Usage

```bash
# Start internal (dev dashboard)
just api-internal

# Start external (remote control)
SILO_API_TOKEN=secret just api-external

# Start both
just api-start

# Check status
just api-status
```

## Verb Allowlist Example

```just
# Remote-executable verb
deploy remote="true":
    ./scripts/deploy.sh

# Local only
dev-test:
    bun test
```

## Tests

72 tests pass across 4 test files.
