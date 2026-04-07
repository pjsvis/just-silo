# Debrief: Justfile Refactor Gamma-Loop

## What Happened

Session on justfile refactor. Goal: clean `--list` output with groups, comments, aliases.

### First Attempt (Failed)
- Tried to rewrite entire justfile with `write`
- Lost 27 lines of comments and section headers
- `git diff` showed the damage

### Second Attempt (Research + Experiment)
- Upgraded to just 1.49.0
- Created `/tmp/just-experiment/` subfolder for testing
- Found: `[group: "name"]` syntax works (quotes required)
- Found: Comments must be immediately before recipe (no blank line)
- Found: Groups work but only with quotes

### Third Attempt (Success)
- Applied findings incrementally
- Committed frequently
- Result: clean organized justfile

## What Worked

1. **Subfolder experimentation** - Low risk, high signal
2. **Frequent commits** - Can always roll back
3. **Research before code** - GitHub issues, changelog, man page
4. **Incremental changes** - `edit` not `write`

## What Didn't Work

1. **Full rewrite with `write`** - Lost comments
2. **Assuming syntax** - Had to experiment to find `[group: "name"]`
3. **Premature optimization** - Groups seemed complex until tested

## For Next Session

- Read: `playbooks/just-playbook.md` (updated with groups pattern)
- Do: `td start <next-issue>`
- Avoid: Full rewrites with `write` - use `edit` instead
- Tip: Upgrade dependencies (`brew upgrade just`) before assuming features don't exist
