# Silo Philosophy

*"A silo is a scoped lexicon — a vocabulary and grammar that lives in the filesystem."*

---

## Pocket Universe

```
input ──→ [ SILO ] ──→ output
          ┌─────────┐
          │ vocab   │
          │ grammar │
          │ state   │
          │ rules   │
          └─────────┘
```

**When you're in, you can only do what it allows.**

The rules are the rails. Constraints create capability.
You can't do anything the silo doesn't allow. That's the point.

Any agent can drop in, read the rules, and just fcuking do it.

You want different rules? Change them. It's your pocket universe.

---

## The Pragmatism

```
We don't need a SOTA model.
We need a model that will just fcuking do it.

No framework friction.
Get stuff.
Turn it into things.
Done.

Any substrate worth its chips should be able to do it.
```

Not rocket science. Simple job. Get stuff, turn into things.

---

## The Reveal

**You don't pre-define the vocabulary. You just say what you want.**

```
"I want to monitor grain moisture and alert when it's too high"
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes"
→ just scan, just score, just flag...
```

**You say the words. Just-silo makes them executable.**

Just ask your AI: "Make the words just happen."

The tool is called *just*. The usage is *just fcuking do it*.

---

## The Core Insight

Every turn, an agent loses its context. Every turn, you have to re-explain the domain.

**The fix:** Scoped the lexicon to the directory.

A silo is not a pipeline. A silo is not a workflow. A silo is a **language** — scoped to a directory, executable via `just`.

```
silo/
├── vocabulary  → justfile (verbs)
├── grammar     → workflow (order)
├── types       → schema.json (what's valid)
├── filters     → queries.json (named transforms)
└── state       → data.jsonl (working memory)
```

The vocabulary is the silo. The silo is the vocabulary.

---

## Scoped Lexicons

**Global vocabulary:**
- `ls`, `cat`, `grep` — work everywhere, mean the same thing everywhere
- Global scope, low fidelity, always available

**Scoped vocabulary:**
- `just status`, `just alerts`, `just harvest` — only work here, mean something specific here
- Lexical scope, high fidelity, domain-native

**The verbs are YOUR choice.** `harvest`, `process`, `flush` are just examples. You define the vocabulary.

**Every directory can have its own language.**

```
grain_silo/     → harvest, process, flush, moisture, elevator_id
code_review/    → scan, score, flag, notify, merge
log_monitor/   → ingest, alert, archive, throttle
incident/      → triage, escalate, resolve, postmortem
monitoring/    → status, who, stuck, throughput, audit
```

**The vocabulary emerges from the domain. You choose the verbs. Not the tool.**

---

## Recommended Verbs

You define your own vocabulary, but these are commonly useful:

**Core (do the thing):**
```
just ingest      → bring data in
just process     → transform data
just flush       → archive output
just clean       → reset state
```

**Observability (see what happened):**
```
just status      → aggregate health (THE main command)
just who         → who is doing what
just stages      → stage-by-stage status
just stuck       → detect stalled stages
just throughput  → processing metrics
just audit       → completion history
just alerts      → surface critical items
just stats       → entry counts
just report      → human-readable summary
```

**Coordination (multi-agent):**
```
just claim       → own a stage
just wait        → block until ready
just done        → mark complete
just heartbeat   → keep claim alive
just help        → what can I do?
just help <verb> → what does this verb do?
```

**The pattern:**
```
just <verb>        → just fcuking do it
just help <verb>   → what will it do?
just help          → what verbs exist?
```

---

## The Formalism

| Concept | Implementation | Meaning |
|---------|---------------|---------|
| **Vocabulary** | `justfile` recipes | Verbs: harvest, process, status |
| **Grammar** | Workflow order | Mount → Sieve → Process → Observe → Flush |
| **Types** | `schema.json` | What valid data looks like |
| **Filters** | `queries.json` | Named jq expressions |
| **State** | `data.jsonl` | Working memory |
| **Scope** | Directory boundary | `cd silo/` to enter |

**A silo = scoped vocabulary + executable grammar.**

---

## Pickled Language

You've **pickled** a language.

Just as you pickle vegetables to preserve them, you've pickled a domain language to preserve context:

```
pickled language = vocabulary + grammar + state
                  = justfile + workflow + data
                  = executable, portable, domain-native
```

The agent doesn't need context injection. It needs to `cd` into the silo and read.

---

## Lexical Scope for the Filesystem Age

Traditional lexical scope:
```
{
  let x = 42;
  // x is scoped to this block
}
```

Silo scope:
```
silo_grain/
{
  harvest → validate → process → flush
  vocabulary: moisture, elevator_id, critical_threshold
  grammar: Mount → Sieve → Process → Observe → Flush
}
```

**The directory is the block. The vocabulary is scoped. The grammar is executable.**

---

## Zero Onboarding

Without silos:
```
Agent: "I don't know what to do"
User: "Process the grain moisture data, flag readings over 15%, 
       validate against the schema, mark as processed, 
       archive to output, tell me if anything's stuck..."
Agent: "I'll try to..."
```

With silos:
```
Agent: "cd grain_silo/"
User: "just harvest"
Agent: (reads justfile)
      "Got it. Validating against schema, ingesting data..."
```

**No explanation. No context injection. Just `cd` and do.**

---

## Context Without Context Injection

The paradox: agents need context, but context degrades with length.

**The solution:** Externalize context into the filesystem.

```
Context injection (bad):
  "You are a grain moisture monitor. Validate against schema. 
   Critical threshold is 15%. Harvest, process, flush..."

Context externalized (good):
  cd grain_silo/
  just help
  just harvest
```

The filesystem **is** the context. The justfile **is** the prompt.

---

## Discoverability

**The safety rail:**

```
just           → what can I do?
just help      → how does this silo work?
just help X    → what does X do?
just X         → just fcuking do X
```

No docs to read. No man pages. Just `just help`.

---

## Composability

Silos can nest or chain:

```
project/
├── silo_ingest/     → fetch, validate, split
├── silo_transform/  → enrich, aggregate, compute
├── silo_notify/     → alert, escalate, report
└── justfile         → orchestrate children
```

Each silo has its own vocabulary. The parent has its own.

---

## The Philosophy

> *"More context doesn't mean better results. Past a threshold, the noise drowns the signal."*

**The rule:** Give agents just enough vocabulary to act. No more.

| Without Silo | With Silo |
|-------------|-----------|
| Prompt every time | `cd silo` |
| Explain domain | Vocabulary embedded |
| Ad-hoc transforms | Named filters |
| Unbounded context | Bounded state |

---

## The Name

**Why "silo"?**

A silo stores grain. It keeps things contained, separated, and preserved.

A **just-silo** stores language. It keeps vocabulary scoped, contained, and executable.

**Silo:** The unit of lexical scope.

---

## The Promise

> *"Just fcuking do it."*

The vocabulary demands action. There's no passive voice in a silo.

```
just harvest     → do the harvest
just help harvest → describe the harvest
```

The command is the imperative. The directory is the scope. The justfile is the grammar.

**Just fcuking do it, or just forget it.**

---

## Summary

A just-silo is:

1. **A scoped lexicon** — vocabulary and grammar that lives in the filesystem
2. **An executable language** — justfile makes it runnable
3. **A context container** — externalizes what agents need to know
4. **A discoverable interface** — `just help` shows what's possible
5. **A portable pattern** — copy template, define domain, ship language

**Not a pipeline. Not a workflow. A language.**

*"just-silo it or just-forget it"* — because without scoped vocabulary, you just forget to do it right.

---

**Further reading:**
- `Silo-Manual.md` — Technical implementation
- `README.md` — Quick start
- `examples/silo_barley/` — Working example
