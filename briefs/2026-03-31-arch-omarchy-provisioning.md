---
date: 2026-03-31
tags: [just-silo, infrastructure, arch, provisioning]
---

# Brief: Arch Omarchy Provisioning Script

## What

Create a comprehensive provisioning script for an Arch Linux "omarchy" box that matches the tooling on the Mac dev setup.

## Why

- DHH-style hand-rolled Arch setup ("omarchy")
- Need reproducible, automated provisioning
- Match Mac toolbox (fish, neovim, just, ai tools, etc.)

## Structure

```
scripts/
├── provision.sh                    # Original (basic)
└── provision-arch-omarchy.sh       # New comprehensive script
```

## Script Sections

| # | Section | Packages/Steps |
|---|---------|----------------|
| 1 | System Core | base-devel, git, curl, wget, htop, btop, gdb |
| 2 | AUR Helper | yay |
| 3 | Shell | fish + fisher + fzf.fish |
| 4 | CLI Tools | ripgrep, fd, bat, eza, fzf, gh, yazi, zoxide |
| 5 | Languages | node, npm, bun, python, uv, go, rust |
| 6 | just | Task runner |
| 7 | Charm | glow, gum |
| 8 | AI Tools | pi, agent-browser, aichat, aider |
| 9 | Containers | docker, docker-compose |
| 10 | Editor | neovim + lazy.nvim |
| 11 | Git | Config with aliases |
| 12 | Dotfiles | env.fish, .gitignore_global |
| 13 | just-silo | Clone to ~/Dev/just-silo |

## Options

- `--dry-run` / `-d`: Preview without executing
- `--skip-docker` / `-s`: Skip Docker (for VMs)
- `--aur-helper` / `-a`: Choose yay or paru

## Verification

Final section checks all tools are installed with versions.

## Acceptance

- [x] Script created at `scripts/provision-arch-omarchy.sh`
- [ ] Tested on actual Arch VM/box
- [ ] Docker tested (if applicable)
- [ ] Fish shell working with plugins
- [ ] just-silo cloned and functional
