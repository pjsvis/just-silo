# {{name}} Silo

{{description}}

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

```
{{name}}/
├── .silo              # Silo manifest (configuration)
├── justfile           # Silo vocabulary (commands)
├── schema.json        # Data validation schema
├── queries.json       # Named jq filters
├── harvest.jsonl      # Raw input data
├── data.jsonl         # Validated working set
├── quarantine.jsonl    # Invalid entries
├── final_output.jsonl # Archived output
├── process.sh         # Domain transformation
├── pipeline.json      # Pipeline definition
└── markers/           # Multi-agent coordination
```

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
