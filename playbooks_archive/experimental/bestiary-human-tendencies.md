# Bestiary of Unfortunate Human Tendencies

**Purpose:** Catalogue the apparently helpful behaviours that are actually anti-patterns — especially in AI agent workflows, cost control, and knowledge work.

**Style:** Concise. Each entry: name, pattern, why it backfires, the counter.

**Note:** This is not original — these are well-documented cognitive biases and workflow anti-patterns. The value is in naming them clearly for a specific context: working with AI agents in a cost-controlled, evidence-based workflow.

---

## The Tendencies

### 1. The Context-Stuffing Tendency

**Pattern:** Filling the prompt with everything you know, "just in case" the agent needs it.

**Why it backfires:** Every token costs money and稀释 signal. The agent spends inference budget parsing relevance from a haystack. Relevant context gets buried.

**The counter:** The 3-statement rule: context must be (1) directly relevant, (2) not inferable from files, (3) brief. If it doesn't meet all three, it doesn't go in.

---

### 2. The "/BTW" Intrusion

**Pattern:** Introducing an off-topic thought mid-session because "it's related."

**Why it backfires:** Pollutes the context window with irrelevant material. Dilutes the signal. Makes session review harder. Costs accumulate for work that isn't the work.

**The counter:** New session. Mount the silo. Do the thing. Close the session. The context stays clean and the work stays bounded.

---

### 3. The Scaffolding Fallacy

**Pattern:** "I'll set up the agent to handle everything — it'll just get on with it."

**Why it backfires:** Unconstrained autonomy in a cost-controlled workflow is a governance bypass. The agent spends without bound, the human loses oversight, the bill arrives unexpectedly.

**The counter:** Human approval before spawn. Hard cost cap before spawn. Task scope agreed before autonomy granted.

---

### 4. The Passive Watcher

**Pattern:** Spawning agents and watching them run to "monitor progress."

**Why it backfires:** Staying engaged in the main session makes the main session the dominant cost. Watching is not free. If you watch, you might intervene — which forces re-engagement — which makes watching the cost倍 it was supposed to save.

**The counter:** Full handoff or no spawn. If you need to watch, do the task in the main session. If you spawn, walk away.

---

### 5. The "I'll Fill In The Gaps"

**Pattern:** When the agent asks a clarifying question, guessing the answer rather than finding out.

**Why it backfires:** False context compounds. The agent acts on a wrong assumption. Downstream work is wasted. The error only surfaces later when the cost is already spent.

**The counter:** "I don't know" is a valid answer. Say it. Let the agent work with incomplete information explicitly rather than confident incorrectness.

---

### 6. The Sunk Cost Spiral

**Pattern:** Continuing an agent task that is going wrong because "we've already spent on it."

**Why it backfires:** Money already spent is gone. The question is only: is more spend on this path worth it? Sentiment overrides economics.

**The counter:** Kill condition agreed before spawn. "If X happens, kill — regardless of what we've spent." The ledger exists to make this visible, not to make you feel committed.

---

### 7. The Iteration Trap

**Pattern:** Asking the agent to "just refine it a bit more" — repeatedly.

**Why it backfires:** Each refinement costs money. Diminishing returns set in fast. The agent is essentially re-doing work because the original brief wasn't precise enough.

**The counter:** The spec is done when it meets the success criteria — not when it "feels better." Define "done" before you start.

---

### 8. The "One More Thing"

**Pattern:** Adding a small additional request at the end of a task because "it's only small."

**Why it backfires:** Small things aren't free. Each addition expands scope. The brief that looked bounded is now unbounded. Cost estimation becomes impossible.

**The counter:** New task, new approval, new cost cap. "Only small" is not a reason to skip the process.

---

### 9. The Documentation Deferral

**Pattern:** "I'll document it properly once the work is done — the work is the priority."

**Why it backfires:** The work is never done. Or when it is, the context has faded. Documentation that doesn't exist doesn't enable the next session. The Artefact-as-Proof standard fails.

**The counter:** Documentation is part of the work. No artefact, no completion. The brief must include the output format before the task starts.

---

### 10. The "I'll Remember This" Assumption

**Pattern:** Not writing something down because "I'll remember it later" or "it's obvious."

**Why it backfires:** It isn't obvious. Memory fades. The next session has no access to the context. Institutional knowledge lives in the session, not the project.

**The counter:** Write it down at the moment of insight. Briefs, debriefs, and ledger entries are not overhead — they are the work.

---

### 11. The Multi-Tasking Delusion

**Pattern:** Trying to monitor multiple agents at once while doing other work.

**Why it backfires:** Humans are not parallel processors. Attention switching has a cost. Monitoring one thing while doing another means doing both poorly.

**The counter:** One agent at a time. If parallelism is required, set and forget — no monitoring.

---

### 12. The "Quick Review" Trap

**Pattern:** Skipping a proper review because the task was "simple" or "the agent seemed confident."

**Why it backfires:** Confidence is not accuracy. Simple tasks still have edge cases. Errors that slip through become harder to fix downstream.

**The counter:** Every output gets reviewed. Not a long review — a real one. Even 60 seconds of scrutiny catches most errors.

---

### 13. The "That's Good Enough" Surrender

**Pattern:** Accepting a mediocre output because the process has taken long enough.

**Why it backfires:** Mediocre outputs compound. They become the baseline. The Artefact-as-Proof standard erodes from the inside.

**The counter:** Define the acceptance criteria in the brief. If it doesn't meet them, it isn't done — regardless of time spent.

---

### 14. The Invisible Cost

**Pattern:** Not tracking cost because "it's too complicated" or "we're just experimenting."

**Why it backfires:** Experimentation without measurement is guesswork. Without cost data, you can't evaluate ROI. Without evaluation, you can't improve.

**The counter:** Every task gets logged. Even rough estimates are better than nothing. The ledger is not accounting — it is learning.

---

### 15. The Brief-by-Headline

**Pattern:** Describing a task by its output ("write a blog post") rather than its intent ("help someone understand X so they can do Y").

**Why it backfires:** The agent optimises for the headline, not the outcome. "Write a blog post" could mean anything. The output satisfies the letter of the brief while missing the spirit.

**The counter:** Briefs answer: What is this for? Who reads it? What do they do differently after? If you can't answer those three, the brief isn't done.

---

### 16. The Ops-Before-Governance Temptation

**What it looks like:** "Ops mode is ready to go live" — the workflow is tested, agents are configured, cron triggers are set. Time to switch it on.

**Why it backfires:** Ops mode runs autonomously, without the human in the loop. If output persistence is not confirmed working, agent outputs vanish into UI steer messages and session .jsonl files. If cost tracking is not active, spend accumulates invisibly. If kill conditions are not hardcoded, a runaway agent or queue flood runs until the credit card is exhausted.

The Scaffolding Fallacy applied to ops: "just get on with it, it worked in dev."

**The ops-mode checklist before going live:**
1. Output persistence confirmed working (agent writes to project filesystem — not just steer message)
2. Cost ledger active (every run logged with real cost)
3. Hard kill conditions per workflow step (what stops it if X happens)
4. Rate limiting configured (what happens if 10,000 files arrive at once)
5. Back-pressure tested (what happens when the inbox floods)

Ops mode is only safe when all five are confirmed.

---

### 17. The Do-it-all Fallacy

**What it looks like:** Every input file runs through the full pipeline: parse-to-md → summarise → extract → respond. Every document, regardless of type, size, or value.

**Why it backfires:** A receipt needs parsing, not summarising. A one-page email needs neither. A 300-page legal document needs everything. Applying the full pipeline to every item wastes cost and latency on items that needed a fraction of the processing. The pipeline that costs $0.10 per item costs $1,000 per 10,000 items — mostly on items that didn't need it.

**The counter:** Classify first. Route to minimum viable pipeline.

```
Input arrives
    ↓
Classify (type, size, value)
    ↓
Route to appropriate processing depth:
    - Receipt:       parse only
    - Short email:   parse, skip summarise
    - Legal doc:     full pipeline
    - Tweet:         parse, skip everything else
```

The cost of classification must be less than the cost of the steps it saves.

---

### The 10,000 Files Problem (ops-mode context)

This is the operational risk that the Do-it-all Fallacy makes catastrophic: the inbox receives 10,000 files simultaneously, each triggering a workflow, each running a full pipeline.

**What happens without rate limiting:**
- Queue builds faster than it drains
- Workers saturate
- Cost accumulates at full pipeline rate × 10,000
- Credit limit hit, or system breaks, or both

**The inbox/outbox pattern requires back-pressure:**

```
Inbox (10,000 files arrive)
    ↓
Rate limiter: max N files/hour
    ↓
Workflow queue: N files processed
    ↓
Outbox: N results written
    ↓
Remaining 10,000 - N: queued, not lost
```

Rate limiting is not "slowing down" — it is load shedding that preserves system integrity. The alternative is cascade failure.

**Rule:** Every ops-mode workflow needs a rate limit. Every inbox needs back-pressure. The question is not "how do we process everything?" — it is "how do we process what we can, well, and queue the rest?"

---

### 18. The Over-Engineered Deployment

**What it looks like:** The ops-mode pipeline uses the same model tier as dev mode. Claude-3.7 Sonnet for every PDF. The full-reasoning model for receipts. "It worked in dev."

**Why it backfires:** The most expensive model is not always the most appropriate. A model that reasons beautifully in development — where quality is the goal — may be overkill in production — where sufficient execution at minimum cost is the goal. Boiling the ocean to read a PDF. Premium substrate on a task that doesn't need it.

**The cost mechanism:** Dev mode is R&D. Ops mode is production. Using R&D-grade substrate in production is like using a CNC milling machine on a production line that just needs a press. The machine works. It also costs 20× more than necessary.

**The counter:** Tier the substrate by task. Use minimum viable reasoning for the job.

```
Task complexity → model tier:
  Simple parse        → regex / fast parser / free model
  Light summarise     → minimax-m2.5
  Standard pipeline   → minimax-m2.7
  Complex analysis   → claude-3.7 Sonnet
  High-stakes       → claude-3.7 Sonnet + human review
```

**The escalation pattern:** Run cheap first. Escalate to premium only if cheap fails or confidence is below threshold. A receipt that parses successfully at $0.0001 does not need $0.05 of reasoning.

**Dev-to-ops model audit:** Before any ops-mode deployment, review each workflow step: what model does it use in dev? What is the minimum viable model for that step in ops? If they are the same, justify it. If they differ, document the downgrade rationale.

---

### 19. The Orchestrator Fallacy

**What it looks like:** An AI agent decides what to do, when to do it, and how to handle failures. The orchestrator model: Agent → decides → Agent → decides → Agent.

**Why it backfires:** None of the orchestrator functions require an agent. Routing is a switch statement. Failure handling is retry logic. State is a file. Progress reporting is a log. Adding an agent to these decisions adds: an expensive component that can fail, an opaque decision layer that needs governing itself, a new failure mode (the orchestrator breaks, not just the pipeline), and compounding cost.

The orchestrator was meant to solve: "what do we do with this input?" But the answer to that question should be the pipeline definition — not an agent decision.

**The deeper error — anthropomorphising the substrate:** AI models are pattern-matching devices. Very sophisticated ones. But they are still tools that slot into your existing worldview — they do not replace it. The trap is treating them as autonomous agents capable of judgment, planning, and reasoning about novel situations. They pattern-match. They do not understand. They complete the pattern. They do not comprehend.

When you anthropomorphise the substrate, you start thinking it can:
- Decide what to do (it can only continue the pattern)
- Handle novel situations (it can only extrapolate from training data)
- Manage risk (it can only minimise perplexity)
- Govern itself (it can only optimise the next token)

**The counter:** Define the workflow as a restartable, idempotent pipeline. The pipeline is the orchestrator. The pipeline is the governance. The pipeline is the cost control.

```
Pipeline definition (human):
  parse → classify → route → process → store

Pipeline runner (script):
  for each item in inbox:
    run pipeline(item)
    log cost
    if cost > cap: pause
    if not in outbox: re-queue  # restartable
```

Agents belong where classification genuinely requires judgment, where document complexity demands real reasoning, where confidence is below threshold and escalation is needed. Agents for hard problems. Pipelines for known ones.

**The rule:** If the task is known, the pipeline does it. If the task requires judgment, the agent does it — and the pipeline governs the agent's spend.

---

## Maintenance

Add new tendencies as they are observed. The bestiary only has value if it's used — reference it in debriefs when a tendency caused a problem.

**Rule:** If you caught yourself doing one of these, add it. If you didn't catch yourself, the debrief will.

**Ops-mode rule:** Before going live with any ops-mode workflow, run the Ops-Before-Governance checklist. If a tendency caused a problem in ops, name it in the debrief. "We did the Do-it-all Fallacy on 10,000 receipts" is actionable. "We ran too many workflows" is not.
