# Sub-Agent Cost Control Playbook

**Purpose:** Govern sub-agent spawn decisions — including when not to use them.  
**Principle:** A sub-agent only makes financial and governance sense if the task requires true parallelism and the cost is acceptable. Most silo workflows do not.

---

## When NOT to Use Sub-Agents

**Sub-agents are a parallelism tool. Most silo workflows are sequential pipelines.**

Do NOT use sub-agents if:

- [ ] **The workflow is sequential** — harvest → process → flush. Each step waits for the previous. No parallelism to exploit.
- [ ] **The task requires human approval mid-flight** — sub-agents bypass the human-in-the-loop gate. Governance matters.
- [ ] **The cost is unconstrained** — the original agent configs said "get on with it, spend what you need". This is unacceptable for budget-controlled work.
- [ ] **The output needs to be a project artefact** — sub-agent outputs disappear into UI steer messages and session .jsonl files. Nothing reaches the project filesystem automatically.
- [ ] **A downstream agent needs the output** — the handoff is fragile. If the main session dies before processing the steer message, the output is gone.
- [ ] **The task is < 2 minutes** — overhead exceeds value. Do it in the main session.

**The Edinburgh Protocol principle:** The human is the Impartial Spectator who approves before action. Sub-agents are a governance bypass unless the task is genuinely autonomous and the cost is bounded.

---

## The Core Insight

```
Main session (orchestrator):   ~$0.006/min at MiniMax-m2.7
Sub-agent (scout, 41s):       ~$0.001
Sub-agent (worker, 16s):       ~$0.000
```

The main session dominates unless you **fully hand off and stop engaging**. The moment you stay active, you become the expensive part.

---

## The Cost Audit Loop

Before every spawn, run this check:

```
1. Check budget:  just api-key-budget   (→ OpenRouter /auth/key)
2. Set a cost cap per agent
3. Log the spawn: just silo-cost-log agent=X task=Y model=Z status=running
4. Log completion: just silo-cost-log agent=X task=Y model=Z status=done duration=N
5. Compare: actual vs estimate. Flag anomalies >2×.
```

---

## Tiered Spawn Strategy

| Task | Agent | Budget | Context window |
|------|-------|--------|----------------|
| Targeted read/grep | `scout` | $0.001 | 2k in + 800 out |
| Single command | `worker` | $0.002 | 2k in + 800 out |
| Multi-step analysis | `worker` | $0.005 | 5k in + 2k out |
| Deep code review | `reviewer` | $0.010 | 5k in + 2k out |
| Full spec or plan | `planner` / `spec` | $0.020 | 8k in + 3k out |

**Rule:** If task < $0.005 and < 2 minutes, just do it in the main session.

---

## Handoff Criteria

Spawn a sub-agent **only if all of the following are true**:

- [ ] **True parallelism required** — the task genuinely runs alongside other work, not instead of it
- [ ] **Task is self-contained** — no need for main session context mid-flight
- [ ] **Cost is bounded** — hard cap set before spawn, not "spend what you need"
- [ ] **Human approval given** — the task and budget have been reviewed before spawning
- [ ] **Output will be persisted** — agent writes result to project filesystem before calling subagent_done
- [ ] **You will NOT stay engaged** — any re-engagement in the main session makes you the dominant cost

**Never spawn to:**
- Monitor progress interactively (stay engaged = main session cost dominates)
- Ask follow-up questions in the main session (forces re-engagement)
- Fix it mid-flight (kill and respawn with full context instead)
- Bypass an approval gate (the human-in-the-loop exists for a reason)

---

## Kill Conditions

Terminate if:
- Running > 5× estimated time
- Cost > 2× budgeted amount
- Model returns "rate limit" or repeated failures

```
kill $(ps aux | grep "pi.*$AGENT_NAME" | grep -v grep | awk '{print $2}')
```

---

## Parallel Spawn Rules

- **2-3 agents** at once: fine (parallelism gains outweigh overhead)
- **> 5 agents**: risky — cost compounds and monitoring breaks
- **Never parallel-spawn** a sub-agent AND stay active in main session

---

## Real API Query

```bash
# Check remaining budget (real-time)
curl -s -H "Authorization: Bearer $(skate get openrouter_api_key)" \
  https://openrouter.ai/api/v1/auth/key \
  | jq '.data.limit_remaining, .data.usage, .data.usage_daily'

# If remaining < $1.00: pause and review before spawning more
```

---

## Session Architecture

For silo workflows, **Option D is the default**:

```
Option A: Main session orchestrates, sub-agents execute
          → Main session cost > sub-agent cost. Only worth it if
            main session does something sub-agents can't (judgment, decisions).

Option B: Spawn, stop engaging, consume result later
          → Sub-agents dominate. Only worth it for large tasks (>$0.01).

Option C: Dedicated sub-agent session (no main session)
          → pi --session /path/to/silo/agent-session
          → All cost is sub-agent cost. Cleanest for agent-to-agent pipelines.

Option D: No sub-agents — sequential silo pipeline with cost tracking
          → Human approves each stage. Cost logged at each step.
          → No governance bypass. No opaque cost accumulation.
          → RECOMMENDED for all silo workflows.
```

---

## Anti-Patterns

These are sub-agent-specific failure modes. See also: `bestiary-human-tendencies.md` — the named human tendencies that apply to all AI agent workflows.

| Anti-pattern | Why | Fix |
|---|---|---|
| Spawn 5 agents and watch them all | Main session stays active = dominant cost | Spawn 1-2, wait for results, spawn next batch |
| Ask sub-agent a follow-up in main | Forces re-engagement | Kill and respawn with full context |
| No cost logging | No feedback loop | Log every spawn and completion |
| Spawn for a 30-second task | Overhead > value | Do it in main session |
| Let runaway sessions run | Credit drain | Hard cap + kill condition |

---

## The Ledger

Every spawn → `just silo-cost-log`  
Every completion → update with real duration  
`just silo-cost` → weekly review

If an agent type consistently costs 3× estimate, it needs a bigger budget or a smaller task.

---

## Quick Reference

```bash
# Pre-spawn budget check
curl -s -H "Authorization: Bearer $(skate get openrouter_api_key)" \
  https://openrouter.ai/api/v1/auth/key \
  | jq '.data.limit_remaining'

# Log spawn
just silo-cost-log agent="scout-recon" task="audit-src" model="minimax/minimax-m2.7" status="running"

# Log done (after agent completes)
just silo-cost-log agent="scout-recon" task="audit-src" model="minimax/minimax-m2.7" status="done" duration_s=47

# View ledger
just silo-cost
just silo-cost-by-agent
```
