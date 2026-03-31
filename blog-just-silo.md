# The Punchline: AI Agents Need Bounded Context

**Everyone's building AI agents. Nobody's solving the context problem.**

Every turn, an agent forgets. Every turn, you re-explain. Context injection becomes ritual. That's no way to ship.

Then it hit me: **the context should live in the filesystem.**

---

## You Have Stuff. You Want Things. You Create a Silo.

A silo is a pocket universe with its own rules.

```
STUFF ──→ [ SILO ] ──→ THINGS
          ┌─────────────────┐
          │ just harvest     │
          │ just status      │
          │ just alert...    │
          └─────────────────┘
```

You define the stuff. You define the things. The silo does the conversion.

**Any agent can drop in, read the rules, and do the job.**

---

## The Reveal

You don't pre-define the vocabulary. You just say what you want.

```
"I want to monitor grain moisture and alert when it's too high"
→ just harvest, just alert, just threshold...

"I want to review PRs and flag risky changes"
→ just scan, just score, just flag...
```

**You say the words. Just-silo makes them executable.**

Ask your AI: "Make up the vocabulary for [what I want]". Done.

---

## The Pocket Universe

When you're in, you can only do what it allows.

The rules are the rails. Constraints create capability. You can't do anything the silo doesn't allow. That's the point.

---

## The Tone

We don't need a SOTA model. We need a model that will just do it.

No framework friction. Get stuff. Turn it into things. Done.

**Any substrate worth its chips should be able to do it.**

---

## The Tool Is Called "Just"

The tool is called `just`. The usage is "just do it".

```
just harvest     → do the harvest
just help harvest → what will harvest do?
just help        → what can I do here?
just status      → see what's happening
```

**Scoped lexicon. Bounded context. Any agent, any turn, no explanation.**

---

## Try It

```bash
cp -r template my-silo && cd my-silo && just help
```

**Repo:** https://github.com/pjsvis/just-silo

The idea is simple. The implications are big. Context should be bounded, not infinite. Owned, not injected. Scoped, not global.

*Just do it.*

---

*What's a silo you wish existed?*
