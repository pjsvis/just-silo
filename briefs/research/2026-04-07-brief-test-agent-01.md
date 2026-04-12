# Brief: test-agent — Test Coverage Enforcement

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P1  

---

## Problem Statement

v0.2 shipped without tests. Manual testing caught nothing; production found edge cases. We need automated test enforcement without creating metric-gaming incentives.

---

## Proposed Solution

**test-agent** enforces test presence and pass/fail, NOT coverage percentage.

**Core principle:** Tests must exist and pass. What they cover is human judgment.

---

## Requirements

### Scope (What test-agent enforces)

| Rule | Enforcement |
|------|-------------|
| Test file exists | ✅ Required |
| Tests pass | ✅ Required |
| Happy path covered | ✅ Required |
| One edge case per exported function | ⚠️ Soft requirement |
| Coverage % | ❌ Forbidden |

### Detection Logic

```typescript
interface TestRequirement {
  sourceFile: string        // e.g., src/silo-api-server.ts
  testFile: string          // e.g., src/silo-api-server.test.ts
  testExists: boolean
  testsPass: boolean
  happyPathExists: boolean
  edgeCaseCount: number
}
```

### Pre-commit Check

```bash
# For each *.ts changed:
if (!testFileExists) {
  FAIL "No test file for <sourceFile>"
}

if (!testsPass) {
  FAIL "Tests failed for <sourceFile>"
}

if (!happyPathCovered) {
  WARN "No happy path test for <function>"
}
```

### td Integration

```bash
# When test check runs:
td log "test-agent: Checking tests" --result
td log "test-agent: Tests pass ✅" --result
# or
td log "test-agent: Missing test file for X" --blocker
```

---

## What Makes a Good Test

| Category | Definition |
|----------|------------|
| **Happy path** | Normal input → expected output |
| **Edge case** | Boundary condition or error case |
| **Integration** | Multiple components together |

test-agent checks:
1. File exists
2. `bun test` passes
3. At least one happy path test exists

Does NOT check:
- How many tests
- What % of code is covered
- Whether edge cases are "sufficient"

---

## File Structure

```
just-silo/
├── agents/
│   └── test-agent/
│       ├── src/
│       │   ├── index.ts        # Entry point
│       │   ├── detector.ts     # Find test files
│       │   ├── runner.ts       # Run tests
│       │   ├── checker.ts      # Verify coverage
│       │   └── reporter.ts     # Report results
│       ├── justfile
│       └── README.md
└── playbooks/
    └── test-agent-playbook.md
```

---

## Implementation Notes

1. **Naming convention** — `<module>.test.ts` for `<module>.ts`
2. **Use bun test** — Already configured
3. **Parse test output** — Extract pass/fail and coverage info
4. **Don't parse coverage %** — Just check if tests exist and pass

---

## Acceptance Criteria

- [ ] Detects all `*.ts` source files
- [ ] Requires corresponding `*.test.ts`
- [ ] Runs `bun test` and checks exit code
- [ ] Flags missing happy path tests (warning, not failure)
- [ ] Integrates with pre-commit hooks
- [ ] Logs findings to td
- [ ] Playbook documents usage

---

## Anti-Patterns to Avoid

| Anti-pattern | Why | Instead |
|-------------|-----|---------|
| Coverage % gates | Agents optimize for %, not quality | Presence + pass gates |
| Minimum test count | Arbitrary number | Presence + pass |
| Auto-generate tests | Template tests are noise | Human writes meaningful tests |

---

## Related

- `briefs/research/2026-04-07-brief-review-agent-01.md` — review-agent (uses test output)
- `briefs/research/2026-04-07-brief-td-api-testing-01.md` — Previous testing recommendations
