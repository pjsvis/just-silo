# Silo Operator Playbook

**For coordinating multiple agents in a silo.**

---

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

## Principles

1. **Agents share the silo, not the work**
2. **Dependencies prevent chaos**
3. **TTL prevents staleness**
4. **Manifest is source of truth**
