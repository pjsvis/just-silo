This brief provides a structured plan for a coding agent to implement a functional demonstration of the **just-silo** framework. The demo will execute a recursive "Launch Prep" workflow, using **Glow** to render agentic reasoning and **Gum** to facilitate rapid human-in-the-loop (HITL) triage.

### Project Brief: Recursive Launch Workflow for Just-Silo

#### 1. Core Objective
Implement a demo workflow where an agent within a **just-silo** (directory) prepares social media outreach and community engagement for the framework's own launch. The system must adhere to the **Hejlsberg Inversion**: the directory is the "program" the agent interprets to "just f*cking do it."

#### 2. Environment & Tooling
*   **The Silo**: A dedicated directory (`./launch-silo/`) with restricted OS permissions.
*   **Glow**: Used for "Reasoning Visibility." Every agent proposal must be rendered as formatted Markdown for the human to read before approval.
*   **Gum**: Used for "Speed-on-the-Loop." Use `gum confirm` for binary approvals and `gum choose` for selecting between generated drafts.
*   **Logic**: A simple Bash or TypeScript wrapper that reads from the silo's `tasks/` folder and writes to `output/`.

#### 3. Functional Requirements: The "Launch Prep" Loop

**Phase A: Intelligence Mapping (Cloud/Planner)**
*   The agent reads a list of local influencers and subreddits from `context/targets.md`.
*   It generates a set of 3 distinct launch post options (e.g., one for Hacker News, one for X, one for Reddit).

**Phase B: Human-in-the-Loop Triage (TUI Interface)**
*   **Step 1 (Glow)**: The agent outputs the draft proposals to a temporary `.md` file and calls `glow proposal.md` to display it to the user with syntax highlighting and professional formatting.
*   **Step 2 (Gum)**: The system immediately follows with a `gum choose` menu:
    *   *Select Draft*: "Draft A (Technical)", "Draft B (Provocative)", "Draft C (Educational)".
*   **Step 3 (Gum)**: If a draft is selected, use `gum input` to allow the user to add a custom "vibe" or tag.
*   **Step 4 (Gum)**: Final confirmation via `gum confirm "Ready to schedule?"`.

**Phase C: Deterministic Execution (Local/Edge)**
*   Upon approval, the agent "just does it" by writing the final approved content to `output/final_launch_schedule.json`.
*   The workflow uses `gum spin --title "Siloing approved assets..."` to provide feedback during the final file writing process.

#### 4. The "Hejlsberg Inversion" Structure
The agent should not be given an open-ended prompt. Instead, the coding agent must structure the silo so that the filesystem *is* the logic:
*   `./tasks/todo.md`: The agent's current objective.
*   `./context/`: Read-only directory containing technical docs.
*   `./scratchpad/`: Temporary directory where the agent drafts ideas before showing them via Glow.
*   `./approved/`: The only directory the agent has write access to after human confirmation.

#### 5. Security & Safety Primitives
*   **Path Enforcement**: The script must use `pwd` and shell variable expansion to ensure every command is prefixed with the silo path, preventing path traversal outside the directory.
*   **Fail-Shut**: If the human rejects a proposal (`gum confirm` returns non-zero), the agent must immediately stop execution and log the rejection to `./logs/audit.log` rather than attempting to "reason" its way out of the rejection.

#### 6. Success Metrics for the Demo
*   **Zero-UI Bloat**: No browser windows or localhost servers were used for the entire launch prep.
*   **High Velocity**: The time from "Draft Generated" to "Ready to Schedule" is under 15 seconds.
*   **Auditability**: The directory contains a physical record of exactly what the human saw (Glow inputs) and what the human clicked (Gum choices).