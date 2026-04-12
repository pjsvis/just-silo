# The Orchestrator

**The overlord. The one who watches.**

**Date: 2026-03-31 | Status: Thinking Out Loud**

---

## The Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATOR                              │
│                        (The Overlord)                            │
│                                                                 │
│   "Keep an eye on them. Make sure they don't cause trouble."    │
│                                                                 │
│   - Watches all silos                                          │
│   - Receives alerts                                            │
│   - Can intervene                                              │
│   - Sets blast radius policies                                  │
│   - Corrals silos back to the herd                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │ silo_barley │     │ silo_alerts │     │ silo_reports│
   │  blast=1    │     │  blast=1    │     │  blast=1    │
   └─────────────┘     └─────────────┘     └─────────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                    "Each silo is a universe."
                    "The orchestrator watches the multiverse."
```

---

## The Orchestrator's Role

| Responsibility | What It Means |
|----------------|---------------|
| **Watch** | Monitor silo health, activity, outputs |
| **Alert** | Receive critical alerts from silos |
| **Intervene** | Can stop, restart, or quarantine a silo |
| **Policy** | Sets blast radius rules for the herd |
| **Corrall** | Pulls wayward silos back into line |
| **Audit** | Maintains overview of what each silo is doing |

---

## The CTX Persona

**CTX = Context controller. The operator who creates oversight.**

```
┌─────────────────────────────────────────────────────────────────┐
│                           CTX                                    │
│                                                                 │
│   "I put together the oversight program."                        │
│                                                                 │
│   - Creates silos                                               │
│   - Sets policies                                               │
│   - Deploys orchestrator                                        │
│   - Reviews outputs                                             │
│   - Intervenes when needed                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

The CTX persona is the human (or AI) in charge. The orchestrator does the watching; CTX decides what to do about it.

---

## Silo vs Orchestrator

| | Silo | Orchestrator |
|---|------|--------------|
| **Scope** | One domain | All silos |
| **Blast radius** | 1 (contained) | Unlimited (watches all) |
| **Role** | Worker | Overseer |
| **Vocabulary** | Domain verbs | System verbs |
| **Watches** | Its own data | All silos |
| **Reports to** | Orchestrator | CTX |

---

## The Oversight Program

CTX creates oversight programs for the orchestrator:

```bash
# CTX creates an oversight program
just orchestrator create-oversight --name "grain-monitoring"

# The oversight program watches:
# - silo_barley (moisture data)
# - silo_alerts (critical thresholds)
# - silo_reports (weekly summaries)

# Orchestrator verbs:
just silo-list              # What silos exist
just silo-status <name>    # How is it doing?
just silo-logs <name>      # What did it do?
just silo-alerts           # Any critical alerts?
just silo-quarantine <name> # Isolate a misbehaving silo
just silo-restart <name>    # Restart if stuck
just silo-pull <name>       # Corrall back to origin
```

---

## The Metaphor Holds

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   MULTIVERSE (the system)                                       │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                    ORCHESTRATOR                          │  │
│   │           "I watch the universes."                       │  │
│   └─────────────────────────┬───────────────────────────────┘  │
│                             │                                    │
│       ┌─────────────────────┼─────────────────────┐            │
│       ▼                     ▼                     ▼            │
│   ┌─────────┐           ┌─────────┐           ┌─────────┐     │
│   │  SILO  │           │  SILO  │           │  SILO  │     │
│   │   A    │           │   B    │           │   C    │     │
│   │         │           │         │           │         │     │
│   │ blast=1 │           │ blast=1 │           │ blast=1 │     │
│   │         │           │         │           │         │     │
│   │ Pocket  │           │ Pocket  │           │ Pocket  │     │
│   │ universe│           │ universe│           │ universe│     │
│   └─────────┘           └─────────┘           └─────────┘     │
│                                                                 │
│   CTX (operator) watches the orchestrator.                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**If metaphors become unwieldy, we drop them.**

Currently:
- Silo = pocket universe ✓ (clear, useful)
- Orchestrator = overlord ✓ (clear, useful)
- Blast radius = contained ✓ (clear, useful)

If they break down, we find better ones.

---

## Orchestrator Commands (Speculative)

```bash
# Discovery
just orchestrator silo-list
just orchestrator silo-find <pattern>
just orchestrator silo-registry

# Monitoring
just orchestrator silo-status <name>
just orchestrator silo-logs <name>
just orchestrator silo-metrics <name>

# Alerts
just orchestrator silo-alerts
just orchestrator silo-alert-subscribe <name> <channel>

# Intervention
just orchestrator silo-quarantine <name>
just orchestrator silo-restart <name>
just orchestrator silo-kill <name>
just orchestrator silo-recover <name>

# Policy
just orchestrator policy-list
just orchestrator policy-set <name> <blast_radius>
just orchestrator policy-audit

# Corralling
just orchestrator silo-pull <name>    # Pull from origin
just orchestrator silo-push <name>    # Push to origin
just orchestrator silo-sync <name>     # Bidirectional
```

---

## Open Questions

- [ ] Is the orchestrator a process, a service, or a silo itself?
- [ ] How does the orchestrator receive alerts? (file polling, webhook, message queue?)
- [ ] What's the minimum orchestrator? (just `ls ~/Dev/silo_*`?)
- [ ] Can silos be nested? (orchestrator running in a silo?)
- [ ] Who watches the orchestrator? (CTX directly)

---

## Related

- [silo-as-pocket-universe.md](./silo-as-pocket-universe.md) — The silo model
- [speculative-multi-silo.md](./speculative-multi-silo.md) — Full architecture
