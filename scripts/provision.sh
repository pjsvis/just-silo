#!/bin/bash
# Provision script for just-silo tools
# Run on a fresh machine to get everything installed

set -e

echo "=== just-silo Provisioning ==="
echo ""

# Detect OS
OS="$(uname -s)"
echo "Detected: $OS"
echo ""

# Detect package manager
if command -v brew >/dev/null 2>&1; then
    PKG_MGR="brew"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
else
    PKG_MGR="none"
fi
echo "Package manager: $PKG_MGR"
echo ""

install_pkg() {
    local pkg="$1"
    case "$PKG_MGR" in
        brew)  brew install "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        apt) sudo apt-get install -y "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
        *) echo "⚠️  Install $pkg manually" ;;
    esac
}

# Core tools
echo "📦 Installing core tools..."
install_pkg jq

# Install just (all platforms)
if ! command -v just >/dev/null 2>&1; then
    echo "Installing just..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
fi

# Install glow (from GitHub releases)
if ! command -v glow >/dev/null 2>&1; then
    echo "Installing glow..."
    curl -sL https://github.com/charmbracelet/glow/releases/download/v1.5.1/glow_1.5.1_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64.tar.gz | tar xz -C /tmp
    sudo mv /tmp/glow /usr/local/bin/glow 2>/dev/null || sudo mv /tmp/glow /usr/bin/glow
fi

# Install gum (from GitHub releases)
if ! command -v gum >/dev/null 2>&1; then
    echo "Installing gum..."
    curl -sL https://github.com/charmbracelet/gum/releases/download/v0.14.1/gum_0.14.1_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64.tar.gz | tar xz -C /tmp
    sudo mv /tmp/gum /usr/local/bin/gum 2>/dev/null || sudo mv /tmp/gum /usr/bin/gum
fi

# Install optional tools
echo "📦 Installing optional tools..."
install_pkg shellcheck
install_pkg watchexec

# Install npm tools
echo "📦 Installing npm tools..."
if ! command -v npm >/dev/null 2>&1; then
    install_pkg nodejs
fi
npm install -g @mariozechner/pi-coding-agent agent-browser

# Install bun (optional)
if ! command -v bun >/dev/null 2>&1; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

echo ""
echo "=== Verification ==="
for cmd in just jq glow gum npm pi agent-browser bun; do
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        echo "✅ $cmd: $version"
    else
        echo "⚠️  $cmd: not found"
    fi
done

echo ""
echo "=== Done ==="
echo "Run 'cd my-silo && just verify' to test"
