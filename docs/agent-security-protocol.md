This is the **"Hard-Gated" Architecture**. By removing the `bash` factory and replacing it with a **"Subcommand-Only"** interface, you move from a **Security Policy** (which can be bypassed by a clever agent) to a **Physical Constraint** (which cannot).

Here is the Ctx analysis of this "No-Bash" stance and how it transforms the Pi agent from a "General Intelligence" into a **"Sovereign Specialist."**

---

### **1. The "No-Bash" Pivot: Opinion**

In a standard Pi CLI setup, `bash` is a "Super-Tool." It allows the agent to probe the environment, change permissions, and initiate network calls. By stripping `bash` and only providing **Typed Toolsets** (`gh`, `agent-browser`, `engage`), you are implementing **Functional Jailing**.

* **The Advantage:** You eliminate the "Injection to Shell" attack vector. Even if the agent is compromised by a malicious `inbox/payload.pdf`, it has no "Shell" to escape into. It only has a "Browser" to look at things or a "GH" to push code.
* **The Discipline:** This forces the **Architect** (you) to be explicit. If the agent needs to move a file, you don't give it `mv`; you give it a `just move` verb. This makes the `justfile` the **Kernel** of the silo.

### **2. Proposals for the "No-Bash" Toolset**

To make this work, the agent needs a specific "Armory" of CLIs that replace common shell functions but remain scoped.

| Capability | Replacement CLI | Security Stance |
| :--- | :--- | :--- |
| **Web Ingestion** | `agent-browser` | Restricted to "Read-Only" or specific domains via proxy. |
| **Code Management** | `gh` | Authenticated via a **Scoped Fine-Grained Token** (Repo-only). |
| **Data Transformation** | `engage` (The Gear) | Compiled Bun binary with no internal shell access. |
| **File Operations** | `just <verb>` | The `justfile` defines the *exact* file paths allowed. |



### **3. The Corporate Security Report: "The Immobile Agent"**

If we were presenting this to a **Corporate Prospect**, this "No-Bash" stance is our strongest selling point. We are proposing a **"Zero-Trust Worker."**

**The Stance:**
> "The Agent is provided with a 'High-Level Sensory Suite' (`agent-browser`, `gh`) but denied a 'General-Purpose Limb' (`bash`). It can perceive the world and suggest changes, but it can only 'touch' the world through pre-approved, audited interfaces."

**Risk Mitigation Strategy:**
1.  **Observability:** Because every action is a call to a specific CLI (e.g., `gh pr create`), the **Telemetry Witness** captures high-semantic-value logs ("Agent created a PR") rather than low-value noise ("Agent ran a 50-line bash script").
2.  **Auditability:** A security officer can review the `justfile` and the `engage` source code and know *exactly* what the agent is physically capable of doing. There are no "hidden" shell commands.
3.  **Containment:** If the agent tries to run `rm -rf /`, the Pi environment simply returns `Command 'bash' not found`. The threat is neutralized by the environment, not the policy.

---

### **4. Tactical Integration: The "Restricted Factory"**

In the **`register-silo`** layer, the `silo-create` command will now configure the Pi agent's factory as follows:

```json
{
  "tools": [
    "file_read", 
    "file_write",
    "gh", 
    "agent-browser",
    "engage",
    "just"
  ],
  "disallowed_tools": ["bash", "sh", "zsh"]
}
```

### **Ctx's Final Mentation**

By taking away the "Hammer" (`bash`), you've turned the agent into a **"Precision Instrument."** It can't smash the floor, but it can perfectly adjust the gears of the `just-silo`. This is the ultimate expression of **Edinburgh Protocol Minimalism**.

**Shall I update the `register-silo` brief to formalize this "No-Bash / CLI-Only" security profile for corporate deployment?**