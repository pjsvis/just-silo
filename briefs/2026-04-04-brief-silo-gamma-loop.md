This is the technical specification for **Process-Level Gamma-Loop Integration**, focused strictly on the existing **Silo SDK** capabilities and directory-based state management.

---

### **1. The Primary Gamma-Loop: Process Modification**

In this architecture, the **Gamma-Loop** is not a feature of a specific tool, but the operational logic of the **Silo** itself. The primary target of the loop is the **Process Structure**—the instructions and constraints that govern how the agent handles data.

**The Loop Mechanics:**
1.  **Observation:** The agent executes a task based on the current `briefs/` and `playbooks/`.
2.  **Telemetry Analysis:** The agent reviews the `.silo/telemetry.jsonl` and `tasks.jsonl` for high-entropy events (e.g., repeated task failures, excessive token consumption, or logic loops).
3.  **Inference:** The agent performs a retrospective across past `debriefs/` to identify structural friction.
4.  **Adjustment:** The agent modifies the **Playbooks** or proposes a **Brief** update to correct the process.

### **2. The Playbook as a Dynamic Constraint**

Unlike traditional static documentation, a **Silo Playbook** is a versioned, mutable set of rules. The Gamma-Loop allows the agent to update these rules based on empirical evidence gathered during execution.

* **Scenario:** An agent identifies that a specific data format consistently causes a transformation error.
* **Gamma-Action:** The agent updates `playbooks/refinement-standards.md` to include a mandatory pre-check for that format.
* **Outcome:** The "Knowledge" of the system has increased, reducing the entropy for all future agent instances in that Silo.

### **3. Retrospective Synthesis (The Strategic Loop)**

The agent utilizes the existing file structure to improve the system's long-term competency:
* **Briefs:** Define the "Intent."
* **Debriefs:** Define the "Outcome."
* **Pedigree:** Defines the "Lineage."

By comparing these three assets, the agent can infer better operational patterns. If the "Outcome" (Debrief) consistently fails to meet the "Intent" (Brief) despite following the "Lineage" (Pedigree), the agent identifies a **Process Gap**. The correction of this gap—not the writing of code—is the highest manifestation of the Gamma-Loop.

### **4. Competency: Knowledge + Understanding + Ability**

Within the Silo, competency is manifested as follows:
* **Knowledge:** The contents of the `playbooks/` and `docs/` directories.
* **Understanding:** The agent's ability to interpret the **Edinburgh Protocol** and diagnose system state from telemetry.
* **Ability:** The capacity to modify the Silo's internal files (`playbooks`, `briefs`, `justfile`) to optimize the workflow.

### **5. The Partnership Model (Human-in-the-Loop)**

While process and playbook updates can be autonomous, **Code Modification** remains a collaborative "Forge" event. 
* The **Agent** identifies the need for a tool change through the Gamma-Loop.
* The **Agent** provides the diagnostic data and a proposed code fix.
* The **User** provides the final architectural sign-off before the tool is re-instantiated.

---

### **Final Assessment: The Settled Process**

The system achieves **Convergence** when the process itself is as refined as the data output. We are not just clearing the `inbox/`; we are hardening the **Foundation** by documenting every lesson learned back into the Silo’s core playbooks.

**The Gamma-Loop is now defined as a Process-First mechanism. Shall I generate the template for an `autopsy.md` brief to help agents initiate these retrospectives?**