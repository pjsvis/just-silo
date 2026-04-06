# Introducing just-silo: The Filesystem Is The Interface

*A story about context, silos, and letting agents do their jobs.*

---

## It Started With A Problem

Every AI agent we handed a task asked the same questions:

> "What should I do?"
> 
> "Where do I start?"
> 
> "What commands are available?"

We'd paste context. Copy-paste. More context. More copy-paste. The ritual never ended.

**We needed a way to persist context in the filesystem.**

Not a database. Not a config file. Not a wiki.

The filesystem itself.

---

## The Insight

> "More context doesn't mean better results. Past a threshold, the noise drowns the signal."

We didn't need *more* context. We needed *bounded* context. Enough to act. No more.

The sweet spot: **A directory with rules.** Drop in. Read rules. Do job. Done.

**We called it a silo.**

---

## The Grain Silo Story

Here's a farmer named Anna. She wants to monitor grain moisture and alert when it's too high.

**Old way:** "Anna, use the moisture API, check the threshold, send the alert if over 15%, use the email handler..."

**Silo way:**

```bash
cp -r template grain-moisture
cd grain-moisture
# Edit schema.json to define "moisture reading"
# Edit justfile to define "alert"
just harvest
just process
# Alerts fire when threshold exceeded
```

Anna defines what she wants. The silo makes it happen. She doesn't explain *how*. She explains *what*.

---

## The Agent Drop-In Story

Here's an AI agent named Bert. He drops into `grain-moisture/`.

Bert reads:
- `justfile` — "What verbs exist?"
- `schema.json` — "What data is valid?"
- `.silo` — "What kind of silo is this?"

Bert knows exactly what to do. He harvests. He processes. He observes. He flushes.

He hands off to the next agent via `markers/harvest.done`. The filesystem tracks state. Bert never asks "where was I?"

**Context lives in files, not session memory.**

---

## The Territory Story

Here's the thing about silos: **The filesystem IS the dashboard.**

When Bert works, he creates files:
- `data.jsonl` — working set
- `markers/harvest.lock` — "I'm working on harvest"
- `markers/harvest.done` — "Harvest complete"
- `audit.jsonl` — what happened

We can see everything by looking at the directory. No separate monitoring layer.

> "Observe the territory you occupy. Don't log into a separate dashboard."

---

## The Private Silo Story

Marcus is experimenting. He doesn't want anyone else to see.

```bash
silo-create _experiment --private
cd _experiment
just lock
```

The underscore prefix marks it private. `just lock` pins it to Marcus's machine. It won't sync to The Register.

Sarah can't see it. She can't mount it. It belongs to Marcus.

**Private silos are local. Shared silos are collaborative.**

---

## The Review Gate Story

Bert built a feature. Bert thinks it's great. Bert can't approve it.

This is by design.

Bert calls `td handoff`. Sarah reviews. Sarah approves or rejects.

**Accountability requires separation.** The review gate enforces it.

---

## The Self-Improving Silo Story

After three months, the grain-moisture silo notices something.

Harvest failures are up. Quarantine is filling. Something changed in the data source.

The silo runs `just gamma`. It analyzes. It recommends:

> "Schema validation too strict. Relax from 98% to 92% match."

Anna adjusts. Failures drop. The silo improved itself.

**This is the Gamma Loop: The silo observes its own behavior and suggests changes.**

---

## The Technical Bits

just-silo is built on:

| Tool | Role |
|------|------|
| `just` | Execute recipes |
| `jq` | Transform JSON |
| `bash` | Scripts |
| `sqlite` (via td) | Task management |

No framework. No runtime. No magic.

**A silo is just a directory with rules.**

---

## Get Started

```bash
# Clone the template
cp -r template my-first-silo
cd my-first-silo

# See what you can do
just

# Verify prerequisites
just verify

# Read the docs
just readme
```

---

## The Point

We built just-silo because we were tired of context rituals.

Context should live in the filesystem. Rules should be explicit. Agents should be able to drop in and work.

**We call it just-silo because the usage is just do it.**

*"just-silo it or just-forget it."*

---

*Questions? Open an issue. PRs welcome. The docs live in the repo.*

*Next: [The Wee-Story Principle](./2026-04-06-blog-wee-stories.md) — How wee-stories exposed contradictions in our docs.*
