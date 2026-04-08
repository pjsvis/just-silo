# Brief: Bestiary of Unfortunate Human Tendencies — Blog Article

## WHAT
A blog post presenting 15 named anti-patterns that make AI agent workflows fail. Each named clearly, explained briefly, with the counter-measure. Written for developers working with AI agents in cost-controlled, evidence-based workflows.

## AUDIENCE
Developers who use AI coding agents (pi, Cursor, Copilot, etc.) and want to understand why their workflows keep costing more than expected or producing worse results than anticipated.

## TONE
Dryly amusing. Each tendency has a clear name and a one-paragraph explanation. Not preachy — observational. "Here's a thing that happens, here's why it backfires, here's what to do instead."

The bestiary format (naming and cataloguing) is the hook. It makes the anti-patterns memorable and referenceable.

## angle
"We built a cost-tracking system for AI agents and discovered the real problem wasn't the technology — it was us."

## STRUCTURE (proposed)

### 1. The context
We built a cost ledger for our AI agent workflow. We started tracking what we actually spent and why. We noticed the same failure modes kept appearing. Not model failures — human failures. We named them.

### 2. The bestiary (main body)
Present the tendencies. 15 is too many for a blog post — select the 8-10 most relevant to AI agent workflows:

**Recommended inclusions:**
1. The Context-Stuffing Tendency — filling prompts with everything, just in case
2. The "/BTW" Intrusion — off-topic tangents mid-session
3. The Scaffolding Fallacy — unconstrained autonomy ("just get on with it")
4. The Passive Watcher — watching agents run while staying engaged
5. The "I'll Fill In The Gaps" — confident wrong assumptions
6. The Sunk Cost Spiral — continuing because we've already spent
7. The "One More Thing" — small additions that expand scope unboundedly
8. The Invisible Cost — not tracking because "it's just an experiment"
9. The Brief-by-Headline — "write a blog post" instead of "help someone understand X"
10. The Documentation Deferral — "I'll do it after" (it never happens)

**Ops-mode tendencies (recommended for completeness):**
11. The Ops-Before-Governance Temptation — switching on autonomous ops before output persistence and cost tracking are confirmed
12. The Do-it-all Fallacy — running every input through the full pipeline regardless of type or value
13. The Over-Engineered Deployment — using R&D-grade models in production ("it worked in dev")

**The 10,000 files problem:** This is the ops-mode cautionary tale — the queue flood. Mention it as context for why rate limiting and back-pressure are not optional.

**Suggested format per tendency:
```
## The [Name]

**What it looks like:** one sentence description.

**Why it backfires:** two sentences. Be specific about the mechanism, not just the outcome.

**The counter:** one sentence. Actionable.
```

### 3. Why naming helps
Patterns that are named can be caught. Patterns that are unnamed are invisible. When a debrief can say "we did the Sunk Cost Spiral here" rather than "we kept going when we shouldn't have" — the retrospective is actionable.

### 4. The cost ledger
Brief mention of what we built to catch these — the silo cost tracking system. But the blog is about the human tendencies, not the technology.

## WHAT WE ARE NOT WRITING ABOUT
This is not a list of cognitive biases (that's been done). This is specifically about AI agent workflows — cost control, session management, evidence-based work.

## SUCCESS CRITERIA
- Reader recognises at least 3 of their own tendencies in the list
- Reader can say "that's the Scaffolding Fallacy" in a debrief and be understood
- Reader is amused by at least one entry
- Reader shares it with a colleague who uses AI agents
- Reader understands why ops mode requires more governance, not less

## EFFORT
Medium-Low. The content exists in the playbook. The blog post is an edited selection with blog framing.

## SCOPE (in)
- 8-10 selected tendencies, formatted for blog
- The naming-and-cataloguing hook
- Why naming makes patterns catchable
- Brief nod to the cost ledger system

## SCOPE (out)
- Don't turn it into a cognitive psychology lecture
- Don't over-reach — these are observed anti-patterns, not formal research
- Don't moralise — observational, not judgmental
- Don't list all 15 — select the most relatable 8-10

## PROPOSED TITLE
"The AI Agent Failure Mode Bestiary: 10 Things We Keep Getting Wrong"

Alternative: "Why AI Agents Cost More Than Expected: A Bestiary of Human Tendencies"

## MEDIUM
Technical blog. Personal site or Dev.to. Shareable.

## DRAFT STATUS
Draft — ready for review and writing
