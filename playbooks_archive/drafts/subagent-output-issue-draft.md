# Issue: Sub-agent outputs are not persisted to the project filesystem

## GitHub Repo
`mariozechner/pi-mono` — specifically `packages/pi-interactive-subagents/`

## Severity
🟠 Major — blocks cost accountability and artefact-as-proof workflows.

## Problem Description

When a sub-agent completes, its output is:

1. **Steered back** to the main session as an ephemeral UI notification (shown once, not persisted)
2. **Written** to the sub-agent's session `.jsonl` file in `~/.pi/agent/sessions/`
3. **Never written** to the project filesystem

There is no automatic mechanism to extract the agent's final output to a persistent, discoverable location within the project that spawned the agent.

## Impact

### 1. Artefact-as-proof standard is broken

For teams using agents in regulated or audit-conscious environments, "the agent ran and said X" is not sufficient — they need the output persisted as a project artefact with timestamp and cost attribution.

Currently:
- The steer message appears in the UI → disappears when session scrolls
- The session `.jsonl` is in `~/.pi/` → not in the project repo
- No output file is written to the project filesystem

### 2. Cost-benefit analysis is impossible

To evaluate whether a sub-agent was worth its cost, you need:
- The task it was given
- The output it produced
- The actual token/cost from the API

Currently only the session `.jsonl` contains all three, but it's:
- Buried in `~/.pi/agent/sessions/<session>.jsonl`
- Not in the project directory
- Not linked to any project artefact

A cost ledger (`just silo-cost-log`) can track that an agent ran, but not what it produced.

### 3. Handoff to downstream agents is fragile

If the main session dies after a sub-agent completes but before processing its output, the output is lost from the main session's perspective. The sub-agent's session file still exists but is not automatically consumed.

## Expected Behaviour

After `subagent()` completes, one of the following should happen:

**Option A: Structured JSON output to disk (recommended)**
```
pipeline/output/
  scout-v3-2026-04-08.jsonl   # {"ts": "...", "agent": "scout-v3", "task": "...", "output": "...", "cost_usd": 0.001}
  worker-v3-2026-04-08.jsonl  # {"ts": "...", "agent": "worker-v3", "task": "...", "output": "...", "cost_usd": 0.000}
```

**Option B: Markdown summary to project dir**
```
briefs/
  2026-04-08-scout-v3-recon.md
  2026-04-08-worker-v3-dev-check.md
```

**Option C: Configurable output path**

The `subagent()` call accepts an optional `outputPath` parameter:
```typescript
subagent({
  name: "scout-v3",
  agent: "scout",
  task: "recon",
  outputPath: "briefs/2026-04-08-scout-recon.md"  // ← new
})
```

If `outputPath` is provided, the agent's final output is written there. If not, no file is written (current behaviour).

## Workaround (current)

Implement in the just-silo template:
1. Spawn agent with full context
2. Agent uses `write` tool to persist output to `briefs/` or `pipeline/output/`
3. Agent calls `subagent_done` with the path
4. Main session reads the file from disk

This works but is:
- Not enforced
- Not documented
- Dependent on agent remembering to write (no automatic fallback)

## Technical Notes

- The `subagent_done` tool receives the final assistant message text
- The session `.jsonl` file contains full output including token counts
- The session dir is `~/.pi/agent/sessions/<session>.jsonl`
- The cwd for the sub-agent is available via `params.cwd`

The fix likely belongs in `packages/pi-interactive-subagents/pi-extension/subagents/subagent-done.ts` — intercept the done payload and write it to `params.cwd` if `params.outputPath` is set.

## Labels

`enhancement` `subagents` `cost-accountability` `workflow`
