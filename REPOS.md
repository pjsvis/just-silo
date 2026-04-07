# Repositories

This project depends on the following external tools and repositories.

---

## Core Dependencies

| Tool | Repository | Purpose | License |
|------|------------|--------|---------|
| **td** | https://github.com/marcus/td | Task management and agent coordination | MIT |
| **sidecar** | https://github.com/marcus/sidecar | Terminal IDE with td integration | MIT |
| **just** | https://github.com/casey/just | Command runner (justfile) | MIT |

---

## Installation

### td

```bash
brew install marcus/tap/td
# or
go install github.com/marcus/td@latest
```

### sidecar

```bash
brew install marcus/tap/sidecar
```

### just

```bash
brew install just
```

---

## Local Copies

| Tool | Local Path | Notes |
|------|------------|-------|
| sidecar | `~/Dev/GitHub/sidecar` | Cloned for reference |

---

## Configuration

### td RAM Disk Setup

td uses SQLite which can corrupt under concurrent access. We run it on a RAM disk:

```bash
# Setup
just td-ramdisk

# This creates:
# - /Volumes/TD-RAMDisk/ (512MB RAM disk)
# - .todos -> /Volumes/TD-RAMDisk/just-silo-dev (symlink)
# - td-root -> /Volumes/TD-RAMDisk/just-silo-dev (for sidecar)
```

See `playbooks/td-playbook.md` for full details.

---

## Sync / Upstream

- Check for updates periodically: `brew upgrade` or `go install @latest`
- Report issues to respective repositories
