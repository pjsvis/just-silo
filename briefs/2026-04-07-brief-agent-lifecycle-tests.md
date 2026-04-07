# Brief: Agent Lifecycle Testing

**Date:** 2026-04-07
**Status:** Proposed
**Priority:** P2

---

## Problem Statement

We have agents (tidy-first-agent, code-review-agent) but haven't tested their full workflows end-to-end. We have scripts but no integration tests proving they work.

---

## Gap Analysis

| Agent | Recipes | Scripts | Integration Test |
|-------|---------|---------|------------------|
| tidy-first-agent | ✅ check, status, run, run-full | ✅ tidy-first-agent | ❌ |
| code-review-agent | ✅ analyze, report, harden | ✅ analyze scripts | ❌ |

---

## tidy-first-agent Lifecycle Test

### Expected Flow

```
check → status → run → status (verify change)
```

### Test Scenario

```bash
# 1. Initial check
cd agents/tidy-first-agent
just check

# Expected: Clean output, no warnings

# 2. Create test "mess"
touch ../../briefs/test-brief-01.md
touch ../../briefs/test-brief-02.md
# ... create 35 briefs to exceed threshold

# 3. Run tidy
just run

# 4. Verify
# - Oldest briefs archived
# - No data lost
# - Status updated

# 5. Cleanup
just run-full  # Should flag test briefs for human review
```

### Test Script

```bash
#!/bin/bash
# test-tidy-agent.sh

set -e

AGENT_DIR="agents/tidy-first-agent"
cd "$AGENT_DIR"

echo "=== Tidy-First-Agent Lifecycle Test ==="

# Setup: Create test briefs
TEST_DIR="test-briefs"
mkdir -p "$TEST_DIR"
for i in $(seq 1 35); do
  echo "test content $i" > "$TEST_DIR/test-brief-$i.md"
done

# Execute lifecycle
echo "Running check..."
just check

echo "Running status..."
just status

echo "Running tidy..."
just run

echo "Running run-full..."
just run-full

# Verify
if [ -d "$TEST_DIR" ]; then
  echo "✓ Lifecycle complete"
else
  echo "✗ Lifecycle failed"
  exit 1
fi

# Cleanup
rm -rf "$TEST_DIR"
```

---

## code-review-agent Lifecycle Test

### Expected Flow

```
analyze --pr N → report → harden (optional)
```

### Test Scenario

```bash
cd agents/code-review-agent

# 1. Analyze current diff
just analyze HEAD~1..HEAD incremental

# 2. Generate report
just report

# 3. Verify output
cat markers/done/report.md | grep -q "FAFCAS"
cat markers/done/summary.json | jq -e '.scores'

# 4. Test harden (if applicable)
just harden --auto
```

### Test Script

```bash
#!/bin/bash
# test-cr-agent.sh

set -e

AGENT_DIR="agents/code-review-agent"
cd "$AGENT_DIR"

echo "=== Code-Review-Agent Lifecycle Test ==="

# Execute lifecycle
echo "Running analyze..."
just analyze HEAD~1..HEAD incremental

echo "Running report..."
just report

# Verify
if [ -f "markers/done/report.md" ]; then
  echo "✓ Report generated"
else
  echo "✗ Report missing"
  exit 1
fi

if [ -f "markers/done/summary.json" ]; then
  echo "✓ Summary generated"
else
  echo "✗ Summary missing"
  exit 1
fi
```

---

## Agent Coordination Test

### Expected Flow

```
parent-agent → markers/request/ → child-agent → markers/done/ → parent-agent
```

### Test Scenario

```bash
# Parent invokes child
just agent-invoke tidy-first-agent

# Child processes
cd agents/tidy-first-agent
just run

# Parent verifies
cd ../..
just agent-status tidy-first-agent

# Verify markers written
ls agents/tidy-first-agent/markers/done/
```

---

## Implementation Plan

1. **Create `scripts/test-tidy-agent.sh`** — tidy-first-agent lifecycle test
2. **Create `scripts/test-cr-agent.sh`** — code-review-agent lifecycle test
3. **Create `scripts/test-agent-coordination.sh`** — coordination test
4. **Wire into `justfile`** — `just agent:test tidy`, `just agent:test cr`
5. **Add to CI** — Run tests on push

---

## Acceptance Criteria

| Test | Criteria |
|------|----------|
| tidy-agent | check, status, run, run-full all complete without error |
| cr-agent | analyze, report, harden complete; outputs valid |
| coordination | markers written correctly; status updates |

---

## For Next Session

- Implement tidy-agent test
- Implement cr-agent test
- Run both, verify outputs
