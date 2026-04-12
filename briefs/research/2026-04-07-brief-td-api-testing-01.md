# Brief: td-v0.2 Testing & Coverage

**Date:** 2026-04-07  
**Author:** ses_cd8f9e (reviewer)  
**Status:** For implementation  
**Priority:** P3  

---

## Context

Reviewed td-4b577e (v0.2: SSE Streaming + Lexicon Mount). Implementation is solid, but lacks test coverage.

**Approved:** ✅  
**Commit:** `d3c2405`  

---

## Recommendations

### 1. Add API Smoke Tests (P3)

**What:** HTTP tests for the SSE endpoints.

**Why:** Streaming endpoints are hard to test manually. Automated tests catch regressions.

**Approach:**
```bash
# Add to justfile
api-test:
    @bun test src/silo-api-server.test.ts

# Or curl-based smoke test
api-smoke:
    @./scripts/api-smoke-test.sh
```

**Effort:** Low (~1-2 hours)

---

### 2. Lexicon CLI Tests (P3)

**What:** Unit tests for the lexicon script.

**Why:** Token lookup, auto-discovery, and formatting need coverage.

**Approach:**
```bash
# Add to dev-tests
lex-test:
    @bun test scripts/silo-lexicon.test.ts
```

**Effort:** Low (~1 hour)

---

### 3. Integration Test for SSE + Lexicon (P3)

**What:** End-to-end test of streaming → lexicon flow.

**Why:** Verify the whole pipeline works together.

**Effort:** Medium (~2-3 hours)

---

## Why Not P1/P2?

These are nice-to-haves, not blockers:
- Code quality is good
- Error handling is present
- Manual testing passed
- Production use cases are covered

**Rule:** Test coverage is important but doesn't block feature delivery.

---

## Implementation Notes

1. **Use existing test infra** — `bun test` already set up
2. **Start with happy path** — Test the common cases first
3. **Add edge cases later** — When bugs surface

---

## Related

- [PR #1: v0.2 streaming + lexicon](https://github.com/pjsvis/just-silo/commit/d3c2405)
- `src/silo-api-server.ts` — SSE endpoints
- `scripts/silo-lexicon` — Lexicon CLI
- `justfile` — test commands

---

## Handoff

| Item | Status |
|------|--------|
| Brief created | ✅ |
| Brief submitted for review | ⏳ |
| Implementation | TODO |
| Review | TODO |
| Approve | TODO |
