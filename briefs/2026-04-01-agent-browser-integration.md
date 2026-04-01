# Brief: agent-browser Integration for silo_launch

**Date:** 2026-04-01
**Task:** td-ebcc60
**Type:** Feature Extension
**Priority:** High

---

## Problem Statement

silo_launch currently generates social media drafts using only the pi agent. To improve content quality and enable actual social posting, we need web scraping and API access.

## Solution

Integrate **agent-browser** into silo_launch for:

1. **Scraping** — Fetch current data from GitHub, HN, Reddit for intelligence
2. **API Access** — Fetch metrics (stars, forks, trending topics)
3. **Future** — Browser automation for actual posting

## Dependencies

- [agent-browser](https://github.com/m那里那里那里那里那里那里那里那里那里那里那里那里那里那里那里那里那里那里) — CLI browser automation
- `curl` + `jq` — API calls
- `glow` — Markdown rendering
- `gum` — TUI components

## Proposed Implementation

### 1. New Recipes

```bash
just scrape    # Scrape URLs from context/targets.md
just fetch     # Fetch API metrics
just intel     # Combined intelligence gathering
```

### 2. Script: scrape.sh

Uses agent-browser to:
- Read URLs from `context/targets.md`
- Open each URL
- Capture accessibility snapshot
- Save to `scratchpad/`

### 3. Script: fetch.sh

Uses curl to:
- Fetch GitHub API for repo metrics
- Parse stars, forks, issues
- Save to `scratchpad/api_metrics.json`

### 4. Updated context/targets.md

```markdown
## Scraping Targets
| Target | URL | Purpose |
|--------|-----|---------|
| just-silo stars | github.com/pjsvis/just-silo | Current engagement |

## API Endpoints
| API | Purpose |
|-----|---------|
| api.github.com/repos/... | Full repo stats |
```

## Files to Create

| File | Purpose |
|------|---------|
| `scripts/scrape.sh` | agent-browser scraping |
| `scripts/fetch.sh` | API metrics |

## Files to Modify

| File | Changes |
|------|---------|
| `justfile` | Add scrape, fetch, intel recipes |
| `context/targets.md` | Add scraping/API targets |
| `README.md` | Document new capabilities |

## Success Criteria

- [x] `just scrape` captures page snapshots ✅
- [x] `just fetch` retrieves GitHub metrics ✅
- [x] `just intel` combines both ✅
- [x] Output saved to scratchpad/ ✅

## Related

- `briefs/2026-04-01-just-silo-ui-demo.md` — Original launch workflow
- `silo_launch/` — Working directory (gitignored)
