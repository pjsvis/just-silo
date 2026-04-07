# Brief: Justfile Refactor

## Problem

Justfile refactor from noun-verb migration lost:
- 27 lines of comments and section headers
- Descriptive comments after recipes
- Helper recipes for sub-command discovery

Current state: 43 flat recipes, no organization, missing `help` without args.

## Proposed Solution

1. **Add groups** for organization in `just --list`
2. **Fix `help`** to work without arguments
3. **Consolidate glow** fallbacks to `about.sh`
4. **Add aliases** for common commands
5. **Move complex logic** (`dev-check`) to script
6. **Restore lost comments** from git diff

## Status

- [ ] Create td task
- [ ] Add groups
- [ ] Fix help
- [ ] Consolidate glow
- [ ] Add aliases
- [ ] Move dev-check
- [ ] Restore comments
- [ ] Test
- [ ] Commit
