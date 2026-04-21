# QMD Agent Playbook

> How AI agents should use QMD for search, retrieval, and knowledge integration.

---

## Overview

QMD is an **on-device hybrid search engine for Markdown files**. It combines BM25 full-text search, vector semantic search, and LLM reranking — all running locally with no API keys or cloud services.

As an agent, you use QMD to find, retrieve, and reason over indexed Markdown content. It is your primary tool for searching knowledge bases, documentation, meeting transcripts, and any indexed Markdown corpus.

---

## Integration Methods

### Option 1: MCP Server (Preferred)

QMD exposes an MCP (Model Context Protocol) server. This is the tightest integration — tools appear natively in your tool palette.

**Tools exposed:**

| Tool | Purpose |
|------|---------|
| `query` | Hybrid search with typed sub-queries, RRF fusion, and reranking |
| `get` | Retrieve a single document by path or docid (with fuzzy matching) |
| `multi_get` | Batch retrieve by glob pattern, comma-separated list, or docids |
| `status` | Index health, collection info, and model status |

**Starting the server:**

```sh
qmd mcp                           # stdio transport (default)
qmd mcp --http                    # HTTP on localhost:8181
qmd mcp --http --daemon           # background daemon
```

**Daemon lifecycle:**

```sh
qmd mcp --http --daemon           # start
qmd status                        # check: shows "MCP: running (PID ...)"
qmd mcp stop                      # stop via PID file
```

Use the HTTP daemon when you need models to persist across requests (avoids ~2s cold start per query).

### Option 2: CLI Commands

When MCP is not available, invoke `qmd` directly via shell. Use structured output formats (`--json`, `--files`) for parsing results.

---

## Search Commands — When to Use Which

| Command | Backend | Speed | Quality | When to Use |
|---------|---------|-------|---------|-------------|
| `qmd search` | BM25 only | Fast | Good for exact terms | Keyword lookup, exact phrase matching, negation |
| `qmd vsearch` | Vector only | Medium | Good for concepts | Semantic similarity, natural language, paraphrases |
| `qmd query` | Hybrid (BM25 + Vector + Expansion + Rerank) | Slower | Best overall | Default choice for most searches |

**Rule of thumb:** Always start with `qmd query`. Fall back to `qmd search` only when you need speed and have precise keywords.

---

## Query Syntax

### Simple Query (Implicit Expand)

```sh
qmd query "how does authentication work"
```

The system auto-expands this into sub-queries, runs BM25 + vector on each, fuses via RRF, reranks, and returns the top results.

### Structured Query Document

When you know exactly what you want from each backend, use typed lines:

```sh
qmd query $'lex: "connection pool" timeout -redis\nvec: why do database connections time out under load'
```

**Line types:**

| Prefix | Backend | Best For |
|--------|---------|----------|
| `lex:` | BM25 full-text | Exact phrases (`"quoted"`), negation (`-term`), keyword matching |
| `vec:` | Vector search | Semantic similarity, natural language descriptions, conceptual queries |
| `hyde:` | HyDE (hypothetical document) | Generate a hypothetical answer and match against it |
| `intent:` | Pipeline-wide | Disambiguates the query across all stages (at most one per document) |

### Grammar

```
query          = expand_query | query_document
expand_query   = text | explicit_expand
explicit_expand= "expand:" text
query_document = [ intent_line ] { typed_line }
intent_line    = "intent:" text newline
typed_line     = type ":" text newline
type           = "lex" | "vec" | "hyde"
```

**Constraints:**
- Standalone expand queries cannot mix with typed lines.
- Query documents allow only `lex:`, `vec:`, or `hyde:` prefixes.
- Each typed line must be single-line text with balanced quotes.

### Using Intent

The `intent` parameter disambiguates ambiguous queries. It steers expansion, chunk selection, reranking, and snippet extraction without being searched on its own.

```sh
qmd query "performance" --intent "runtime speed optimization"
```

Or in a structured query:

```sh
qmd query $'intent: runtime speed optimization\nlex: performance\nvec: slow execution bottlenecks'
```

**Always provide intent when the query is ambiguous.** For example:
- `"risk"` → intent: `"regulatory compliance risk"` vs `"financial credit risk"`
- `"testing"` → intent: `"unit test coverage"` vs `"user acceptance testing"`
- `"report"` → intent: `"quarterly financial report"` vs `"incident report"`

---

## Output Formats

Choose the format based on how you'll consume the results:

| Flag | Format | When to Use |
|------|--------|-------------|
| (default) | Colorized CLI | Human reading, TTY output |
| `--json` | JSON with snippets | Programmatic parsing, structured data extraction |
| `--files` | docid, score, filepath, context | Getting a list of relevant files |
| `--md` | Markdown | Embedding results in Markdown documents |
| `--csv` | CSV | Spreadsheet import, tabular processing |
| `--xml` | XML | Systems that expect XML |

**For agent consumption, prefer `--json` or `--files`.**

### JSON Output

```sh
qmd query "authentication" --json -n 10
```

Returns structured results with: docid, score, title, path, snippet, context, and (with `--explain`) retrieval score traces.

### Files Output

```sh
qmd query "error handling" --all --files --min-score 0.4
```

Returns one result per line: `docid,score,filepath,context`. Ideal for getting a quick inventory of relevant documents.

---

## Document Retrieval

### Get a Single Document

```sh
# By path
qmd get "notes/meeting-2025-01-15.md"

# By docid (from search results)
qmd get "#abc123"

# With line range
qmd get "notes/meeting-2025-01-15.md:50" -l 100    # line 50 onwards, max 100 lines
```

**Always retrieve full documents with `--full` when you need the complete content:**

```sh
qmd get "docs/api-reference.md" --full
```

### Batch Retrieval

```sh
# Glob pattern
qmd multi-get "journals/2025-05*.md"

# Comma-separated list (supports docids)
qmd multi-get "doc1.md, doc2.md, #abc123"

# With limits
qmd multi-get "docs/*.md" --max-bytes 20480 -l 200
```

---

## Search Options Reference

| Flag | Default | Description |
|------|---------|-------------|
| `-n <num>` | 5 (20 for `--files`/`--json`) | Max results to return |
| `--all` | off | Return all matches (pair with `--min-score`) |
| `--min-score <num>` | 0 | Minimum similarity score (0.0–1.0) |
| `--full` | off | Output full document instead of snippet |
| `--line-numbers` | off | Include line numbers in output |
| `--explain` | off | Include retrieval score traces (JSON/CLI) |
| `--no-rerank` | off | Skip LLM reranking (faster, RRF scores only) |
| `-c, --collection <name>` | all | Restrict to one or more collections |
| `-C, --candidate-limit <n>` | 40 | Max candidates to rerank |

---

## Score Interpretation

| Score Range | Meaning |
|-------------|---------|
| 0.8 – 1.0 | Highly relevant — directly answers the query |
| 0.5 – 0.8 | Moderately relevant — contains useful information |
| 0.2 – 0.5 | Somewhat relevant — tangentially related |
| 0.0 – 0.2 | Low relevance — likely not useful |

**Use `--min-score 0.3` as a reasonable default filter** for most agent workflows.

---

## Common Agent Workflows

### Workflow 1: Answer a Question from the Knowledge Base

```
1. qmd query "<question>" --json -n 5 --min-score 0.3
2. Inspect results — check titles, scores, snippets
3. qmd get "<best_result_path>" --full   (or by docid)
4. Synthesize answer from retrieved content
```

**Tip:** If the initial results are poor, try:
- Adding `--intent` to disambiguate
- Using a structured query with `lex:` and `vec:` lines
- Increasing `-n` to cast a wider net
- Using `--no-rerank` for speed when you're iterating

### Workflow 2: Find All Documents on a Topic

```
1. qmd query "<topic>" --all --files --min-score 0.3
2. Review the file list
3. qmd multi-get "<pattern>" --json    (batch retrieve)
4. Process full content of all relevant documents
```

### Workflow 3: Check if Specific Information Exists

```
1. qmd search "<exact phrase or keywords>" -n 3
2. If found → retrieve full document
3. If not found → try semantic search:
   qmd vsearch "<natural language description>" -n 5
```

### Workflow 4: Compare Information Across Collections

```
1. qmd query "<topic>" -c collection-a --json -n 5
2. qmd query "<topic>" -c collection-b --json -n 5
3. Compare and synthesize
```

### Workflow 5: Trace a Timeline or Sequence

```
1. qmd search "<event or entity>" --all --files --min-score 0.2
2. Sort results by date (from filenames or content)
3. qmd multi-get "<sorted_file_list>" --json
4. Construct timeline from retrieved documents
```

---

## Best Practices for Agents

### 1. Start Broad, Then Narrow

Begin with `qmd query` for a broad search. If results are noisy, add `--intent`, use structured queries, or filter by collection with `-c`.

### 2. Use Intent for Ambiguous Queries

Always provide `--intent` when a query term has multiple meanings. This is the single most impactful quality lever.

### 3. Respect Score Thresholds

Don't waste context window on low-scoring results. Use `--min-score 0.3` as a baseline. For high-precision tasks, use `--min-score 0.5`.

### 4. Retrieve Before Reasoning

Search results give you snippets and scores. Always retrieve the full document (`qmd get --full`) before drawing conclusions. Snippets may miss critical context.

### 5. Use --files for Inventory, --json for Content

`--files` is fast and lightweight — use it to scan what's available. `--json` gives you snippets for preliminary judgment. Retrieve full documents only for the finalists.

### 6. Prefer --no-rerank for Iterative Searches

When you're running multiple searches to explore a topic, `--no-rerank` is significantly faster. Use full reranking for your final, definitive query.

### 7. Leverage Collections for Scope

If you know which collection is relevant, always specify `-c <name>`. This reduces noise and improves relevance.

### 8. Use Structured Queries for Precision

When you know the exact term AND want semantic expansion:

```sh
qmd query $'lex: "Companies House" appeal\nvec: regulatory filing deadline extensions'
```

This gives you both exact matches and conceptual coverage.

### 9. Handle Missing Collections Gracefully

If `qmd status` shows no collections, the knowledge base hasn't been indexed yet. You cannot search. Report this to the user and suggest:

```sh
qmd collection add <path> --name <name>
qmd embed
```

### 10. Check Status Before Deep Work

Run `qmd status` at the start of a session to understand:
- How many documents are indexed
- Which collections exist
- Whether vectors are up to date
- What chunking strategy is active

---

## MCP Tool Usage Patterns

### query Tool

```json
{
  "query": "authentication flow",
  "intent": "user login and session management",
  "collections": ["docs"],
  "limit": 5,
  "minScore": 0.3,
  "rerank": true
}
```

### get Tool

```json
{
  "path": "docs/api-reference.md",
  "full": true
}
```

Or by docid:

```json
{
  "path": "#abc123",
  "full": true
}
```

### multi_get Tool

```json
{
  "pattern": "meetings/2025-01*.md",
  "maxBytes": 20480,
  "limit": 200
}
```

### status Tool

```json
{}
```

Returns index health, collection list, document counts, and model information.

---

## Query Expansion — What Happens Under the Hood

Understanding the pipeline helps you write better queries:

1. **Query Expansion**: Your query is expanded into 2 alternative queries using a local fine-tuned model. The original query gets 2× weight.
2. **Parallel Retrieval**: Each query runs against both BM25 and vector indexes (6 total retrieval passes).
3. **RRF Fusion**: All results merged via Reciprocal Rank Fusion. Top-rank documents get a bonus.
4. **Top-K Selection**: Top 30 candidates selected for reranking.
5. **LLM Reranking**: Qwen3-Reranker scores each candidate with yes/no + logprobs confidence.
6. **Position-Aware Blend**: Final scores blend RRF and reranker scores, weighting RRF more for top-ranked results.

This means:
- **Short, natural language queries work well** — the expansion model handles variation.
- **Specific queries benefit from `lex:` lines** — to ensure exact terms aren't diluted.
- **The system tolerates typos in vector search** — but not in BM25.

---

## Troubleshooting

### No Results Found

1. Check `qmd status` — are there indexed documents?
2. Try `qmd search` with exact keywords — is the content there at all?
3. Try `qmd vsearch` — maybe the terms don't match but the meaning does.
4. Lower `--min-score` to 0.1 to see weak matches.

### Poor Quality Results

1. Add `--intent` to disambiguate.
2. Use structured queries with `lex:` for exact terms.
3. Increase `-n` and filter manually.
4. Try a different collection with `-c`.

### Slow Queries

1. Use `--no-rerank` to skip the reranking step.
2. Use `qmd search` (BM25 only) for fast keyword lookups.
3. Reduce `--candidate-limit` (default 40).
4. Use the HTTP daemon to keep models loaded: `qmd mcp --http --daemon`.

### Stale Results

The index doesn't auto-refresh. Re-index when content changes:

```sh
qmd update          # re-index all collections
qmd embed           # refresh vector embeddings
qmd update --pull   # git pull + re-index (for git-tracked collections)
```

---

## Quick Reference Card

```
# Search
qmd query "natural language query"                    # best quality
qmd query "query" --intent "disambiguation"           # disambiguate
qmd query $'lex: exact terms\nvec: semantic idea'     # structured
qmd search "exact keywords"                            # fast BM25
qmd vsearch "semantic description"                     # vector only

# Retrieve
qmd get "path/to/doc.md" --full                       # full document
qmd get "#docid" --full                               # by docid
qmd multi-get "pattern/*.md"                           # batch

# Filter/Format
-n 10          --min-score 0.3    --json    --files
--all          --no-rerank        --md      --csv
-c <name>      --explain          --xml     --full

# Maintenance
qmd status                   # check index health
qmd update                   # re-index
qmd embed                    # refresh vectors
qmd cleanup                  # clear caches
```
```

Path: bbl/playbooks/qmd-agent-playbook.md