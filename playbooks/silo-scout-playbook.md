# Silo Scout Playbook

**For agents entering unknown silos.**

---

## The Inversion

```
OLD: How smart should I be?
NEW: See that silo? What's in it?
```

**Start from what's there. Assess first. Then act.**

---

## The Scout Mindset

**Accept:**
- Incomplete information
- Variable capabilities
- Imperfect tools
- "Good enough" output

**Do:**
- Best with what you have
- Output something
- Forward motion

**Don't:**
- Block on perfection
- Retrospect endlessly
- Wait for ideal conditions

---

## Scout Protocol

```
1. ENTER: cd into the silo
2. ASSESS: What's in it? (just help)
3. EVALUATE: Can I work with this?
4. PROCEED or EXIT
5. PROCESS: Best you can with your capabilities
6. OUTPUT: Include honest assessment ("these are shite")
7. NOTIFY: Tell interested parties
8. MOVE ON: Next job
```

---

## The Hotel Paris Example

```
┌─────────────────────────────────────┐
│         HOTEL_PARIS                │
│                                     │
│  Input: "Find me a hotel"         │
│                                     │
│  Agent without web:                 │
│  → Training data → general recs    │
│                                     │
│  Agent with web:                   │
│  → Search → specific recs         │
│                                     │
│  Output:                            │
│  → Top 5 recommendations          │
│  → "These are shite"               │
│  → "Need verification"             │
│                                     │
│  Both: Done. Move on.              │
└─────────────────────────────────────┘
```

**Same silo. Same output format. Different agents. Different quality. All done.**

---

## Output Pattern

```
STUFF IN: Raw input
PROCESS: Best evaluation
STUFF OUT:
  - Recommendations (or "I can't do this")
  - Honest assessment ("these are shite")
  - Confidence level
  - What needs more work
NOTIFY: Whoever needs it
MOVE ON: Don't look back
```

---

## Forward Motion

**Data flows. Agents act. That's it.**

```
Input → Process → Output → Notify → Move On
                      ↑
              Even "I can't do this" is output
```

---

## Remember

**The silo is the constant. The agent is the variable.**

- Same interface regardless of agent capability
- Quality varies, workflow doesn't
- "Done" is "done", not "perfect"

**Accept. Process. Output. Notify. Move on.**

---

## Assessing Silo Complexity

**Quick triage when entering an unknown silo:**

```bash
# 30-second assessment
just help              # How many verbs? (< 10 is healthy)
just status            # How many stages? (< 7 is healthy)
ls -la | grep -c \.ts  # How much code? (< 5 .ts files is healthy)
```

**Complexity signals:**

| Signal | Interpretation |
|--------|----------------|
| >10 verbs in `just --list` | Over-engineered |
| >7 pipeline stages | Consider splitting |
| Multiple .ts files in root | Complexity creeping |
| External npm deps | Maintenance burden |
| README >500 words | Documentation debt (they're explaining instead of simplifying) |

**The scout's choice:**
- Complex silo + complex task → Do your best, flag complexity
- Simple silo + complex task → Suggest simplification first
- Any silo + simple task → Just do it

## The Bucket List

| Item | Status |
|------|--------|
| Procedural lexicon (just-silo) | ✅ |
| Scout playbook | ✅ (this) |
| Semantic lexicon | 📋 |
| Core directives | 📋 |

---

*The silo doesn't care who's visiting. It takes input, produces output. The agent adapts.*
