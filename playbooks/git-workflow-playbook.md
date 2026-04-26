---
date: 2026-04-26
tags: [playbook, git, workflow, worktree, branching]
---

# Git Workflow Playbook

## Purpose
Prevent branch divergence and merge conflicts by keeping a clean, predictable Git workflow across two worktrees.

## Setup

Two worktrees share the same underlying repository:

| Worktree | Branch | Purpose |
|----------|--------|---------|
| `just-silo/` | `main` | Read-only. Pull only. |
| `just-silo-dev/` | Feature branches | All development work. |

## Rules

### 1. `just-silo/` is read-only
- Only `git pull` or `git merge --ff-only` here.
- Never commit, never create branches, never work in this directory.
- Its sole purpose is a clean reference copy of `main`.

### 2. All work happens in `just-silo-dev/`
- Create a **new branch** for every task or PR.
- Use prefixes: `feat/`, `fix/`, `docs/`, `refactor/`.
- **Never reuse merged branches.** If a branch has been merged via PR, delete it. Create a new branch for the next chunk of work.

### 3. Branch lifecycle: create → work → push → PR → merge → delete

```bash
# In just-silo-dev/
git checkout -b feat/what-you-are-building

# Work, commit, iterate
git push -u origin feat/what-you-are-building

# Open PR on GitHub, merge via GitHub UI
# Then clean up:
git checkout main
git branch -d feat/what-you-are-building
git push origin --delete feat/what-you-are-building
```

### 4. Sync both worktrees after every merge

```bash
# In just-silo/
git pull origin main

# In just-silo-dev/
git checkout main
git pull origin main
```

### 5. Never force-push main
- If main diverges from origin, reset it to match origin first, then re-create your feature branch.
- Force-push is acceptable **only** for feature branches you own and no one else has checked out.

## Why This Works

The previous failure mode: a long-lived `pr/two-tier-api-agents-gamma` branch was merged via PR #2, then kept alive with 82 more commits. This created a merge-history fork that could not be fast-forwarded and required force-pushing main.

The fix: **branches are disposable.** They live for one PR and die. Worktrees are directories, not branch containers.

## Two Active Agents: Human + PR Review Agent

This workflow supports two active committers on the same repository: you (human) and the PR review agent.

### td stays in branch mode
- `td` tracks issues in its local database. It does **not** create git worktrees.
- Your working directory is always `just-silo-dev/`. `td` records what you're doing there; it does not provision parallel checkouts.
- Mapping transient issue state to persistent directories creates zombie worktrees. Don't.

### PR review agent uses temporary worktrees
- When the agent finds fixable review comments, it creates a **temporary worktree**, fixes, pushes, then removes it.
- The agent never touches `just-silo-dev/` or `just-silo/`.

```bash
# Agent pattern: surgical checkout
PR=42
TMP="../just-silo-review-$PR"
git worktree add "$TMP" "origin/pull/$PR/head"
cd "$TMP"
# ... apply fixes ...
git push origin "HEAD:refs/heads/pr-$PR-fixes"
git worktree remove "$TMP"
```

### Coordination flow

| Step | Human | PR Review Agent |
|------|-------|----------------|
| 1 | Create `feat/new-thing` in `just-silo-dev/`, push, open PR | — |
| 2 | Switch to next task or wait | Monitors PR comments |
| 3 | `git pull` in `just-silo-dev/` to get agent's fixes | Creates temp worktree, fixes, pushes to PR branch |
| 4 | Review agent's changes, continue work | Removes temp worktree, done |

### Rule: only one persistent dev worktree
- `just-silo/` — read-only reference
- `just-silo-dev/` — human workspace
- All other worktrees are **temporary** and must be removed after use

## Invoking the PR Review Agent

The harness has built-in PR review tools. The deprecated `agents/pr-review-agent/` script has been removed.

### Via the agent harness (preferred)

```
# Start monitoring a PR for review comments
pr_watch <pr-number>

# Check monitoring status
pr_status

# Auto-fix review issues
pr_fix_issues

# Escalate to human when auto-fix fails
pr_escalate
```

### Via just recipes

```bash
# Discover your open PRs and prepare to watch them
just pr-watch-open

# Watch a specific PR
just pr-watch <pr-number>

# Summarize review state via gh CLI
just pr-review <pr-number>
```

### What the agent does

1. Polls GitHub for new review comments on the PR
2. Categorizes by severity: `MUST_FIX`, `SHOULD_FIX`, `SUGGESTION`, `NOISE`
3. Attempts auto-fix for `MUST_FIX` and `SHOULD_FIX`
4. Pushes fixes back to the PR branch
5. Stops cleanly if the PR is merged/closed (404 handling)

## Common Commands

```bash
# Create feature branch in dev worktree
cd ~/Dev/GitHub/just-silo-dev
git checkout -b feat/new-thing

# Push and open PR
git push -u origin feat/new-thing

# After PR merges, clean up
git checkout main
git branch -d feat/new-thing
git push origin --delete feat/new-thing

# Sync both worktrees
cd ~/Dev/GitHub/just-silo && git pull
cd ~/Dev/GitHub/just-silo-dev && git pull
```
