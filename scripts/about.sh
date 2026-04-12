#!/usr/bin/env bash
# Show file or directory with Glow fallback to cat/ls
# Usage: ./scripts/about.sh [file-or-dir]
#
# Dependencies: glow (optional), bat (optional)

set -euo pipefail

TARGET="${1:-${ABOUT_FILE:-README.md}}"

show_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        exit 1
    fi
    
    if command -v glow >/dev/null 2>&1; then
        glow -p "$file"
    elif command -v bat >/dev/null 2>&1; then
        bat --style=plain --color=always "$file"
    else
        cat "$file"
    fi
}

show_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory not found: $dir" >&2
        exit 1
    fi
    
    if command -v glow >/dev/null 2>&1 && [[ -t 0 ]]; then
        glow "$dir"
    else
        ls -la "$dir"
    fi
}

if [[ -f "$TARGET" ]]; then
    show_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
    show_dir "$TARGET"
else
    echo "Error: Not found: $TARGET" >&2
    echo "Usage: ./scripts/about.sh [file-or-dir]" >&2
    exit 1
fi
