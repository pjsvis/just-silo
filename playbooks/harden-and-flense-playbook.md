# Harden and Flense Playbook

**Pattern:** Iterative system improvement with self-correction  
**Principle:** Don't get out of bed unless it's worth your while.

---

## The Core Loop

```
HARDEN → TEST → FLENSE → TEST → HARDEN → ...
   ↑                              ↓
   ←←←←←←←← REPEAT ←←←←←←←←←←←←←
```

**Self-correction:** Hardening reveals what to flense. Flensing reveals what to harden next.

You don't do everything at once. You do one thing, test it works, then remove what became unnecessary.

---

## Phase 1: Harden

**Add structure. Add checks. Add validation.**

### What to Harden

| Area | Action | Test |
|------|--------|------|
| **Invariants** | Run `just silo-verify` before write | Pass/fail |
| **Schema validation** | Validate JSON on harvest | `jq --schema-file schema.json` |
| **Secrets** | Check for leaked credentials | `scripts/secrets-check.sh` |
| **Telemetry integrity** | Hash logs on write | Verify hash on read |
| **Agent policy** | Set `agent_policy` in `.silo` | Observe/Assist/Act |

### Gate Pattern

```bash
# Before any write workflow:
just silo-verify || {
    echo "⚠️ Invariants broken. Fix first."
    exit 1
}
```

### The Test

After hardening: **Does the system hold?**

```
RUN → PASS → Next
RUN → FAIL → Fix, then FLENSE
```

---

## Phase 2: Flense

**Remove the unnecessary with precision.**

### What to Flense

| Condition | Action |
|-----------|--------|
| File exists in two places | Archive one. Keep canonical. |
| Deprecated by newer version | Archive old. Keep new. |
| Never referenced | Archive. Retrieve via search if needed. |
| Noisy, not useful | Archive. Don't delete. |
| Complexity for its own sake | Remove. |

### Flensing Rules

```
1. If it exists in two places → archive one
2. If superseded → archive old
3. If never used → archive (don't delete)
4. If creates noise → archive
```

### The Test

After flensing: **Is context leaner?**

```
LEAN → Next
MESSY → Continue flensing OR escalate
```

---

## Phase 3: Context Entropy Check

**Before starting any harden/flense cycle, assess total context entropy.**

### The Calculation

```
TOTAL ENTROPY = Complexity + Uncertainty + Risk
```

| Factor | Low (do it) | High (escalate) |
|--------|-------------|-----------------|
| **Complexity** | Single change | Multiple changes needed |
| **Uncertainty** | Know what to do | Unclear outcome |
| **Risk** | Reversible | Could break invariants |

### Decision Matrix

| Total Entropy | Action |
|--------------|--------|
| **Low** | Do it. Hardening/flensing is worth while. |
| **Medium** | Do it carefully. Test after each step. |
| **High** | Don't get out of bed. Escalate or defer. |

### Escalation Rule

> **If total entropy is too high, escalate or defer. Don't start a messy fight.**

```
Messy context + messy fix = messier context
```

---

## The Tidy-First Overlay

**Every harden/flense cycle starts with TIDY FIRST.**

```
1. TIDY FIRST: Is context lean enough to work?
   ↓ No
   tidy first until lean
   ↓ Yes
2. HARDEN/FLENSE: What needs fixing?
3. TEST: Does it work?
4. REPEAT or DONE
```

---

## Self-Correction Mechanics

**The loop is self-correcting because:**

```
HARDEN reveals → "This old thing is now obsolete" → FLENSE
FLENSE reveals → "This new thing needs protection" → HARDEN
```

Each phase generates information for the next.

---

## Anti-Patterns

❌ **Harden everything at once** — test after each change
❌ **Flense without testing** — could break invariants
❌ **Start messy fight** — context too complex, escalate
❌ **Delete instead of archive** — retrieve later via search
❌ **Keep deprecated files** — creates confusion

**DO:**
- Hard one thing, test, flense what became unnecessary
- Archive rather than delete
- Escalate if entropy too high
- Keep context lean throughout

---

## Session Template

```
=== HARDEN/FLENSE SESSION ===

ENTROPY CHECK:
  Complexity:    [Low/Medium/High]
  Uncertainty:   [Low/Medium/High]
  Risk:          [Low/Medium/High]
  
  Decision: [DO IT / DEFER / ESCALATE]

HARDEN:
  - item 1
  - item 2
  
TEST: [PASS / FAIL]

FLENSE:
  - archive X
  - remove Y

TEST: [PASS / FAIL]

NEXT: [CONTINUE / DONE]
```

---

## Examples

### Example 1: Add Schema Validation (Harden)

```
1. TIDY FIRST: Context is lean ✓
2. HARDEN: Add schema validation to harvest
3. TEST: Run just silo-harvest with valid data → PASS
4. FLENSE: Found unused "legacy-validate.sh" → archive
5. TEST: System still works ✓
6. DONE
```

### Example 2: Archive Duplicates (Flense)

```
1. TIDY FIRST: Found FRAMEWORK.md and docs/SILO-FRAMEWORK.md
2. FLENSE: Archive FRAMEWORK.md (duplicated)
3. TEST: References still work? → YES (grep shows none)
4. HARDEN: Add "no-duplicates" check to silo-verify
5. TEST: Check passes ✓
6. DONE
```

### Example 3: Too Messy to Fix

```
1. TIDY FIRST: Found 30 deprecated files, unclear refs
2. ENTROPY CHECK: Complexity=High, Uncertainty=High
3. DECISION: DEFER
4. Action: Document "needs cleanup" in debrief
5. Next session: Small batch approach
```

---

## The Economy Principle

> **Don't get out of bed unless it's worth your while.**

Every harden/flense cycle has a cost:
- Time
- Token usage
- Risk of breaking something

**Only do it if the benefit exceeds the cost.**

| Situation | Worth doing? |
|-----------|--------------|
| 1 small fix, clear path | Yes |
| 10 interdependent changes | Defer |
| Unclear outcome | Defer |
| Could break invariants | No |

---

**Related:**
- `playbooks/entropy-management-playbook.md` — Think Fast → Archive → Gap Fill
- `scripts/silo-verify-structure.sh` — Invariant validation
- `briefs/2026-04-12-brief-silo-philosophy.md` — Capability model