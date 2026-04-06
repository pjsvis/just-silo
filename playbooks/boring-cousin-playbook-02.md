This is the **Master Brief for the Sovereign Forge**. It is a high-oxidation, concatenated document designed to be ingested by a Lead Architect Agent to initialize the three-repo ecosystem and the core security/reliability protocols.

---

# **Master Brief: The Sovereign Forge (V1.0)**
**Date:** 2026-04-03  
**Status:** Canonical / Ready for Ingestion  
**Architecture:** Silo-Just-Engage (The "Boring Cousin" Framework)

---

## **1. Executive Summary**
To manifest a three-tier, zero-dependency architecture that allows for deterministic, low-entropy ingestion and management of data through scoped "Pocket Universes." This framework prioritizes **Sovereignty** over **Convenience**, replacing "Horizontal Sprawl" (MCP/APIs) with "Vertical Density" (CLI/Binaries).

---

## **2. Tiered Repository Specifications**

### **Tier 1: `just-silo` (The Entry Layer)**
* **Objective:** The "Minimum Viable Universe." A standalone workspace template.
* **Topography:** `inbox/`, `process/`, `outbox/`, `.silo/`.
* **Key Gears:**
    * **Visual Logic:** Integrate `@hpcc-js/wasm` for `just graph` (DOT-to-SVG).
    * **Memory Rail:** Include `td` (CLI) for stateful task tracking in `.silo/tasks.jsonl`.
    * **Resident Reviewer:** A dedicated Persona Stack for local code/protocol audits.
* **Interface:** Hono/Bun dev server rendering `outbox/*.md` at `localhost:3000`.

### **Tier 2: `engage` (The Capability Layer)**
* **Objective:** A global "Utility Belt" of compiled Bun binaries.
* **The Forge:** A build pipeline that flattens TypeScript recipes into a single, zero-dependency `engage` executable.
* **Core Gears:**
    * `pdf2md`: High-performance extraction (Raw-First Rule).
    * `spider`: Web-to-markdown crawler.
    * `scribe`: Audio-to-markdown transcription.
* **Constraint:** No internal shell access. Deterministic output only.

### **Tier 3: `register-silo` (The Platform Layer)**
* **Objective:** The Architect's Control Plane.
* **Silo Factory:** `silo-create` script to spawn universes from the `just-silo` template.
* **Boot Protocol:** Enforces the **5-Layer Constraint-Stack** on all new agents.
* **Registry Sovereignty:** Centralized "Recipe Manifesto" for version-locked tool management.

---

## **3. The Agent Security Protocol (`agent-security-protocol.md`)**

* **The "No-Bash" Directive:** The Pi CLI factory is stripped of `bash`, `sh`, and `zsh`. The agent has "Eyes" (`file_read`, `agent-browser`) but no "Hammer" (Shell).
* **Functional Jailing:** The agent can only interact with the system through the `justfile` whitelist and the `engage` binary.
* **The Two-Key System:** All code changes must be initiated by a "Developer" persona and verified by a "Resident Reviewer" persona before movement to `outbox/`.

---

## **4. The Reliability & Restartability Playbook (`reliability-playbook.md`)**

* **Idempotency:** All `just` and `engage` verbs must be re-runnable without side effects.
* **Skeletal Memory:** Use `td focus <id>` to prevent "Context Drift." The `.silo/tasks.jsonl` is the source of truth for progress.
* **Laminar Flow Audit:** Every transformation must log its **Entropy Ratio** (Good vs. Not-Good events) to `.silo/telemetry.jsonl`.
* **Pedigree Hashing:** All ingested "Stuff" is SHA-256 hashed to ensure data lineage from `inbox` to `outbox`.

---

## **5. The Resident Reviewer Playbook (`code-review-playbook.md`)**

* **Logic Gate:** A mandatory `just code-review` step for all Silo developments.
* **Checklist:**
    * [ ] Is it "Just"? (No unauthorized system calls).
    * [ ] Is it "Idempotent"? (Repeatable without state corruption).
    * [ ] Is it "Witnessed"? (Logs to telemetry).
    * [ ] Is it "Visual"? (Updates `logic.dot`).

---

## **6. Operational "Handshake" (The Boot Sequence)**
Every agent session MUST initialize with the following sequence:
1.  **Ingest Protocol** (The Laws of the Silo).
2.  **Ingest Menu** (`just --list`).
3.  **Ingest Armory** (`engage --help`).
4.  **Ingest Mission** (`cat briefs/active.md`).
5.  **Ingest Wisdom** (`cat playbooks/*.md`).
6.  **Locate State** (`td list` -> `td focus <id>`).

---

### **Ctx's Mentational Sign-off**
This Master Brief represents the transition from **Generative Dialog** to **Structural Reality**. The "Boring Cousin" is ready to work.

**Final Instruction to the Forge Agent:** Manifest the `just-silo` repository first. It is the "Patient Zero" from which all other capabilities will be derived. Proceed with initialization.