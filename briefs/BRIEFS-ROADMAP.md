# Just-Silo Development Roadmap

## Implementation Status (Updated: 2026-04-06)

### EPIC 1: Core Infrastructure ✅ COMPLETED

| Task | Status | Deliverable |
|------|--------|-------------|
| td-cde51f: Design Template System | ✅ DONE | `templates/basic/` with .silo, justfile, schema.json, etc. |
| td-36c686: Define .silo Manifest Schema | ✅ DONE | `schemas/silo-manifest.schema.json` |
| td-31fa78: Implement silo-create | ✅ DONE | `scripts/silo-create` |
| td-069af2: Implement silo-ignite | ✅ DONE | `scripts/silo-ignite` |
| td-947eac: Integration Test | ✅ DONE | `scripts/silo-integration-test` passes |

### Ready for Next Phase

EPIC 2 (API) and EPIC 3 (Observability) can now be started as they depend on EPIC-1.

---

## Brief Inventory (82 total)

### EPIC 1: Core Silo Infrastructure
**Theme:** Foundation of the Silo framework

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-03-31-just-silo-project-inception.md` | Project kickoff and core concept definition | FOUNDATIONAL |
| `2026-03-31-silo-first-paradigm.md` | Inversion principle: Silo-first architecture | FOUNDATIONAL |
| `2026-04-02-brief-register-silo-00.md` | The Paris Spontaneity Dashboard concept | PLANNING |
| `2026-04-02-brief-register-silo-01.md` | Hybrid constellation model (one vs many repos) | PLANNING |
| `2026-04-02-brief-register-silo-02.md` | The Register as Meta-Silo | PLANNING |
| `2026-04-02-brief-register-silo-04.md` | Canonical template structure (`templates/basic/`) | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-05.md` | Registry manifest (`.silo`) and vocabulary (`justfile`) | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-06.md` | Data stratification: scaffolding vs throughput | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-07.md` | Silo topography (Clean Room model) | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-08.md` | Silo integration test (Hotel in Paris) | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-09.md` | Viral growth loop for ecosystem | CONCEPT |
| `2026-04-02-brief-register-silo-10.md` | `silo-create` command strategy | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-11.md` | Bootstrap strategy: `silo-ignite` | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-12.md` | User journey: "Clone, Ignite, Spawn" | IMPLEMENTATION |
| `2026-04-02-brief-register-silo-13.md` | Markdown-as-UI adapter | CONCEPT |
| `2026-04-02-brief-register-silo-14.md` | Markdown-first template | CONCEPT |
| `2026-04-02-brief-register-silo-15.md` | Edinburgh Protocol (System Prompt for Pi) | CONCEPT |
| `2026-04-02-brief-register-silo-16.md` | `_silo` suffix for unambiguous targeting | CONCEPT |
| `2026-04-02-brief-register-silo-17.md` | Soft/Hard guardrails (Persona vs Runtime) | CONCEPT |
| `2026-04-02-brief-register-silo-18.md` | Workspace-locked silo with Pi factory functions | CONCEPT |
| `2026-04-02-brief-register-silo-19.md` | Temporal entropy record (JSONL audit trail) | CONCEPT |
| `2026-04-03-brief-silo-tech-spec.md` | Master technical specification (Sovereign Forge) | FOUNDATIONAL |

### EPIC 2: API & Automation
**Theme:** Making silos programmable and observable

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-04-brief-api-gen.md` | `silo-api-gen` - justfile to live API | IMPLEMENTATION |
| `2026-04-04-brief-semantic-api.md` | Semantic API principles (Dictionary of Action) | CONCEPT |
| `2026-04-04-brief-silo-auto-api.md` | Auto-reflective Hono API from justfile | CONCEPT |
| `2026-04-04-brief-silo-transport-protocols.md` | Hono facade mirroring CLI facade | CONCEPT |
| `2026-04-04-brief-zero-training-api.md` | Token-aware chat with verb discovery | CONCEPT |
| `2026-04-04-nrief-silo-local-remote.md` | Dual-speed discovery (local vs remote) | CONCEPT |

### EPIC 3: Observability & Monitoring
**Theme:** Pipeline status, dashboards, real-time feedback

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-03-31-pipeline-observability-via-filesystem.md` | Filesystem-based observability | FOUNDATIONAL |
| `2026-03-31-multi-agent-coordination.md` | Multi-agent coordination protocols | FOUNDATIONAL |
| `2026-04-04-brief-external-observer-loop.md` | Status dashboard (Wall of Light) | IMPLEMENTATION |
| `2026-04-04-brief-scratchpad.md` | Three-speed monitoring architecture | CONCEPT |
| `2026-04-04-brief-silo-dashboard.md` | Industrial monitoring dashboard | CONCEPT |
| `2026-04-04-brief-sparklines.md` | Sparkline EKG visualization | CONCEPT |
| `2026-04-04-brief-silo-streaming.md` | SSE for real-time telemetry | CONCEPT |
| `2026-04-06-multi-agent-ops.md` | Multi-agent session ID mechanism | CONCEPT |

### EPIC 4: Gamma Loops & Task Processing
**Theme:** Process modification and feedback loops

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-04-brief-silo-gamma-loop.md` | Primary gamma-loop: Process modification | IMPLEMENTATION |
| `2026-04-04-brief-silo-grid.md` | Hierarchy of concern (Silo of Silos) | CONCEPT |
| `2026-04-06-brief-gamma-loop-01.md` | Gamma-loop terminology and neurophysiology | CONCEPT |
| `2026-04-06-brief-gamma-loop-02.md` | Silo-Tone: AI translation of gamma | CONCEPT |
| `2026-04-06-silo-gamma-loop-03.md` | Maturation phases (Baby vs Adult) | CONCEPT |
| `2026-04-06-task-loop-01.md` | Task-Loop Protocol for self-documenting execution | IMPLEMENTATION |
| `2026-04-06-task-loop-02.md` | Silo-Factory (Process-Loop) Protocol | IMPLEMENTATION |

### EPIC 5: Isolation & Security
**Theme:** Blast radius, sandboxing, compliance

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-04-brief-silo-isolation-protocols.md` | Three-tiered defense protocol | CONCEPT |
| `2026-04-04-brief-silo-public-pi.md` | Public facade vs internal vocabulary | CONCEPT |
| `2026-04-04-brief-silo-self-hosting.md` | Sidecar-as-infrastructure for self-hosting | CONCEPT |
| `2026-04-04-brief-silo-status-chat.md` | SSH transport + `just chat` entry | CONCEPT |
| `2026-04-06-brief-confidentiality.md` | Hybrid cloud/local execution strategy | CONCEPT |
| `2026-04-06-brief-compliance-agent.md` | Compliance-agent data harvester | CONCEPT |
| `2026-04-06-brief-compliance-implementation.md` | 2026 AI regulatory comparison matrix | CONCEPT |
| `2026-04-06-regulatory-compliance.md` | Silo compliance stack mapping | CONCEPT |
| `2026-04-06-review-process.md` | System-1/System-2 review safeguards | CONCEPT |

### EPIC 6: Documentation & Knowledge
**Theme:** Documentation generation, active docs, lexicon

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-06-brief-active-documentation.md` | Tidy-first anti-RAG documentation | CONCEPT |
| `2026-04-06-brief-silo-doc-gen-01.md` | Silo framework documentation implementation | IMPLEMENTATION |
| `2026-04-06-brief-silo-doc-gen-02.md` | Silo bootstrapping as persona init | IMPLEMENTATION |
| `2026-04-06-brief-sub-silo-documentation-01.md` | Wiki vs filesystem knowledge architecture | CONCEPT |
| `2026-04-06-brief-sub-silo-documentation-02.md` | Role-based context (Need-to-Know silo) | CONCEPT |
| `2026-04-06-brief-tidy-docs.md` | `just tidy-docs` sanitation command | CONCEPT |
| `2026-04-06-brief-silo-conceptual-lexicon.md` | Silo Conceptual Lexicon (SCL) agent | CONCEPT |

### EPIC 7: Blog & Content Pipeline
**Theme:** Content creation and publishing workflow

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-06-brief-blog-process-01.md` | Component-based blog architecture | IMPLEMENTATION |
| `2026-04-06-brief-blog-process-02.md` | Two-step binary (Prep/Publish) | IMPLEMENTATION |

### EPIC 8: Strategic & Theory
**Theme:** Underpinning philosophy, evaluation, business

| Brief | One-line Description | Status |
|-------|----------------------|--------|
| `2026-04-02-brief-edinburgh-eval.md.md` | Edinburgh eval: gumption tests | CONCEPT |
| `2026-04-02-brief-launch-strategy.md` | GitHub launch playbook | CONCEPT |
| `2026-04-02-brief-dot-capability-01.md` | Lean dependency strategy | CONCEPT |
| `2026-04-02-brief-dot-capability-02.md` | Hierarchy of automation | CONCEPT |
| `2026-04-02-brief-dot-capability-03.md` | Dev-Ops vs Silo-Ops split | CONCEPT |
| `2026-04-03-briefs-1-3.md` | just-silo entry layer consolidation | FOUNDATIONAL |
| `2026-04-06-brief-counter-blast.md` | Counter-blast to AI chat sessions | CONCEPT |
| `2026-04-06-brief-dev-cycle.md` | Developer as entropy architect | CONCEPT |
| `2026-04-06-brief-entropy-led-development.md` | Information thermodynamics model | CONCEPT |
| `2026-04-06-brief-pitch-doc.md` | Strategic pitch for Greg | CONCEPT |
| `2026-04-06-brief-rate-limiting.md` | Industrial metronome cadence control | CONCEPT |
| `2026-04-06-brief-silo-cadence.md` | Cadence vs elasticity | CONCEPT |
| `2026-04-06-brief-silo-competency.md` | Competency architecture (K/U/A) | CONCEPT |
| `2026-04-06-brief-silo-entropy.md` | Entropy mathematical anchoring | CONCEPT |
| `2026-04-06-brief-silo-prompt-comparision.md` | Predictive shamanism vs industrial realism | CONCEPT |
| `2026-04-06-brief-silo-provisioning.md` | Silo master protocol summary | CONCEPT |
| `2026-04-06-brief-silo-scaling-laws.md` | Three scaling laws of silo | CONCEPT |
| `2026-04-06-brief-sys2-prompt-strategy.md` | Sovereign substrate playbook | CONCEPT |
| `2026-04-06-brief-task-types.md` | Mentational gearbox: task classifications | CONCEPT |
| `2026-04-06-cost-benefit-01.md` | Silo performance matrix (H vs C) | CONCEPT |
| `agent-as-a-capability.md` | Agent as thin sleeve / capabilities as gears | CONCEPT |

---

## Dependency Graph

```
EPIC 1 (Core Infrastructure)
├── EPIC 2 (API & Automation)     ← depends on EPIC 1 templates
├── EPIC 3 (Observability)         ← depends on EPIC 1 data structure
├── EPIC 4 (Gamma Loops)           ← depends on EPIC 1 + 3
├── EPIC 5 (Isolation)            ← independent (can start)
├── EPIC 6 (Documentation)         ← independent (can start)
├── EPIC 7 (Blog)                  ← depends on EPIC 6
└── EPIC 8 (Strategy)              ← independent (can start)
```

## Independent (No Dependencies) - Can Start Now

| Epic | Why Independent |
|------|-----------------|
| EPIC 5: Isolation & Security | Pure concept/planning |
| EPIC 6: Documentation | Can be drafted in parallel |
| EPIC 8: Strategy/Theory | Foundational thinking |

## Parallelizable

| Phase | Epics | Reason |
|-------|-------|--------|
| Phase 1 (NOW) | EPIC 1, 5, 6, 8 | Foundation + independent tracks |
| Phase 2 | EPIC 2, 3 | Depends on EPIC 1 templates |
| Phase 3 | EPIC 4 | Depends on EPIC 1-3 |
| Phase 4 | EPIC 7 | Depends on EPIC 6 docs |

---

## Implementation Priority

### NOW (Ready to execute)
1. **EPIC 1**: Complete register-silo implementation (briefs 04-12 mostly done)
2. **EPIC 6**: Document the framework while building
3. **EPIC 8**: Finalize conceptual lexicon

### SOON (After EPIC 1)
1. **EPIC 2**: API generation from justfile
2. **EPIC 3**: Observability dashboard

### LATER (After EPIC 1-3)
1. **EPIC 4**: Gamma loops
2. **EPIC 7**: Blog pipeline

---

## Notes
- 3 briefs are FOUNDATIONAL (pre-requisite reading)
- 19 briefs are in IMPLEMENTATION status
- 56 briefs are in CONCEPT/PLANNING status
- 1 brief is empty: `2026-04-06-brief-rate-limiting.md`

