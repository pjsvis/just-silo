# QMD User Playbook

> A practical guide for setting up, managing, and searching your documents with qmd.

---

## Overview

qmd is an on-device search engine for Markdown files. It runs entirely locally — no cloud APIs, no data leaving your machine. It combines three search strategies:

| Command | Strategy | Speed | Quality | When to Use |
|---------|----------|-------|---------|-------------|
| `qmd search` | BM25 keywords | Fast | Good for exact terms | You know the exact words |
| `qmd vsearch` | Vector similarity | Medium | Good for concepts | You want semantic matching |
| `qmd query` | Hybrid + LLM reranking | Slower | Best quality | General purpose, exploratory |

All three use local GGUF models downloaded automatically to `~/.cache/qmd/models/`.

---

## 1. Installation

```sh
# Via Bun (recommended)
bun install -g @tobilu/qmd

# Via npm
npm install -g @tobilu/qmd

# One-off run (no install)
bunx @tobilu/qmd ...
```

**Requirements:**
- Node.js >= 22 or Bun >= 1.0.0
- macOS: `brew install sqlite` (for extension support)
- ~2 GB disk space for models (auto-downloaded on first use)

Verify the install:

```sh
qmd --version      # should print 2.1.0 or later
qmd status         # shows index health, GPU info, models
```

---

## 2. Setting Up Collections

A **collection** is a folder of Markdown files that qmd indexes. You can have multiple collections in a single index.

### Add Your First Collection

```sh
# From inside a folder
cd ~/my-project
qmd collection add . --name myproject

# Or point at an explicit path
qmd collection add ~/Documents/notes --name notes

# With a custom file pattern (default: **/*.md)
qmd collection add ~/code/myapp --name myapp --mask "**/*.md"
```

### Manage Collections

```sh
qmd collection list              # see all collections
qmd collection show notes        # details for one collection
qmd collection rename old new    # rename
qmd collection remove notes      # remove (de-indexes, doesn't delete files)
qmd ls notes                     # list indexed files in a collection
qmd ls notes/subfolder           # list files in a sub-path
```

### Multiple Collections

You can index separate knowledge bases side by side:

```sh
qmd collection add ~/notes --name personal
qmd collection add ~/work/docs --name work
qmd collection add ~/meetings --name meetings
```

---

## 3. Adding Context

Context is the most underrated feature. It attaches descriptive metadata to collections and paths, and that context is returned alongside search results. This dramatically improves relevance, especially for ambiguous queries.

```sh
# Context for a whole collection
qmd context add qmd://notes "Personal notes, journal entries, and ideas"
qmd context add qmd://meetings "Meeting transcripts and action items"

# Context for a sub-path within a collection
qmd context add qmd://docs/api "REST API reference documentation"
qmd context add qmd://docs/architecture "System architecture decision records"

# Global context (applies to all collections)
qmd context add / "Knowledge base for project documentation"

# Review what you've set
qmd context list

# Remove context
qmd context rm qmd://notes/old-section
```

**Tip:** Spend 2 minutes adding context when you create a collection. It pays off on every subsequent search.

---

## 4. Indexing and Embedding

After adding collections, you need to index and embed the files.

### Step 1: Re-index (scan for file changes)

```sh
qmd update                # re-index all collections
qmd update --pull         # re-index + git pull first (for git repos)
```

### Step 2: Generate Vector Embeddings

```sh
qmd embed                 # embed all new/changed documents
qmd embed -f              # force re-embed everything
qmd embed --chunk-strategy auto   # AST-aware chunking for code files
```

**AST-aware chunking** (`--chunk-strategy auto`) uses tree-sitter to chunk TypeScript, JavaScript, Python, Go, and Rust files at function and class boundaries instead of arbitrary positions. This gives better search results for codebases. The default is `regex` which uses smart Markdown break-point detection.

**Typical workflow after adding or changing files:**

```sh
qmd update && qmd embed
```

---

## 5. Searching

### Quick Keyword Search (`qmd search`)

Fast BM25 full-text search. Best when you know the exact words you're looking for.

```sh
qmd search "authentication"
qmd search "BBLS term loan" -c regulatory      # limit to one collection
qmd search "deadline" -n 10                    # more results
qmd search "payment plan" --full               # full document content
```

### Semantic Search (`qmd vsearch`)

Vector similarity. Good for conceptual queries where the exact wording may differ.

```sh
qmd vsearch "how does the appeals process work"
qmd vsearch "bank failing to follow regulations"
qmd vsearch "what are my rights as a borrower"
```

### Hybrid Search (`qmd query`) — Recommended

Combines BM25 + vector + LLM query expansion + LLM reranking. This is the best-quality search mode.

```sh
# Simple natural language
qmd query "how does the dispute escalation process work"

# With intent (disambiguates what you mean)
qmd query "performance" --intent "bank's failure to meet regulatory deadlines"

# Limit results and set quality threshold
qmd query "breach of regulations" -n 10 --min-score 0.3

# Skip reranking for faster results (useful on CPU-only machines)
qmd query "loan terms" --no-rerank

# Filter to a specific collection
qmd query "meeting notes about appeal" -c meetings
```

### Understanding Scores

| Score | Meaning |
|-------|---------|
| 0.8 – 1.0 | Highly relevant |
| 0.5 – 0.8 | Moderately relevant |
| 0.2 – 0.5 | Somewhat relevant |
| 0.0 – 0.2 | Low relevance |

Use `--min-score` to filter out noise:

```sh
qmd query "deadline enforcement" --min-score 0.4
```

---

## 6. Retrieving Documents

### Get a Single Document

```sh
# By file path
qmd get "meetings/2026-01-15.md"

# By docid (shown in search results as #abc123)
qmd get "#abc123"

# Starting at a specific line, with a line limit
qmd get "notes/long-file.md:50" -l 100

# Full document
qmd get "docs/guide.md" --full
```

### Batch Retrieval (`qmd multi-get`)

```sh
# Glob pattern
qmd multi-get "journals/2025-05*.md"

# Comma-separated list (mixes paths and docids)
qmd multi-get "doc1.md, doc2.md, #abc123"

# Limit file size and line count
qmd multi-get "docs/*.md" --max-bytes 20480 -l 50
```

---

## 7. Output Formats

Useful for exporting, scripting, or feeding into other tools:

```sh
qmd query "auth flow" --json          # structured JSON
qmd query "auth flow" --md            # Markdown
qmd query "auth flow" --csv           # CSV
qmd query "auth flow" --xml           # XML
qmd query "auth flow" --files         # just file paths
qmd query "auth flow" --json --explain  # includes score breakdown
qmd query "auth flow" --line-numbers  # add line numbers to snippets
```

---

## 8. Editor Integration

qmd emits clickable terminal hyperlinks (OSC 8) when running in a TTY. Click a search result to open it in your editor at the exact line.

Configure the editor target:

```sh
# VS Code (default)
export QMD_EDITOR_URI="vscode://file/{path}:{line}:{col}"

# Cursor
export QMD_EDITOR_URI="cursor://file/{path}:{line}:{col}"

# Zed
export QMD_EDITOR_URI="zed://file/{path}:{line}:{col}"
```

Add the export to your shell profile (`~/.zshrc`, `~/.bashrc`) for persistence.

---

## 9. Maintenance

### Regular Maintenance

```sh
qmd status              # check index health, collection stats
qmd update              # re-index after file changes
qmd embed               # re-embed new/changed files
qmd cleanup             # clear caches, vacuum the database
```

### When Things Go Wrong

```sh
# Force full re-embed (e.g., after changing embedding model)
qmd embed -f

# Check index health
qmd status

# Nuclear option — delete and reindex
rm ~/.cache/qmd/index.sqlite
qmd collection add . --name myproject
qmd update && qmd embed
```

### Switching Embedding Models

```sh
# Use a multilingual model (e.g., for CJK content)
export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"
qmd embed -f   # must re-embed all vectors after switching
```

---

## 10. Day-to-Day Workflow

Here's a typical daily workflow:

```sh
# Morning: pull latest changes and re-index
qmd update --pull && qmd embed

# During the day: search as needed
qmd query "what did we decide about the escalation timeline"
qmd search "BR-001" -c evidence

# Retrieve a specific document you found
qmd get "#a1b2c3"

# End of day: quick cleanup
qmd cleanup
```

---

## 11. Configuration File (Optional)

For persistent config, create a `qmd.yml` or `index.yml`:

```yaml
editor_uri: "cursor://file/{path}:{line}:{col}"

models:
  embed: "hf:ggml-org/embeddinggemma-300M-GGUF"
  rerank: "hf:ggml-org/Qwen3-Reranker-0.6B-Q8_0-GGUF"
  generate: "hf:tobil/qmd-query-expansion-1.7B-gguf"
```

---

## 12. Cheatsheet

| Task | Command |
|------|---------|
| Install | `bun install -g @tobilu/qmd` |
| Add collection | `qmd collection add ~/path --name X` |
| Add context | `qmd context add qmd://X "description"` |
| Index files | `qmd update` |
| Generate embeddings | `qmd embed` |
| Keyword search | `qmd search "exact terms"` |
| Semantic search | `qmd vsearch "conceptual query"` |
| Best-quality search | `qmd query "natural language"` |
| With intent | `qmd query "term" --intent "what I mean"` |
| Get document | `qmd get "path/file.md"` or `qmd get "#docid"` |
| Get multiple | `qmd multi-get "pattern*.md"` |
| JSON output | `qmd query "x" --json` |
| Score breakdown | `qmd query "x" --json --explain` |
| Check health | `qmd status` |
| Clean up | `qmd cleanup` |
| Fast hybrid (no rerank) | `qmd query "x" --no-rerank` |

---

## 13. Troubleshooting

| Problem | Solution |
|---------|----------|
| No results from search | Run `qmd update && qmd embed` |
| Low-quality results | Add context with `qmd context add` |
| Slow queries | Use `--no-rerank` or `qmd search` (BM25 only) |
| Embedding stalls | `qmd embed -f` to force re-embed |
| ABI mismatch error | Ensure runtime matches installer (bun vs node) |
| GPU not detected | Falls back to CPU automatically; slower but functional |
| Out of memory during embed | `qmd embed --max-docs-per-batch 50 --max-batch-mb 100` |

---

*Last updated: 2026-04-20 · qmd v2.1.0*