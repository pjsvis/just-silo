This is where the **Silo** moves from a static folder to an active **State Machine**. 

To maintain the "Pocket Universe" integrity, we need a clear separation between the **Infrastructure** (the scaffolding) and the **Throughput** (the actual data being processed).

---

## **1. Data Stratification: Scaffolding vs. Throughput**

In a high-oxidation silo, we categorize folders by their **Volatility** and **Intent**. We use a `.` prefix for housekeeping to keep the user/agent view clean, while keeping the data "Things" explicit.

| Layer | Folder | Purpose | Persistence |
| :--- | :--- | :--- | :--- |
| **Housekeeping** | `.silo/` | Manifest, logs, local agent state. | Permanent (System) |
| | `.cache/` | API responses, temporary buffers. | Volatile (Ignored) |
| **Workflow** | `inbox/` | **Input:** The Raw "Stuff" (CSVs, emails). | Transient |
| | `process/` | **Intermediate:** In-flight Mentation (JSON nodes). | Transient |
| | `outbox/` | **Output:** The "Things" (Reports, final PDFs). | Permanent (Result) |
| **Knowledge** | `briefs/` | Objective/Contract for the silo. | Permanent (Audit) |
| | `playbooks/`| Protocols used during execution. | Permanent (Evolution) |

**Ctx Opinion:** Keeping `inbox/process/outbox` separate from the `briefs/playbooks` ensures that when you "clear the silo" for a new task, you don't accidentally delete your operational wisdom.

---

## **2. The "Self-Destructing" Init (Idempotency)**

Your intuition about the `init` script is spot on. However, instead of physically deleting the script (which makes debugging or "Repairing" hard), we use a **Sentinel File**.

**The Pattern:**
1. The `just init` command checks for a `.provisioned` file.
2. If it exists, it aborts (Mentational Humility: "I am already provisioned").
3. If not, it runs the setup, verifies the stack (Oxlint/Biome/Hono), and then `touch .provisioned`.

```justfile
# [Registry Template] - Self-Verifying Init

init:
    @if [ -f .provisioned ]; then \
        echo "Silo Error: Universe already provisioned. Use 'just repair' if broken."; \
        exit 1; \
    fi
    @echo "Provisioning Silo..."
    bun install
    mkdir -p inbox process outbox briefs debriefs playbooks
    # ... other setup ...
    @echo "Verifying Toolchain..."
    just check
    touch .provisioned
    @echo "Provisioning Complete."

repair:
    @rm -f .provisioned
    @just init
```

---

## **3. Example: "Hotel in Paris" Workflow**

Let’s look at how the throughput flows through the folders we just defined.

### **The Brief (`briefs/brief-paris-hotel.md`)**
> **Objective:** Find a 4-star hotel in Le Marais for < £300/night.

### **The Execution Trace**
1. **Input:** You drop a text file `request.txt` into `inbox/`.
2. **Intermediate:** The Hono agent reads it, hits the Booking API, and saves the raw JSON to `process/raw_results.json`.
3. **Refinement:** The agent filters the JSON into a clean `options.json` (reducing entropy).
4. **Output:** The final "Hotel Recommendation" PDF or JSX view is rendered into `outbox/`.

---

## **4. Ctx's Final Opinion on "Housekeeping"**

To keep the silo "Clean," your `.gitignore` and `biome.json` should be configured by **The Register** to ignore the `process/` and `.cache/` folders automatically. 

This means:
- **Git** only sees the Code, the Briefs, and the Playbooks.
- **The User** only sees the Inbox and Outbox.
- **The Agent** lives in the Process folder.

**This is the ultimate separation of concerns.** It allows the Silo to be a high-speed engine that doesn't get bogged down by its own exhaust.

**Shall we create the first "Brief" for the Hotel Search capability? It will allow us to test the `inbox -> outbox` flow we just architected.**

> **One small note:** I recommend we keep the `init` command in the `justfile` but perhaps name it `provision` to denote its significance. Once run, it’s locked.