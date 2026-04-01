#!/bin/bash
#===============================================================================
# just-silo Arch Linux Omarchy Provisioning
# DHH-style hand-rolled Arch setup
# Target: Fresh Arch install with same tooling as Mac dev box
#===============================================================================

set -euo pipefail

# Configuration
DRY_RUN="${DRY_RUN:-0}"
VERBOSE="${VERBOSE:-0}"
OMARCHY_ROOT="${OMARCHY_ROOT:-$HOME/omarchy}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Dry run wrapper
run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "[DRYRUN] $*"
    else
        "$@"
    fi
}

# Section header
section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Check if running as root (for pacman operations)
check_root() {
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    else
        SUDO="sudo"
    fi
}

# Verify we're on Arch
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is for Arch Linux only!"
        exit 1
    fi
    log_ok "Arch Linux detected"
}

#===============================================================================
# 1. SYSTEM CORE
#===============================================================================
provision_core() {
    section "1. System Core"
    
    log_info "Updating package database..."
    run $SUDO pacman -Sy --noconfirm
    
    log_info "Installing base development tools..."
    # Core utilities
    CORE_PACKAGES=(
        base-devel
        git
        curl
        wget
        rsync
        unzip
        zip
        gzip
        bzip2
        xz
        tar
        coreutils
        findutils
        grep
        sed
        awk
        gawk
        man
        man-pages
        less
        which
        whereis
        tree
        htop
        btop
        iftop
        strace
        ltrace
        gdb
        valgrind
    )
    run $SUDO pacman -S --noconfirm "${CORE_PACKAGES[@]}"
    
    log_ok "Core system packages installed"
}

#===============================================================================
# 2. AUR HELPER (yay or paru)
#===============================================================================
provision_aur_helper() {
    section "2. AUR Helper"
    
    if command -v yay >/dev/null 2>&1; then
        log_ok "yay already installed"
    elif command -v paru >/dev/null 2>&1; then
        log_ok "paru already installed"
    else
        log_info "Installing yay (AUR helper)..."
        local tmp_dir="/tmp/yay-install-$$"
        run mkdir -p "$tmp_dir"
        run $SUDO pacman -S --noconfirm git go
        run git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
        run cd "$tmp_dir/yay"
        run makepkg -si --noconfirm
        run cd ~
        run rm -rf "$tmp_dir"
        log_ok "yay installed"
    fi
    
    # Use yay as AUR helper
    AUR_HELPER="${AUR_HELPER:-yay}"
}

#===============================================================================
# 3. SHELL (fish)
#===============================================================================
provision_shell() {
    section "3. Shell (fish)"
    
    log_info "Installing fish shell..."
    run $SUDO pacman -S --noconfirm fish
    
    # fisher (fish plugin manager)
    if ! command -v fisher &>/dev/null; then
        log_info "Installing fisher (fish plugin manager)..."
        run curl -sL https://git.io/fisher | run fish -c "source - | fish"
    fi
    
    # Recommended fish plugins
    run fish -c "fisher install jorgebucaran/fzf.fish"
    run fish -c "fisher install gazorby/fish-abbreviation-tips"
    
    # Set fish as default shell
    if [[ "$(echo $SHELL)" != *"fish"* ]]; then
        log_info "Setting fish as default shell..."
        if command -v fish &>/dev/null; then
            run $SUDO chsh -s "$(which fish)" "$USER"
        fi
    fi
    
    log_ok "fish shell configured"
}

#===============================================================================
# 4. CORE CLI TOOLS
#===============================================================================
provision_cli_tools() {
    section "4. Core CLI Tools"
    
    # Install via pacman
    log_info "Installing CLI tools via pacman..."
    PACMAN_TOOLS=(
        jq          # JSON CLI
        shellcheck  # Shell script linter
        ripgrep     # Better grep
        fd          # Better find
        bat         # Cat with syntax highlighting
        fzf         # Fuzzy finder
        gh          # GitHub CLI
        go          # Go
        rustup      # Rust toolchain
        man-db      # Better man pages
        man-pages
    )
    run $SUDO pacman -S --noconfirm "${PACMAN_TOOLS[@]}"
    
    # Initialize rust if needed
    if command -v rustup &>/dev/null && [[ ! -f "$HOME/.cargo/bin/rustc" ]]; then
        run rustup default stable
    fi
    
    # Install eza via AUR (better ls)
    log_info "Installing eza (better ls)..."
    run $AUR_HELPER -S --noconfirm eza-git
    
    # Install yazi (file picker)
    log_info "Installing yazi (file picker)..."
    run $AUR_HELPER -S --noconfirm yazi-bin
    
    # Install zoxide (smarter cd)
    log_info "Installing zoxide..."
    run $AUR_HELPER -S --noconfirm zoxide
    
    log_ok "CLI tools installed"
}

#===============================================================================
# 5. PROGRAMMING LANGUAGES
#===============================================================================
provision_languages() {
    section "5. Programming Languages"
    
    # Node.js (via pacman)
    log_info "Installing Node.js..."
    run $SUDO pacman -S --noconfirm nodejs npm
    
    # bun (from official installer)
    if ! command -v bun >/dev/null 2>&1; then
        log_info "Installing bun..."
        run curl -fsSL https://bun.sh/install | run bash
    fi
    
    # Python + uv (via uv, the fast Python installer)
    log_info "Installing Python + uv..."
    run $SUDO pacman -S --noconfirm python python-pip
    
    if ! command -v uv >/dev/null 2>&1; then
        log_info "Installing uv..."
        run curl -LsSf https://astral.sh/uv/install.sh | run sh
    fi
    
    # Set up Python defaults via uv
    if command -v uv &>/dev/null; then
        run uv python install 3.11 3.12
        run uv default python 3.12
    fi
    
    log_ok "Languages installed"
}

#===============================================================================
# 6. JUST (Task Runner)
#===============================================================================
provision_just() {
    section "6. just (Task Runner)"
    
    if ! command -v just >/dev/null 2>&1; then
        log_info "Installing just..."
        run $AUR_HELPER -S --noconfirm just
    else
        log_ok "just already installed: $(just --version)"
    fi
    
    # Create default justfile locations
    mkdir -p "$HOME/.config/just"
    
    log_ok "just installed"
}

#===============================================================================
# 7. CHARM TOOLS (glow, gum)
#===============================================================================
provision_charm_tools() {
    section "7. Charm Tools (glow, gum)"
    
    # glow (Markdown viewer)
    if ! command -v glow >/dev/null 2>&1; then
        log_info "Installing glow..."
        local glow_ver="v1.5.1"
        run curl -sL "https://github.com/charmbracelet/glow/releases/download/${glow_ver}/glow_${glow_ver#v}_linux_amd64.tar.gz" | run tar xz -C /tmp
        run $SUDO mv /tmp/glow /usr/bin/glow
        run $SUDO chmod +x /usr/bin/glow
    fi
    
    # gum (TUI helpers)
    if ! command -v gum >/dev/null 2>&1; then
        log_info "Installing gum..."
        local gum_ver="v0.14.1"
        run curl -sL "https://github.com/charmbracelet/gum/releases/download/${gum_ver}/gum_${gum_ver#v}_linux_amd64.tar.gz" | run tar xz -C /tmp
        run $SUDO mv /tmp/gum /usr/bin/gum
        run $SUDO chmod +x /usr/bin/gum
    fi
    
    log_ok "Charm tools installed"
}

#===============================================================================
# 8. AI TOOLS (pi, agent-browser, aichat, aider)
#===============================================================================
provision_ai_tools() {
    section "8. AI Tools"
    
    # pi coding agent
    log_info "Installing pi coding agent..."
    if ! npm list -g @mariozechner/pi-coding-agent &>/dev/null; then
        run npm install -g @mariozechner/pi-coding-agent
    fi
    
    # agent-browser
    log_info "Installing agent-browser..."
    if ! npm list -g agent-browser &>/dev/null; then
        run npm install -g agent-browser
    fi
    
    # aichat (via AUR)
    log_info "Installing aichat..."
    run $AUR_HELPER -S --noconfirm aichat
    
    # aider (Python-based AI coding assistant)
    if ! command -v aider &>/dev/null; then
        log_info "Installing aider..."
        run pip install aider-chat
    fi
    
    log_ok "AI tools installed"
}

#===============================================================================
# 9. CONTAINERS (Docker)
#===============================================================================
provision_containers() {
    section "9. Containers (Docker)"
    
    if command -v docker &>/dev/null; then
        log_ok "Docker already installed: $(docker --version)"
        return
    fi
    
    log_info "Installing Docker..."
    run $SUDO pacman -S --noconfirm docker docker-compose
    
    # Add user to docker group
    if ! groups | grep -q docker; then
        log_info "Adding $USER to docker group..."
        run $SUDO gpasswd -a "$USER" docker
    fi
    
    # Enable and start docker service
    run $SUDO systemctl enable docker
    run $SUDO systemctl start docker
    
    log_ok "Docker installed (may need logout/login for group changes)"
}

#===============================================================================
# 10. EDITOR (Neovim)
#===============================================================================
provision_editor() {
    section "10. Editor (Neovim)"
    
    log_info "Installing Neovim..."
    run $AUR_HELPER -S --noconfirm neovim
    
    # Install lazy.nvim (plugin manager) if not present
    local lazy_dir="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [[ ! -d "$lazy_dir" ]]; then
        log_info "Installing lazy.nvim..."
        run mkdir -p "$(dirname "$lazy_dir")"
        run git clone --filter=blob:none https://github.com/folke/lazy.nvim.git "$lazy_dir"
    fi
    
    log_ok "Neovim installed"
}

#===============================================================================
# 11. GIT CONFIGURATION
#===============================================================================
provision_git() {
    section "11. Git Configuration"
    
    # Only set if not already configured
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        log_info "Git user.name not set (configure manually or via github cli)"
    fi
    
    if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
        log_info "Git user.email not set (configure manually or via github cli)"
    fi
    
    # Git aliases and settings
    cat >> "$HOME/.gitconfig" << 'GITCONFIG'

[alias]
    ls = log --oneline --decorate --graph --all
    ll = log --oneline --decorate --graph --all -20
    co = checkout
    st = status
    br = branch
    cf = config --list --show-origin
[core]
    editor = nvim
    excludesfile = ~/.gitignore_global
[pull]
    rebase = false
[init]
    defaultBranch = main
GITCONFIG
    
    log_ok "Git configuration added to ~/.gitconfig"
}

#===============================================================================
# 12. DOTFILES SETUP
#===============================================================================
provision_dotfiles() {
    section "12. Dotfiles Setup"
    
    # Create local bin directory
    mkdir -p "$HOME/.local/bin"
    
    # Create env.fish if it doesn't exist
    if [[ ! -f "$HOME/.local/bin/env.fish" ]]; then
        cat > "$HOME/.local/bin/env.fish" << 'ENVFISH'
# Add local bin to PATH
if not contains "$HOME/.local/bin" $PATH
    set -x PATH "$HOME/.local/bin" $PATH
end

# Rust/Cargo
if test -d "$HOME/.cargo/bin"
    if not contains "$HOME/.cargo/bin" $PATH
        set -x PATH "$HOME/.cargo/bin" $PATH
    end
end

# bun
if test -f "$HOME/.bun/bun"
    if not contains "$HOME/.bun/bin" $PATH
        set -x PATH "$HOME/.bun/bin" $PATH
    end
end
ENVFISH
        log_ok "Created ~/.local/bin/env.fish"
    fi
    
    # Create git ignore global
    if [[ ! -f "$HOME/.gitignore_global" ]]; then
        cat > "$HOME/.gitignore_global" << 'GITIGNORE'
# OS
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db
desktop.ini

# Editor
*.swp
*.swo
*~
.netrwhist

# Build
*.o
*.so
*.pyc
__pycache__/
node_modules/
.env
.env.local
GITIGNORE
        log_ok "Created ~/.gitignore_global"
    fi
}

#===============================================================================
# 13. just-silo
#===============================================================================
provision_just_silo() {
    section "13. just-silo"
    
    # Clone or update just-silo
    local silo_dir="$HOME/Dev/just-silo"
    
    if [[ -d "$silo_dir" ]]; then
        log_info "just-silo exists, pulling latest..."
        run git -C "$silo_dir" pull
    else
        log_info "Cloning just-silo..."
        mkdir -p "$(dirname "$silo_dir")"
        run git clone https://github.com/petersmith/just-silo.git "$silo_dir"
    fi
    
    # Create symlinks for just-silo templates
    mkdir -p "$HOME/.config/just/silos"
    
    log_ok "just-silo ready"
}

#===============================================================================
# 14. FINAL VERIFICATION
#===============================================================================
verify() {
    section "14. Verification"
    
    local failures=0
    
    echo ""
    echo "Checking installed tools:"
    echo ""
    
    # Array of commands to check: "command:name:optional"
    local tools=(
        "bash:Bash:no"
        "fish:Fish shell:no"
        "git:Git:no"
        "jq:jq:no"
        "just:just:no"
        "glow:Glow:no"
        "gum:Gum:no"
        "rg:Ripgrep:no"
        "fd:fd:no"
        "bat:bat:no"
        "eza:eza:no"
        "fzf:fzf:no"
        "gh:GitHub CLI:no"
        "yazi:yazi:no"
        "zoxide:zoxide:no"
        "node:Node.js:no"
        "npm:npm:no"
        "bun:bun:no"
        "python3:Python:no"
        "uv:uv:no"
        "go:Go:no"
        "cargo:Rust:no"
        "nvim:Neovim:no"
        "docker:Docker:yes"
        "pi:pi (agent):yes"
        "agent-browser:agent-browser:yes"
        "aichat:aichat:yes"
        "aider:aider:yes"
    )
    
    for tool in "${tools[@]}"; do
        IFS=':' read -r cmd name optional <<< "$tool"
        if command -v "$cmd" &>/dev/null; then
            local ver
            ver=$("$cmd" --version 2>/dev/null | head -1 || "$cmd" -V 2>/dev/null | head -1 || echo "installed")
            echo -e "  ${GREEN}✓${NC} $name: $ver"
        else
            if [[ "$optional" == "yes" ]]; then
                echo -e "  ${YELLOW}○${NC} $name: (optional, not installed)"
            else
                echo -e "  ${RED}✗${NC} $name: NOT FOUND"
                ((failures++))
            fi
        fi
    done
    
    echo ""
    if [[ $failures -eq 0 ]]; then
        log_ok "All required tools installed!"
        return 0
    else
        log_error "$failures required tool(s) missing"
        return 1
    fi
}

#===============================================================================
# USAGE
#===============================================================================
usage() {
    cat << USAGE
just-silo Arch Linux Omarchy Provisioning

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help
    -d, --dry-run       Show what would be done (don't execute)
    -v, --verbose       Verbose output
    -s, --skip-docker   Skip Docker installation
    -a, --aur-helper    AUR helper to use: yay or paru (default: yay)

Examples:
    $0                  # Full provisioning
    $0 --dry-run        # Preview actions
    $0 --skip-docker    # Skip Docker (for containers/VMs)

USAGE
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    local skip_docker=0
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -s|--skip-docker)
                skip_docker=1
                shift
                ;;
            -a|--aur-helper)
                AUR_HELPER="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║       just-silo Arch Linux Omarchy Provisioning                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [[ "$DRY_RUN" == "1" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    # Pre-flight checks
    check_arch
    check_root
    
    # Run provisioning sections
    provision_core
    provision_aur_helper
    provision_shell
    provision_cli_tools
    provision_languages
    provision_just
    provision_charm_tools
    provision_ai_tools
    
    if [[ $skip_docker -eq 0 ]]; then
        provision_containers
    fi
    
    provision_editor
    provision_git
    provision_dotfiles
    provision_just_silo
    
    # Final verification
    verify
    
    echo ""
    log_info "Provisioning complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and log back in (for Docker group, fish shell)"
    echo "  2. Configure git: gh auth login"
    echo "  3. Clone a silo: git clone <your-repo> ~/Dev/my-silo"
    echo "  4. Run: cd ~/Dev/my-silo && just verify"
    echo ""
}

# Run
main "$@"
