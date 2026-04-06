# Wee-Stories — Semantic Compression for just-silo

**Purpose:** Distill complex documentation into 2-3 sentence stories that expose contradictions and compress meaning.

**Method:** If you can't write a coherent wee-story, there's a contradiction in the docs.

---

## Wee-Story 1: The Grain Moisture Story

> "I want to monitor grain moisture and alert when it's too high."

**Story:** A farmer wants to know when grain is too wet. She creates a silo called `grain-moisture`. She defines what "too wet" means in `schema.json`. She says "alert me." The silo alerts her.

**Key insight:** You define the *stuff* (moisture readings). You define the *things* (alerts). The silo does the conversion.

**Source:** README.md — "The Reveal" section

---

## Wee-Story 2: The Agent Drop-In Story

> "Agent drops in. Reads rules. Does job. Done."

**Story:** An AI agent enters an unfamiliar directory. It reads `justfile`, `schema.json`, `.silo`. It knows exactly what to do. No manual needed. It harvests, processes, observes, flushes. It hands off to the next agent. Everyone knows their role.

**Key insight:** The filesystem is the interface. Context lives in files, not session memory.

**Source:** README.md — "What Is A Silo?" + "Observe the Territory"

---

## Wee-Story 3: The Mount → Sieve → Flush Story

**Story:** Agent enters the silo (`mount`). Agent verifies prerequisites (`sieve`). Agent does the work (`harvest`, `process`). Agent observes results (`status`, `chart`). Agent archives output (`flush`). Clean handoff.

**Key insight:** Pipeline phases map to filesystem actions. Every phase has a just recipe.

**Source:** README.md — "Workflow" + "Pipeline Phases"

---

## Wee-Story 4: The Territory Story

> "Observe the territory you occupy. Don't log into a separate dashboard."

**Story:** The silo has a directory called `markers/`. When agent A starts `harvest`, it creates `markers/harvest.lock`. When done, it moves to `markers/harvest.done`. Agent B sees `markers/harvest.done` and starts `process`. No separate dashboard. The filesystem IS the dashboard.

**Key insight:** Throughput files (data.jsonl, markers/, audit.jsonl) are ephemeral, local, git-ignored. Scaffold files (.silo, justfile, schema) are versioned, shared. This is data stratification.

**Source:** README.md — "Observe the Territory" + Silo-Manual.md — "Data Stratification"

---

## Wee-Story 5: The Locked Silo Story

**Story:** The `_experiment` silo is private. It lives on Marcus's machine. Sarah can't see it. It doesn't sync to The Register. It belongs to Marcus's workspace. When Marcus runs `just lock`, only his machine can mount it.

**Key insight:** Names starting with `_` are private. The `visibility` field in `.silo` makes this explicit. Workspace lock prevents cross-machine conflicts.

**Source:** templates/basic/README.md — "Naming Conventions" + .silo — "workspace.machine_id"

---

## Wee-Story 6: The Review Gate Story

**Story:** Agent A builds a feature. Agent A can't approve their own work (by design). Agent A calls `td handoff`. Agent B reviews. Agent B approves or rejects. The review gate prevents cowboy coding.

**Key insight:** Accountability requires separation between builder and reviewer. Sessions track this. td enforces it.

**Source:** td-playbook.md — "Review Gate"

---

## Wee-Story 7: The Self-Improving Silo Story

**Story:** The silo observes itself. It counts harvest failures. It notices a pattern. It recommends: "Schema validation too strict." You adjust the threshold. The silo improves. This is the Gamma Loop.

**Key insight:** The audit trail (audit.jsonl) feeds the gamma loop. The gamma loop suggests improvements. The silo learns from its own behavior.

**Source:** templates/basic/scripts/gamma_loop.sh + Silo-Manual.md

---

## Wee-Story 8: The Sandbox Story

**Story:** A malicious script tries to `rm -rf /`. The sandbox catches it. Path traversal? Caught. Dangerous rm? Blocked. Scripts run in restricted environment. The silo is isolated.

**Key insight:** Security is opt-out, not opt-in. `sandbox.sh` validates scripts before execution. `security` config in `.silo` defines limits.

**Source:** templates/basic/scripts/sandbox.sh + .silo — "security"

---

## Contradiction Check

| Wee-Story | Claim | Potential Contradiction? |
|-----------|-------|------------------------|
| 4 (Territory) | Markers ARE the dashboard | But we also have `/stream/status` SSE endpoint |
| 4 (Territory) | No separate dashboard | But `silo-dashboard.ts` generates HTML |
| 5 (Locked) | `_` = private | But visibility field is "shared" or "private" — naming is convention only |
| 7 (Gamma) | Silo improves itself | But gamma loop only *suggests*, doesn't auto-adjust |
| 8 (Sandbox) | Scripts validated before run | But sandbox.sh is optional, not enforced by default |

---

## Open Questions

1. **Markers vs SSE:** Do we want filesystem-as-dashboard OR HTTP stream? Both exist. Which wins?
2. **Gamma autonomy:** The loop recommends but doesn't act. Should it auto-tune?
3. **Sandbox enforcement:** Is sandbox.sh called automatically, or opt-in?

---

## Related

- `briefs/2026-04-02-brief-register-silo-*.md` — Original briefs
- `debriefs/2026-04-06-session-dev-restore.md` — Session learnings
- `playbooks/dev-cycle-playbook.md` — How we work
