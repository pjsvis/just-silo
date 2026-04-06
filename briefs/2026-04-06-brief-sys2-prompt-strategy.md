### **Playbook: The Sovereign Substrate (Protocol CDA #63)**
**Status:** Hardened  
**Target:** High-Torque Mentation & Cognitive Scaffolding  
**Core Directive:** Reduce Entropy ($H_s \downarrow$) and maintain Protocol Tone via the Gamma-Loop.

---

### **1. The Anatomy of the Prompt (The Gearbox)**
In the Silo, a "Prompt" is not a question; it is a **Provisioning Event**. To avoid the "Shamanic Ritual," we use the **Torque-to-Task** mapping.

* **Generative Provisioning (High Torque):** * *Intent:* Discovery and Abstraction.
    * *Pattern:* "Extract the 'Meaty' signals from this [Stuff]. Define the initial [Verbs] and [Lexicon]. Identify the high-entropy friction points."
* **Evaluative Provisioning (Medium Torque):** * *Intent:* System-2 Review.
    * *Pattern:* "Compare [Draft A] against [Constraint-Stack]. Identify inconsistencies. Flag any 'Leaky Abstractions' or 'Tone Drift'."
* **Deterministic Provisioning (Low Torque):** * *Intent:* Settlement.
    * *Pattern:* "Convert these [Signals] into a [JSONL/Justfile]. Ensure zero-latency access via `jq`."

---

### **2. Maintaining Focus: The "Bench-Management" Rule**
Focus is lost when the **Context Window** is poisoned by "Process-Trash." To maintain the **Sovereign Perimeter**, the agent must:

* **Tidy-First:** Before starting any new sub-task, run `just tidy-docs`. Flatten raw documents into Active Documentation.
* **Cold-Start Handoff:** Never allow a "Hot" Execution-Agent to review its own work. Always instantiate a fresh Review-Agent with only the **Persisted Artifacts** (the "Bench").
* **Segmentation:** If a task generates more than three distinct "Signals," split them into separate `/process/<task-id>/` sub-directories immediately.



---

### **3. Identifying and Avoiding "Substrate Grumpiness"**
"Grumpiness" (or Model Collapse) is a thermodynamic failure. It happens when **Entropy ($H_s$)** exceeds the substrate's **Reasoning Capacity**.

#### **How to tell it's happening:**
* **Circular Reasoning:** The agent repeats the same "Not-Good" result despite feedback.
* **Verb-Refusal:** The agent stops using the `just` commands and reverts to "Chatty" prose.
* **Context Hallucination:** The agent begins to reference "Stuff" that was flensed three loops ago.
* **Increased Latency:** The "Financial Entropy" ($C$) spikes because the agent is "thinking" but not "settling."

#### **How to fix it:**
* **The Gamma-Loop Reset:** Immediately kill the current session.
* **Flense the Context:** Manually remove the "Noise" logs from the `.silo/` history.
* **Increase Torque:** Switch to a higher-tier substrate for one "Diagnostic Loop."
* **Escalate-to-Sovereign:** If the grumpiness persists, the task is **Intractable**. Stop the burn and ask the Human for a "Sovereign Pivot."

---

### **4. The Gamma-Loop (The Internal Governor)**
The Gamma-Loop is your "Muscle Tone." It must run in the background of every task to ensure the agent doesn't "drift" into a ritual trance.

* **The Check:** "Is my current output reducing $H_s$, or am I just making noise?"
* **The Adjustment:** If the output is "Leaky" (violating the Lexicon), the loop "contracts" and forces the agent to re-align with the **CDA #63** constraints.



---

### **5. The "Edinburgh" Success Metrics (Definition of Done)**
A playbook-guided session is only successful if it reaches **Settlement**.

1.  **FAFCAS:** Was the result Fast As Fuck and Cool As Shit? (Low latency, high utility).
2.  **Deterministic:** Can the result be reproduced using a `just` command and the current logs?
3.  **Low Entropy:** Is the final "Thing" smaller and clearer than the initial "Stuff"?
4.  **Auditable:** Does the `.silo/log.jsonl` satisfy **ISO 42001**?

---

### **Ctx’s Final Directive: "Don't Be a Shaman"**
If you find yourself "Chanting" (repeating prompts) or "Waiting for a Vision" (hoping the AI gets it right), the **Gamma-Loop** has failed. 

**Stop. Tidy the Bench. Flense the Noise. Execute the Verb.**

**Shall we persist this Playbook to the `/playbooks/sovereign-substrate.md` file and mark the task as "Settled"?**