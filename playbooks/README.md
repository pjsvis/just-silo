# Playbooks Directory

**Purpose:** Domain knowledge and operational procedures for just-silo.

## Structure

```
playbooks/
├── *.md              # Active playbooks (canonical)
└── archive/          # Superseded, drafts, experimental
    ├── drafts/       # Incomplete, not for use
    ├── superseded/   # Replaced by newer versions
    └── experimental/ # Untested, use with caution
```

## Categories

### SILO (14 files)
Lifecycle and operational playbooks for silo management.

| Playbook | Purpose |
|----------|---------|
| `silo-builder-playbook.md` | Creating new silos |
| `silo-operator-playbook.md` | Running silos |
| `silo-agent-*.md` | Agent integration |
| `silo-logging-*.md` | Entropy logging |
| `silo-security-*.md` | Security considerations |
| `silo-clean-room.md` | Clean workspace patterns |

### TOOLS (7 files)
Reference documentation for CLI/tools.

| Playbook | Tool |
|---------|------|
| `just-playbook.md` | just (task runner) |
| `jq-playbook.md` | jq (JSON processor) |
| `jsonl-playbook.md` | JSON Lines format |
| `watchexec-playbook.md` | watchexec (file watcher) |
| `td-playbook.md` | td (task database) |
| `tsconfig-tiered-playbook.md` | TypeScript config |

### PROCESS (8 files)
Workflow and methodology playbooks.

| Playbook | Purpose |
|----------|---------|
| `entropy-management-playbook.md` | THINK FAST → ARCHIVE → GAP FILL |
| `gamma-loop-playbook.md` | Self-improvement cycle |
| `debriefs-playbook.md` | Post-session reflection |
| `tidy-first-playbook.md` | Workspace hygiene |
| `dev-cycle-playbook.md` | Development workflow |

### REFERENCE (15 files)
Agent patterns, security, and domain-specific.

| Playbook | Purpose |
|----------|---------|
| `edinburgh-protocol-playbook.md` | Scottish Enlightenment agent |
| `reliability-playbook.md` | System reliability |
| `caveman-ultra-playbook.md` | Cognitive optimization |
| `semantic-compression-playbook.md` | Dense communication |

## Archive

Archived playbooks are in `playbooks/archive/`:
- `drafts/` — Incomplete, experimental
- `superseded/` — Replaced versions
- `experimental/` — Untested patterns

**Rule:** Never delete. Archive and retrieve if needed.

## Usage

```bash
# Browse playbooks
just playbooks

# Read specific playbook
just about-file playbooks/silo-builder-playbook.md
```

## Adding Playbooks

1. Create in `playbooks/` with frontmatter:
```markdown
---
date: 2026-04-12
tags: [playbook, category]
agent: any
environment: local
---

# My Playbook
```

2. Run `just silo-verify-structure` to validate
3. If superseded, move to `archive/superseded/`

