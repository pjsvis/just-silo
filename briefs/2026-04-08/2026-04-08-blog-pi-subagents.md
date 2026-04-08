# Brief: How to Wrangle pi Sub-Agents

## WHAT
A technical blog post documenting what we learned running pi sub-agents in a real project, including why we concluded they don't fit our silo workflow — and what we built instead.

## AUDIENCE
Developers using pi in multi-agent workflows. Also useful for anyone building agent cost control systems.

## TONE
Honest, technical, "lessons from the coal face". We failed, we spent money, we learned. Write about what actually happened. No vendor pitch.

## REFRAMED ANGLE

**"We spent real money on sub-agents, found they don't fit our workflow, and built a cost tracking system instead."**

The blog is not "how to make sub-agents work." It's "here's what we learned, including why we stopped using them, and what the real innovation is."

## STRUCTURE (proposed)

### 1. The setup
Set up 5 sub-agents (scout, worker, reviewer, planner, spec) to run parallel smoke tests in a codebase monitoring pipeline.

### 2. What went wrong — three failures

**Failure 1: Wrong model ID**
- All agents used `minimax/minimax-2.7-4k` — not in OpenRouter catalog
- Fix: remove model override from agent configs, use global default

**Failure 2: Frozen panes**
- SIGTERM from earlier kills orphaned cmux surfaces
- New agents couldn't attach — "Surface is not a terminal"
- Fix: wait for cascade to clear

**Failure 3: No output persistence**
- Agent completes → steer message in UI → gone when session scrolls
- Session .jsonl persists in ~/.pi/ but not in project
- No artefact written to project filesystem
- The "artefact-as-proof" standard requires output on disk

### 3. What we learned — sub-agents don't fit silo workflows

**The core issue:** Sub-agents are a parallelism tool. Most silo workflows are sequential pipelines: harvest → process → flush. Each step waits for the previous. There is nothing to parallelize.

**The governance issue:** The original agent configs said "get on with it, spend what you need." That's a governance bypass — unconstrained autonomous spending in a budget-controlled workflow.

**The cost issue:** Real numbers from today:
- scout-v3: 41s, ~$0.001
- worker-v3: 16s, ~$0.000
- Main session (today): ~$0.032
- Sub-agents only win financially if you fully hand off and stop engaging

**The conclusion:** Sub-agents add risk, opacity, and cost without adding capability to sequential silo pipelines.

### 4. What we built instead — the cost tracking system

A ledger in the project filesystem:

```
pipeline/history.jsonl
  scout-v3  minimax-m2.7  done  41s  $0.001
  worker-v3 minimax-m2.7  done  16s  $0.000
```

Five just recipes:
- `just silo-cost-log` — log a task before/after
- `just silo-cost` — show summary: per-agent, totals
- `just silo-cost-by-agent` — grouped view
- `just cost-archive` — archive entries >30 days
- `just cost-clear` — wipe ledger

Pre-spawn: check OpenRouter budget via API
Post-completion: log with real duration
Weekly: review cost per agent type, flag anomalies

### 5. The blog post is really about two things

1. **Sub-agents**: what they are, when they make sense (parallel, self-contained, budget-bounded tasks), why they don't fit most silo workflows
2. **Cost tracking**: how we built it, why it matters, how to use it

The cost tracking is the real innovation. The sub-agent section is the cautionary tale.

### 6. What pi needs (the honest ask)

Sub-agents are not production-ready for cost-controlled, audit-aware workflows:
- No automatic output to project filesystem
- No real cost tracking per agent (only session metadata, not in project)
- No output path parameter on subagent()

We raised a GitHub issue on this.

## SUCCESS CRITERIA
- Reader understands when sub-agents make sense and when they don't
- Reader can implement the cost tracking system in their own project
- Reader knows what gaps remain in pi
- Reader trusts the honest framing — we failed, here's what we learned

## EFFORT
Medium. Writing from experience, minimal code. One or two diagrams.

## SCOPE (in)
- Real session data, real costs, real failures
- The cost ledger approach we built
- The governance argument against unconstrained sub-agents

## SCOPE (out)
- Don't pitch sub-agents as a solution for silos
- Don't pretend everything worked
- Don't over-engineer — we don't have a fix for output persistence
- Don't omit the conclusion — say clearly: sub-agents don't fit this workflow

## PROPOSED TITLE
"How to wrangle pi sub-agents: what we learned, why we stopped, and what we built instead"

## MEDIUM
Technical blog, personal site or Dev.to. Not a vendor pitch.

## DRAFT STATUS
This brief — needs approval before writing
