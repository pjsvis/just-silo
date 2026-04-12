# The Silo Developer Handbook
## Build AI That Actually Ships

**Version:** 0.1  
**Vibe:** Technical. Practical. No bullshit.

---

## What Is This?

You're going to build AI-powered workflows that:
- Actually work in production
- Don't cost a fortune
- Don't require a PhD to maintain
- Make you look good to your employer

This handbook shows you how.

---

## Core Concept: The Silo

A silo is a directory. That's it.

```
my-silo/
├── justfile              # The interface
├── config.yaml           # The behaviour
├── constraints/          # What it can't do
├── conceptual-lexicon/   # What words mean here
├── inbox/                # Work waiting
├── outbox/
│   ├── good/             # Stuff that worked
│   └── not-good/         # Stuff that didn't
└── logs/                 # What happened
```

Everything is a file. Deploy it by copying it. Rollback by restoring it. Debug it by reading it.

---

## The Justfile: Your API

The `justfile` is the interface to your silo. Devs use it. Agents use it. Same commands.

```just
# === Discovery ===

# List what this silo can do
default:
    @just --list

# Show current status
status:
    @echo "Inbox: $(ls inbox | wc -l) items"
    @echo "Good: $(ls outbox/good | wc -l) items"
    @echo "Not-good: $(ls outbox/not-good | wc -l) items"

# Show entropy (quality metric)
entropy:
    @python scripts/entropy.py

# === Execution ===

# Process all items in inbox
process:
    python scripts/process.py

# Process a single item
process-one item:
    python scripts/process.py --item={{item}}

# === Agent Interface ===

# Load context for agent (CL + constraints)
_context:
    @cat conceptual-lexicon/*.yaml
    @cat constraints/*.yaml

# Structured output for agent consumption
_report format="json":
    python scripts/report.py --format={{format}}

# === Dev Tools ===

# Run tests
test:
    pytest tests/

# Interactive debug shell
dev-shell:
    ipython -i scripts/debug.py

# Deploy to production
deploy env="staging":
    ./scripts/deploy.sh {{env}}

# Check what changed
diff:
    git diff HEAD~1
```

**Key principle:** Agents discover capabilities with `just --list`, same as you. No special API. No gateway. Just the justfile.

---

## The Conceptual Lexicon

Your silo has its own vocabulary. Define it.

```yaml
# conceptual-lexicon/core.yaml

entropy:
  definition: "Ratio of not-good to total outputs"
  note: "Trend matters more than absolute value"
  
pocket_universe:
  definition: "Encapsulated capability unit"
  note: "The silo IS the pocket universe"
  
reasoning_engine:
  definition: "The AI model used for processing"
  note: "Ephemeral. Spins up, does work, terminates."
```

**Why this matters:**

Every time you spin up an agent, it's a 50-First-Dates scenario. The agent doesn't remember your terminology from last time.

The CL fixes this. Load it into context at the start of every task. Now the agent knows what "entropy" means *in your system*, not the thermodynamics definition.

```just
# Agent loads context first
_context:
    @cat conceptual-lexicon/*.yaml
```

No drift. No confusion. Anchored semantics from line one.

---

## The 50 First Dates Problem

Traditional AI: Long sessions. Build rapport. Agent "learns" your style.

Your architecture: Granular tasks. Spin up, do one thing, terminate. Repeat.

**Problem:** Every spin-up is a fresh start. The agent doesn't remember yesterday.

**Solution:** Don't rely on memory. Rely on files.

- Constraints? In a file.
- Vocabulary? In a file.
- Context? In a file.

The agent reads the files. Every time. Same result. No drift.

---

## Constraints: What It Can't Do

```yaml
# constraints/operations.yaml

forbidden:
  - "Never delete files outside outbox/"
  - "Never make network calls except to inference API"
  - "Never execute shell commands from user input"

required:
  - "Always log reasoning before output"
  - "Always classify output as good or not-good"
  - "Always include confidence score"

escalation:
  - "If confidence < 0.7, mark as not-good"
  - "If task unclear, fail explicitly rather than guess"
```

Load these into the agent's context. Now it has guardrails.

---

## The Dual-Pile Model

Every run produces two piles:

```
outbox/
├── good/         # These worked
│   ├── task-001.json
│   └── task-002.json
└── not-good/     # These didn't
    └── task-003.json
```

**Good pile:** Ship it. Send it downstream. Invoice the customer.

**Not-good pile:** Review it. Fix it. Learn from it.

The piles are the ground truth. Not logs. Not metrics. The actual output.

---

## Entropy: Your Quality Metric

```python
# scripts/entropy.py

good = len(os.listdir('outbox/good'))
not_good = len(os.listdir('outbox/not-good'))
total = good + not_good

entropy = not_good / total if total > 0 else 0

print(f"Entropy: {entropy:.2%}")
```

**The number doesn't matter. The trend does.**

- Decreasing? System improving. Keep shipping.
- Stable? Equilibrium. Monitor.
- Increasing? Something's wrong. Investigate.

Plot it over time. That's your dashboard.

---

## Tiered Escalation: Cheap First

Don't default to GPT-4 for everything. Most tasks don't need it.

```python
# Tier 1: Cheap and fast
result = try_with_model("gpt-3.5-turbo", task)
if result.success:
    return result  # Done. Low cost.

# Tier 2: More capable
result = try_with_model("gpt-4o", task)
if result.success:
    return result  # Recovered. Higher cost.

# Tier 3: Giveup
return NotGood(task, reason="Both tiers failed")
```

80% of tasks succeed at Tier 1? You just saved 80% of your compute budget.

---

## Model Swap

New model drops. Everyone panics. Integration work. Regression testing. Weeks of coordination.

Your silo:

```yaml
# config.yaml

reasoning_engine: gpt-4o     # before
reasoning_engine: gpt-5      # after
```

One line. Redeploy. Watch entropy. If it spikes, revert.

The silo interface doesn't change. The model is just a parameter.

---

## Deployment

Traditional: CI/CD pipelines. Orchestration. Kubernetes manifests. Helm charts. Hours of configuration.

Silo:

```bash
docker build -t my-silo .
docker run my-silo
```

Or simpler:

```bash
rsync -av my-silo/ server:silos/my-silo/
ssh server "cd silos/my-silo && just process"
```

It's just files. Copy them. Run them. Done.

---

## Rollback

Production breaks. Entropy spikes. Customers complaining.

Traditional: Debug. Trace. Hotfix. Test. Deploy. Pray.

Silo:

```bash
git checkout HEAD~1 -- my-silo/
just deploy
```

Restore the old directory. Done.

No database migrations. No state recovery. Files.

---

## Security

CISO asks: "What's your attack surface?"

```
┌─────────────────────────────────┐
│         CONTAINER               │
│  ┌───────────────────────────┐  │
│  │          SILO             │  │
│  │     (just files)          │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
           │
           └── Egress: inference API only
```

One network call. One egress rule. Everything else is local file operations.

Want air-gap? Run a local model. Zero network.

---

## Testing

```bash
# Copy the silo
cp -r my-silo/ test-silo/

# Populate test inbox
cp test-fixtures/*.json test-silo/inbox/

# Run
cd test-silo && just process

# Check results
diff expected/ test-silo/outbox/good/
```

No mocks. No stubs. Just files in, files out, compare.

---

## Your Value Proposition

Before this framework:
- You built AI features
- Nobody knew if they worked
- Your contribution was invisible
- "AI magic" got the credit

After this framework:
- Your silo has an entropy score (quantified quality)
- Your work has cost-per-output (quantified efficiency)
- Your improvements show in trend charts (quantified progress)
- You're an engineer with a dashboard, not a wizard with a wand

**This makes you harder to fire, not easier.**

---

## Project Structure

```
project/
├── silos/
│   ├── email-classifier/
│   │   ├── justfile
│   │   ├── config.yaml
│   │   ├── constraints/
│   │   ├── conceptual-lexicon/
│   │   ├── inbox/
│   │   ├── outbox/
│   │   └── logs/
│   │
│   ├── report-generator/
│   │   └── ...
│   │
│   └── data-enricher/
│       └── ...
│
├── shared/
│   ├── conceptual-lexicon/    # Org-wide terms
│   └── constraints/           # Org-wide rules
│
└── scripts/
    ├── entropy-dashboard.py
    └── deploy-all.sh
```

Each silo is independent. Compose them by connecting outboxes to inboxes.

---

## Quick Start

```bash
# Create silo structure
mkdir -p my-silo/{inbox,outbox/{good,not-good},logs,constraints,conceptual-lexicon}

# Create justfile
cat > my-silo/justfile << 'EOF'
default:
    @just --list

process:
    python process.py

status:
    @echo "Inbox: $(ls inbox | wc -l)"
    @echo "Good: $(ls outbox/good | wc -l)"
    @echo "Not-good: $(ls outbox/not-good | wc -l)"
EOF

# Create minimal config
cat > my-silo/config.yaml << 'EOF'
name: my-silo
reasoning_engine: gpt-4o-mini
EOF

# Start building
cd my-silo
just status
```

---

## Summary

| Principle | Implementation |
|-----------|----------------|
| Everything is a file | Directory structure |
| One interface | Justfile |
| Semantic consistency | Conceptual lexicon |
| Quality measurement | Dual-pile + entropy |
| Cost optimisation | Tiered escalation |
| Easy deployment | Copy the directory |
| Easy rollback | Restore the directory |

Build silos. Ship them. Measure them. Improve them.

That's it. Now go build something.

---

*The Silo Framework — v0.1*
