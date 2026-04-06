# silo_launch

Social media launch prep for just-silo using gum/glow HITL workflow + pi agent + browser automation.

## Quick Start

```bash
cd silo_launch
just intel     # Scrape + fetch (build intelligence)
just plan      # pi agent generates 3 drafts based on intel
just review    # Glow renders, gum selects & confirms
just execute   # Write to output/
```

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  just intel                                             │
│  ├─> agent-browser scrapes pages                      │
│  └─> curl fetches API metrics                        │
│      └─> writes to scratchpad/                     │
│                                                         │
│  just plan                                             │
│  ├─> pi agent reads intel                            │
│  └─> Generates 3 drafts (HN, X, Reddit)            │
│      └─> Writes to scratchpad/drafts.md            │
│                                                         │
│  just review                                           │
│  ├─> glow renders drafts                              │
│  ├─> gum choose selects draft                         │
│  └─> gum confirm approves                             │
│                                                         │
│  just execute                                          │
│  └─> Writes approved content to output/                │
└─────────────────────────────────────────────────────────┘
```

## Intelligence Tools

| Command | Tool | Output |
|---------|------|--------|
| `just scrape` | agent-browser / curl | Page snapshots |
| `just fetch` | curl | API metrics (GitHub) |
| `just intel` | Both | Combined intel |

## Data Files (JSONL)

| File | Format | Purpose |
|------|--------|---------|
| `scratchpad/api_metrics.jsonl` | JSONL | GitHub metrics (append) |
| `scratchpad/drafts.md` | Markdown | Agent-generated drafts |
| `output/final_launch_schedule.jsonl` | JSONL | Approved posts (append) |
| `logs/audit.log` | Text | Full audit trail |
| `queries.json` | JSON | Named jq filters |

**JSONL pattern:** Streaming, appendable, scalable. Process with `jq`.

### Named Queries

```bash
# Latest metrics
jq -c -f queries.json filters.latest_metrics jq < scratchpad/api_metrics.jsonl

# All approved posts
jq -c 'select(.status == "approved")' output/final_launch_schedule.jsonl
```

## Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| `pi` | AI agent for draft generation | npm |
| `agent-browser` | Browser automation | npm |
| `glow` | Markdown renderer | brew |
| `gum` | TUI components | brew |
| `curl` | API fetching | system |
| `jq` | JSON parsing | brew |

## Success Metrics

- Zero browser/UI bloat
- Intel → Draft in < 60 seconds
- Full audit trail in `logs/audit.log`
