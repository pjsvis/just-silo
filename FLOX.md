# Flox Environment — just-silo

## Purpose

`flox.toml` defines the just-silo dev environment as a **Flox manifest** (Nix-based). This lets you activate a reproducible environment on Arch Linux without relying on `pacman` / `yay` / AUR directly.

**Three layers, one goal:**

| Layer | Tools | Method |
|-------|-------|--------|
| **Flox** | `just`, `jq`, `watchexec`, `nodejs`, `glow`, `gum`, `fzf`, `ripgrep`, `bat`, `fd`, `tree`, `shellcheck`, `rclone`, `gh`, `python3`, `man`, `go` | `flox install` |
| **marcus** | `td` (task management), `sidecar` (TUI IDE with td integration) | Official setup script |
| **npm** | `pi` (`@mariozechner/pi-coding-agent`) | `npm install -g` |
| **Script** | `bun`, `uv` | Official install scripts |

## Quick Start (Arch Linux)

```bash
# 1. Install flox
#    https://flox.dev/install

# 2. Activate environment
flox activate

# 3. Install marcus ecosystem (td + sidecar)
curl -fsSL https://raw.githubusercontent.com/marcus/sidecar/main/scripts/setup.sh | bash
#    Or on macOS: brew install marcus/tap/sidecar

# 4. Install bun (not in nixpkgs)
curl -fsSL https://bun.sh/install | bash

# 5. Install pi coding agent (not in nixpkgs)
npm install -g @mariozechner/pi-coding-agent

# 6. Clone and run
git clone https://github.com/petersmith/just-silo.git
cd just-silo
flox run -- just verify
```

## Running Commands in the Environment

```bash
# One-shot without shell
flox run -- just silo-status
flox run -- just dev-check
flox run -- just watch-tests

# Full dev shell
flox activate
just --list
```

## Tool Inventory

Derived from all `command -v` checks and `require_cmd` invocations across `scripts/` and `justfile`.

### Required (Core)

| Tool | Used in | Notes |
|------|---------|-------|
| `just` | All recipes | Task runner |
| `jq` | All scripts | JSON processing |
| `watchexec` | `just watch-*` | File watcher |
| `nodejs` | `npm install` calls | npm runtime |

### Optional (Flox-installed)

| Tool | Used in | Notes |
|------|---------|-------|
| `glow` | `scripts/about.sh` | Markdown renderer |
| `gum` | `scripts/briefs.sh`, `scripts/google-docs-*.sh` | TUI helpers |
| `fzf` | `scripts/briefs.sh` (find, plan, archive) | Fuzzy finder |
| `ripgrep` | Throughout scripts | Better grep |
| `bat` | Throughout scripts | Cat with syntax |
| `fd` | Throughout scripts | Better find |
| `tree` | `just --list` / docs | Directory viewer |
| `shellcheck` | Agent shell work | Shell linter |
| `rclone` | `scripts/google-docs-*.sh` | Google Drive sync |
| `gh` | `scripts/pr-review.sh` | GitHub CLI |
| `python3` | `scripts/markdown-sanitize.sh` | Inline Python scripts |
| `man` | `just help` / docs | Manual pages |
| `go` | marcus setup script | Required for building td/sidecar from source |

### marcus ecosystem (Go binaries, not in nixpkgs)

| Tool | Used in | Install |
|------|---------|---------|
| `td` | Task management, agent coordination | `curl -fsSL https://raw.githubusercontent.com/marcus/sidecar/main/scripts/setup.sh \| bash` |
| `sidecar` | TUI IDE with td integration | Same setup script or `brew install marcus/tap/sidecar` |

### Not in nixpkgs (Post-activate install)

| Tool | Used in | Install |
|------|---------|---------|
| `bun` | `just api-*`, TypeScript builds | `curl -fsSL https://bun.sh/install \| bash` |
| `pi-coding-agent` | Agent framework | `npm install -g @mariozechner/pi-coding-agent` |
| `uv` | Python fast env | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `skate` | Optional KV store | System binary |

## Package Availability Map

```
Tool              nixpkgs  Arch pacman  Brew      Arch AUR
--------------   -------  ------------ --------  --------
just             ✅       ✅           ✅        yay
jq               ✅       ✅           ✅        ✅
watchexec        ✅       ❌           ✅        yay
nodejs           ✅       ✅           ✅        ✅
glow             ✅       GitHub       ✅        GitHub
gum              ✅       GitHub       ✅        GitHub
fzf              ✅       ✅           ✅        ✅
ripgrep          ✅       ✅           ✅        ✅
bat              ✅       ✅           ✅        ✅
fd               ✅       ✅           ✅        ✅
tree             ✅       ✅           ✅        ✅
shellcheck       ✅       ✅           ✅        ✅
rclone           ✅       ✅           ✅        ✅
gh               ✅       ✅           ✅        ✅
python3          ✅       ✅           ✅        ✅
man              ✅       ✅           ✅        ✅
go               ✅       ✅           ✅        ✅
git              ✅       ✅           ✅        ✅
bun              ❌       ❌           ✅        script
td              ❌       ❌           ❌        ❌
sidecar         ❌       ❌           ✅        ❌
pi-coding-agent  ❌       ❌           ❌        ❌
uv              ❌       ❌           ✅        pip
skate            ❌       ❌           ❌        ❌
```

## Flox vs. Omarchy

The `scripts/provision-arch-omarchy.sh` is the **reference full-box setup** — it installs everything from scratch including Docker, Neovim, fish, the full Charm toolchain, and more.

`flox.toml` is **finer-grained**: it's per-project, activated on demand, and doesn't require root. Use it when you want to:

- Reproduce the just-silo environment in a CI container
- Give a collaborator a single `flox activate` to get running fast
- Keep the environment explicit and version-controlled alongside the code
- Layer only the tools you need over an existing Arch install

## Architecture Notes

- Flox uses **nixpkgs-unstable** under the hood, so newer packages land faster than Arch stable
- `bun` is intentionally excluded from nixpkgs-based installs — the official install script is faster and avoids version skew
- `uv` is in nixpkgs but the official script is faster for CI
- `td` and `sidecar` are Go binaries from the marcus ecosystem — not in nixpkgs, installed via the official sidecar setup script (which handles both)
- `pi-coding-agent` is a private npm package — not in any public catalog
- `skate` is macOS/Linux only — no cross-platform install needed

## See Also

- `scripts/provision.sh` — Simplified Arch provisioning
- `scripts/provision-arch-omarchy.sh` — Full Arch omarchy setup
- `scripts/dev-check.sh` — Prerequisite checker
- `AGENTS.md` — Agent framework docs
