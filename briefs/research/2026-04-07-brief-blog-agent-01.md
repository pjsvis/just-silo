# Brief: blog-agent — Content Pipeline from Docs

**Date:** 2026-04-07  
**Author:** ses_cd8f9e  
**Status:** For implementation  
**Priority:** P3  

---

## Problem Statement

We have good ideas documented in playbooks, briefs, and debriefs. We have stories embedded in session logs and retrospectives. But we don't have blog posts.

The gap: Good content exists, but it's not accessible to readers.

---

## The Pattern: Extract → Weave → Publish

```
docs ──→ [wee-story extractor] ──→ [wee-stories bank] ──→ [blog weaver] ──→ post
           ↑                                                         │
           └────────────────── iterate ─────────────────────────────┘
```

**wee-story:** A small, self-contained anecdote that illustrates a concept. 2-5 sentences. Has a beginning, middle, end.

**wee-stories bank:** Curated collection of reusable stories. Taggable, searchable.

**blog weaver:** Agent that selects relevant stories and composes them into a post.

---

## Phase 1: Wee-Story Extraction

### Extraction Agent

Reads docs and extracts candidate stories:

```bash
# Input: *.md files from playbooks, briefs, debriefs
# Output: candidates.jsonl of story candidates

wee-story-extractor scan --source playbooks/ --output candidates.jsonl
```

### Candidate Format

```json
{
  "id": "ws-001",
  "source": "playbooks/td-playbook.md",
  "text": "We had a td database corrupt three times in one session. The fix: RAM disk. Now it runs on /Volumes/TD-RAMDisk and hasn't corrupted since.",
  "tags": ["td", "problem-solving", "ram-disk", "sqlite"],
  "concepts": ["ephemeral-data", "failure-recovery"],
  "quality_score": 0.8,
  "status": "candidate"
}
```

### Human Curation

Stories are candidates until human approves:

```bash
wee-story-extractor review          # Show candidates
wee-story-extractor approve ws-001 # Move to bank
wee-story-extractor reject ws-002  # Discard
wee-story-extractor bank --list    # Show approved
```

---

## Phase 2: Story Banking

### The Bank Structure

```
wee-stories/
├── bank.jsonl          # All approved stories
├── tags/
│   ├── td.jsonl        # Stories tagged "td"
│   ├── resonance.jsonl # Stories tagged "resonance"
│   └── ...
└── topics/
    ├── problem-solving.jsonl
    ├── agent-design.jsonl
    └── ...
```

### Bank Operations

```bash
wee-story bank add ws-001              # Add to bank
wee-story bank search "resonance"    # Find by tag
wee-story bank related ws-001         # Find similar
wee-story bank stats                  # Show counts by tag
```

---

## Phase 3: Blog Weaving

### Weaving Agent

Takes a topic and weaves stories into a post:

```bash
# Input: Topic, style guide, available stories
# Output: Draft blog post

blog-weaver weave \
  --topic "resonance communication" \
  --style guide.md \
  --output drafts/resonance-in-silos.md
```

### Weaving Process

1. **Parse topic** — Extract key concepts
2. **Find stories** — Search bank for related stories
3. **Draft structure** — Intro → concepts → stories → conclusion
4. **Weave stories** — Insert stories as illustrations
5. **Polish** — Flow, transitions, headline
6. **Output** — Draft ready for human review

### Example Output Structure

```markdown
# Resonance: Communication as Tuning

## The Problem

[Concept intro]

## The Insight

[Main concept explanation]

## The Story

> "We had a td database corrupt three times in one session..."

[Commentary on story]

## The Pattern

[Generalized learning]

## The Application

[How to apply it]

## Related Stories

- [ws-001] RAM disk story
- [ws-023] Brief drift story
```

---

## Phase 4: Human Review

### Review Flow

```bash
blog-weaver weave --topic X --output drafts/x.md
# Human edits drafts/x.md
# Human approves
# Publish
```

### Style Guide

```markdown
# Blog Style Guide

## Voice
- First person plural ("we", "our")
- Direct, practical, not academic
- Humorous but not flippant

## Structure
- Headline: Clear, not clickbait
- Intro: Problem or hook (2 sentences)
- Body: Concept → Story → Concept → Story
- Conclusion: Apply it

## Length
- Target: 800-1200 words
- Minimum: 400 words
- Maximum: 2000 words

## Formatting
- H2 for major sections
- H3 for subsections
- Blockquotes for stories
- Bold for key concepts
```

---

## File Structure

```
agents/
└── blog-agent/
    ├── src/
    │   ├── wee-story-extractor/
    │   │   ├── scanner.ts      # Find story candidates
    │   │   ├── parser.ts       # Extract story text
    │   │   └── scorer.ts       # Quality scoring
    │   ├── wee-story-bank/
    │   │   ├── store.ts        # Bank operations
    │   │   ├── search.ts       # Tag/search
    │   │   └── curate.ts       # Human curation
    │   ├── blog-weaver/
    │   │   ├── planner.ts      # Structure draft
    │   │   ├── selector.ts     # Pick stories
    │   │   ├── weaver.ts       # Compose
    │   │   └── polisher.ts     # Final touches
    │   └── index.ts
    ├── bank/
    │   └── .gitkeep
    ├── drafts/
    │   └── .gitkeep
    ├── templates/
    │   ├── story-candidate.md
    │   └── blog-post.md
    ├── style-guide.md
    ├── justfile
    └── README.md
```

---

## Commands

### Wee-Story Commands

```bash
wee-story scan          # Scan docs for candidates
wee-story bank --list   # Show bank contents
wee-story bank search <tag>
wee-story review        # Review candidates
wee-story approve <id>
wee-story reject <id>
wee-story stats         # Bank statistics
```

### Blog Commands

```bash
blog topics             # List available topics
blog weave <topic>      # Generate draft
blog drafts --list      # Show drafts
blog drafts --approve <draft>
blog drafts --reject <draft>
blog publish <draft>    # Move to _posts
```

---

## Integration with Other Agents

```
docs-agent          → Detects doc changes → Triggers story scan
tidy-first-agent   → Archives old docs → Maintains story source quality
briefs-agent        → Creates briefs → Briefs are story sources
debriefs-agent      → Creates debriefs → Debriefs are story sources
```

**Story sources:**
- Playbooks (patterns and anti-patterns)
- Briefs (problem → solution arc)
- Debriefs (experience → lesson arc)
- Session logs (raw stories)

---

## Acceptance Criteria

### Phase 1 (Extraction)
- [ ] Scanner finds candidates in docs
- [ ] Parser extracts story text
- [ ] Scorer rates quality
- [ ] Candidates exportable to candidates.jsonl

### Phase 2 (Banking)
- [ ] Stories can be added to bank
- [ ] Stories searchable by tag
- [ ] Human curation workflow works
- [ ] Bank stats show counts

### Phase 3 (Weaving)
- [ ] Weaves stories into coherent post
- [ ] Respects style guide
- [ ] Produces readable draft
- [ ] Includes proper attribution

### Phase 4 (Review)
- [ ] Draft workflow: weave → review → approve → publish
- [ ] Human can edit drafts
- [ ] Published posts go to _posts/

---

## Priority Rationale

P3: Content pipeline is valuable for external communication but doesn't affect core product quality. Lower than agents that affect code/docs quality.

---

## Related

- `playbooks/blog-process-playbook.md` — Manual blog workflow (if exists)
- `briefs/research/2026-04-07-brief-resonance-01.md` — Resonance concept (story source)
