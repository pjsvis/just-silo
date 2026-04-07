# Playbook: WatchExec — File Watching

**Automatic command execution on file changes.**

---

## Why WatchExec?

| Feature | Benefit |
|---------|---------|
| **Kernel events** | Fast, no polling |
| **Rust** | Small binary, native speed |
| **Simple** | `watchexec <cmd>` just works |
| **Recommended** | Marcus (td author) uses it |

---

## Installation

```bash
brew install watchexec
```

Verify:
```bash
watchexec --version
```

---

## Core Syntax

```bash
watchexec [OPTIONS] [COMMAND...]
```

### Essential Options

| Option | Purpose |
|--------|---------|
| `-e, --exts` | File extensions to watch |
| `-w, --watch` | Specific paths to watch |
| `-i, --ignore` | Patterns to ignore |
| `-r, --restart` | Restart on change (for servers) |
| `-c, --clear` | Clear screen between runs |
| `-s, --stop-signal` | Signal to send (for restart) |

---

## Common Patterns

### Development

```bash
# Run tests on TS/JS changes
watchexec -e ts,tsx,js bun test

# Run linter on changes
watchexec -e ts,tsx -- bun run lint

# Clear screen, then build
watchexec -c -e ts,tsx -- bun run build
```

### just-silo Specific

```bash
# Watch and show trends
watchexec -e jsonl just trend

# Regenerate dashboard
watchexec -e jsonl just trend-dashboard

# Auto-tidy on brief changes
watchexec -e md --ignore 'briefs/archive/*' just agents tidy check

# Watch td files
watchexec -w .todos -- td status
```

### Server Development

```bash
# Restart API server on changes
watchexec -r bun run src/silo-api-server.ts

# With port
PORT=8080 watchexec -r bun run src/silo-api-server.ts
```

### Shell Commands

```bash
# Echo when file changes
watchexec -e jsonl -- echo "Data changed!"

# Multiple commands
watchexec -e jsonl -- "just trend && just trend-dashboard"
```

---

## just-silo Commands

```bash
just watch-tests       # Run tests on TS/JS changes
just watch-trend      # Show trends in terminal
just watch-dashboard  # Regenerate dashboard HTML
```

---

## Filtering

### By Extension

```bash
# Only .ts and .tsx files
watchexec -e ts,tsx bun test

# Only .json files
watchexec -e json just status
```

### By Path

```bash
# Watch specific directories
watchexec -w src -w tests -- bun test

# Watch specific file
watchexec -w justfile -- just verify
```

### By Pattern (Ignore)

```bash
# Ignore node_modules
watchexec --ignore 'node_modules/*' bun test

# Ignore archive
watchexec -e md --ignore 'archive/*' just agents tidy check

# Multiple ignores
watchexec --ignore '*.log' --ignore '.git/*' --ignore 'node_modules/*' bun test
```

---

## Signals and Restart

### Restart Pattern (for servers)

```bash
# Auto-restart on changes
watchexec -r bun run src/server.ts

# Custom restart signal
watchexec -r -s SIGTERM bun run server.ts
```

### No-Restart (one-shot)

```bash
# Run once, then exit
watchexec -n bun test

# Or without -r (default)
watchexec bun test
```

---

## Troubleshooting

### "Command not found"

```bash
# Use full path if needed
watchexec -- /usr/local/bin/bun test

# Or
PATH="/usr/local/bin:$PATH" watchexec bun test
```

### High CPU usage

```bash
# Ignore common patterns
watchexec --ignore '*.swp' --ignore '*.tmp' --ignore '.git/*' bun test
```

### Not watching subdirectories

```bash
# Explicitly watch subdirs
watchexec -w src -w tests -w scripts -- bun test
```

---

## Cron vs WatchExec

| Mode | Use Case |
|------|----------|
| **WatchExec** | Active development, terminal open |
| **Cron** | Scheduled ops, no terminal needed |

Example:
```bash
# During development: watch
watchexec -e jsonl just trend-dashboard

# At night (via cron): snapshot
0 2 * * * cd /path && just trend-dashboard
```

---

## Quick Reference

```bash
# Watch extensions
-e ts,tsx,js,jsx

# Watch paths
-w src -w tests

# Ignore patterns
--ignore 'node_modules/*'

# Restart on change
-r

# Clear screen
-c

# Stop signal
-s SIGTERM

# One-shot (no restart)
-n
```

---

## Related

- `REPOS.md` — External dependencies
- `playbooks/agent-ops-playbook.md` — Agent coordination
- `scripts/watch-*` — just-silo watcher scripts
