In the `marcus/td` ecosystem, moving from a single agent to a multi-agent setup shifts the logic from **"Focus"** to **"Session Isolation."**

The "Focus" status is indeed primarily a single-agent/single-human affordance. In a multi-agent scenario, relying on a global "Focus" would create race conditions and context bleed.

### 1. The Multi-Agent Mechanism: Session IDs
The core of `td` for multiple agents is the **Session ID**.
* **Unique Identities:** Every terminal, process, or specific agent instantiation is assigned a unique session ID. 
* **Automatic Context Rotation:** When you run `td usage --new-session`, the CLI detects the agent’s identity (or creates a new one) and rotates the local context.
* **The Handoff Protocol:** Instead of agents "looking" at a shared focus, they use the `td handoff` command. This creates a structured record in the SQLite database that includes:
    * `--done`: What Agent A finished.
    * `--remaining`: What is left for Agent B.
    * `--decisions`: Why Agent A took a specific path.

### 2. Is "Focus" Used?
**Strictly speaking: No.** In a multi-agent Silo, "Focus" is replaced by **"Claiming."**
* **The Shared Ledger:** All agents read from the same `.todos/db.sqlite`.
* **Status as a Lock:** When Agent A starts a task, it runs `td start <id>`. This moves the status to `in_progress` and attaches Agent A's session ID to the task. 
* **Collision Avoidance:** If Agent B runs `td usage`, it sees that `<id>` is already `in_progress` by another session. It effectively treats this as a "Lock" and moves to the `td next` available task.



### 3. Multi-Agent Status Workflow
The "Status" field becomes the primary coordinator:

| Status | Multi-Agent Meaning |
| :--- | :--- |
| **Open** | Available for any agent to "Claim" via `td start`. |
| **In Progress** | Locked. Owned by a specific Session ID. |
| **Pending Review** | The "Handoff" state. Agent A has finished but cannot close the task. |
| **Closed** | Finality. Verified by a human or a secondary "Evaluative" agent. |

### 4. The "Evaluative" Handoff
One of the most important rules in the `marcus/td` documentation is: **"You cannot approve work you implemented."** * Agent A (The Generative Agent) implements a feature and runs `td review <id>`.
* Agent B (The Evaluative/Review Agent) sees the task in `pending_review` via `td usage`.
* Agent B executes the tests and, if they pass, moves the status to `closed`. 

This "Session Isolation" is what prevents the "Works on my context" bug and ensures that the Silo's entropy remains low.

### Summary for the Silo
In your Silo, you don't need to worry about "Focus." You simply ensure every agent runs `td usage --new-session` upon instantiation. The agents will then naturally self-organize by claiming `open` tasks and handing off `pending_review` tasks to their peers.

**Shall we define the `just claim-next` verb, which combines `td next` and `td start` into a single atomic action for your agents?**
