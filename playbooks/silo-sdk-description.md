This is the **Silo Framework SDK README**, designed as the primary entry point for the **Sovereign Forge**. It establishes the technical standards, security boundaries, and operational protocols for building industrial-grade AI environments.

---

# **Silo Framework SDK**
**A framework for building secure, deterministic, and autonomous data refineries.**

## **1. Core Concept**
The **Silo Framework SDK** is a development kit for creating isolated, "boxed" execution environments called **Silos**. It moves AI security from the application layer to the infrastructure layer, replacing the "General-Purpose Agent" model with a **Gated Capability Model**. 

By enforcing **Technical Primacy** and **Physical Context Isolation**, the SDK ensures that AI-driven workflows remain auditable, observable, and secure, regardless of the underlying LLM substrate (local or cloud).

---

## **2. The Five Pillars**

### **I. Security (Infrastructure-Level Isolation)**
* **The Box:** Every Silo is deployed within an OCI-compliant container.
* **The Blast Radius:** Rogue code execution is physically contained within the container boundary. The host OS and corporate network remain unreachable by default.
* **Decidable Lockdown:** Users can toggle between "Development Mode" (full shell access) and "Sealed Mode" (no bash, verbs-only) depending on the deployment lifecycle.

### **II. Self-Improvement (The Forge Loop)**
* **Binary Compilation:** The SDK leverages **Bun’s binary compiler** to transform TypeScript recipes into standalone, zero-dependency executables (`engage`).
* **Capability Evolution:** Agents identify required tools, develop them in a local "Forge," and compile them into the global registry, mitigating supply-chain risks by eliminating transitive dependencies.

### **III. Memory (The Memory Rail)**
* **State Persistence:** Task state is managed via **`td`**, a CLI-based task manager that records progress in `.silo/tasks.jsonl`.
* **Context Continuity:** Sessions are stateless; the "Memory" exists in the file system. This allows for zero-drift handoffs between different models or human auditors.

### **IV. Auditability (Pedigree & Lineage)**
* **Content Hashing:** All inputs (`inbox/`) and outputs (`outbox/`) are tracked via SHA-256 hashes.
* **The Witness:** The `.silo/pedigree.jsonl` file provides a verifiable record of data provenance and transformation history.

### **V. Observability (Structured Telemetry)**
* **Pino Compatibility:** All logs are emitted as **JSONL (Newline-Delimited JSON)**, following the Pino standard.
* **Instant Integration:** Silo logs are natively ingestible by enterprise SIEM, ELK stacks, and observability platforms without pre-processing.

---

## **3. The "Silo-Just-Engage" (SJE) Topography**

| Component | Role | Functional Implementation |
| :--- | :--- | :--- |
| **Silo** | **Space** | A scoped directory with `inbox/`, `process/`, and `outbox/`. |
| **Just** | **Protocol** | A `justfile` acting as a "Verbs-Only" facade for agent interaction. |
| **Engage** | **Power** | A utility belt of audited, compiled binaries for atomic data tasks. |

---

## **4. Operational Handshake**
All agents initialized within the SDK must follow the **Edinburgh Protocol (v2.1)** initialization sequence:
1.  **Ingest Protocol:** Load security and reliability constraints.
2.  **Ingest Menu:** Execute `just --list`.
3.  **Ingest Toolset:** Execute `engage --help`.
4.  **Synchronize State:** Execute `td list` and `td focus <id>`.

---

## **5. Deployment Maturity Model**
1.  **Naked Silo:** Local directory execution for rapid R&D.
2.  **Boxed Silo:** Containerized execution with full shell access for complex tool forging.
3.  **Sealed Silo:** Hardened container with no shell access; strictly limited to audited `just` verbs for production deployment.

---

**Final Mentation:** The Silo Framework SDK provides the "Governor" for modern LLM substrates. It allows for high-velocity development within a low-risk, industrial-grade architecture.

**The SDK README is now canonical. Shall I generate the initial `package.json` and directory scaffolding for the `register-silo` repository?**