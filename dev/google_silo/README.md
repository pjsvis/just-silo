# google_silo

**Status:** Development  
**Purpose:** Build a self-sufficient sub-silo for Google-origin document ingestion, normalization, and handoff into `just-silo` knowledge workflows.

---

## Mission

`google_silo` is the dedicated ingestion boundary for Google content.

It exists to:

1. **Ingest selectively** from Google Drive/Docs sources.
2. **Normalize reliably** into Markdown-first local artifacts.
3. **Track provenance** (what was pulled, when, from where, with what status).
4. **Publish clean outputs** for downstream indexing/search (`qmd`) and project curation.
5. **Evolve toward self-sufficiency** so parent-level glue shrinks over time.

---

## Scope (Current)

### In Scope
- DOCX-first discovery and selection.
- DOCX → Markdown conversion paths.
- Imported markdown sanitization.
- Download manifest tracking and dedupe visibility.
- Cache + top-up for large remote listings.
- Operator-friendly CLI workflows.

### Out of Scope (for now)
- Broad Google API write/edit flows.
- Native Google Docs advanced mutation.
- Multi-account orchestration.
- Complex inter-silo message bus.
- Any cloud-hosted runtime dependency for core ingestion.

---

## Why This Silo Exists

Without a dedicated silo, Google ingestion concerns leak into the root project:

- auth quirks,
- export format differences,
- conversion/sanitization edge cases,
- repetitive re-download handling,
- cache latency concerns.

`google_silo` centralizes these into one bounded capability so root workflows remain simple.

---

## Architecture Intent

### Inputs
- Remote Google file references (via local CLI auth/runtime).
- Operator selections (extension + filename filters).
- Optional scoped folder paths for incremental top-ups.

### Processing
- Source listing cache.
- Extension-constrained selection (`.docx` first).
- Conversion pull to markdown outputs.
- Per-file sanitization pass.
- Manifest updates with success/failure outcomes.

### Outputs
- Markdown artifacts in controlled local paths.
- Download manifest (`downloaded.jsonl`) for repeat-run awareness.
- Operational logs suitable for audit and replay reasoning.

---

## Self-Sufficiency Roadmap

## Phase 0 — Boundary Stabilization (now)
- [x] Dedicated `google_silo` workspace created.
- [ ] Move/port Google ingestion scripts into this silo namespace.
- [ ] Define canonical command surface for operators.
- [ ] Document expected local runtime dependencies.

## Phase 1 — Functional Independence
- [ ] Keep all Google ingestion behavior executable from this silo alone.
- [ ] Ensure markdown sanitizer is first-class in this silo workflow.
- [ ] Keep manifest schema stable and versioned.
- [ ] Add deterministic dry-run behavior for all major commands.

## Phase 2 — Contracted Outputs
- [ ] Define `inbox/` + `outbox/` contracts for parent integration.
- [ ] Emit machine-readable status summary after each run.
- [ ] Provide “new-only” and “show-downloaded” modes as stable defaults/toggles.
- [ ] Add validation gates before publishing outputs.

## Phase 3 — Operational Hardening
- [ ] Add smoke tests for pull/convert/sanitize/manifest loop.
- [ ] Add failure taxonomy (`auth`, `not-found`, `conversion`, `sanitize`, etc.).
- [ ] Add replay-safe idempotence tests for repeated runs.
- [ ] Add performance budget checks for cached vs uncached listing behavior.

## Phase 4 — Promotion Readiness
- [ ] Remove implicit parent path assumptions.
- [ ] Minimize external dependencies to explicit, documented contracts.
- [ ] Prepare deploy profile for `silos/google_silo/`.
- [ ] Produce promotion checklist and acceptance report.

---

## Success Criteria

`google_silo` is considered self-sufficient when:

1. A new operator can run ingestion from this silo docs alone.
2. Pull/convert/sanitize/track runs without parent script coupling.
3. Outputs are contract-stable and consumable by downstream search/indexing.
4. Repeat runs avoid duplicate churn by default.
5. Failure states are explicit, actionable, and test-covered.

---

## Near-Term Tasks (Next 3)

1. Consolidate existing Google ingestion scripts into this silo’s `scripts/`.
2. Add a silo-local `justfile` command surface (`pick`, `pull`, `sanitize`, `status`).
3. Add a concise operator runbook in `docs/` with fast-path and troubleshooting paths.

---

## Notes

- Keep the root project thin; complexity belongs here.
- Prefer deterministic local artifacts over hidden runtime state.
- Treat conversion quality and provenance tracking as first-class, not optional.