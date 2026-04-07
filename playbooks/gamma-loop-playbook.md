# Gamma Loop Playbook

## What is a Gamma Loop?

A **Gamma Loop** is a self-monitoring and self-correction mechanism within a Silo. It keeps the Silo healthy without requiring human intervention for routine maintenance.

## The Gamma Loop Model

```
Observe ──▶ Orient ──▶ Act ──▶ (repeat)
    ▲                         │
    └─────────────────────────┘
```

| Phase | Silo Action |
|-------|-------------|
| **Observe** | Check state, count artifacts, detect drift |
| **Orient** | Compare against thresholds/constraints |
| **Act** | Apply corrections (archive, prune, flag) |
| **Escalate** | Notify human for complex issues |

## When to Run Gamma Loops

| Scenario | Frequency | Command |
|----------|-----------|---------|
| Daily maintenance | Every 8 hours | `just agents-tidy "run"` |
| Weekly deep-clean | Weekly | `just agents-tidy "run --full"` |
| Pre-session | Before work | `just agents-tidy "check"` |
| Post-session | After work | `just agents-tidy "run"` |

## Gamma Loop Commands

```bash
# Quick health check
just agents-tidy "check"

# Detailed status
just agents-tidy "status"

# Auto-tidy (safe operations)
just agents-tidy "run"

# Full tidy (includes brief-gen for complex issues)
just agents-tidy "run --full"

# Install cron schedules
just agents-tidy "install-crons"
```

## What Gamma Loops Can Do

### ✅ Archive Old Artifacts
- Old briefs → `briefs/archive/`
- Old debriefs → `debriefs/archive/`
- Stale markers → `archive/`

### ✅ Prune Git Branches
- Remove merged branches
- Clean up old feature branches

### ✅ Flag for Human Review
- Stale td issues (> 14 days)
- Complex decisions needing briefs

## What Gamma Loops Must NOT Do

### ❌ Never Delete
Only archive/move. Deletion is irreversible.

### ❌ Never Modify Source Code
Gamma loops touch data, not code.

### ❌ Never Touch Secrets
Credentials remain untouched.

## Escalation Criteria

Escalate to human when:

1. **Threshold exceeded for new artifact type**
2. **Unknown error during correction**
3. **Constraint policy violation detected**
4. **Gamma loop itself is corrupted**

## Adding a New Gamma Loop

### Step 1: Define Thresholds

```bash
# In your silo
cat >> .silo << 'EOF'
"gamma": {
  "thresholds": {
    "maxBriefs": 30,
    "maxDebriefs": 20,
    "staleDays": 14
  }
}
EOF
```

### Step 2: Create Check Script

```bash
#!/bin/bash
# scripts/gamma-check.sh

SILO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SILO_DIR/.silo"

# Count briefs
BRIEF_COUNT=$(ls "$SILO_DIR/briefs"/*.md 2>/dev/null | wc -l)
MAX_BRIEFS=${gamma_thresholds_maxBriefs:-30}

if [ "$BRIEF_COUNT" -gt "$MAX_BRIEFS" ]; then
  echo "⚠️  Briefs exceeded: $BRIEF_COUNT > $MAX_BRIEFS"
fi
```

### Step 3: Create Correct Script

```bash
#!/bin/bash
# scripts/gamma-correct.sh

# Archive oldest briefs
ARCHIVE_DIR="briefs/archive"
mkdir -p "$ARCHIVE_DIR"
ls -t briefs/*.md | tail -n +31 | xargs -I{} mv {} "$ARCHIVE_DIR/"
```

### Step 4: Wire to justfile

```just
gamma-check:
    @./scripts/gamma-check.sh

gamma-correct:
    @./scripts/gamma-correct.sh

gamma-loop:
    @just gamma-check && just gamma-correct
```

## Gamma Log

All gamma loop actions are logged:

```json
{"timestamp": "2026-04-07T10:00:00Z", "action": "archive", "target": "briefs/old.md", "reason": "threshold_exceeded"}
{"timestamp": "2026-04-07T10:00:00Z", "action": "prune", "target": "feature/old-branch", "reason": "merged"}
```

## See Also

- `agents/tidy-first-agent/` - Canonical implementation
- `briefs/2026-04-07-brief-gamma-loop-architecture.md` - Architecture doc
