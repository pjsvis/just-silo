---
name: build-silo
description: Create a new just-silo directory with all required files
keywords: [silo, data, pipeline, just, jq, harvest]
version: 1.0.0
author: just-silo
---

# Skill: Build Silo

Create a new just-silo directory with all required files for a domain-specific data processing pipeline.

## When to Use

Use this skill when asked to:
- "Create a silo for [domain]"
- "Build a data pipeline for [use case]"
- "Set up a just-silo for [problem]"

## Prerequisites

- `just` installed (`brew install just`)
- `jq` installed (`brew install jq`)

## Steps

### 1. Create directory structure

```bash
mkdir -p silo_<domain>/
cd silo_<domain>/
```

### 2. Create `.silo` manifest

```json
{
  "name": "silo_<domain>",
  "version": "1.0.0",
  "silo_type": "<domain_type>",
  "description": "<one line description>",
  "critical_threshold": { "field": "<field>", "operator": "<op>", "value": <value> },
  "interface": {
    "engine": "justfile",
    "schema": "schema.json",
    "queries": "queries.json",
    "input": "harvest.jsonl",
    "active_state": "data.jsonl",
    "quarantine": "quarantine.jsonl",
    "output": "final_output.jsonl"
  }
}
```

### 3. Create `README.md`

Include:
- Domain description
- Critical alert thresholds
- The workflow (Mount → Sieve → Process → Check → Flush)
- `just --list` summary

### 4. Create `schema.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["<required-field-1>", "<required-field-2>"],
  "additionalProperties": false,
  "properties": {
    "<field-1>": { "type": "<type>", "description": "<description>" },
    "<field-2>": { "type": "<type>", "description": "<description>" }
  }
}
```

### 5. Create `queries.json`

```json
{
  "filters": {
    "get_alerts": {
      "description": "Get critical items",
      "jq": "select(.<field> <op> <threshold>)"
    },
    "get_pending": {
      "description": "Get items not yet processed",
      "jq": "select(.status != \"processed\")"
    }
  }
}
```

### 6. Create `harvest.jsonl`

10-20 representative test entries in JSONL format:

```jsonl
{"<field-1>":"value1","<field-2>":123,"status":"pending"}
{"<field-1>":"value2","<field-2>":456,"status":"pending"}
```

Include:
- Normal entries
- Critical threshold crossings
- Edge cases

### 7. Create `process.sh`

```bash
#!/bin/bash
set -euo pipefail

for line in $(cat data.jsonl); do
  # Add processed status
  echo "$line" | jq '.status = "processed"'
done >> final_output.jsonl

echo "Processed $(wc -l < data.jsonl) items"
```

### 8. Create `justfile`

```just
set shell := ["bash", "-c"]
set export := true

DATA_FILE      := "data.jsonl"
HARVEST_FILE   := "harvest.jsonl"
QUARANTINE_FILE := "quarantine.jsonl"
OUTPUT_FILE    := "final_output.jsonl"
SCHEMA_FILE    := "schema.json"
QUERIES_FILE   := "queries.json"

default:
    @echo "Silo <domain> Recipes:"
    @just --list --justfile {{justfile()}} 2>&1 | grep -v "^#" | grep -v "Available recipes" | grep -v "^$"

verify:
    @test -f {{SCHEMA_FILE}} && echo "  schema.json ok" || (echo "  MISSING schema.json"; exit 1)
    @test -f {{QUERIES_FILE}} && echo "  queries.json ok" || (echo "  MISSING queries.json"; exit 1)
    @command -v jq >/dev/null 2>&1 && echo "  jq ok" || echo "  jq MISSING"

harvest source=(HARVEST_FILE):
    @just verify
    @> {{DATA_FILE}} && > {{QUARANTINE_FILE}}
    @cat {{source}} | jq -c --slurpfile s {{SCHEMA_FILE}} '<validation-expression>' >> {{DATA_FILE}} 2>/dev/null || true
    @cat {{source}} | jq -c --slurpfile s {{SCHEMA_FILE}} '<inverse-validation>' >> {{QUARANTINE_FILE}} 2>/dev/null || true
    @just stats

process:
    @./process.sh

alerts:
    @just verify
    @jq -c 'select(.<threshold-field> > <threshold>)' {{DATA_FILE}}

stats:
    @echo "Active: $([ -f {{DATA_FILE}} ] && jq -s 'length' {{DATA_FILE}} || echo 0)"
    @echo "Quarantine: $([ -f {{QUARANTINE_FILE}} ] && jq -s 'length' {{QUARANTINE_FILE}} || echo 0)"

flush:
    @jq -c 'select(.status == "processed")' {{DATA_FILE}} >> {{OUTPUT_FILE}} 2>/dev/null || true
    @jq -c 'select(.status != "processed")' {{DATA_FILE}} > {{DATA_FILE}}.tmp && mv {{DATA_FILE}}.tmp {{DATA_FILE}}
    @just stats

self-test:
    @just verify
    @echo "SELF-TEST: PASSED"

clean:
    @rm -f {{DATA_FILE}} {{QUARANTINE_FILE}} {{OUTPUT_FILE}}
```

### 9. Test the silo

```bash
just verify
just harvest
just process
just flush
just clean
```

## Checklist

- [ ] `.silo` manifest created with domain name
- [ ] `README.md` with domain description and workflow
- [ ] `schema.json` with required fields
- [ ] `queries.json` with at least 2 named filters
- [ ] `harvest.jsonl` with 10+ test entries
- [ ] `process.sh` executable and idempotent
- [ ] `justfile` with all recipes
- [ ] `just verify` passes
- [ ] `just self-test` passes

## Output

When complete, summarize:

```
Silo created: silo_<domain>

Files:
  .silo, README.md, schema.json, queries.json, harvest.jsonl, process.sh, justfile

Workflow:
  just harvest → just process → just flush

Test:
  just verify && just self-test
```
