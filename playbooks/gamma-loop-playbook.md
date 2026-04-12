# Gamma-Loop Playbook

## The Pattern

Whenever we learn a lesson, we capture it.

```
Develop → Verb → Document → Tidy
```

---

## The Gamma-Loop

**Gamma** = the third letter. After alpha (first attempt), beta (iteration), gamma (learning).

### The Cycle

1. **Develop** — Figure it out. Get it working.
2. **Verb** — Add `just` verbs. Make it repeatable.
3. **Document** — Write playbook, brief, or debrief.
4. **Tidy** — Prune dead verbs, stale docs, old briefs.

### When to Run

- End of every session
- When a pattern emerges
- Before starting something new

---

## How It Works

### 1. Develop

```
cd new-thing
# Figure it out
command --that --works
```

### 2. Verb

```bash
# Add to justfile
do-thing ARG:
    command --that --works {{ARG}}
```

### 3. Document

Create a playbook:
```bash
# playbooks/new-thing-playbook.md
# How to use the thing
```

Or update an existing one.

### 4. Tidy

```bash
just tidy-first
```

Prune:
- Dead verbs
- Stale docs
- Old briefs without follow-up
- Unused scripts

---

## Example: PXY Presentation

**Develop:**
- Figured out WebSocket push works
- Markdown renders on server
- Theme switching via JSON message

**Verb:**
```bash
just present    # Start + display
just push 01    # Show slide
just theme dark # Switch theme
```

**Document:**
- `playbooks/presentation-playbook.md`
- `briefs/.../pxy-presentation-brief.md`
- `debriefs/.../pxy-presentation-debrief.md`

**Tidy:**
- Deprecated old server scripts (Python, Node)
- Marked agent scripts as deprecated
- Updated AGENTS.md

---

## Tidy-First Triggers

Run `just tidy-first` when:

| Trigger | Action |
|---------|--------|
| Session end | Prune dead verbs, mark stale docs |
| New domain starts | Archive old briefs without follow-up |
| 10+ briefs | Archive oldest 5 |
| Verb not used in 30 days | Prune or comment |
| Script > 3 files | Split or archive |

---

## The Benefit

**Alpha** = figuring it out
**Beta** = making it work
**Gamma** = learning from it

The gamma-loop ensures:
- Knowledge persists
- Commands stay clean
- Context transfers between sessions

---

## See Also

- `playbooks/td-playbook.md` — Local-first task management
- `playbooks/presentation-playbook.md` — Example of gamma-loop in action
