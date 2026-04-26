---
date: 2026-04-26
tags: [brief, pivot, engage, flox, environment, tools]
---

# Brief: Pivot from `engage` to `flox`

## Context

Historical documents (`docs/agent-security-protocol.md`, `docs/silo-security.md`, `docs/ai-security-gap.md`) describe an `engage` toolbelt — a compiled Bun binary providing scoped capabilities to the agent (PDF parsing, web crawling, data transformation).

`engage` was a concept, not a delivered tool.

## Decision

**Replace `engage` with `flox` as the environment manager.**

`flox` provides what `engage` was intended to provide:
- Scoped tool provisioning (install only what the silo needs)
- Reproducible environments (declarative, not imperative)
- Auditability (manifest is the contract)
- No shell escape (tools are installed into the environment, not arbitrary execution)

## Mapping

| `engage` Concept | `flox` Reality |
|------------------|----------------|
| Compiled Bun binary with scoped modalities | `flox.toml` declaring tool packages |
| "If it isn't in engage, the agent can't use it" | `flox install` adds to manifest; `flox activate` scopes environment |
| Forge Versors/Modalities from audited source | Nix packages from nixpkgs (audited upstream) |
| Telemetry Witness logs every engage call | Environment already logs via `just` + `telemetry/` |

## Implication

The security model is the same — the agent can only use what's in its environment — but the mechanism is `flox` (declarative package management) not `engage` (custom binary).

Old docs remain in `docs/` as historical reference but are superseded by `playbooks/silo-anatomy-playbook.md` and the `flox.toml` manifest.

## Action

- Update current playbooks to reference `flox`, not `engage`
- Do not rewrite old docs; mark as historical
- Future silos declare tools in `.silo` → `flox.toml`, not `engage` binary
