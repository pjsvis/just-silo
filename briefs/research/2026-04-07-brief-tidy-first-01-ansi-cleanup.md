# Brief: Tidy-First Agent — ASCII Cleanup Task

**Date:** 2026-04-07
**Status:** Pending
**Agent:** `tidy-first-agent`
**Type:** Internal Task

---

## Problem Statement

Documentation uses Unicode/ANSI box-drawing characters (`╔═╗`, `║`, `╚═╝`) which render broken in:
- GitHub diffs
- Code review tools
- PDF exports
- Plain text viewers

These should use ASCII alternatives (`+`, `-`, `|`) for universal readability.

---

## Task Scope

### Files to Audit

```bash
# Find files with box-drawing characters
grep -rl '[╔╗╚╝║╠╣╦╩╬─╨╥�处分]' *.md
```

### Character Mappings

| Unicode | ASCII |
|---------|-------|
| `╔` | `+` |
| `╗` | `+` |
| `╚` | `+` |
| `╝` | `+` |
| `║` | `\|` |
| `╠` | `+` |
| `╣` | `+` |
| `╦` | `+` |
| `╩` | `+` |
| `╬` | `+` |
| `═` | `-` |
| `─` | `-` |
| `╖` | `+` |
| `╜` | `+` |
| `╙` | `+` |
| `╛` | `+` |
| `╓` | `+` |
| `║` | `\|` |
| `╒` | `+` |
| `╓` | `+` |
| `╔` | `+` |

### Additional Patterns

| Pattern | Replace With |
|---------|-------------|
| `┌───┐` | `+---+` |
| `│` | `\|` |
| `└───┘` | `+---+` |
| `├` | `+` |
| `┤` | `+` |
| `┬` | `+` |
| `┴` | `+` |
| `┼` | `+` |
| `─` | `-` |
| `│` | `\|` |

---

## Policy Recommendation

**Encode this in Silo-Manual.md:**

> Use ASCII-only box-drawing in all documentation. No Unicode box characters in `.md` files.
> 
> Rationale: Documentation must be readable in the worst common denominator (plain text, git diffs, code review).

---

## Implementation

1. [ ] Audit all `.md` files for Unicode box characters
2. [ ] Replace with ASCII equivalents
3. [ ] Add lint check to CI (`scripts/check-docs-ascii`)
4. [ ] Update `Silo-Manual.md` with policy
5. [ ] Archive this brief when complete

---

## For Next Session

- Run `tidy-first-agent` on this task
- Review the ASCII policy
- Consider adding to template's `README.md`
