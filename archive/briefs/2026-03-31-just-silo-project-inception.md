---
date: 2026-03-31
tags: [just-silo, inception, pattern]
---

# Brief: just-silo Project Inception

## What

Create a standalone repository for the Silo pattern — a directory-based task system for AI agents.

## Why

- The Silo pattern proved valuable in ctx-cli development
- Separate repo enables sharing and contribution
- Clear separation from ctx-cli-specific work

## Goals

1. Publish just-silo as open source
2. Include all documentation (playbook, manual)
3. Demonstrate the process (briefs, debriefs)
4. Make it usable by other agent practitioners

## Structure

```
just-silo/
├── README.md
├── template/
├── examples/
├── playbooks/     # By role: user, builder, agent, operator

├── manual.md      # Detailed guide
├── briefs/
└── debriefs/
```

## Success Criteria

- [ ] Repo created and public
- [ ] README with quick start
- [ ] Template ready to copy
- [ ] Working example (silo_barley)
- [x] Playbooks by role
- [ ] This brief and eventual debrief
