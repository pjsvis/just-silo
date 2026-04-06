This is the **Sovereign Forge Master Brief (v1.1)**. All metaphors have been removed and replaced with specific technical terminology, functional definitions, and architectural constraints.

---

# **Master Brief: The Sovereign Forge (Technical Specification)**
**Date:** 2026-04-03  
**Status:** Final Specification  
**Architecture:** Silo-Just-Engage (SJE)

---

## **1. Architectural Definition**
The SJE framework is a three-tier system for deterministic data processing. It operates through **Physical Context Isolation**, where AI agents are restricted to local directory boundaries and interaction is limited to a whitelist of compiled binaries and command-line interfaces (CLIs).

---

## **2. Repository Tier Specifications**

### **Tier 1: `just-silo` (Workspace Layer)**
* **Functional Role:** A standardized, isolated directory for task execution.
* **Directory Structure:**
    * `inbox/`: Entry point for raw, unstructured data (PDF, JSON, Audio).
    * `process/`: Staging area for intermediate transformations and scripts.
    * `outbox/`: Storage for structured Markdown files and UI assets.
    * `.silo/`: Internal directory for telemetry logs, task state, and metadata.
* **Core Tooling:**
    * **`just`**: Command runner for local task automation.
    * **`td`**: CLI-based task manager using `tasks.jsonl` for state persistence.
    * **`@hpcc-js/wasm`**: WASM-based Graphviz engine for logic visualization via `.dot` files.

### **Tier 2: `engage` (Capability Layer)**
* **Functional Role:** A centralized repository for compiled, high-performance Bun binaries.
* **Build Protocol:** TypeScript source code is compiled into standalone, zero-dependency executables.
* **Standard Toolset (Gears):**
    * `pdf2md`: Extracts text from PDF files to Markdown.
    * `spider`: Converts Web/URL content to Markdown.
    * `scribe`: Transcribes Audio files to Markdown text.
* **Constraints:** Binaries must be atomic and idempotent. No internal shell access or persistent network listeners.

### **Tier 3: `register-silo` (Platform Layer)**
* **Functional Role:** The management plane for silo orchestration.
* **Automation:** Scripts to automate the instantiation and configuration of `just-silo` directories.
* **Governance:** Centralized management of binary versioning and deployment of standardized playbooks.

---

## **3. Agent Security Protocol (`agent-security-protocol.md`)**

* **Shell Restriction:** The AI agent’s environment is configured without access to `bash`, `sh`, or `zsh`. 
* **Tool Gating:** Agent capabilities are restricted to `file_read`, `file_write`, and a specific whitelist of CLI tools (`gh`, `agent-browser`, `engage`, `just`).
* **Verification Logic:** All system modifications must be initiated by a "Developer" persona and audited by a "Resident Reviewer" persona.
* **Telemetry:** Every command execution and file modification is recorded with a timestamp and a SHA-256 hash of the modified content.

---

## **4. Reliability & Repeatability Protocol (`reliability-playbook.md`)**

* **Idempotency Requirement:** System commands must be designed so that multiple executions yield the same result as a single execution.
* **State Management:** Use of `td focus <id>` ensures the agent operates on a single, tracked task ID to prevent context drift.
* **Data Lineage:** The `.silo/pedigree.jsonl` file records the source URL and SHA-256 hash of all data moved from `inbox/` to `process/`.
* **Verification Gate:** Workflow logic must be defined in a `.dot` file and rendered via `just graph` for human-in-the-loop validation before final execution.

---

## **5. Specialized Personas (Functional Profiles)**

### **The Resident Reviewer**
* **Responsibility:** Auditing local code against the Security Protocol and Reliability Playbook.
* **Gate:** Executes `just code-review` to detect unauthorized system calls or non-idempotent logic.

### **The Workflow-Checker**
* **Responsibility:** Optimizing token consumption and processing efficiency.
* **Intervention:** Prevents the ingestion of high-entropy formats (e.g., PCL, raw PDF streams). Enforces pre-conversion via `engage` binaries to reduce input size and increase reasoning accuracy.

---

## **6. Operational Initialization (Handshake Sequence)**

All agent sessions must execute the following sequence to achieve operational alignment:
1.  **Ingest Protocol:** Load the core security and reliability constraints.
2.  **Ingest Interface:** Run `just --list` to identify executable verbs.
3.  **Ingest Toolset:** Run `engage --help` to identify available binaries.
4.  **Load Task:** Identify the active brief in `briefs/`.
5.  **Identify State:** Run `td list` and `td focus <id>` to synchronize with current task progress.

---

## **7. Corporate Compliance Alignment**
The framework transitions AI usage from **Untrusted Code Execution** (General Shell) to **Auditable Data Refinement** (Scoped CLIs). This provides a verifiable audit trail and predictable operational costs, meeting requirements for high-compliance environments.
