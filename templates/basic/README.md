# {{name}} Silo

{{description}}

## Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|----------|
| _(underscore) | **Private** — local-only, not synced | `_experiment` |
| (none) | **Shared** — synced to The Register | `data-monitor` |

**Private silos** (`_name`):
- Not synced to The Register
- Not shared with other agents
- Machine-specific, local-only

**Shared silos** (`name`):
- Synced to The Register
- Discoverable by other agents
- Versioned and collaborative

## Quick Start

```bash
# Initialize the silo
just init

# Verify prerequisites
just verify

# Harvest and validate data
just harvest

# Process the data
just process

# Check status
just status

# Flush to output
just flush
```

## File Structure

### Data Stratification

Silo files are divided into two categories based on change frequency:

**Scaffold Files** (git-tracked, versioned, shared):
```
{{name}}/
├── .silo              # Silo manifest
├── justfile           # Silo vocabulary
├── schema.json        # Data validation
├── queries.json       # Named jq filters
├── process.sh         # Domain transformation
└── scripts/           # Utilities
```

**Throughput Files** (git-ignored, local, ephemeral):
```
{{name}}/
├── harvest.jsonl      # Raw input data
├── data.jsonl         # Validated working set
├── quarantine.jsonl    # Invalid entries
├── final_output.jsonl # Archived output
├── markers/           # Multi-agent coordination
├── pipeline.json      # Pipeline state
└── status.json        # Health status
```

> **Why?** Scaffold files define the silo contract. Throughput files are the "stuff" that flows through. Keeping them separate prevents git bloat and makes pipelines faster.

## Pipeline Phases

| Phase | Command | Purpose |
|-------|---------|---------|
| Mount | `cd silo/` | Enter the silo |
| Sieve | `just verify` | Check prerequisites |
| Harvest | `just harvest` | Ingest + validate |
| Process | `just process` | Transform data |
| Observe | `just status` | Check health |
| Flush | `just flush` | Archive output |

## Multi-Agent

```bash
just claim <stage>      # Own a stage
just wait <marker>      # Wait for upstream
just done <marker>      # Signal completion
just heartbeat          # Keep claims alive
```

## Configuration

Edit `.silo` to configure:
- `name`: Silo identifier
- `domain`: Problem domain
- `thresholds`: Alert thresholds
- `toolchain`: Required tools
