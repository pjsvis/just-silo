# AI Legislation Silo

A working example of the **silo framework**.

## Workflow

```dot
digraph silo {
  rankdir=TB;
  node [shape=box style=rounded fontname="Helvetica" fontsize=12];
  edge [fontname="Helvetica" fontsize=10];

  inbox [label="INBOX\nraw legislation\nharvest.jsonl\ninputs/" fillcolor=lightblue];
  process [label="PROCESS\ntransform scripts\njustfile recipes\nvalidation" fillcolor=lightyellow];
  outbox [label="OUTBOX\ncompliance artifacts\ncore-directives.md\nconceptual-lexicon.md" fillcolor=lightgreen];

  inbox -> process [label="ingest"];
  process -> outbox [label="deliver"];
}
```

## Directory Structure

This silo follows the four-layer model:

```
ai-legislation-silo/
│
├── .silo              # Manifest (layer references)
├── README.md          # This file
│
├── justfile           # LAYER 3: Our Code — task facade
├── process/           # LAYER 3: Our Code — transformation scripts
├── inbox/             # LAYER 3: Our Code — raw inputs
│   ├── harvest.jsonl
│   └── inputs/
├── outbox/            # LAYER 3: Our Code — deliverables
│   ├── core-directives.md
│   └── conceptual-lexicon.md
├── scripts/           # LAYER 3: Our Code — (optional, not yet used)
├── src/               # LAYER 3: Our Code — (optional, not yet used)
│
├── briefs/            # LAYER 4: Thinking — what we're considering
├── debriefs/          # LAYER 4: Thinking — what we learned
├── playbooks/         # LAYER 4: Thinking — how we operate
│
├── markers/           # LAYER 3: checkpoint system
├── telemetry/         # LAYER 3: cost/token logs
│
│   (bun, TypeScript, hono — LAYER 2: Runtime — assumed present)
│   (flox, jq, pandoc — LAYER 1: Environment — declared in Flox)
```

## Documentation

| Folder | Purpose |
|--------|---------|
| `briefs/` | Active research, plans, open questions about this domain |
| `debriefs/` | Retrospectives, decisions, lessons learned per session |
| `playbooks/` | Operational procedures: how to convert PDFs, how to tag provisions, how to interview |

These folders keep the silo's thinking durable. The agent (and human) can read them to resume work without context loss.

## Running the Silo

```bash
cd examples/ai-legislation-silo/
just --list          # See available recipes
just run             # Execute full pipeline
just status          # Check pipeline state
just audit           # Cost and coverage report
```

## Using as a Template

Copy the directory, edit `.silo` and `README.md` for your domain, populate `inbox/` with your raw data, write `process/` scripts for your transformation:

```bash
cp -r examples/ai-legislation-silo/ silos/my-domain-silo/
cd silos/my-domain-silo/
# Edit .silo, README.md
# Populate inbox/
# Write process/ scripts
just run
```
