# Brief: Raise GitHub Issue — Sub-Agent Outputs Not Persisted to Project Filesystem

## WHAT
A well-crafted GitHub issue for `mariozechner/pi-mono` describing the output persistence gap in `pi-interactive-subagents`. Must read as human-written, not AI-generated.

## CONTEXT
AI-generated GitHub issues are treated with suspicion. This one needs to be specific, honest about the gap, include a workaround, and not overclaim.

## ISSUE TITLE
Sub-agent outputs disappear after completion — only in session .jsonl, not in the project

## PROPOSED BODY (real data filled in)

```
## Problem

When a sub-agent completes, its output goes to the main session UI (steer message) and into the agent's session .jsonl file. Neither of these are in the project directory.

I ran two sub-agents today (scout and worker). Their outputs were useful — the scout found 5 real issues in the codebase, the worker confirmed all dev dependencies were satisfied. I need these outputs as project artefacts for cost-benefit review and downstream agent handoff.

I don't have them in the project.

## What actually happened

scout-v3 (41s, ~$0.001):
- Output: found 5 stale files, stale playbooks, missing .github/agents/
- Shown in UI as steer message → gone when session scrolls
- Persisted: ~/.pi/agent/sessions/--Users-petersmith-Dev-GitHub-just-silo-dev--/2026-04-08T06-26-25-015Z_a3e206ca-f0345d13-48695437-9010.jsonl

worker-v3 (16s, ~$0.001):
- Output: all dev dependencies satisfied
- Same story: UI message, then gone

Those session files are at ~/.pi/agent/sessions/. Not in the project. Not linked to any project artefact. I cannot hand them to a downstream agent or attach them to a project issue.

## What I need

Option A: subagent({ outputPath: "briefs/scout-output.md" }) — write the agent's final output to this path automatically

Option B: session files written to params.cwd instead of ~/.pi/agent/sessions/

Option C: pipeline/output/ convention — completed agent outputs land here automatically

## Workaround

I tell every agent: "use the write tool before calling subagent_done". This works but:
- Relies on the agent remembering
- Not enforced — early exit means nothing written
- No structured format — agents output free text

## Labels

enhancement, subagents
```

## PROCESS

- Post as Issue (not PR — no fix proposed, just the gap)
- No "Feature request:" prefix
- No "## Solution" section
- ~200 words
- Session paths are real — do not change
- Workaround included

## BEFORE POSTING

- Copy the body above
- Do not add emoji
- Do not add a "## Solution" heading
- Do not thank the maintainers in advance
- Add labels: `enhancement`, `subagents`

## APPROVAL

This brief needs approval before raising. Review:
- Does the body read as human-written?
- Is the framing honest enough?
- Session paths are real — confirm they match your system
