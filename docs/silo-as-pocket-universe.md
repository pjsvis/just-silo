# Silo as Pocket Universe

**Date: 2026-03-31 | Status: Thinking Out Loud**

---

## The Core Insight

**A silo is just a folder that said "I'm a silo."**

Any directory can be:
1. **Just a folder** — files, no contract
2. **A silo** — folder with `.silo` manifest, declares itself

The difference is the declaration, not the structure.

```
FOLDER                          SILO
───────                         ────
files                           files
                                .silo (manifest)
                                justfile (vocabulary)
                                schema.json (grammar)
                                blast_radius = 1

Agent visits:                   Agent visits:
  reads what's there              gets PROVISIONED
  figures it out                  understands domain
  no contract                     has rules
```

---

## The Declaration

**Creating a GitHub repo = declaring a pocket universe.**

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│   git init                     git clone                       │
│        │                              │                        │
│        ▼                              ▼                        │
│   ┌────────────────┐        ┌─────────────────────────┐       │
│   │  LOCAL FOLDER  │        │   .silo manifest        │       │
│   │  becomes       │─────── │   justfile added        │       │
│   │  a silo        │        │   schema.json exists    │       │
│   └────────────────┘        └─────────────────────────┘       │
│                                                                │
│   "This is my space. I control it. It has its own rules."     │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

When you create a GitHub repo, you're saying:
- This is a controlled space
- I own it
- It has its own rules
- Blast radius is mine
- Agents visiting this space can be provisioned

---

## Two Scenarios

### Scenario 1: Multi-Silo

Multiple silos, each a pocket universe, coordinating.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ silo_barley │    │ silo_alerts │    │ silo_reports│
│ (grain)     │───→│ (critical)  │───→│ (weekly)    │
└─────────────┘    └─────────────┘    └─────────────┘
     dev                 dev                dev
```

Each has:
- Owner's rules
- Vocabulary
- Blast radius
- Can be corralled back

### Scenario 2: Multi-Agent (within one silo)

Multiple agents working in the same pocket universe.

```
┌────────────────────────────────────────────────────────────────┐
│                        silo_barley                              │
│                                                                │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│    │ Agent A  │    │ Agent B  │    │ Agent C  │              │
│    │ (harvest)│───→│ (process)│───→│ (alert)  │              │
│    └──────────┘    └──────────┘    └──────────┘              │
│         │                                                │      │
│         │         SHARED:                                 │      │
│         │         - Vocabulary (justfile)                 │      │
│         │         - Schema (grammar)                       │      │
│         │         - Blast radius (isolation)               │      │
│         │         - Markers (coordination)                  │      │
│         │         - Data (in/, work/, out/)               │      │
│         └─────────────────────────────────────────────────┘      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

Agents share the universe but have different roles.

---

## The Provisioning Model

When an agent enters a silo:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   Agent visits silo_barley                                       │
│                                                                 │
│   ┌───────────────────────┐                                      │
│   │   .silo manifest      │                                      │
│   │   {                  │                                      │
│   │     id: "550e...",   │                                      │
│   │     owner: "pjsvis", │                                      │
│   │     domain: "grain",  │                                      │
│   │     blast_radius: 1  │                                      │
│   │   }                  │                                      │
│   └───────────────────────┘                                      │
│              │                                                   │
│              ▼ reads                                             │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │  PROVISIONED FOR silo_barley:                          │   │
│   │                                                          │   │
│   │   Domain: Grain moisture monitoring                     │   │
│   │   Owner: pjsvis                                         │   │
│   │   Vocabulary: harvest, process, alert, flush, status   │   │
│   │   Blast radius: 1 (lab)                                 │   │
│   │   Rules: Don't touch production. Stay in ~/Dev.         │   │
│   │                                                          │   │
│   │   "You may do these things. Only here."                 │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Provisioning is automatic.** Read `.silo`, understand the universe, follow the rules.

---

## The Herd Mentality

**Dev silos vs Deployed silos**

```
┌─────────────────────────────────────────────────────────────────┐
│                           HERD                                   │
│                                                                 │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│   │ silo_a  │ │ silo_b  │ │ silo_c  │ │ silo_d  │            │
│   │  dev    │ │  dev    │ │  prod   │ │  prod   │            │
│   │  id=?   │ │  id=?   │ │  id=?   │ │  id=?   │            │
│   └─────────┘ └─────────┘ └─────────┘ └─────────┘            │
│        │                                                    │    │
│        └────────────────────────────────────────────────────┘    │
│                     "Corralled back easily"                       │
│                                                                 │
│   Discovery: ls ~/Dev/silo_*                                    │
│   Registry: ~/.config/just-silo/registry.json                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Dev silos** have:
- IDs, metadata, full manifest
- Git history
- Owner information
- Blast radius set
- Can be corralled back (just pull from origin)

**Deployed silos** might be:
- Minimal runtime copies
- Synced data outputs
- Aggregated results

---

## What "Just Do It Here" Means

**Accept the folder as-is:**
```
~/Projects/random-folder/
├── stuff.json
└── notes.md
```
Agent visits, reads files, figures it out. No contract.

**Turn it into a silo:**
```
cd ~/Projects/random-folder
just init
```
Now it's declared:
- Has manifest
- Has vocabulary
- Has rules
- Agent gets provisioned on entry

**The choice is always the owner.**
```
mkdir foo          # Folder
git init           # Declare it yours
just init          # Turn it into a silo
git clone          # Copy someone's declared universe
```

---

## The Rules

1. **A silo is a folder with a declaration.**
   - `.silo` manifest makes it official
   - No manifest = just a folder

2. **Provisioning is automatic.**
   - Agent reads manifest on entry
   - Gets vocabulary, rules, blast radius

3. **Blast radius is physical.**
   - Not "don't do that"
   - "Can't do that"

4. **Dev vs deployed is fluid.**
   - Dev: full metadata, git, owner
   - Deployed: subset, syncs back
   - Either can be corralled

5. **The herd is discoverable.**
   - Local registry
   - Git origin
   - Directory scanning

---

## Open Questions

- [ ] What triggers provisioning? cd? just commands? explicit?
- [ ] Can agents visit silos without being provisioned?
- [ ] What's the minimum manifest to call something a silo?
- [ ] How does "corralling back" work in practice?
- [ ] Deployed silos: same model or subset?

---

## Related

- [speculative-design.md](./speculative-design.md) — Full multi-silo architecture
- [briefs/2026-03-31-multi-silo-architecture.md](../briefs/2026-03-31-multi-silo-architecture.md)
- [briefs/2026-03-31-blast-radius-security.md](../briefs/2026-03-31-blast-radius-security.md)
