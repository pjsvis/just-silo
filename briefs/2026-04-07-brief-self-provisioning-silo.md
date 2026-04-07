# Brief: Self-Provisioning Silo Template

**Date:** 2026-04-07
**Status:** Proposed
**Priority:** P1

---

## Problem Statement

Currently, new silos are created from template but don't automatically:
- Inherit gamma-loop configuration
- Set up logging directories
- Configure entropy thresholds
- Register with mesh (future)

A new silo requires manual setup after creation.

---

## Goal

> "A new silo should be productive within 5 minutes of creation with zero human intervention."

---

## What a Self-Provisioning Silo Gets

### On Creation

```
just dev-new my-silo
```

Automatically provisioned:

| Component | Created |
|-----------|---------|
| Directory structure | ✅ |
| Basic justfile | ✅ |
| .silo manifest | ✅ |
| logs/ directory | ✅ |
| stories/ directory | ✅ |
| gamma-loop config | ✅ |
| entropy thresholds | ✅ |
| markers/ directory | ✅ |

### Gamma-Loop Auto-Inheritance

```bash
# From template
templates/basic/
├── scripts/
│   └── gamma-loop.sh    # Auto-copied to new silo
├── justfile             # Includes gamma-check, gamma-correct
└── .silo                # Includes gamma thresholds
```

New silo automatically has:

```just
# Gamma loop recipes
gamma-check:     # Run on creation and daily
gamma-correct:   # Auto-tidy based on thresholds
gamma-status:    # Show gamma state
```

---

## Configuration

### Entropy Thresholds (in .silo)

```json
{
  "gamma": {
    "enabled": true,
    "thresholds": {
      "maxBriefs": 30,
      "maxDebriefs": 20,
      "staleDays": 14,
      "maxLogSize": "100MB"
    },
    "schedule": {
      "autoTidy": "0 */6 * * *",
      "healthCheck": "0 * * * *"
    }
  }
}
```

### Auto-Inherited Recipes

```just
# From template
gamma-check:
    @./scripts/gamma-check.sh

gamma-correct:
    @./scripts/gamma-correct.sh

gamma-status:
    @./scripts/gamma-status.sh
```

---

## Implementation Plan

1. **Update `templates/basic/`** — Add gamma-loop components
2. **Create `scripts/gamma-check.sh`** — Check thresholds
3. **Create `scripts/gamma-correct.sh`** — Apply corrections
4. **Create `scripts/gamma-status.sh`** — Show state
5. **Update `.silo` template** — Include gamma config
6. **Test self-provisioning** — Create silo, verify setup

---

## Test Scenario

```bash
# Create new silo
just dev-new test-auto-silo

# Move into it
cd test-auto-silo

# Verify gamma-loop
just gamma-check
just gamma-status

# Verify logging
ls -la logs/

# Verify thresholds
cat .silo | jq .gamma

# Run gamma-loop
just gamma-correct

# Cleanup
cd ..
rm -rf test-auto-silo
```

---

## Acceptance Criteria

| Criterion | Test |
|-----------|------|
| Logs directory created | `ls logs/` succeeds |
| Gamma recipes available | `just gamma-check` runs |
| Thresholds configured | `cat .silo | jq .gamma` returns config |
| Auto-tidy works | `just gamma-correct` archives old data |

---

## For Next Session

- Update template with gamma-loop
- Create gamma scripts
- Test creation flow
