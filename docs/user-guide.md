# just-silo User Guide

*"just-silo it or just-forget it"*

---

## Quick Start

### Installation

```bash
# Clone the repo
git clone https://github.com/marcus-nicolaou/just-silo.git
cd just-silo

# Check prerequisites
just dev-check

# Run tests
just dev-tests
```

### Create Your First Silo

```bash
# Create a new silo
just dev-new my-first-silo

# Move into it
cd my-first-silo

# See what commands are available
just --list
```

---

## Core Concepts

### What is a Silo?

A **Silo** is a directory-based skill framework for AI agents. It externalizes domain knowledge into the filesystem.

```
my-silo/
├── .silo              # Manifest
├── justfile           # Commands (verbs)
├── schema.json         # Data validation
├── harvest.jsonl       # Raw input
├── data.jsonl          # Validated data
└── process.sh         # Domain logic
```

### The Pipeline

```
Mount → Sieve → Process → Observe → Flush
```

| Step | Command | Purpose |
|------|---------|---------|
| Mount | `cd my-silo/` | Agent reads rules |
| Sieve | `just harvest` | Validate data |
| Process | `just process` | Run domain script |
| Observe | `just status` | Monitor pipeline |
| Flush | `just flush` | Compact to archive |

### Entry Point

Mount a silo and just say what you want:

```bash
cd my-silo
just --list    # See available commands
just --help    # Get help
just VERSION   # Check version
```

---

## Standard Commands

Every silo has these commands:

```bash
just verify      # Check prerequisites
just harvest     # Ingest + validate data
just process     # Run domain script
just status      # Show pipeline status
just flush       # Archive processed items
just clean       # Reset state files
```

### Verifying Prerequisites

```bash
just verify
```

Checks:
- Required tools installed
- Schema valid
- Directory structure correct

### Harvesting Data

```bash
just harvest < input.jsonl
```

Validates input against `schema.json`, writes to `data.jsonl`.

### Processing

```bash
just process
```

Runs your domain script (`process.sh` or `src/`).

### Viewing Status

```bash
just status          # Quick status
just trend-show      # ASCII sparklines
just trend-dashboard # HTML dashboard
```

---

## Justfile Recipes

### Recipe Anatomy

```just
# Recipe with description
recipe-name:  # Description
    @echo "Running recipe"
    ./script.sh

# Recipe with parameters
greet name:
    @echo "Hello, {{name}}!"
```

### Recipe Groups

Recipes are organized into groups:

```
$ just --list

Available recipes:
    version

    [silo]
    silo-verify
    silo-harvest
    silo-process

    [docs]
    docs-readme
    docs-manual
```

### Aliases

Shortcuts for common commands:

```bash
just s   # status
just t   # dev-tests
just d   # dev-check
just v   # dev-check
just a   # about
```

---

## API Servers

just-silo includes a two-tier HTTP API:

### Internal API (Development)

```bash
just api-internal
# Starts on http://127.0.0.1:3001
```

Features:
- Full command introspection
- Real-time SSE streams
- Localhost only

### External API (Remote Control)

```bash
SILO_API_TOKEN=secret just api-external
# Starts on http://0.0.0.0:3000
```

Features:
- Minimal surface area
- Auth required (`X-Silo-Token`)
- Verb allowlist

### Both APIs

```bash
just api-start
just api-status
```

---

## Agent System

### Built-in Agents

| Agent | Purpose |
|-------|---------|
| `tidy-first-agent` | Workspace hygiene |
| `code-review-agent` | Code review |

### Running Agents

```bash
# Check agent status
just agent-status

# Run tidy agent
just agents-tidy "check"
just agents-tidy "run"

# Run code review
just agents-cr "scan --pr 123"
```

### Creating New Agents

```bash
# Create agent from template
just agent-create my-agent mounted

# Invoke agent
just agent-invoke my-agent
```

---

## Data Pipeline

### JSONL Format

All data is stored in JSONL (JSON Lines):

```jsonl
{"id": "1", "value": "foo"}
{"id": "2", "value": "bar"}
{"id": "3", "value": "baz"}
```

### Schema Validation

Define your schema in `schema.json`:

```json
{
  "type": "object",
  "required": ["id", "value"],
  "properties": {
    "id": { "type": "string" },
    "value": { "type": "string" }
  }
}
```

### Query with jq

```bash
# Filter data
just query filter

# Aggregate
just query summarize

# Export
just query export > output.json
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SILO_DIR` | `.` | Silo directory |
| `SILO_API_PORT` | `3000` | API port |
| `SILO_API_TOKEN` | - | External API token |
| `TD_DIR` | `.todos` | TD database dir |

### Justfile Settings

```just
set shell := ["bash", "-o", "pipefail", "-c"]
set positional-arguments := true
```

---

## Troubleshooting

### "Command not found"

```bash
# Check just is installed
just --version

# List available recipes
just --list
```

### "Schema validation failed"

```bash
# Check schema
cat schema.json | jq .

# Validate sample
echo '{}' | jq -f schema.json
```

### "Agent not responding"

```bash
# Check agent status
just agent-status

# Check markers
ls -la agents/*/markers/
```

---

## Advanced

### Custom Recipes

```just
# Custom recipe in justfile
my-task arg:
    @echo "Custom task: {{arg}}"
    @./my-script.sh {{arg}}
```

### Multi-Agent Coordination

Agents communicate via marker files:

```
markers/
├── request/    # What to do
├── done/       # What's complete
├── error/      # What failed
└── state/      # Current state
```

### Gamma Loops

Self-monitoring and self-correction:

```bash
just agents-tidy "check"   # Quick check
just agents-tidy "run"     # Auto-correct
```

---

## See Also

- [README.md](README.md) - Project overview
- [Silo-Manual.md](Silo-Manual.md) - Full manual
- [Silo-Philosophy.md](Silo-Philosophy.md) - Why it works
- [playbooks/](playbooks/) - Usage patterns
