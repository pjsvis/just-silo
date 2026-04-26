---
date: 2026-04-26
tags: [debrief, pr-review-agent, bugfix, 404, github-api]
---

# Debrief: Fix PR Review Agent 404 Noise on Merged/Closed PRs

## Context
The `pr-review-agent` (at `agents/pr-review-agent/src/pr-review-agent`) had a bug where watching a PR that had been merged or closed would produce noisy, misleading output. Instead of cleanly detecting the 404 from GitHub's API, it fabricated a fake PR with `state: 'open'` and continued polling until it falsely declared the PR "Ready for Review."

## Accomplishments

- **Fixed 404 handling in `ghFetch`**: The function previously only threw on messages containing "Bad" or "rate", silently returning any other GitHub error JSON (including `"Not Found"` for merged PRs). Now it throws on any `json.message`, propagating the actual error.
- **Fixed `getPRInfo` to return `null` on missing PRs**: Previously returned a fabricated PR object with `state: 'open'`. Now returns `null` when the PR is not found, allowing callers to handle it cleanly.
- **Removed duplicate `getRepo()` definition**: The second shadowing definition was dead code that added confusion.
- **Made `poll()` return `boolean`**: Returns `false` when the PR no longer exists, signaling upstream to stop.
- **Made `watch()` stop cleanly on 404**: Exits with `"PR #N no longer available — stopping watch"` instead of counting 3 fake iterations and declaring readiness.
- **Updated `status()` to handle missing PRs**: Prints `"PR #N not found"` and exits cleanly.

## Problems

- **Silent 404 propagation**: The root cause was `ghFetch` treating `"Not Found"` as a valid response because it didn't match the two hardcoded error strings. This is a classic incomplete error-handling pattern.
- **Fabricated fallback data**: `getPRInfo` created a fake PR with optimistic defaults (`state: 'open'`) rather than admitting the territory had changed. The system was designed to never stop, so it invented data to justify continuation.
- **Duplicated function**: `getRepo()` was defined twice in the same file — the second shadowed the first. This was harmless but sloppy.

## Lessons Learned

- **Throw on all error messages, not just known ones**: Hardcoding specific error strings (`'Bad'`, `'rate'`) creates blind spots. If GitHub returns `{"message": "Not Found"}`, that's an error — treat it as one.
- **Null is better than fiction**: Returning `null` and letting the caller decide is far preferable to inventing default data that silently corrupts downstream logic.
- **Signal intent through return types**: Making `poll()` return `boolean` creates a clear contract: "I checked, and here's whether the PR still exists." Void functions can't communicate state changes.

## Verification

- Reviewed `git diff` to confirm all changes were surgical and focused.
- Confirmed no briefs needed archiving (this was a bugfix, not a planned feature).
- Verified file compiles with `bun run` syntax check.
