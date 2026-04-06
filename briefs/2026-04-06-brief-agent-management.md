# Brief: Agent Management Pattern

## Context

**Question:** How do we define and manage agents or sub-agents in just-silo?

**Insight:** Agents are just silos with a `.agent` manifest. The silo framework *is* the agent management system.

## The Pattern

```
AGENT = SILO + .agent manifest + coordinate.sh
```

| Component | Purpose |
|-----------|---------|
| `.silo` | Domain rules (what it knows) |
| `.agent` | Agent identity (what it is) |
| `justfile` | Capabilities (what it does) |
| `coordinate.sh` | Communication protocol |
| `markers/` | State coordination |

## Agent Types

### 1. Standalone Agent

Runs independently. Owns its workflow.

```
my-agent/
├── .agent
├── .silo
├── justfile
└── coordinate.sh  # May be minimal
```

### 2. Mounted Agent (Sub-Agent)

Runs within parent context. Inherits parent markers.

```
parent-silo/
├── agents/
│   └── code-review/
│       ├── .agent
│       └── ...
└── markers/  # Shared with parent
```

### 3. Tool Agent

Stateless. Given input, produces output. No coordination needed.

```
my-tool/
├── .agent  # type: "tool"
└── run.sh
```

## .agent Manifest Schema

```json
{
  "name": "string",
  "type": "standalone | mounted | tool",
  "role": "string",
  "version": "semver",
  "inputs": {
    "format": "json | jsonl | text",
    "schema": "json-schema-uri | inline"
  },
  "outputs": {
    "format": "json | jsonl | text",
    "schema": "json-schema-uri | inline"
  },
  "parent": {
    "required": true | false,
    "protocol": "markers | pipe | http"
  },
  "peers": ["agent-name"],
  "resources": {
    "timeout": "seconds",
    "memory": "mb",
    "parallel": true | false
  }
}
```

## Coordinate Protocol

### Marker Files Pattern

```
silo/
├── markers/
│   ├── request/        # What to do
│   ├── done/           # What's complete
│   ├── error/          # What failed
│   └── state/         # Current state
└── .agent
```

### Request/Response Flow

```
PARENT                           CHILD
  |--- write markers/request --->|
  |<-- write markers/done --------|
  |     (or error)               |
```

### State Machine

```
IDLE → REQUESTED → RUNNING → DONE
                      ↓
                   ERROR → RETRY (max 3)
```

## Agent Lifecycle

| Stage | Parent Action | Child Action |
|-------|---------------|--------------|
| Create | `just agent:create <name>` | - |
| Mount | `just agent:mount <name>` | Read markers/ |
| Invoke | Write to markers/request | Read, process |
| Complete | Read markers/done | Write to markers/done |
| Error | Read markers/error | Write error, retry |
| Unmount | `just agent:unmount <name>` | Clean markers/ |

## Multi-Agent Coordination

### Fan-Out (One → Many)

```
parent/
├── markers/request/all    # Single request
└── agents/
    ├── agent-a/markers/done
    ├── agent-b/markers/done
    └── agent-c/markers/done
```

### Fan-In (Many → One)

```
parent/
├── markers/request/      # N requests
└── markers/done/         # N completions
    ├── agent-a
    ├── agent-b
    └── agent-c
```

### Pipeline (Chain)

```
agent-1 → markers/done → agent-2 → markers/done → agent-3
```

## Implementation in just-silo

### Template: agents/

```
template/
├── agents/
│   └── _agent/           # Agent template
│       ├── .agent
│       ├── .silo
│       ├── justfile
│       ├── coordinate.sh
│       ├── run.sh
│       └── markers/
│           ├── request/
│           ├── done/
│           ├── error/
│           └── state/
```

### justfile Recipes

```just
# Create agent from template
agent:create name:
    cp -r {{AGENTS_DIR}}/_agent "agents/{{name}}"
    # Initialize markers/

# Mount agent (set up coordination)
agent:mount name:
    mkdir -p markers/{{name}}
    ln -sf ../markers/{{name}} "agents/{{name}}/markers/parent"

# Invoke agent
agent:invoke name input:
    echo '{{input}}' > markers/{{name}}/request/ payload.jsonl
    just agent:wait {{name}}

# Wait for completion
agent:wait name timeout=300:
    # Poll markers/{{name}}/done until present or timeout
```

## Code Review Agent Specifics

### Role
Reviews code changes for FAFCAS compliance and auto-hardens.

### Inputs
- Target: PR number, branch, diff, or file path
- Scope: full | incremental | single
- Mode: review | harden | both

### Outputs
- FAFCAS report (Markdown)
- Hardening patches (optional)
- Summary (JSON)

### Coordinate with just-silo

```bash
# Mount in any silo
just agent:mount code-review

# Request review
just agent:invoke code-review --pr 123 --scope incremental

# Get report
cat markers/code-review/done/report.md
```

## Open Questions

1. **Lifecycle**: Who kills hung agents?
2. **Resources**: How to enforce memory/timeout limits in bash?
3. **Debugging**: How to inspect agent state?
4. **Composition**: How to chain agents (output → input)?

## Related

- `briefs/2026-04-06-brief-code-review-agent.md` — Specific implementation
- `briefs/2026-04-06-brief-silo-cadence.md` — Agent cadence
- `playbooks/silo-agent-playbook.md` — Agent mounting
