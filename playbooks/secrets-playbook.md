# Secrets Management Playbook

*Using skate for secrets in just-silo*

---

## Policy

**No secrets in code, docs, or commits.**

Secrets stay in skate. Code references keys, not values.

---

## Quick Start

```bash
# Set a secret
skate set GITHUB_TOKEN "ghp_xxxxx"

# Get a secret (for scripts)
skate get GITHUB_TOKEN

# List keys (no values)
skate list
```

---

## Usage Patterns

### 1. Scripts retrieve secrets at runtime

```bash
#!/usr/bin/env bash
TOKEN=$(skate get GITHUB_TOKEN)
curl -H "Authorization: Bearer $TOKEN" https://api.github.com/...
```

### 2. Environment variables

```bash
# In shell
export $(skate get SOME_KEY | xargs)

# In justfile
my-task:
    @GITHUB_TOKEN=$(skate get GITHUB_TOKEN) ./scripts/my-script.sh
```

### 3. CI/CD

```yaml
# .github/workflows/deploy.yml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  # Set via GitHub UI: Settings → Secrets
```

---

## What NOT to Do

| Anti-Pattern | Why | Fix |
|-------------|-----|-----|
| `TOKEN="ghp_xxx"` in script | Leaked to repo | `skate get TOKEN` |
| `export TOKEN=xxx` in .env | Same problem | Use skate |
| Committing .env files | Breach waiting | Add to .gitignore |
| Logging secrets | Leaked to output | Use `***` in output |

---

## Skate Commands

| Command | Purpose |
|---------|---------|
| `skate list` | Show all keys (no values) |
| `skate get <key>` | Get value |
| `skate set <key>` | Set value (interactive) |
| `skate delete <key>` | Remove key |
| `skate export` | Export all as shell vars |

---

## GitHub Actions Integration

1. Add secrets in GitHub UI:
   - Repository → Settings → Secrets and variables → Actions
   - New repository secret

2. Reference in workflow:
   ```yaml
   env:
     MY_SECRET: ${{ secrets.MY_SECRET }}
   ```

3. skate can sync with GitHub secrets:
   ```bash
   skate sync github
   ```

---

## Local Development

```bash
# Install skate
brew install skate

# Initialize (creates ~/.skate/)
skate init

# Set your first secret
skate set GITHUB_TOKEN "ghp_xxxxx"
```

---

## Detection

If a secret is accidentally committed:

1. **Immediately rotate the secret** (in GitHub UI or skate)
2. **Remove from git history:**
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch <file>' HEAD
   ```
3. **Push with force:**
   ```bash
   git push origin --force
   ```

---

## Enforcement

This repo uses GitHub's secret scanning:

- Push protection blocks commits with detected secrets
- Secret scanning alerts for found secrets

---

## Summary

```
Code:     References keys only
Secrets:  In skate, not in repo
CI/CD:    GitHub Secrets
Local:    skate get <key>
```

**Key principle: Retrieve at runtime, never hardcode.**

---

## Known Issue: Badger Lock Contention on Shell Init

### Symptom

```
Cannot acquire directory lock on "~/Library/Application Support/charm/kv/default".
Another process is using this Badger database. error: resource temporarily unavailable
```

Appears on reboot or when multiple shell sessions start simultaneously. API keys silently fail to load, requiring manual `source ~/.zshrc` to recover.

### Root Cause

Skate uses Badger (an embedded KV store) with an exclusive file lock. Multiple `skate get` calls in `.zshrc` race for the lock when parallel shells initialize — the losers get empty values.

This affects any embedded database (Badger, BoltDB, LevelDB, SQLite) used from shell init where concurrent process spawning is common (multiple tabs, tmux panes, login shells on boot).

### Fix: Cache Skate Keys to File

Replace individual `skate get` calls in `.zshrc` with a cached read:

```bash
# api keys are stored in Charm's Skate (cached to avoid Badger lock contention)
SKATE_CACHE="$HOME/.skate_env"
if [[ ! -f "$SKATE_CACHE" || $(find "$SKATE_CACHE" -mmin +60 -print) ]]; then
  skate list 2>/dev/null | sed 's/\t/=/' | sed 's/^/export /' > "$SKATE_CACHE"
fi
source "$SKATE_CACHE"
```

This reads from skate at most once per hour and sources a flat file on every shell init — no lock contention, no race conditions.

### Maintenance

- **After adding/changing a key:** `rm ~/.skate_env` then open a new shell
- **Force refresh:** `rm ~/.skate_env && source ~/.zshrc`
- **Cache lifetime:** 60 minutes (adjust `-mmin +60` as needed)
