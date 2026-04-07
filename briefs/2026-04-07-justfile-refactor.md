# Brief: Justfile Refactor

## Problem

Justfile needed:
- Better organization in `--list`
- Comments that actually show
- Better help navigation
- Aliases for common commands

## Solution

### 1. Groups ✅
```just
[group: "silo"]
silo-verify:
    @cd templates/basic && just verify
```
Organizes `--list` output. Filter with `just --list --group silo`.

### 2. Recipe Comments ✅
```just
# Verify prerequisites  (shows in list)
silo-verify:
    @cd templates/basic && just verify
```
Must be immediately before recipe (no blank line) or inline.

### 3. Help Navigation ✅
```bash
just help              # Show topics
just help silo         # Show silo commands
just help agents       # List agents
```
Delegates to `scripts/help.sh`.

### 4. Aliases ✅
```just
alias s := status
alias t := dev-tests
alias d := dev-check
alias v := dev-check
alias a := about
```

### 5. Consolidated Glow ✅
`about.sh` handles files and directories. `docs-*` recipes use it.

### 6. Moved dev-check to Script ✅
Complex logic → `scripts/dev-check.sh`. Justfile stays thin.

## Status

- [x] Add groups
- [x] Fix recipe comments
- [x] Fix help
- [x] Add aliases
- [x] Consolidate glow
- [x] Move dev-check to script
- [x] Test
- [x] Commit

## Key Learnings

1. **Comments in `--list`:** Must be immediately before recipe (no blank line)
2. **Groups:** Syntax is `[group: "name"]` (quotes required)
3. **Subfolder testing:** Safer than editing main justfile
4. **Upgrade just:** Groups require just 1.49.0+
