# just-silo - Directory-Based Skill Framework

## What Is This?

A silo is a scoped vocabulary (executable grammar) that lives in a directory.

Why? AI agents lose context every turn. A silo persists domain knowledge
in the filesystem. Hand an agent a silo and it acts without prior context.

## Quick Start

    just verify        # Check prerequisites
    just harvest       # Ingest data
    just process       # Run domain script
    just alerts        # Surface critical items
    just flush         # Archive output

## Core Workflow

    Mount -> Sieve -> Process -> Observe -> Flush

| Step    | Command       | Purpose             |
|---------|---------------|--------------------|
| Mount   | cd my-silo/   | Agent reads rules  |
| Sieve   | just harvest  | Validate + ingest   |
| Process | just process  | Run domain script   |
| Observe | just status   | Monitor pipeline    |
| Flush   | just flush    | Archive output      |

## Key Files

| File                  | Purpose                    |
|-----------------------|----------------------------|
| justfile              | Commands (just --list)     |
| Silo-Philosophy.md    | Why this exists            |
| Silo-Manual.md        | Technical details          |
| AGENTS.md             | Agent instructions         |
| silo-lexicon.jsonl    | Conceptual vocabulary      |

## How to Develop It

See playbooks/silo-builder-playbook.md for creating new silos.

## Philosophy

See Silo-Philosophy.md for the full philosophy.

**Bring your own inference.** A silo stores vocabulary and grammar,
not inference logic. You bring your own AI: Claude, GPT-4, local model.
The silo provides context; your inference engine provides cognition.

## Documentation

| Doc                                     | For                 |
|----------------------------------------|---------------------|
| playbooks/silo-user-playbook.md          | Using silos        |
| playbooks/silo-builder-playbook.md       | Creating silos     |
| playbooks/silo-agent-playbook.md         | Agent operations   |
| playbooks/tidy-first-playbook.md         | Workspace hygiene  |

## Status

Run just status to see current state.
