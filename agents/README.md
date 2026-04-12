# Agents Registry

Sub-agents available in this project.

---

## Usage

```bash
just agents              # List all agents
just agents <name>       # Show agent summary
just agents <name> <cmd> # Run agent command
just agents help        # Show this help
```

---

## Available Agents

| Agent | Alias | Description |
|-------|-------|-------------|
| tidy-first | tidy | Workspace hygiene automation |
| code-review | cr | Automated code review |

---

## Adding a New Agent

1. Create `agents/<name>-agent/` directory
2. Add `manifest.json` with metadata
3. Add `justfile` with commands
4. Add README.md with documentation

---

## Cron Setup

```bash
# Daily tidy (8am)
0 8 * * * cd /path/to/just-silo && just agents tidy run >> /tmp/tidy.log 2>&1
```

