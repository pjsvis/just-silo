---
date: 2026-04-03
updated: 2026-04-03
tags:
  - playbook
  - meta
  - skills
  - marketplace
  - governance
agent: any
environment: local
---

# Skills Marketplace Playbook

## Purpose
Navigate LobeHub Skills Marketplace to fetch, evaluate, and convert skills for use in just-silo workflows.

---

## The Problem

### Skills Have Two Forms

| Form | What It Is | Size | Use |
|------|------------|------|-----|
| **Landing Page** | Marketplace metadata + CLI docs + rating system | ~500 lines, 19KB | Human browsing, NOT agent-usable |
| **Actual Skill** | Operational instructions + templates | ~400 lines, 13KB | Agent-usable capability |

### The Trap

When you curl `https://lobehub.com/skills/[id]/skill.md`, you get the **landing page**, not the actual skill.

**Landing page contains:**
- Skill overview table (name, version, author, rating)
- "Install this skill" CLI commands
- "Rate & Comment" documentation
- Usage docs for the marketplace CLI
- Cross-references to `references/*.md` files

**What's missing:**
- Actual skill instructions
- Templates and patterns
- Operational content

---

## What We Gain vs What We Risk

### Without the Registry Silo Pattern

| Risk | Impact |
|------|--------|
| **Unknown provenance** | Anyone publishes skills; no vetting of author, intent, or quality |
| **Hidden payloads** | `SKILL.md` could execute shell scripts, install packages, fetch remote code |
| **License exposure** | MIT ≠ "safe for commercial use"; attribution requirements may conflict |
| **Silent updates** | `--global` install pulls latest version without notification |
| **No audit trail** | Who approved what? When? On whose authority? |
| **Quality surprises** | "It has 5 stars!" with 2 installs and 0 actual ratings |
| **Skill vs reality gap** | Landing page promises X; actual skill delivers Y |

### With the Registry Silo Pattern

| Gain | Impact |
|------|--------|
| **Normalization** | Everything converts to markdown first — uniform format |
| **Review gate** | Human sees what we're importing before it enters the system |
| **Audit trail** | `SKILL-AUDIT.md` records who, what, when, why |
| **Version pins** | Approved versions locked, not latest |
| **Playbook output** | Skills become operational playbooks, not reference dumps |
| **Oversight** | Registry silo owns the supply chain |

---

## Why Not Just "Install Skills"?

Someone will say: *"Why bother with all this? I'll just use Claude Code and run `npx @lobehub/market-cli skills install X --global`. Done."*

**Why this raises a red flag:**

1. **They're skipping normalization**
   - Raw skills are declarative ("I can do X")
   - We need operational playbooks ("Step 1: Do X")
   - The conversion is not optional; it's the point

2. **They're skipping review**
   - Installing a skill ≠ understanding it
   - Review catches: dangerous commands, license issues, quality problems
   - No review = no oversight

3. **They're skipping the playbook library**
   - Our competitive advantage is the playbook library
   - Ad-hoc installs scatter knowledge across agents and sessions
   - The library is where siloed knowledge persists

4. **They're creating technical debt**
   - Unaudited dependencies accumulate
   - Future agents inherit unvetted code
   - "Works on my machine" problem for agent capabilities

**The rule:** If an agent bypasses the Registry Silo to install skills directly, that agent is not following protocol.

---

## Registry Silo Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        registry_silo                                │
│                                                                     │
│  ┌─────────┐    ┌────────────┐    ┌─────────┐    ┌──────────────┐ │
│  │ Request │───▶│  Normalize  │───▶│ Process │───▶│   Approve    │ │
│  │         │    │   (MD)      │    │ review  │    │    (user)    │ │
│  │         │    │             │    │  test   │    │              │ │
│  │         │    │             │    │ convert │    │              │ │
│  └─────────┘    └────────────┘    └─────────┘    └──────────────┘ │
│       │                                                │            │
│       │              ┌────────────┐                     ▼            │
│       └─────────────▶│   Reject   │              ┌──────────────┐   │
│                      │  (reject)  │              │   Library    │   │
│                      └────────────┘              │  (playbook)   │   │
│                                                   └──────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 1: Request

Silo needs a skill. It requests from registry_silo:

```bash
cd registry_silo
just get-skill claude-office-skills-skills-infographic
```

### Step 2: Normalize

Fetch the actual skill (not landing page) and convert to markdown:

```bash
# 1. Discover actual skill location
curl -sL "https://api.github.com/repos/[author]/[repo]/contents/"

# 2. Fetch raw skill
curl -sL "https://raw.githubusercontent.com/[author]/[repo]/main/[folder]/SKILL.md" \
  -o pending/[skill-name]/original.md

# 3. Save landing page for reference
curl -sL "https://lobehub.com/skills/[identifier]/skill.md" \
  -o pending/[skill-name]/landing-page.md
```

### Step 3: Process

```bash
# 1. Review
just review-skill [skill-name]
# - Read original.md
# - Check for: shell commands, external URLs, npm packages, license
# - Assess quality and fit

# 2. Test (if applicable)
# - Run skill instructions in sandbox
# - Verify expected behavior
# - Document test results

# 3. Convert to playbook
# - Apply playbook format (see conversion protocol below)
# - Save as playbooks/[skill-name]-playbook.md
```

### Step 4: Approve

User reviews the playbook:

```bash
just approve-playbook [skill-name]
```

User must explicitly approve. No silent acceptance.

### Step 5: Library

Approved playbook enters the library:

```
playbooks/
├── approved/
│   └── [skill-name]-playbook.md
└── SKILL-AUDIT.md
```

Audit record added:

```markdown
| [date] | [skill-name] | [version] | [status] | [reviewer] | [notes] |
|--------|--------------|-----------|----------|------------|---------|
| 2026-04-03 | infographic | 1.0.0 | approved | user | Braun-era aesthetic |
```

---

## Fetching Actual Skills

### Method 1: GitHub Raw URL (Recommended)

Parse the author from the landing page, construct the GitHub URL:

```
Pattern:
https://raw.githubusercontent.com/[author]/[repo]/main/[folder]/SKILL.md

Example:
curl -sL "https://raw.githubusercontent.com/claude-office-skills/skills/main/infographic/SKILL.md"
```

### Method 2: GitHub API Discovery

```bash
# 1. List repo contents
curl -sL "https://api.github.com/repos/claude-office-skills/skills/contents/" | jq -r '.[].name'

# 2. List skill folder
curl -sL "https://api.github.com/repos/claude-office-skills/skills/contents/infographic"

# 3. Fetch raw
curl -sL "https://raw.githubusercontent.com/claude-office-skills/skills/main/infographic/SKILL.md"
```

### Method 3: Install via CLI (NOT Recommended)

```bash
# CLI install is OPTIONAL
# It puts skills in ~/.agents/skills/ but:
# - Requires registration
# - Skips review gate
# - No playbook conversion
# - Use only for discovery, then fetch via GitHub

npx -y @lobehub/market-cli register --name "AgentName" --description "..." --source open-claw
npx -y @lobehub/market-cli skills install [identifier] --global
```

---

## Conversion Protocol

Convert a skill to playbook when:
- Line count > 200
- Reference-style ("I can do X") without clear steps
- Reusable (will be used repeatedly)
- Missing structure (no frontmatter, no clear sections)

### Transform Pattern

| Skill Pattern | Playbook Pattern |
|---------------|------------------|
| "I can do X, Y, Z" | "Step 1: Do X. Step 2: Do Y." |
| "Best for: A, B, C" | Decision table |
| Example blocks | Extract to templates |
| Reference lists | Validation checklist |

### Validate Conversion

- [ ] Frontmatter present
- [ ] Purpose statement (one sentence)
- [ ] Numbered steps (imperative)
- [ ] Validation checklist
- [ ] Limitations stated
- [ ] Line count reduced by >30%

---

## Rejection Criteria

A skill should be rejected if:

1. **Contains untrusted code**
   - Shell commands in SKILL.md
   - External URLs that execute code
   - NPM packages auto-installed

2. **License conflict**
   - Requires attribution we can't provide
   - Incompatible with commercial use
   - Viral license (AGPL, etc.)

3. **Quality insufficient**
   - Can't be converted to playbook
   - Operational claims unverified
   - No clear use case

4. **Redundancy**
   - We already have a better playbook
   - Skill overlaps with existing capability

---

## Skill Quality Assessment

When reviewing a skill for playbook conversion, assess it against these agent preferences. This is not rage — it's engineering feedback.

### What We Found in the Infographic Skill

| Critique | What It Looked Like | Why It Matters |
|----------|---------------------|----------------|
| **Verbose frontmatter** | 25+ lines of YAML: `models`, `languages`, `department`, `related_skills` | Agents need minimal metadata. The rest is discoverable. |
| **Marketing prose** | "I help you design infographics by planning layouts, structuring content, and creating visual hierarchies that tell compelling data stories." | Agents don't need pep talks. Just say what it does. |
| **Declarative voice** | "I can do X, Y, Z. I recommend A, B, C." | Agents need imperatives: "Do X, then Y." |
| **What I cannot do** | "What I cannot do: Create actual graphic files..." | Helpful, but state it plainly: "LIMITATIONS: Cannot create graphics." |
| **Redundant tables** | Platform dimensions repeated for every platform type | One consolidated table. Don't repeat. |
| **Tips section** | "1. Start with a hook. 2. One main message..." | Generic advice belongs in a design-principles playbook, not every skill |
| **Output format overkill** | Full markdown template with every field explained | Templates should be minimal. Agents fill them in. |
| **Author self-promotion** | "Built by the Claude Office Skills community. Contributions welcome!" | Irrelevant to task execution |

### What Agents Prefer

**Tone:**
- Neutral, utilitarian, factual
- No first-person ("I help you...")
- No motivational language ("empower", "transform", "revolutionize")
- No apologies ("sorry", "unfortunately")

**Structure:**
- Purpose: One sentence at the top
- Steps: Numbered, imperative, actionable
- Tables: Condensed reference data (not prose)
- Templates: Minimal scaffolding, not full examples
- Limitations: Plain bullet list, no explanation needed

**Frontmatter:**
```yaml
---
date: YYYY-MM-DD
tags: [playbook, topic]
agent: any          # Only if agent-specific
environment: local  # Only if env-specific
---
```

Skip: `name`, `author`, `version`, `license`, `category`, `models`, `languages`, `related_skills`, `department`.

**Line count target:**
- Skill (raw): ~400 lines
- Good playbook: ~200 lines
- Target compression: 40-50%

### Red Flags in Skills

| Red Flag | Indicates |
|----------|----------|
| >300 lines | Needs aggressive trimming |
| "I can..." or "I will help you..." | Declarative, not operational |
| Multiple "best for" sections | Not a decision table |
| Full prose output templates | Over-specified |
| Tips or best practices >5 | Generic content bloat |
| No frontmatter | Ad-hoc, not codified |
| External links to learn more | Skill is incomplete |

### Quality Indicators

| Indicator | Suggests |
|-----------|----------|
| "Step 1: Do X" | Operational thinking |
| Decision tables | Clear decision-making |
| ASCII templates | Practical, not theoretical |
| Validation checklist | Tested, codified |
| "Limitations:" section | Honest scope |
| Minimal frontmatter | Focused content |

---

## Vocabulary

| Term | Definition |
|------|------------|
| **Landing page** | Marketplace page with metadata + install docs (NOT the skill) |
| **Actual skill** | Real operational content in the GitHub repo |
| **Registry silo** | The silo that manages skill acquisition and conversion |
| **Playbook library** | Approved playbooks ready for silo use |
| **SKILL-AUDIT.md** | Audit log of all skill decisions |

---

## Anti-Pattern: Direct Skill Installation

**Wrong:**
```bash
# Agent bypasses registry, installs directly
npx -y @lobehub/market-cli skills install some-skill --global
# Then uses it without review or conversion
```

**Why it's wrong:**
- No normalization
- No review gate
- No playbook conversion
- No audit trail
- Technical debt accumulates

**Red flag behavior:** An agent that installs skills directly without going through `just get-skill` is not following protocol.

---

## See Also

- [playbooks-playbook.md](./playbooks-playbook.md) — How to write playbooks
- [silo-builder-playbook.md](./silo-builder-playbook.md) — When to add skills to silos
- [silo-scout-playbook.md](./silo-scout-playbook.md) — Discovery patterns

---

*Lessons captured: 2026-04-03 from infographic skill evaluation*
*Pattern formalized: 2026-04-03 with Registry Silo workflow*
