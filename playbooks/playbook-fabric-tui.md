# Playbook: Fabric CLI

## When to use each script

### fabric-tui.sh — Full power user mode

When you know Fabric exists and want the full experience:
```bash
./fabric-tui.sh
```

**Flow:**
1. Search/select pattern
2. Select model (optional)
3. Enter query
4. View output
5. Save or pipe to something else

### fabric-ctx.sh — Quick query mode

When you want ctx-style frictionless search:
```bash
./fabric-ctx.sh
```

**Flow:**
1. Select pattern
2. Enter query
3. Done

**Good for:** one-off queries, muscle memory

### fabric-explore.sh — Discovery mode

When you don't know what you want:
```bash
./fabric-explore.sh
```

**Flow:**
1. Browse patterns with descriptions
2. Type to filter
3. Select pattern
4. Enter query

**Good for:** learning Fabric, finding new patterns

## Quick patterns

```bash
# Full TUI
./fabric-tui.sh

# Quick mode (uses 'ai' pattern, single line)
./fabric-tui.sh --quick

# Specific pattern directly
./fabric-tui.sh -p analyze_prose "Your text"

# Explorer mode
./fabric-explore.sh

# Ctx style
./fabric-ctx.sh
```

## Integration with ctx-cli

Add to your `ctx.json`:

```json
{
  "type": "command",
  "command": "fabric-tui",
  "description": "full fabric TUI",
  "category": "ai"
},
{
  "type": "command",
  "command": "fabric-explore",
  "description": "browse fabric patterns",
  "category": "ai"
}
```

Then link to scripts:
```bash
ln -s ~/Dev/GitHub/ctx-cli/experiments/fabric-tui/fabric-tui.sh ~/bin/fabric-tui
ln -s ~/Dev/GitHub/ctx-cli/experiments/fabric-tui/fabric-explore.sh ~/bin/fabric-explore
```

## Finding patterns

```bash
# List all patterns
fabric --listpatterns | head -20

# Find patterns containing 'code'
fabric --listpatterns | grep code

# See what a pattern does
cat ~/.config/fabric/patterns/ai/system.md
```

## Custom patterns

```bash
# Create new pattern
mkdir -p ~/.config/fabric/patterns/my_pattern
# Add system.md with # IDENTITY and PURPOSE section
# fabric-explore.sh will pick it up
```

## Troubleshooting

### "gum not found"
```bash
brew install gum
```

### "fabric not found"
Install Fabric: https://github.com/danielmiessler/fabric

### Slow startup
Cache is in `~/.cache/fabric-explore/`. Clear with:
```bash
rm ~/.cache/fabric-explore/descriptions.txt
```

### TTY errors in scripts
The scripts work fine interactively. For automated testing:
```bash
echo "query" | ./fabric-tui.sh --quick
```

## Philosophy

**fabric-tui is the explorer. ctx-cli is the compass.**

- ctx-cli: "I know there's a command for this"
- fabric-tui: "I know there's a pattern for this"

Both follow the same principle: **low friction recall**.

## Sharing with others

**The pitch:**
> "Fabric is like presets for AI. This TUI makes it searchable. Type `fabric-explore` and browse."

**Show them:**
1. `fabric-explore.sh` — browse patterns
2. `fabric-tui.sh` — full workflow
3. The reminder card after selection

## Extending

### Add a new mode

1. Copy an existing script
2. Modify the workflow
3. Test with `expect` or `script`

### Improve description extraction

Current method:
```bash
grep -A1 "^# IDENTITY and PURPOSE" system.md
```

Better method:
- Parse markdown sections properly
- Handle missing sections
- Extract EXAMPLES for longer descriptions

### Variables support

Fabric patterns can take `-v` flags:
```bash
fabric --pattern summarize -v maxlength=500
```

Add this to the TUI:
```bash
gum input --placeholder "Variables (e.g., maxlength=500)"
```

## The dream

> You know AI can help. You know Fabric has a pattern.
> You just can't remember which one.
> 
> `fabric-explore`
> 
> Browse. Find. Run. Remember.
