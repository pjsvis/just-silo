#!/bin/bash
# Provision script for Arch Linux
# Run on a fresh Arch machine to install just-silo tools

set -e

echo "=== just-silo Arch Provisioning ==="
echo ""

# Core tools via pacman
echo "📦 Installing core tools..."
sudo pacman -S --noconfirm jq nodejs npm

# Install yay for AUR packages
if ! command -v yay >/dev/null 2>&1; then
    echo "📦 Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install tools via yay
echo "📦 Installing tools via yay..."
yay -S --noconfirm just shellcheck

# Install glow + gum (from GitHub)
echo "📦 Installing glow + gum..."
curl -sL https://github.com/charmbracelet/glow/releases/download/v1.5.1/glow_1.5.1_linux_amd64.tar.gz | tar xz -C /tmp
sudo mv /tmp/glow /usr/bin/glow

curl -sL https://github.com/charmbracelet/gum/releases/download/v0.14.1/gum_0.14.1_linux_amd64.tar.gz | tar xz -C /tmp
sudo mv /tmp/gum /usr/bin/gum

# Install pi + agent-browser
echo "📦 Installing npm tools..."
npm install -g @mariozechner/pi-coding-agent agent-browser

# Install bun
if ! command -v bun >/dev/null 2>&1; then
    echo "📦 Installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

echo ""
echo "=== Verification ==="
for cmd in just jq glow gum npm pi agent-browser bun; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd"
    else
        echo "⚠️  $cmd: not found"
    fi
done

echo ""
echo "=== Done ==="
echo "Clone a silo and run: cd my-silo && just verify"
