# Playbook: ctx - Command Memory Palace

**Type `ctx` when you forget what you know.**

## When someone asks about commands

**Scenario:** "How do I attach to a tmux session?"

**Old way:** Tell them the command. They forget it tomorrow.

**New way:** "Just type `ctx`, search for attach."

## When onboarding someone

**Scenario:** New dev joining the team.

1. "Install gum: `brew install gum`"
2. "Install ctx: `npm install -g ctx-cli`"
3. "Link it: `ln -s ~/Dev/GitHub/ctx-cli/ctxx.sh ~/bin/ctx`"
4. "When you forget, just type `ctx`"

They get:
- A fuzzy command lookup
- Your curated command memory
- A pattern they can extend

## When someone asks "what is this ctx thing?"

**Elevator pitch:**
> "It's a fuzzy command lookup. Type `ctx` when you forget what you know. It's my command memory palace."

**Technical pitch:**
> "Bash + gum. Fuzzy search with pretty output. Your commands, searchable. I can show you."

## When someone wants their own

**Option 1:** Clone and customize
```bash
git clone https://github.com/pjsvis/ctx-cli.git ~/Dev/GitHub/ctx-cli
# Edit ctx.json to add your commands
```

**Option 2:** Fork the repo
- Fork on GitHub
- Customize ctx.json
- Publish as your own

## Adding new commands

1. Edit `ctx.json`
2. Add entry:
   ```json
   {
     "type": "command",
     "command": "the actual command",
     "description": "what it means",
     "category": "your-category"
   }
   ```
3. Commit and push

## Categories: when to add

Add a category when you have:
- 5+ related commands
- A workflow pattern
- Something you keep forgetting

Current categories:
- **tmux** — Terminal (10 commands)
- **td** — Tasks (16 commands)
- **github** — PRs (10 commands)
- **bun** — Build (6 commands)
- **help** — How to use ctx (7 commands)

## Fuzzy search tips

**To match exactly:** Type the category with colon
```
tmux:
```

**To fuzzy search:** Type fragments in order
```
attach     → tmux attach -t [name]
pr list    → gh pr list
```

**Fuzzy rules:**
- Characters must appear in order
- "tma" matches "tmux attach" (t-m-a in order)
- Doesn't need to be contiguous

## The ctx conversation

**Them:** "How do I attach to tmux?"

**You:** 
```
$ ctx

  CTX  

  what do you need? attach
```

**Result:** "Oh right, `tmux attach -t [name]`"

## When ctx isn't enough

ctx is for commands you know but forget syntax.

For learning new things, use:
- `man` pages
- `--help` flags
- Google
- Documentation

ctx is the last step in the learning journey, not the first.

## Extending for teams

1. **Shared JSON:** Git repo with ctx.json, team syncs
2. **Personal overlay:** Your ctx.json + team's ctx.json
3. **Category inheritance:** Base categories + personal additions

## Fabric Integration

**experiments/fabric-tui/** contains AI pattern tools:
- `fabric-tui.sh` — Full TUI for Fabric patterns
- `fabric-ctx.sh` — Lightweight ctx-style lookup
- `fabric-explore.sh` — Browse patterns by description

To add fabric patterns to ctx:
1. Link scripts to ~/bin
2. Add to ctx.json:
   ```json
   {
     "type": "command",
     "command": "fabric-explore",
     "description": "browse fabric patterns",
     "category": "ai"
   }
   ```

> "ctx-cli is the compass. fabric-tui is the explorer."

## The dream

> Every developer has their own ctx.
> Team leads share templates.
> New devs clone and customize.
> "Just type `ctx`" becomes common knowledge.

---

**Later, dude. Ship it.**
