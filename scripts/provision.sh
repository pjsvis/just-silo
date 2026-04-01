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

if [ "$OS" = "Darwin" ]; then
    # macOS
    echo "📦 Installing via Homebrew..."
    
    # Core tools
    brew install just jq glow gum
    
    # Optional but common
    brew install shellcheck watchexec
    
    echo ""
    echo "📦 Installing via npm..."
    npm install -g @mariozechner/pi-coding-agent agent-browser
    
    echo ""
    echo "📦 Installing bun (optional)..."
    curl -fsSL https://bun.sh/install | bash
    
elif [ "$OS" = "Linux" ]; then
    # Linux
    echo "📦 Installing via apt..."
    sudo apt-get update
    sudo apt-get install -y curl jq shellcheck
    
    # Install just
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s --to /usr/local/bin
    
    # Install glow (from GitHub releases)
    curl -sL https://github.com/charmbracelet/glow/releases/download/v1.5.1/glow_1.5.1_linux_amd64.tar.gz | tar xz -C /usr/local/bin
    
    # Install gum
    curl -sL https://github.com/charmbracelet/gum/releases/download/v0.14.1/gum_0.14.1_linux_amd64.tar.gz | tar xz -C /usr/local/bin
    
    echo ""
    echo "📦 Installing via npm..."
    npm install -g @mariozechner/pi-coding-agent agent-browser

else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

echo ""
echo "=== Verification ==="
echo ""

# Verify installs
for cmd in just jq glow gum pi agent-browser; do
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        echo "✅ $cmd: $version"
    else
        echo "⚠️  $cmd: not found"
    fi
done

echo ""
echo "=== Done ==="
echo "Run 'just --list' to see silo commands"
