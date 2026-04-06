# Playbook: Dev Cycle — just-silo Development Process

**Purpose:** Capture how we work so agents (and humans) can repeat the process.

---

## Session Start

```bash
# 1. Start new td session
td usage --new-session

# 2. Read current state
td next              # What's next
git log --oneline -3 # Recent commits
cat SESSION-STATE.md 2>/dev/null || true
```

---

## Development Rhythm

### The EPIC Loop

```
┌─────────────────────────────────────────────────────────────┐
│ START                                                         │
│   td start <issue-id>                                        │
│   git status                                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ IMPLEMENT                                                      │
│   Edit files                                                   │
│   Test locally (just verify, just self-test)                   │
│   Log progress: td log "Did X" --result                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ COMMIT                                                         │
│   git add <changed-files>                                     │
│   git commit -m "EPIC-X.Y: Description"                       │
│   td log <issue-id> "Completed" --result                      │
│   td review <issue-id>                                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ NEXT                                                           │
│   td next                                                      │
│   (repeat)                                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Commit Convention

Format: `TYPE: Short description`

| TYPE | Use |
|------|-----|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `chore:` | Maintenance, tooling |
| `docs:` | Documentation |
| `refactor:` | Code improvement |
| `EPIC-X.Y:` | EPIC implementation |

Examples:
```
feat: Add SSE streaming endpoints
EPIC-1.5: Data Stratification — scaffold vs throughput
chore: Add root justfile for project commands
docs: Update td-playbook with SQLite issue
```

---

## File Change Rules

### Templates (templates/basic/)

**Always validate before commit:**
```bash
jq empty templates/basic/.silo
jq empty templates/basic/schema.json
jq empty templates/basic/queries.json
```

**Test in isolation:**
```bash
rm -rf /tmp/test-silo
./scripts/silo-create test-silo --template basic
cd /tmp/test-silo
just verify
just self-test
```

### Scripts (scripts/, templates/basic/scripts/)

**Make executable:**
```bash
chmod +x scripts/*.sh
```

**Test standalone:**
```bash
./scripts/audit_log.sh test_event foo=bar
cat audit.jsonl
```

### Justfiles

**Avoid `.` in default parameter names:**
```just
# BAD
audit filter=(.event):

# GOOD  
audit filter=(".event"):
```

**Complex logic → separate script:**
```just
# BAD
lock:
    @MACHINE_ID=$(hostname -s)-$(whoami); jq ...

# GOOD
lock:
    @./scripts/workspace_lock.sh lock
```

---

## Validation Checklist

Before committing template changes:

- [ ] `jq empty .silo` passes
- [ ] `jq empty schema.json` passes
- [ ] `jq empty queries.json` passes
- [ ] Created test silo and ran `just verify`
- [ ] Scripts are executable (`chmod +x`)
- [ ] `.gitignore` covers throughput files

---

## The td Dance

### Adding Issues
```bash
# Batch add to avoid WAL lock
td add "EPIC-1.5: Data Stratification" --priority P2
td add "EPIC-1.6: _silo naming" --priority P2
# ... wait between adds if needed
```

### Working
```bash
td start <id>           # Begin
td log <id> "Did X"      # Progress
td log <id> "Blocked"    # Blocker
td log <id> "Done" --result # Complete
td review <id>           # Request review
```

### Review Gate
- You cannot approve your own work (by design)
- `--minor` flag allows self-review for trivial changes
- If td WAL locks, wait 1-2 seconds and retry

---

## Git Workflow

### Branch Model
- `dev` — Main development branch
- Feature branches for large changes: `feat/sse-streaming`

### Sync Before Commit
```bash
git fetch origin
git rebase origin/dev  # Keep history clean
```

### Push Strategy
```bash
git push origin dev  # After 2-3 commits, or end of session
```

---

## Common Patterns

### Adding a New Command to Justfile

1. Write the logic in a script first
2. Add recipe that calls the script
3. Add to help text
4. Test: `just <command>`
5. Commit with `feat:` prefix

### Adding a New Template File

1. Create in `templates/basic/`
2. Add to `.silo["#meta"]["stratification"]["scaffold"]`
3. Add to `.gitignore` (if throughput)
4. Document in README
5. Test: create test silo, verify file exists

### Fixing a Bug

1. `td add "Fix: description" --priority P1`
2. `td start <id>`
3. Write failing test first (if applicable)
4. Fix
5. Commit with `fix:` prefix
6. `td review <id>`

---

## Troubleshooting

### "No justfile found"
- You're not in a silo directory
- `cd templates/basic/` or check root has `justfile`

### "jq: parse error"
- JSON file has syntax error
- Run `jq empty <file>` to validate

### "td: database is locked"
- SQLite WAL contention
- Wait 1-2 seconds, retry
- Or symlink: `rm -rf .todos && ln -s ~/.config/.todos .todos`

### "just: Unknown start of token"
- Likely a `.` in recipe parameter
- Rename parameter to avoid dots

---

## Session End

```bash
# Review what was done
git log --oneline -5

# Update SESSION-STATE.md
cat > SESSION-STATE.md << 'EOF'
# Session State — DATE

## Committed Work
...

## TD Backlog
...

## Next Steps
...
EOF

# Push if meaningful
git push origin dev
```

---

## Related

- [td-playbook.md](td-playbook.md) — Task management
- [silo-builder-playbook.md](silo-builder-playbook.md) — Creating silos
- [debriefs-playbook.md](debriefs-playbook.md) — How to write debriefs
