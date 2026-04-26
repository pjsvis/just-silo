# AI Legislation Silo

A working example of the **silo framework**.

## What It Is

A filesystem pipeline that turns raw AI legislation into structured compliance artifacts.

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

```
ai-legislation-silo/
├── .silo              # Manifest
├── README.md          # This file
├── justfile           # Workflow recipes
├── inbox/             # Raw inputs
│   ├── harvest.jsonl  # Legislation provisions (JSONL)
│   └── inputs/        # Documents, PDFs, profiles
├── process/           # Transformation scripts
│   └── (scripts that read inbox/ → write outbox/)
├── outbox/            # Deliverables
│   ├── core-directives.md
│   └── conceptual-lexicon.md
├── markers/           # Checkpoint system
└── telemetry/         # Cost/token logs
```

## The Three Questions

Every silo answers these before it runs:

| Question | Answer (for this silo) |
|----------|-------------------------|
| **What do we get?** | Raw legislation provisions (EU AI Act, NIST AI RMF, etc.) as JSONL entries |
| **When do we get it?** | Up front — placed in `inbox/harvest.jsonl` or `inbox/inputs/` |
| **What do we do with it?** | Validate, extract, organize, interview the user, construct tailored directives |
| **What is the end result?** | `outbox/core-directives.md` and `outbox/conceptual-lexicon.md` |
| **How do we know we have it?** | Files exist, non-empty, validated against schema |

## Running the Silo

```bash
cd examples/ai-legislation-silo/
just --list          # See available recipes
just run             # Execute full pipeline
just status          # Check pipeline state
just audit           # Cost and coverage report
```

## Validation

A silo is "done" when:

1. `outbox/core-directives.md` exists and is non-empty
2. `outbox/conceptual-lexicon.md` exists and is non-empty
3. Both files validate against the conceptual schema
4. Telemetry shows the pipeline completed all phases

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
