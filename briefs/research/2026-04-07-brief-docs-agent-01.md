# Brief: docs-agent — Documentation Sync

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P2  

---

## Problem Statement

Documentation drifts from code over time. Commands change, output formats differ, examples become stale. Humans forget to update docs; agents don't know what changed.

---

## Proposed Solution

**docs-agent** watches for code changes and flags or fixes doc inconsistencies:

1. **Passive mode:** Flag docs that reference changed code
2. **Active mode:** Auto-update simple doc references

---

## Requirements

### Detection Logic

```typescript
interface DocCheck {
  // For each *.ts, *.sh file changed:
  findReferencedDocs: (file: string) => string[]
  // Find docs that mention the file/function/command
  
  checkConsistency: (doc: string, ref: FileRef) => Issue[]
  // Compare doc content to actual code
  
  autoFixable: (issue: Issue) => boolean
  // Can we auto-fix this?
}
```

### What Gets Checked

| File Type | Checks |
|-----------|--------|
| `.ts` source | References in `playbooks/*.md`, `README.md` |
| `justfile` | Commands in `playbooks/*.md` |
| `scripts/*` | Usage examples in `playbooks/*.md`, `README.md` |
| `src/*.ts` | API examples in `README.md`, `playbooks/` |

### Issue Types

| Issue | Auto-fixable? |
|-------|---------------|
| Command output format changed | ⚠️ Maybe |
| Function renamed, doc still uses old name | ❌ Manual |
| Missing parameter in example | ❌ Manual |
| Dead link | ✅ Yes |
| Outdated version number | ✅ Yes |

---

## User Interface

### Silent Mode (Passive)

```bash
# docs-agent watches, reports via marker file
cat markers/docs-agent-report.md
# ## Issues Found
# - README.md: 'td init' output format outdated
# - playbooks/api.md: Function 'foo' renamed to 'bar'
```

### Active Mode

```bash
just docs-agent --fix    # Apply auto-fixable changes
just docs-agent --report # Generate report only
just docs-agent --watch  # Watch mode (long-running)
```

### td Integration

```bash
# When docs drift detected:
td log "docs-agent: Flagged 3 doc inconsistencies" --blocker

# After docs fixed:
td log "docs-agent: Fixed auto-fixable issues" --result
```

---

## File Structure

```
just-silo/
├── agents/
│   └── docs-agent/
│       ├── src/
│       │   ├── index.ts        # Entry point
│       │   ├── detector.ts     # Change detection
│       │   ├── checker.ts      # Consistency checking
│       │   ├── fixer.ts        # Auto-fix logic
│       │   └── reporter.ts     # Report generation
│       ├── justfile
│       └── README.md
└── playbooks/
    └── docs-agent-playbook.md
```

---

## Implementation Notes

1. **Parse justfile** — Extract commands and their outputs
2. **Regex match** — Find doc references to functions/commands
3. **LLM for complex checks** — Some issues need judgment
4. **Watch mode** — Use `fs.watch` or `inotifywait`

---

## Acceptance Criteria

- [ ] Detects changed source files
- [ ] Finds referencing documentation
- [ ] Flags inconsistencies
- [ ] Auto-fixes dead links and version numbers
- [ ] Generates report in `markers/docs-agent-report.md`
- [ ] Integrates with td (logs findings)
- [ ] Playbook documents usage

---

## Priority Rationale

P2 not P1: Review-agent is higher priority (blocks the workflow). docs-agent is valuable but drift is survivable.

---

## Related

- `briefs/research/2026-04-07-brief-review-agent-01.md` — review-agent
- `briefs/research/2026-04-07-brief-td-api-testing-01.md` — test-agent
