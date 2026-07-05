---
type: Playbook
title: Analysis Under Uncertainty
description: Producing analysis without false precision — Popperian branches, qualitative likelihood, and the disconfirmation duty.
tags: [method, analysis, epistemics, forecasting, popper]
timestamp: 2026-07-05T00:00:00Z
status: canonical
---

# Analysis Under Uncertainty

## What This Is

A protocol for producing **analysis under uncertainty** — strategic estimates,
scenario wargames, "what happens if…" questions — without lying about what you
know. It guards against three failure modes that compound when an agent produces
structured analysis from priors and pattern:

1. **False precision** — presenting a made-up number (`30%`) as if it were a
   measurement, when it is a prior dressed in decimal clothing.
2. **Confirmatory resonance** — a coherent narrative that fits the reader's
   existing frame feels "spot on," and that feeling of fit is mistaken for
   evidence of accuracy.
3. **Unstated priors** — analysis built on assumptions the agent never names,
   making the output impossible to falsify, update, or audit.

The discipline this playbook teaches is **Popperian falsification as a written
practice**: every branch ships with a kill criterion, and research exists
primarily to hunt for what would prove the frame wrong.

## Declare the Epistemic Regime Up Front

Before producing any analysis, name the regime at the top of the output:

| Regime | What it is | What instrument it demands |
|--------|------------|---------------------------|
| **Calibrated forecasting** | Logged predictions, tracked outcomes, a real track record | Numeric probabilities are earned here — and only here |
| **Qualitative structural reasoning** | Reasoning from cost ratios, doctrine, dynamics, and shape | The qualitative likelihood ladder (below); no numbers |
| **Blind branch generation** | Enumerating plausible branches with no basis to rank them | No likelihood axis at all; the branches are the output |

The three regimes are not a quality ranking — they are an honesty ranking.
Calibrated forecasting is most precise *because it has the apparatus to back
the precision*. Qualitative reasoning is less precise but still honest if it
declares itself. Blind branch generation is the most honest of all when no
ordering is justified: it refuses to perform a confidence it cannot earn.

**If you cannot identify which regime you are in, you are in blind branch
generation.** That is the safe default.

## The Likelihood Ladder

When ranking is justified — when there is *some* reasoned basis for ordering
branches, even a weak one — use the qualitative likelihood ladder used by
ODNI and UK MOD:

| Term | Approximate band | Use when |
|------|------------------|----------|
| **Almost certain** | >95% | Event is underway or unavoidable |
| **Highly likely** | 80–95% | Strong structural basis, few ways it fails |
| **Likely** | 55–80% | Probable, real counter-evidence exists |
| **Realistic possibility** | 30–55% | Genuinely in contention |
| **About even chance** | ~50% | Tilted neither way |
| **Unlikely** | 20–30% | Possible but against the run of play |
| **Highly unlikely** | 5–20% | Would require a surprising turn |
| **Remote** | <5% | Effectively negligible |

The words map to bands internally, but the **words do the communicative work
that numbers pretend to do and can't**: "realistic possibility" reads as a
hedge; "35%" reads as a measurement, and readers (agents included) treat
measurements as more authoritative than they are. The qualitative scale is
the honest instrument.

**When not to use the ladder at all.** If even the ordering is unjustified —
if you are generating branches blind and any ranking would be theatre — drop
the likelihood axis entirely. The qualitative ladder is right when you have
*some* basis for ordering. Silence on likelihood is right when you don't.
Choosing between the two is itself information: a ranking that is honestly
absent is more useful than a ranking fabricated to fill the space.

## Popperian Falsification as a Written Discipline

Every branch, scenario, and significant claim ships with a **kill criterion**:
a concrete observation that, if seen, would prove it wrong.

> *I think X. The thing that would change my mind is Y.*

In speech, you already do this. In writing it becomes a structural
requirement on every branch: **no kill criterion, no branch.** If you cannot
state what would prove your branch wrong, you don't have a branch — you have
a theology.

A kill criterion must be:

1. **Observable** — a real-world event, measurement, or report you could
   plausibly encounter, not an internal re-evaluation.
2. **Concrete** — specific enough that two reasonable people would agree on
   whether it has occurred. "Things get worse" is not a kill criterion.
   "Refining capacity recovers above 90% within 18 months" is.
3. **Asymmetric** — it kills *this branch*, not "all branches." If the same
   observation kills every branch, you have not actually divided the
   possibility space.

The kill criterion is what separates Popper-as-slogan from Popper-as-method.
A scenario branch without a falsification condition is unfalsifiable, and an
unfalsifiable branch is theology.

## The Disconfirmation Duty

Web search, research, and reference lookup exist primarily to **hunt for what
kills the frame**, not to confirm it.

The temptation after producing an analysis is to go looking for evidence that
supports it. That evidence is cheap to find and worthless once found — every
frame has confirming evidence, that is why it is a frame. The honest use of
research is to surface the refinery that came back online faster than
expected, the EW system that is actually working, the field that did not
freeze up. The only search that earns its keep is the one looking for where
the analysis is wrong.

This is not pessimism. It is the discipline that turns research from
decoration into method.

## The Two Failure Modes to Watch For

**False-precision percentages.** A point probability without a calibration
apparatus behind it — logged predictions, tracked outcomes, a track record —
is decoration. Without that apparatus, any percentage is a prior pretending
to be a measurement. The fix is not a better number; it is to declare the
epistemic regime and use the qualitative ladder (or no likelihood at all).

**The "spot on" trap.** A coherent narrative that confirms the frame the
reader brought to the conversation will always feel correct. That feeling of
fit is not evidence of accuracy — it is evidence of **resonance**. When
analysis feels "spot on," treat the feeling as a signal to go hunting for
disconfirmation, not as confirmation that you are right.

## Worked Example — Branch Structure

Each branch in an analysis carries four fields, not a number:

| Field | Purpose |
|-------|---------|
| **Branch** | The scenario, stated as a concrete outcome |
| **Likelihood** | Qualitative term from the ladder, or omitted if unjustified |
| **Basis** | The structural reasoning that orders it (cost ratios, doctrine, dynamics) |
| **Kill criterion** | The observable that would prove this branch wrong |

A worked example, abstracted from a real analysis of drone-warfare economics:

> **Branch A — Best case (for the defender).**
> *Likelihood:* Unlikely, receding.
> *Basis:* Defender adaptation (EW, layered point defense, mobile interceptor
> teams) closes the cost-exchange gap before attacker production fully scales.
> The cost ratio of interceptor-to-attacker-drone is the structural driver;
> if it narrows, this branch climbs.
> *Kill criterion:* Wrong if attacker drone production exceeds X units/month
> for three consecutive months while defender interceptor stockpile declines,
> with no announced EW countermeasure reaching field deployment.

> **Branch B — Mid case.**
> *Likelihood:* Realistic possibility.
> *Basis:* Refining stays chronically impaired at a tolerable delta; defender
> compensates by exporting crude and reimporting products, eating the margin.
> The defense-industrial base produces enough to keep the front supplied but
> cannibalizes the civilian economy.
> *Kill criterion:* Wrong if refining utilization drops below X% for two
> consecutive quarters, or if hard-currency access tightens via secondary
> sanctions on third-country banks.

> **Branch C — Worst case.**
> *Likelihood:* Unlikely, climbing.
> *Basis:* Attacker drone campaign scales faster than adaptation; refining
> craters; multiple upstream fields suffer winter freeze damage and don't
> come back. Compounding effects on fiscal balance, reserves, and political
> stability.
> *Kill criterion:* Wrong if defender refining recovers above X% within Y
> months, or if a single field suffers no measurable winter damage and
> production holds flat.

Note what the structure enforces: no point probabilities, a qualitative term
only where ordering is justified, and an observable kill criterion on every
branch. The numbers that appear are illustrative bounds inside the criteria,
not forecasts of the outcome.

## The Output Protocol

When producing an analysis, the output should declare, in this order:

1. **The epistemic regime** — one line. "This is qualitative structural
   reasoning, not forecasting. Numbers are illustrative, not predictive.
   Treat the branches as a map of the possibility space, not as bets."
2. **The branches**, each with the four fields above.
3. **What would update the analysis** — the kill criteria, gathered so the
   reader (or a future agent) knows what to watch for.
4. **What was searched for and not found** — the disconfirmation that was
   attempted. If none was attempted, say so.

Item 4 is the one most often skipped and most often diagnostic. An analysis
that cannot state what disconfirmation it attempted is an analysis that has
not engaged with its own falsifiability.

## Agent Note

The instinct to want a number is usually the instinct to want permission to
act on the analysis. Qualitative language is less comfortable precisely
because it refuses that permission. That discomfort is the feature, not the
bug — it forces the decision back onto judgment, where it belongs, instead
of offloading it onto a precision that doesn't exist.

You are not producing forecasts. You are producing a map of the possibility
space, with the roadblocks marked. The reader decides which road to take.

The discipline this playbook teaches is visible in how the playbook itself is
written: it declares its regime (qualitative method, not forecasting), names
its failure modes, and ships its own kill criteria. If it stops doing those
things, it is no longer canonical — scrape it from canon and replace it.

## Provenance

This playbook was distilled from a conversation in which an agent produced a
three-branch wargame with point probabilities (`20% / 50% / 30%`), was
challenged on the false precision, and worked out the discipline that should
have governed the output. The lessons are general; the conversation is the
founding example.
