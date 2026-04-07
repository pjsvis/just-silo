---
date: 2026-03-31
tags: [just-silo, security, blast-radius, isolation]
---

# Brief: Blast Radius Security Model

## The Problem

Traditional security is advisory:

> "Don't access production data."
> "Don't write outside your directory."
> "Don't make network calls to external APIs."

**But agents are stubborn.** They will find ways around policies. They will make mistakes. They will follow instructions that lead somewhere unexpected.

## The Insight

> **Physical isolation > Policy enforcement.**

Instead of "you *shouldn't*," make it "you *can't*."

```
┌────────────────────────────────────────┐
│           SILO (Blast Radius = 1)      │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │        CAN ACCESS               │   │
│   │   • Own filesystem              │   │
│   │   • Configured APIs only        │   │
│   │   • Local resources             │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │        CANNOT ACCESS             │   │
│   │   • Production systems          │   │
│   │   • Other silos' data           │   │
│   │   • Unauthorized networks        │   │
│   │   • Parent directories          │   │
│   └─────────────────────────────────┘   │
└────────────────────────────────────────┘
                    │
                    │ If something goes wrong:
                    ▼
            ┌───────────────┐
            │   BOOM        │
            │   (contained) │
            └───────────────┘
```

## Blast Radius Levels

| Level | Name | Network | Filesystem | Resources |
|-------|------|---------|-----------|-----------|
| 0 | **Void** | None | Self only | Minimal |
| 1 | **Lab** | Configured only | Self + tmp | Capped |
| 2 | **Dev** | localhost | ~/Dev | Standard |
| 3 | **Prod** | Any | Any | Uncapped |

### Level 0: Void

For testing. No network. No persistence. Fire and forget.

```json
{
  "blast_radius": 0,
  "network": "none",
  "filesystem": "self",
  "memory_mb": 64,
  "cpu_percent": 10
}
```

### Level 1: Lab

Experimentation. Approved APIs only. Results don't leave.

```json
{
  "blast_radius": 1,
  "network": "allowlist",
  "allowlist": ["api.openweathermap.org", "api.stripe.com"],
  "filesystem": "self",
  "memory_mb": 512,
  "cpu_percent": 25
}
```

### Level 2: Dev

Development work. Can reach local services, not prod.

```json
{
  "blast_radius": 2,
  "network": "localhost-plus",
  "localhost_plus": ["localhost:3000", "redis:6379"],
  "filesystem": "~/Dev",
  "memory_mb": 2048,
  "cpu_percent": 50
}
```

### Level 3: Prod

Production access. Full trust, full risk.

```json
{
  "blast_radius": 3,
  "network": "any",
  "filesystem": "any",
  "memory_mb": 8192,
  "cpu_percent": 100
}
```

## Enforcement Mechanisms

### 1. Filesystem (easiest)

```bash
# Run silo in restricted directory
cd /silos/silo_barley
chroot .

# Or use container
docker run --read-only --tmpfs /tmp -v $(pwd):/silo

# Orland
unshare --mount --pid --fork
```

### 2. Network (moderate)

```bash
# iptables-based firewall
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -j REJECT

# Or per-silo network namespace
ip netns exec silo_barley ...
```

### 3. Syscall (hard)

```bash
# seccomp to filter syscalls
seccomp-tools whitelist ./silo_binary

# Or landlock (Linux 5.13+)
landlock --filesystem=/silos/silo_barley
```

### 4. Resource Limits

```bash
# cgroups
cgcreate -g memory,cpu:/silo_barley
echo 512M > /sys/fs/cgroup/memory/silo_barley/memory.limit_in_bytes
echo 256000 > /sys/fs/cgroup/cpu/silo_barley/cpu.cfs_quota_us
```

## Implementation Options

### Option A: Convention + Documentation

- Document the rules
- Trust the agent
- Humans verify outputs

**Pros:** Simple, no infrastructure
**Cons:** Not enforced, humans fail

### Option B: Containerized Silos

Each silo runs in its own container.

```bash
# Start silo in container
docker run --rm \
  --read-only \
  --memory=512m \
  --cpus=0.5 \
  --network=none \
  -v silo_data:/silo \
  just-silo-runtime silo_barley
```

**Pros:** True isolation
**Cons:** Docker overhead, complexity

### Option C: Landlock + Namespaces

Linux-native sandboxing, no containers.

```bash
# Set up restricted environment
unshare --mount --pid --fork \
  ip netns create silo_net \
  landlock --filesystem=silo_barley \
  cgroup --memory=512m \
  ./run_silo.sh
```

**Pros:** Lightweight, Linux-native
**Cons:** Requires modern kernel, complex setup

### Option D: Hybrid

- Level 0-1: Simple chroot/container
- Level 2-3: More relaxed, human oversight

## The Blast Radius Promise

> **"Just do it here. Not anywhere else."**

When a silo has `blast_radius = 1`:
- It can only hurt itself
- The rest of the system is safe
- Agents can experiment freely
- Mistakes are contained

## Questions

1. **What's the minimum viable blast radius?** (Probably level 1)
2. **Should blast radius be per-silo or per-task?** (Per-silo, tasks inherit)
3. **How do we audit?** (Logs of boundary crossings attempted)
4. **Who sets blast radius?** (Owner, at creation time)

## Status

- [x] Concept documented
- [ ] Blast radius levels defined
- [ ] Enforcement mechanism chosen
- [ ] Implementation planned
