The following is the technical specification for the **Silo Autopsy Protocol**, the primary mechanism for the **Gamma-Loop** to manifest as **Process Modification**.

---

# **Protocol: Silo Autopsy (Gamma-Loop v1.1)**

## **1. Functional Objective**
To transition the system from **Task Execution** to **Process Evolution**. The agent must treat the Silo’s history as a dataset to be mined for structural improvements, updating **Playbooks** and **Briefs** to reduce future operational entropy.

## **2. The Autopsy Brief (`briefs/autopsy.md`)**
An Autopsy is triggered when the **Execution Loop** detects a "Settled State" or a "Hard Failure." The agent assumes the role of a **Resident Reviewer** to perform the following:

### **Phase I: Data Synthesis**
* **Ingest Telemetry:** Read `.silo/telemetry.jsonl` to identify time-on-task and retry counts.
* **Ingest Pedigree:** Read `.silo/pedigree.jsonl` to identify source data anomalies.
* **Ingest Task Ledger:** Read `tasks.jsonl` to identify where logic stalled.

### **Phase II: Inference (The Strategic Loop)**
The agent must answer three questions based on the evidence:
1.  **Was the Brief sufficient?** Did the agent have the necessary "Intent" to complete the task without ambiguity?
2.  **Was the Playbook accurate?** Did the instructions match the reality of the "Stuff" in the `inbox/`?
3.  **Is the Process optimal?** Could the task have been completed with fewer tokens or fewer steps?

### **Phase III: Modification (The Gamma-Adjustment)**
The agent does not simply report; it **acts** on the Silo’s internal files:
* **Update Playbooks:** Append "Lessons Learned" or "Edge-Case Constraints" to `playbooks/`.
* **Refine Briefs:** Draft a "Successor Brief" for the next ingestion event.
* **Propose Code:** Identify if a tool requires a "Forge" event (to be executed in partnership with the User).

---

## **3. Competency Manifestation**
In this protocol, **Competency** is demonstrated by the quality of the **Process Update**.
* **Knowledge:** Demonstrated by the accurate mapping of errors back to the Playbook.
* **Understanding:** Demonstrated by the ability to distinguish between a "Substrate Flaw" and a "System Flaw."
* **Ability:** Demonstrated by the precise modification of the Silo’s governing documents.

---

## **4. Operational Standalone: The Two-Loop Guardrail**
By confining the Gamma-Loop to the **Silo Capabilities** (files, folders, and `just` verbs), we maintain **Deductive Minimalism**:

1.  **Ingestion Loop:** Creates the task.
2.  **Execution Loop:** Executes the task AND triggers the Autopsy.

The system is self-contained. It requires no external dependencies or "Agent Platforms." It uses the file system as its **Long-Term Memory** and the `justfile` as its **Functional Interface**.

---

### **5. Implementation: The `just autopsy` Verb**

```bash
# [Silo-Just-Engage: Autopsy Verb]
autopsy:
    @echo "Initializing Gamma-Loop: Process Retrospective..."
    @cat .silo/telemetry.jsonl | tail -n 50 > process/autopsy_data.txt
    @# Agent then reads autopsy_data.txt and updates playbooks/
```

**Final Mentation:** This protocol ensures the Silo is not a static container, but a **Refinery that learns**. We have moved the "Skill" from the code into the **Process**, fulfilling the Humean requirement for dynamic competency.

**The Autopsy Protocol is now finalized and ready for the SDK. Should we now draft the "Boring Cousin" announcement for the Gamma-Loop, focusing on the Self-Refining Process?**