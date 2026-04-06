This is the **Sovereign Forge Master Brief**, stripped of metaphorical language and focused on technical specification, operational protocols, and security constraints.

---

# **Master Brief: The Sovereign Forge (V1.0)**
**Date:** 2026-04-03  
**Status:** Operational Specification  
**Architecture:** Silo-Just-Engage

---

## **1. Architectural Summary**
The framework is a three-tier, zero-dependency system for deterministic data processing. It replaces high-entropy agentic sprawl (APIs/MCP) with a restricted execution environment based on local file-system boundaries and compiled binaries.

---

## **2. Repository Tier Specifications**

### **Tier 1: `just-silo` (Workspace Layer)**
* **Purpose:** The fundamental unit of execution and data isolation.
* **Topography:** * `inbox/`: Raw input data.
    * `process/`: Staging area for transformation and logic.
    * `outbox/`: Final structured output and minimalist UI assets.
    * `.silo/`: Metadata, telemetry logs, and task state.
* **Core Tooling:**
    * **`just`**: Command runner for local workflow automation.
    * **`td`**: CLI-based task manager for state persistence in `tasks.jsonl`.
    * **`@hpcc-js/wasm`**: Local Graphviz engine for deterministic logic visualization.

### **Tier 2: `engage` (Capability Layer)**
* **Purpose:** A centralized repository for high-performance, compiled Bun binaries.
* **The Forge:** A build pipeline that flattens TypeScript source code into standalone, zero-dependency executables.
* **Operational Gears:**
    * `pdf2md`: PDF-to-Markdown extraction.
    * `spider`: Web-to-Markdown ingestion.
    * `scribe`: Audio-to-Markdown transcription.
* **Constraints:** No internal shell access; binaries must perform atomic, idempotent operations.

### **Tier 3: `register-silo` (Management Layer)**
* **Purpose:** The control plane for workspace orchestration.
* **Silo Factory:** Scripts to automate the creation and configuration of new `just-silo` instances.
* **Registry Sovereignty:** Centralized management of binary versions and standardized playbooks.

---

## **3. Agent Security Protocol (`agent-security-protocol.md`)**

* **Restricted Shell Access:** The AI agent’s environment is stripped of `bash`, `sh`, and `zsh`. 
* **Functional Gating:** The agent is restricted to `file_read`, `file_write`, and a whitelist of approved CLI tools (`gh`, `agent-browser`, `engage`, `just`).
* **Two-Persona Verification:** All code or data transformations must be initiated by a "Developer" persona and validated by a "Resident Reviewer" persona within the same silo.
* **Audit Trail:** Every command execution is logged with a timestamp and a SHA-256 content hash of the workspace.

---

## **4. Reliability & Repeatability Protocol (`reliability-playbook.md`)**

* **Idempotency:** Any command must be re-runnable without changing the system state beyond the initial execution.
* **Skeletal Memory:** Use of `td focus <id>` ensures the agent operates on a single, tracked task, preventing context drift across sessions.
* **Raw-First Ingestion:** External data must be dumped to `process/raw.txt` for an entropy/integrity check before refinement.
* **Data Lineage:** The `.silo/pedigree.jsonl` tracks the source URI and hash of all ingested data.

---

## **5. Specialized Resident Personas**

### **The Resident Reviewer**
* **Responsibility:** Validating local code against security and reliability playbooks.
* **Gate:** Executes `just code-review` to verify that no unauthorized system calls (e.g., hidden shell executions) have been introduced.

### **The Workflow-Checker**
* **Responsibility:** Optimizing token consumption and processing logic.
* **Intervention:** Identifies high-entropy formats (e.g., PCL, raw PDF) and enforces pre-refinement via `engage` gears to reduce context costs and improve reasoning accuracy.

---

## **6. Operational Handshake (Initialization Sequence)**

To achieve immediate alignment, every agent session must execute the following sequence:
1.  **Ingest Protocol:** Load the core security and reliability constraints.
2.  **Ingest Menu:** Run `just --list` to identify available actions.
3.  **Ingest Armory:** Run `engage --help` to identify available tools.
4.  **Identify Mission:** Read the active brief in `briefs/`.
5.  **Identify State:** Run `td list` and `td focus <id>` to locate the current task.

---

### **Corporate Compliance Alignment**
By removing the general-purpose shell and enforcing a "Verbs-Only" interface, the framework transitions AI usage from "Untrusted Code Execution" to "Auditable Data Refinement."

**Final Status:** This brief is now the canonical reference for the Silo-Just-Engage deployment. Proceed to repository initialization.