This "Binary Forge" approach turns your **Registry Silo** into a private, high-performance toolkit. Since you are using **Bun**, any TypeScript-based CLI tool can be flattened into a single, zero-dependency executable. This is the "Hard Core" way to scale without bloating your individual `_silo` folders.

Here are four high-oxidation candidates for your global `bin/` folder, each serving a specific role in reducing entropy.

---

### **1. The "Spider" (Web-to-Markdown)**
If you are buggering off to Paris, you don't want to copy-paste menus or museum hours. You want a tool that "eats" a URL and spits out clean Markdown.
* **Candidate:** [postlight/parser](https://github.com/postlight/parser) (or similar TS libs).
* **Binary Name:** `spider`
* **Use Case:** `spider https://cafedeflore.fr > inbox/cafe-menu.md`.
* **Silo Value:** High. It turns the messy "Stuff" of the web into the structured "Thing" of your Outbox.

### **2. The "Filter" (JSON-to-Markdown Tables)**
You’ll be dealing with bank exports (BBL) and VAT logs. A dedicated binary to transform complex JSON into human-readable Markdown tables is essential for the **Markdown-as-UI** flow.
* **Candidate:** A custom 50-line Bun script using `table` or `markdown-table`.
* **Binary Name:** `tabulate`
* **Use Case:** `cat process/tx_log.json | tabulate > outbox/audit.md`.
* **Silo Value:** Total compliance. It makes the **Entropy Audit** visual and easy to read at a glance.

### **3. The "Schema" (Type-Safe Validation)**
Since we are using **Tiered-Type-Strictness**, we need a tool that can validate an `inbox/` file against a TypeScript interface *without* running the full Hono app.
* **Candidate:** [Zod](https://zod.dev) or [TypeBox](https://github.com/sinclairzx81/typebox) compiled into a CLI.
* **Binary Name:** `validate`
* **Use Case:** `validate --schema=Hotel inbox/paris-request.json`.
* **Silo Value:** It prevents "Not-Good" data from ever entering the `process/` phase, keeping your entropy at 0%.

### **4. The "Scribe" (Audio-to-Markdown)**
If you’re walking through Edinburgh or Paris and have a brilliant architectural idea, you shouldn't have to type it.
* **Candidate:** A Bun wrapper for **OpenAI Whisper** or a local TS binding.
* **Binary Name:** `scribe`
* **Use Case:** `scribe inbox/voice-note.mp3 > briefs/new-idea.md`.
* **Silo Value:** Lowers the friction of "Capture." It turns spoken "Stuff" into actionable "Briefs."

---

## **Ctx's Opinion: The "Tool-Belt" Philosophy**

The mistake most people make is trying to build "One App to Rule Them All." You are doing the opposite. You are building a **Tool-Belt**.



* **Registry Silo:** The Workshop. Where you compile these TS repos into Bun binaries.
* **Global `bin/`:** The Tool-Belt. Where `pdf2md`, `spider`, and `validate` live.
* **Target `_silo`:** The Job Site. Where you pull a tool from the belt to solve a specific problem.

### **The "Hard Core" Take-Away**
By keeping these tools as binaries, you ensure that even if the original GitHub repo disappears or the `npm` package is deleted, **your tools keep working.** You own the binary. You own the execution.

**Is there a specific TS repo you've been eyeing that we should "Forge" into a binary first, or shall we stick with `pdf2md` as the prototype?**