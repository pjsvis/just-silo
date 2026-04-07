#!/bin/bash
# td-ramdisk-setup.sh
# Sets up td database on a RAM disk for corruption-proof operation
# 
# Usage: ./td-ramdisk-setup.sh [project-dir]
#   project-dir: Optional. Defaults to current directory.
#
# Requirements:
#   - td CLI installed
#   - Disk space: ~50MB recommended (we use 512MB)
#
# Note: Data is volatile. On reboot, run this again to recreate the RAM disk.

set -e

PROJECT_DIR="${1:-.}"

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
TODOS_DIR="$PROJECT_DIR/.todos"
RAM_DISK_BASE="/Volumes/TD-RAMDisk"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "TD RAM Disk Setup"
echo "=========================================="
echo "Project: $PROJECT_DIR"
echo ""

# Step 1: Check if RAM disk already mounted
if mount | grep -q "$RAM_DISK_BASE"; then
    echo -e "${YELLOW}RAM disk already mounted at $RAM_DISK_BASE${NC}"
else
    echo "Creating RAM disk..."
    DISK=$(hdiutil attach -nomount ram://1048576)
    diskutil erasevolume HFS+ "TD-RAMDisk" $DISK > /dev/null
    echo -e "${GREEN}RAM disk created at $RAM_DISK_BASE${NC}"
fi

# Step 2: Set up project directory on RAM disk
PROJECT_RAM_DIR="$RAM_DISK_BASE/$(basename "$PROJECT_DIR")"
if [ -d "$PROJECT_RAM_DIR" ]; then
    echo -e "${YELLOW}Project directory already exists on RAM disk${NC}"
else
    mkdir -p "$PROJECT_RAM_DIR"
    echo "Created $PROJECT_RAM_DIR"
fi

# Step 3: Handle existing .todos directory
if [ -L "$TODOS_DIR" ]; then
    echo -e "${GREEN}.todos is already symlinked to RAM disk${NC}"
elif [ -d "$TODOS_DIR" ]; then
    echo "Moving existing .todos to RAM disk..."
    # Check if there's a valid database
    if [ -f "$TODOS_DIR/issues.db" ] && [ -s "$TODOS_DIR/issues.db" ]; then
        cp "$TODOS_DIR/issues.db" "$PROJECT_RAM_DIR/"
        cp "$TODOS_DIR/command_usage.jsonl" "$PROJECT_RAM_DIR/" 2>/dev/null || true
        echo "Preserved existing database"
    fi
    rm -rf "$TODOS_DIR"
fi

# Step 4: Create symlink
if [ ! -L "$TODOS_DIR" ]; then
    ln -sf "$PROJECT_RAM_DIR" "$TODOS_DIR"
    echo -e "${GREEN}Symlinked .todos -> $PROJECT_RAM_DIR${NC}"
fi

# Step 5: Initialize database if needed
if [ ! -f "$PROJECT_RAM_DIR/issues.db" ] || [ ! -s "$PROJECT_RAM_DIR/issues.db" ]; then
    echo "Initializing td database..."
    # Create in temp directory first, then copy
    TEMP_DIR=$(mktemp -d)
    (
        cd "$TEMP_DIR"
        td init > /dev/null 2>&1 || true
        cp .todos/issues.db "$PROJECT_RAM_DIR/"
        cp .todos/command_usage.jsonl "$PROJECT_RAM_DIR/" 2>/dev/null || true
    )
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}Database initialized${NC}"
fi

# Step 6: Verify
echo ""
echo -e "${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "Database location: $PROJECT_RAM_DIR"
echo "Symlink: $TODOS_DIR"
echo "RAM disk size: $(df -h "$RAM_DISK_BASE" | tail -1 | awk '{print $2}')"
echo "Used: $(df -h "$RAM_DISK_BASE" | tail -1 | awk '{print $3}')"
echo ""
echo -e "${YELLOW}Note: RAM disk data is volatile.${NC}"
echo "On reboot, run: $0 $PROJECT_DIR"
echo ""

# Add to LaunchAgent if requested
if [ "$2" == "--install-launchd" ]; then
    echo "Installing LaunchAgent for auto-mount..."
    cat > "$HOME/Library/LaunchAgents/com.user.td-ramdisk.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.user.td-ramdisk</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>
            DISK=$(hdiutil attach -nomount ram://1048576)
            diskutil erasevolume HFS+ "TD-RAMDisk" $DISK
            mkdir -p /Volumes/TD-RAMDisk
        </string>
    </array>
    <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF
    launchctl load "$HOME/Library/LaunchAgents/com.user.td-ramdisk.plist" 2>/dev/null || true
    echo "LaunchAgent installed."
fi
