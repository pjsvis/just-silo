# Show HN: Just-Silo — Bounded Context for AI Agents

**TL;DR:** Stop explaining context to agents every turn. Scoped a lexicon to a directory. Now agents just drop in and do the job.

---

Every turn, an agent loses its context. Every turn, you re-explain the domain. That's broken.

**The idea:** Make the context live in the filesystem. Agents drop in, read the rules, just do it.

```
STUFF ──→ [ SILO ] ──→ THINGS
          ┌─────────────────┐
          │ just harvest     │
          │ just status      │
          │ just alert...    │
          └─────────────────┘
```

You define the vocabulary. Any agent can drop in. Read the rules. Do the job.

**No context injection. No prompts. Just `cd` and do.**

---

**The reveal:** You don't pre-define the vocabulary. You just say what you want.

```
"I want to monitor grain moisture and alert when it's too high"
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes"
→ just scan, just score, just flag...
```

**You say the words. Just-silo makes them executable.**

Ask your AI: "Make up the vocabulary for [what I want]". Done.

---

**The pocket universe:**

When you're in, you can only do what it allows. Constraints create capability. The rules are the rails.

**No framework friction.** Get stuff. Turn it into things. Done. Any substrate worth its chips should be able to do it.

---

Repo: https://github.com/pjsvis/just-silo

Quick start:
```bash
cp -r template my-silo && cd my-silo && just help
```
