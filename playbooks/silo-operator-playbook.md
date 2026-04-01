# Silo Operator Playbook

**For coordinating multiple agents in a silo.**

---

## The Reveal

**Multi-agent silos are pocket universes with shared rules.**

Agents coordinate via marker files. When agents are in, they can only do what the silo allows.

**You say the words. Just-silo coordinates them.**

## Multi-Stage Pattern

Agents work on different stages of the same pipeline:

```
Agent A (Stage 1): harvest → creates harvest.done
Agent B (Stage 2): waits for harvest.done → process
```

## Coordination Recipes

These recipes coordinate multi-agent workflows.

### lock

Create a marker file to claim a stage:

```just
lock marker:
    @mkdir -p markers
    @echo '{"agent":"$(AGENT_ID)","at":"'$(date -Iseconds)'"}' > markers/{{marker}}.lock
```

### is-locked

Check if a stage is claimed:

```just
is-locked marker:
    @test -f markers/{{marker}}.lock && echo "LOCKED" || echo "UNLOCKED"
```

### wait

Wait for a marker file:

```just
wait marker:
    @while [ ! -f markers/{{marker}}.lock ]; do sleep 5; done
    @echo "{{marker}} ready"
```

### done

Mark stage complete:

```just
done marker:
    @mv markers/{{marker}}.lock markers/{{marker}}.done
```

### cleanup

Remove stale locks (>1 hour):

```just
cleanup:
    @find markers/ -name "*.lock" -mmin +60 -delete
    @echo "Cleaned stale locks"
```

## Agent Workflows

### Agent A (Stage 1: Ingest)

```bash
just verify
just harvest
just lock harvest.done
```

### Agent B (Stage 2: Process)

```bash
just wait harvest.done
just verify
just process
just lock process.done
```

### Agent C (Stage 3: Flush)

```bash
just wait process.done
just flush
just clean
```

## Stage Manifest

For complex pipelines, define stages in `.silo-manifest`:

```json
{
  "name": "my-silo",
  "stages": [
    {"id": 1, "name": "ingest", "recipe": "harvest", "marker": "harvest.done"},
    {"id": 2, "name": "process", "recipe": "process", "depends_on": [1], "marker": "process.done"},
    {"id": 3, "name": "flush", "recipe": "flush", "depends_on": [2]}
  ]
}
```

## Directory Structure

```
silo/
├── markers/
│   ├── harvest.done     # Stage 1 complete
│   ├── process.done     # Stage 2 complete
│   └── flush.done       # Stage 3 complete
├── stages/
│   ├── ingested/
│   ├── processed/
│   └── output/
└── .silo-manifest
```

## Edge Cases

| Edge Case | Fix |
|-----------|-----|
| Crash mid-stage | TTL + cleanup |
| Race on claim | Atomic mkdir |
| Orphaned lock | `just cleanup` |
| Backpressure | Wait with timeout |

## Agent Integration

**Agents can be stages in a silo pipeline.**

just-silo supports invoking AI agents as pipeline stages via shebang scripts.

### Available Agents

| Agent | Invocation | Notes |
|-------|------------|-------|
| `pi` | `pi -p "task"` | Current agent (requires auth) |
| `claude` | `claude -p "task"` | Claude Code (requires auth) |
| `ollama` | `ollama run llama3 "task"` | Local (no auth needed) |

### Example: Agent Stage

```typescript
// stages/analyze.ts
#!/usr/bin/env bun

import { readFileSync, writeFileSync } from "node:fs";

const analyze = async () => {
  const data = readFileSync("data.jsonl", "utf-8");
  
  // Call pi agent to analyze
  const result = Bun.spawnSync(["pi", "-p", `Analyze: ${data}`], {
    stdout: "pipe",
    stderr: "pipe"
  });
  
  writeFileSync("analysis.txt", new TextDecoder().decode(result.stdout));
  console.log("✅ Analysis complete");
};

analyze();
```

### Example: justfile Recipe

```just
analyze:
    #!/usr/bin/env bun
    bun stages/analyze.ts
```

### Agent Stage Pattern

```
1. Agent reads input from data.jsonl
2. Agent processes (can call external services, APIs, etc.)
3. Agent writes output to analysis.txt
4. Pipeline continues
```

## Cross-Silo Communication

**Silos are isolated pocket universes, but can coordinate via events.**

### Pattern 1: Marker-Based (Simplest)

```bash
# silo_alpha signals completion
touch silo_alpha/markers/harvest.done

# silo_beta checks and reacts
just wait-silo silo_alpha harvest
```

### Pattern 2: Event Log

```jsonl
# silo_alpha/.events.jsonl
{"time":"2026-03-31T09:00:00Z","silo":"alpha","event":"harvest_complete","records":42}

# silo_beta reads events
jq '.silo == "alpha" and .event == "harvest_complete"' ../silo_alpha/.events.jsonl
```

### Pattern 3: Parent Orchestration

```json
// silo_orchestrator/.silo
{
  "name": "silo_orchestrator",
  "type": "workflow",
  "children": ["silo_alpha", "silo_beta"],
  "pipeline": [
    {"stage": "alpha_harvest", "silo": "silo_alpha", "action": "harvest"},
    {"stage": "beta_process", "silo": "silo_beta", "action": "process", "depends_on": "alpha_harvest"}
  ]
}
```

**Recommendation:** Start with marker-based. Add event log only when you need audit trail. Use parent orchestration only for complex multi-silo workflows.

## Event-Driven Silos

**Pattern: cron + watchexec = autonomous workflow**

```
┌─────────────────┐    cron     ┌─────────────────┐
│  Agent A        │ ──────────→│  input/         │ ← trigger
│  (web harvester)│            └────────┬────────┘
└─────────────────┘                     │ watch
                                        ↓
                               ┌─────────────────┐
                               │  watchexec      │
                               │  just ingest    │
                               └────────┬────────┘
                                        │
                                        ↓
                               ┌─────────────────┐
                               │  pipeline       │
                               │  ingest→clean   │
                               │  →process→flush│
                               └─────────────────┘
```

### Setup

```bash
# 1. Ensure watchexec is available
which watchexec  # Should return path

# 2. Create input directory
mkdir -p input/

# 3. Watch input folder — fires just ingest on new files
watchexec -w input/ just ingest

# 4. Optional: Watch data.jsonl for downstream processing
watchexec -w data.jsonl just process
```

### justfile Recipes

```just
# Watch input folder (requires watchexec)
watch-input:
    @which watchexec >/dev/null 2>&1 || (echo "⚠️  watchexec not installed"; exit 1)
    @echo "Watching input/ for changes..."
    watchexec -w input/ just ingest

# Watch data.jsonl for processing
watch-data:
    @which watchexec >/dev/null 2>&1 || (echo "⚠️  watchexec not installed"; exit 1)
    @echo "Watching data.jsonl for changes..."
    watchexec -w {{DATA_FILE}} just process

# Watch markers for live pipeline monitoring
watch-status:
    @which watchexec >/dev/null 2>&1 || (echo "⚠️  watchexec not installed"; exit 1)
    @echo "Watching markers/ for pipeline events..."
    watchexec -w markers/ just status
```

### Cron + Watcher Setup

```bash
# Example crontab: Agent A pulls data every hour
0 * * * * cd /path/to/silo && pi -p "Pull latest data from source and save to input/" >> /var/log/silo-cron.log 2>&1

# In another terminal: Watch for new files
watchexec -w input/ just ingest
```

### Common Patterns

| Pattern | Command | Use Case |
|---------|---------|----------|
| Input trigger | `watchexec -w input/ just ingest` | New data arrives |
| Data trigger | `watchexec -w data.jsonl just process` | Incremental processing |
| Markers trigger | `watchexec -w markers/ just status` | Live monitoring |
| Full rebuild | `watchexec -e jsonl just clean && just ingest` | Development |

### Graceful Degradation

If watchexec is not installed:
```just
watch-input:
    @which watchexec >/dev/null 2>&1 || (echo "⚠️  watchexec not installed: run brew install watchexec"; exit 1)
    watchexec -w input/ just ingest
```

**Note:** Event-driven silos require `watchexec` as a dependency. Add to `just deps` check.

## Principles

1. **Agents share the silo, not the work**
2. **Dependencies prevent chaos**
3. **TTL prevents staleness**
4. **Manifest is source of truth**
