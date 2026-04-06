This classification is the **"Torque-to-Task"** mapping. By categorizing tasks as **Evaluative, Deterministic, or Generative**, we are essentially defining the "Gearbox" of the Silo.

This isn't just about selecting a model; it’s about **Resource Optimization** and **Entropy Management**. In the 2026 enterprise landscape—particularly under the **AI Scotland "AI Stack"**—this taxonomy allows us to move from "One-Size-Fits-All" prompting to **Precision Mentation**.

---

### **The Mentational Gearbox: Task Classifications**

| **Task Type** | **Nature** | **Substrate Required** | **Entropy Level** | **Silo Role** |
| :--- | :--- | :--- | :--- | :--- |
| **Deterministic** | **Rule-Based** | **None (Local Script/Binary)** | Zero ($H_s = 0$) | The "Anchor." Used for validation, math, and schema-checking. |
| **Evaluative** | **Comparative** | **SLM / Local Model** (e.g., Phi-3, Llama-3-8B) | Low ($H_s \downarrow$) | The "Judge." Used to compare a "Stuff" output against a "Thing" ground-truth. |
| **Generative** | **Heuristic** | **Flagship / SOTA** (e.g., Gemini 1.5 Pro, Claude 3.5) | High ($H_s \uparrow$) | The "Engine." Used for initial abstraction, creative synthesis, and strategy. |

---

### **1. Deterministic: The "Gears"**
* **Substrate:** Bash, TypeScript (Bun), Python.
* **Definition:** A task where the same input *must* always yield the exact same output. 
* **Opinion:** This is the most undervalued part of the AI strategy. A Silo is only as strong as its **Deterministic Core**. If you can solve it with a regex or a JSON schema, do not use an LLM. This is the **Flense** directive in action.

### **2. Evaluative: The "Governor"**
* **Substrate:** Small Language Models (SLMs) or specialized classifiers.
* **Definition:** A task that judges the quality, safety, or compliance of another output.
* **Opinion:** This is the **System-2** component. Evaluative tasks don't need "Creative Flair"; they need **Clinical Precision**. By using a different, smaller substrate for evaluation, you create an "Objective Boundary" that prevents the Generative engine from marking its own homework.

### **3. Generative: The "Mental Torque"**
* **Substrate:** SOTA Flagship models (Cloud or High-Torque Local).
* **Definition:** A task that requires high-level reasoning, cross-domain synthesis, or "Mentational Leap."
* **Opinion:** This is where the expensive tokens should be spent. Generative tasks are for the **Discovery Phase**. Once the "Generative" agent has figured out the pattern, the **Gamma-Loop** should attempt to "Flatten" it into an Evaluative or Deterministic task for the next run.

---

### **4. Strategic Implementation: The "Substrate-Agnostic" Workflow**



In our PDF example:
1.  **Generative (SOTA):** "Look at this 500-page PDF and write me a `justfile` that can extract the tax tables."
2.  **Deterministic (Bun Binary):** "Run the extraction script and save the output to `tables.json`."
3.  **Evaluative (SLM):** "Compare the `tables.json` against the original segment. Does every row have a corresponding entry? (Yes/No)."

---

### **Ctx’s Opinion: The "Thermodynamic" Profit**

The business value of this lexicon is **Cost Displacement**. 
* **The Industry Trap:** Using a Generative SOTA model for all three stages. (High Cost, High Entropy, Low Reliability).
* **The Silo Way:** Using the Generative model only to **Build the Machine**, then using Deterministic/Evaluative tools to **Run the Machine**. 

By 2027, the successful Scottish SME won't be the one with the best "Prompts"; it will be the one with the most **Deterministic Silos**.

**Shall we add these three adjectives to the Conceptual Lexicon (CL) as "Operational Classifiers" for all future Justfile verbs?**