# Playbook: Sub-Agents — Progressive Disclosure

**Discover and execute sub-agents via `just`.**

---

## Philosophy

> **Progressive Disclosure**: `just agents` reveals what's available. No need to read directories or docs upfront.

The agent system provides:
1. **Discovery** — What agents exist?
2. **Summary** — What does this agent do?
3. **Execution** — Run the agent's commands

---

## Core Interface

```bash
just agents              # List all agents
just agents <name>       # Show agent summary
just agents <name> <cmd> # Run agent command
```

### Aliases

```bash
just agents-show <name>  # Same as: just agents <name>
just agents-run <name> <cmd>  # Run agent command
just agents-tidy <cmd>   # Convenience: tidy-first-agent
just agents-cr <cmd>     # Convenience: code-review-agent
```

---

## Available Agents

| Agent | Alias | Purpose |
|-------|-------|---------|
| `tidy-first-agent` | `tidy` | Workspace hygiene automation |
| `code-review-agent` | `cr` | Automated code review |

---

## Agent Structure

```
agents/
├── README.md                 # Registry (lists all agents)
├── <name>-agent/
│   ├── README.md            # Agent documentation
│   ├── manifest.json        # Machine-readable metadata
│   └── justfile            # Agent commands
└── ...
```

### manifest.json Schema

```json
{
  "name": "tidy-first-agent",
  "alias": "tidy",
  "description": "Workspace hygiene automation",
  "commands": ["check", "status", "run", "run-full"],
  "entry": "justfile"
}
```

---

## Examples

### Discovery

```bash
# List all agents
just agents

# Output:
# | Agent     | Alias | Description                  |
# |-----------|-------|------------------------------|
# | tidy-first| tidy  | Workspace hygiene automation |
# | code-review| cr   | Automated code review        |
```

### Info

```bash
# Show tidy-first-agent summary
just agents tidy

# Show code-review-agent
just agents cr

# Show by full name
just agents code-review
```

### Execution

```bash
# Run tidy check
just agents tidy check
just agents-run tidy check
just agents-tidy check

# Run tidy full
just agents tidy run-full

# Run code review
just agents cr review
just agents-cr review
```

---

## Cron Integration

Agents can run via cron for scheduled automation.

### Pattern

```bash
# Daily tidy (8am)
0 8 * * * cd /path/to/just-silo && just agents tidy run

# Weekly deep clean (Monday 9am)
0 9 * * 1 cd /path/to/just-silo && just agents tidy run-full
```

### Log Output

```bash
# Redirect to log file
0 8 * * * cd /path && just agents tidy run >> /tmp/tidy.log 2>&1
```

---

## Adding a New Agent

### 1. Create Directory

```bash
mkdir -p agents/my-agent
```

### 2. Add manifest.json

```json
{
  "name": "my-agent",
  "alias": "my",
  "description": "What this agent does",
  "commands": ["start", "stop", "status"],
  "entry": "justfile"
}
```

### 3. Add justfile

```justfile
# my-agent justfile

start:
    @echo "Starting..."

status:
    @echo "Status: running"

stop:
    @echo "Stopped"
```

### 4. Add README.md

```markdown
# My Agent

Brief description of what this agent does.

## Commands

- `just start` - Start the agent
- `just status` - Check status
- `just stop` - Stop the agent
```

### 5. Register

Agents are auto-discovered. No registration needed.

---

## Agent Design Principles

### 1. Idempotent

Running the same command twice should be safe.

### 2. Documented

Each agent has README.md explaining purpose and commands.

### 3. Manifested

manifest.json provides machine-readable metadata.

### 4. Delegable

Agents delegate to their own justfile, not the parent.

### 5. Observable

Agents should log their actions (to stdout or files).

---

## Troubleshooting

### "Agent not found"

```bash
# Check agent exists
just agents

# Check spelling
just agents tidy  # correct
just agents tiddy # wrong
```

### "No justfile"

```bash
# Agent must have a justfile
ls agents/<name>-agent/justfile
```

### "Command not found"

```bash
# Check available commands
just agents <name>

# Or check manifest
cat agents/<name>-agent/manifest.json | jq .commands
```

---

## Quick Reference

```bash
# List
just agents

# Info
just agents tidy
just agents cr

# Run
just agents tidy run
just agents-cr review

# Help
just agents-help
```

---

## Coding Standards for Agents

> **When coding agents act, they follow these rules.**

### The Simplicity Rule

> **Extract to scripts. Keep justfiles thin.**

| Situation | Don't Do | Do |
|----------|----------|----|
| Recipe > 80 chars | Inline jq pipeline | Call `scripts/process.sh` |
| Data transformation | `jq` in justfile | `scripts/transform.sh` |
| Conditional logic | Nested `if/elif/else` | Call `scripts/decide.sh` |
| Multi-step workflow | Long recipe with `\` | `just step1 && just step2` |

### Why Simplicity Wins

1. **Debugging** — Simple code fails predictably
2. **Readability** — Future you thanks present you
3. **Composability** — Scripts call scripts
4. **Testability** — Scripts can be tested independently

### The Trigger

Extract to a script when:
- Line exceeds 80 characters
- Nested quotes (`'"..."'`)
- Variable interpolation complexity
- Multi-line `\` chains
- Data manipulation (jq, sed, awk)

### Pattern

```just
# BAD: Justfile does the work
transform:
    @jq -c 'select(.status == "ready")' data.jsonl > ready.jsonl
    @jq -c 'select(.status != "ready")' data.jsonl > pending.jsonl
    @echo "Split $(wc -l < ready.jsonl) ready, $(wc -l < pending.jsonl) pending"

# GOOD: Script does the work
transform:
    @./scripts/transform.sh
```

### The justfile Mantra

```
Justfile = vocabulary (orchestration)
Scripts  = grammar (implementation)
```

### Agent-Specific Rules

1. **Log actions** — stdout or `.silo/logs/`
2. **Fail loud** — Let errors propagate
3. **Idempotent** — Safe to run twice
4. **Manifest** — Update `manifest.json` when commands change
5. **Test** — Agent lifecycle tests in `tests/` directory

---

## Related

- `agents/README.md` — Agent registry
- `agents/<name>-agent/` — Individual agent directories
- `scripts/resolve-agent.sh` — Name/alias resolution
- `playbooks/watchexec-playbook.md` — File watching (for agents)
- `playbooks/justfile-design-playbook.md` — Justfile design rules
- `playbooks/lessons-learned.md` — Collected wisdom
