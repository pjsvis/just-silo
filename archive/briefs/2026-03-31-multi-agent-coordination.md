---
date: 2026-03-31
tags: [just-silo, multi-agent, coordination]
---

# Brief: Multi-Agent Coordination

## What

Implement coordination recipes in the justfile to support multiple agents working in the same silo.

## Problem

Single-agent silos are useful, but production workflows often need multiple agents:
- Agent A harvests data
- Agent B processes it
- Agent C flushes and archives

Without coordination, agents collide or process out-of-order.

## Proposed Solution

Add coordination recipes:

| Recipe | Purpose |
|--------|---------|
| `lock <marker>` | Claim a stage |
| `is-locked <marker>` | Check claim |
| `wait <marker>` | Block until ready |
| `done <marker>` | Mark complete |
| `cleanup` | Remove stale locks |

## File Structure

```
silo/
├── markers/
│   ├── harvest.done
│   └── process.done
└── stages/
```

## Workflow

```
Agent A: just harvest && just lock harvest.done
Agent B: just wait harvest.done && just process && just lock process.done
Agent C: just wait process.done && just flush
```

## Acceptance

- [ ] Recipes implemented in template
- [ ] Tested in silo_barley
- [ ] Documented in operator playbook
- [ ] Brief and debrief created
