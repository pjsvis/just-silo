---
date: 2026-04-26
tags: [playbook, security, blast-radius, isolation]
---

# Blast Radius Playbook

## Principle

**Physical isolation > Policy enforcement.**

Instead of "you *shouldn't*," make it "you *can't*."

When a silo has `blast_radius = 1`:
- It can only hurt itself
- The rest of the system is safe
- Agents can experiment freely
- Mistakes are contained

## Levels

| Level | Name | Network | Filesystem | Memory | Use Case |
|-------|------|---------|-----------|--------|----------|
| 0 | **Void** | None | Self only | 64MB | Throwaway tests |
| 1 | **Lab** | Allowlist | Self + tmp | 512MB | Experimentation |
| 2 | **Dev** | localhost+ | ~/Dev | 2GB | Development work |
| 3 | **Prod** | Any | Any | 8GB | Production access |

## Manifest

Declare in `.silo`:

```json
{
  "blast_radius": 1,
  "network": "allowlist",
  "allowlist": ["api.example.com"],
  "filesystem": "self",
  "memory_mb": 512
}
```

## Enforcement

| Mechanism | Level | Effort |
|-----------|-------|--------|
| chroot / unshare | 0-1 | Low |
| iptables network namespace | 1-2 | Medium |
| Docker container | 0-3 | Medium (overhead) |
| Landlock + cgroups | 0-2 | High (kernel reqs) |

## Current Practice

We operate at **Level 2 (Dev)** by convention:
- Silo directory is the boundary
- No containerization yet
- Policy: agent only acts within `justfile` recipes
- Audit: `telemetry/costs.jsonl` + `markers/` checkpoints

Future: evaluate Landlock for Linux-native sandboxing without Docker overhead.
