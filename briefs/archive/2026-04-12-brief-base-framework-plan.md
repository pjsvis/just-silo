# Action Plan: Base Framework Consolidation

**Date:** 2026-04-12  
**Session:** ses_c7686a  
**Branch:** pr/two-tier-api-agents-gamma

---

## Phase 0: Tidy First (This Session)

### Directory Audit

| Path | Status | Action |
|------|--------|--------|
| `glow` (97KB) | Binary log artifact | Archive or gitignore |
| `opentui-examples` (80MB) | Binary binary | Move to archive or delete |
| `info-graphic.png` (1.7MB) | Static asset | Move to assets/ or docs/ |
| `.DS_Store` | macOS artifact | Add to .gitignore |
| `ANDERS.md` | Unclear purpose | Clarify or archive |
| `SESSION-STATE.md` | Stale state file | Archive or delete |
| `td-report.md` | Snapshot report | Archive |
| `REPOS.md` | Reference doc | Keep in docs/ |
| `PROMPT.md` | Reference doc | Keep in prompts/ |
| `SHORTCUTS.about.md` | Reference doc | Keep or merge |

### Proposed Structure

```
just-silo-dev/
├── .silo/                  # Project manifest
├── src/                     # TypeScript (Tier 2)
│   └── lib/                 # Shared libraries
├── scripts/                 # Shell scripts (Tier 1)
│   ├── lab/                 # Experimental (Tier 0)
│   └── silo-*              # Core operational scripts
├── docs/                    # Documentation
├── playbooks/               # Domain procedures
├── brief/                   # Briefs archive
├── debriefs/               # Post-mortems
├── template/                # Silo template (the product)
├── launch_silo/            # Launch procedure
├── silos/                  # Deployed silos (gitignored)
├── dev/                    # Development workspaces
├── scratch/                # Agent workspace (gitignored)
├── insights/                # Content stories
├── agents/                 # Agent definitions
├── schemas/                # JSON schemas
└── archive/                # Historical materials
    ├── briefs/             # Old briefs
    ├── marketing/          # Old marketing
    └── ...
```

---

## Phase 1: Silo Framework Documentation

### What We Have

| Component | Location | Status |
|-----------|----------|--------|
| **silo-create** | `scripts/silo-create` | ✅ Functional |
| **silo-deploy** | `scripts/silo-deploy.sh` | ✅ Functional |
| **silo-build** | `scripts/silo-build.sh` | ✅ Functional |
| **silo-ignite** | `scripts/silo-ignite` | ✅ Functional |
| **provision** | `scripts/provision.sh` | ✅ Arch Linux focused |
| **Template** | `template/` | ✅ Complete |
| **Schema** | `template/schema.json` | ⚠️ Grain elevator example (not generic) |

### Gap Analysis

| Gap | Severity | Action |
|-----|----------|--------|
| No generic schema template | HIGH | Create `schema-generic.json` |
| No deployment verification tests | MEDIUM | Add `silo-verify` integration test |
| No clear "develop → deploy" path documented | MEDIUM | Document in README |
| provision.sh is Arch-specific | MEDIUM | Add provision-linux.sh, provision-macos.sh |
| No CI/CD for silo deployment | LOW | Add GitHub Actions workflow |

---

## Phase 2: Documentation Tasks

1. **Create `docs/SILO-FRAMEWORK.md`**
   - Overview of silo lifecycle
   - Diagram: create → build → deploy → operate
   - Component inventory

2. **Update `template/README.md`**
   - Real usage instructions
   - Remove placeholder text

3. **Create `docs/DEPLOYMENT.md`**
   - Dev workflow → Silo workflow
   - Migration path

4. **Update `AGENTS.md`**
   - Current state vs. archived sub-agent layer

---

## Phase 3: Quick Wins (From Briefs)

| Brief | Priority | Estimated |
|-------|----------|-----------|
| `pr-review-html-cleanup` | P3 | 30min |
| `silo-clean` (script exists) | Document | 15min |

---

## Phase 4: Briefs Backlog Triage

| Category | Count | Action |
|----------|-------|--------|
| INFRA | 22 | Triage: what is implemented vs. drafted |
| AGENTS | 16 | Review: which are implemented |
| MISC | 16 | Archive: many are superseded |
| DOCS/BLOG | 6 | Low priority |
| GAMMA | 4 | Keep: core architecture |

---

## Opinion

**The system is functional but poorly documented.** You have the "engine" (silo-create, deploy, build) but no "driver's manual."

**Priority:** Get the framework documentation solid first. Then triage the 71 briefs. The LPC/CFL benchmarking experiments (Briefs 2-3) are interesting but should not block foundation work.

**Entropy Reduction:** The 80MB `opentui-examples` binary is a good first cut. It signals "experimentation phase" is over.

---

## Next Actions

- [ ] Tidy directory (archive/remove cruft)
- [ ] Create `docs/SILO-FRAMEWORK.md`
- [ ] Create generic schema template
- [ ] Document deployment workflow
- [ ] Triage briefs backlog (archive stale)