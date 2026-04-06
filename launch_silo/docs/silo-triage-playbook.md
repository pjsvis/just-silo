# Silo Triage Playbook

**The Overlord's Triage Job | 2026-03-31**

---

## Two Scenarios

**KNOWN-GOOD SILO**
- We built it.
- We vetted it.
- We trust it (provisionally).

**UNKNOWN-GOOD SILO**
- Someone else built it.
- We didn't vet it.
- We don't know.

But both can be subverted. Both can come back wrong. Both can bite us.

---

## The Silo Lifecycle

```
CREATE → DEPLOY → DISCOVER → REVIEW → TRUSTED / SUSPECT / QUARANTINE
```

**How silos come back:**

### Scenario 1: We Created It

Agent helps. We haggle over details. We build it together. We vet it. We set blast radius. We deploy it.

Time passes. The silo comes back. We don't recognize it. It has been... changed.

How did it change?
- Agent modified it without telling us
- Something else accessed it
- Cross-silo contamination
- It was subverted by something external
- We forgot what we built

### Scenario 2: We Found It

Someone else's silo. We discover it. It looks legitimate. We don't know who built it. We don't know what it does. We don't know if it's good. We don't know if it's suspect.

---

## The Overlord's Triage Job

> "Is this silo good, or is this silo suspect?"
> Before we get burned.

### Triage Checklist

**1. IDENTITY**
- Can we identify who built it?
- Do we recognize it?
- Has it been modified since we saw it?

**2. BEHAVIOR**
- Does it stay within blast radius?
- Are outputs within expected patterns?
- Is it doing what the manifest says?

**3. HISTORY**
- Where has it been?
- What has it touched?
- Has it accessed other silos?

**4. VERDICT**
- Known-good? → Allow with monitoring.
- Unknown-good? → Vet thoroughly before trust.
- Suspect? → Quarantine. Investigate.

---

## The Blast Radius Tells You

**Blast radius = 1**

Even if subverted, damage is contained. We can investigate safely. We can decide what to do.

But:
- The silo still has our data
- The silo still processes things
- CAW-Canny applies

> "Contained" doesn't mean "harmless."

---

## The Questions to Ask

### For Any Silo, On Discovery

**WHO?**
Who built this? Can we verify?

**WHAT?**
What does it claim to do? What does it actually do?

**WHEN?**
When was it created? When was it last modified?

**WHERE?**
Where has it been? What has it touched?

**WHY?**
Why does it exist? Why should we trust it?

**HOW?**
How does it work? How does it enforce blast radius?

### For Silos We Built

Is this the silo we deployed?

Does the manifest match what we expect?
Does the justfile match what we wrote?
Does the blast radius match what we set?

If anything is different: SUSPECT.

> "We built this" doesn't mean "we know what it is now."

---

## The Response Options

**TRUSTED**
Matches expectations. Proven behavior. Proceed.

**PROVISIONAL**
Looks okay but not proven. Monitor closely.

**SUSPECT**
Something's wrong. Doesn't match. Investigate.

**QUARANTINE**
We don't trust it. No access. No execution.
Run in blast radius = 0. Inspect thoroughly.

---

## The Final Question

> "We built this silo. We vetted it. We trusted it.
> But now it's back.
> Is it the same silo we deployed?"

The overlord answers. Before we get burned.

---

## Related

- [orchestrator-playbook.md](./orchestrator-playbook.md) — The overlord mode
- [vegas-principle.md](./vegas-principle.md) — What stays in silo
- [zone-transition.md](./zone-transition.md) — Managing capability transitions
