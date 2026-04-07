# Brief: Blog Workflow - Story Extraction Pipeline

**Date:** 2026-04-07
**Status:** Proposed
**Priority:** P2

---

## Problem Statement

We have extensive documentation (briefs, debriefs, playbooks, docs) but no systematic way to extract narrative elements ("wee stories") for blog content.

---

## Concept

```
briefs/docs/ → [story-scanner] → stories.jsonl → [blog-generator] → _posts/
```

**"Wee stories"** are compact narrative elements extracted from documentation:
- Origin stories ("How we discovered X")
- Lessons learned ("What we got wrong")
- Process insights ("Why we built it this way")
- Anti-patterns ("What to avoid")

---

## Story Schema

```jsonl
{"id": "uuid", "source": "file.md", "type": "origin|lesson|insight|anti-pattern", "narrative": "...", "tags": [], "usefulness": "high|medium|low", "created": "ISO8601"}
```

### Example

```jsonl
{"id": "gamma-loop-origin", "source": "brief-gamma-loop-01.md", "type": "insight", "narrative": "The gamma-loop concept emerged from neurophysiology - the feedback mechanism that maintains muscle tone without conscious thought.", "tags": ["gamma-loop", "concept", "bio-mimicry"], "usefulness": "high", "created": "2026-04-07T10:00:00Z"}
```

---

## Pipeline Components

### 1. Story Scanner

```bash
# Extract stories from all docs
./scripts/story-scan.sh

# Scan specific file
./scripts/story-scan.sh briefs/brief-gamma-loop-01.md
```

**Scanner logic:**
- Look for narrative paragraphs (not headers/lists/code)
- Identify story types by markers (origin, lesson, insight, anti-pattern)
- Extract to stories.jsonl

### 2. Story Index

```jsonl
{"id": "...", "source": "...", "type": "...", "narrative": "...", "tags": [...]}
```

Stored in: `stories/stories.jsonl`

### 3. Blog Generator

```bash
# Generate post from stories
./scripts/blog-generate.sh --tag gamma-loop

# Generate with template
./scripts/blog-generate.sh --template technical --stories 5
```

**Output:** `_posts/YYYY-MM-DD-title-slug.md`

---

## Commands

```bash
just blog-scan         # Scan docs for stories
just blog-list         # List all stories
just blog-search TAG   # Find stories by tag
just blog-generate TAG # Generate post from stories
```

---

## Directory Structure

```
silo/
├── stories/
│   ├── stories.jsonl      # Story index
│   └── _archive/          # Old stories
├── _posts/                # Generated posts
└── scripts/
    ├── story-scan.sh      # Extract stories
    ├── story-list.sh      # List stories
    ├── story-search.sh    # Search stories
    └── blog-generate.sh   # Generate posts
```

---

## Implementation Plan

1. **Create `scripts/story-scan.sh`** — Extract stories from docs
2. **Create `stories/` directory** — Story storage
3. **Create `scripts/story-list.sh`** — List/search stories
4. **Scan existing docs** — Extract initial story set
5. **Create `scripts/blog-generate.sh`** — Generate posts

---

## Inspiration

Stories should answer:
- "How did we get here?"
- "What did we learn?"
- "Why does this work?"
- "What should we avoid?"

---

## For Next Session

- Implement story scanner
- Scan existing briefs for stories
- Build initial story index
