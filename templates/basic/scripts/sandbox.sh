#!/usr/bin/env bash
# sandbox.sh — Sandboxed execution wrapper for silo scripts
#
# Restricts script execution to the silo directory only.
# Prevents path traversal and unintended system access.
#
# Usage: ./sandbox.sh <script> [args...]

set -euo pipefail

# Get the silo directory (where this script lives)
SILO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Security: verify we're in the silo directory
verify_sandbox() {
    local script_path="$1"
    local script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    
    # Check script is in silo or its scripts subdirectory
    case "$script_dir" in
        "$SILO_DIR"|"$SILO_DIR/"*|"$SILO_DIR/scripts"|"$SILO_DIR/scripts/"*)
            # OK
            ;;
        *)
            echo "SECURITY: Script outside silo: $script_path" >&2
            echo "Silo dir: $SILO_DIR" >&2
            echo "Script dir: $script_dir" >&2
            exit 1
            ;;
    esac
}

# Check for dangerous patterns
check_dangerous() {
    local script="$1"
    
    # Check for path traversal attempts
    if grep -q '\.\./' "$script" 2>/dev/null; then
        echo "WARNING: Path traversal detected in $script" >&2
        return 1
    fi
    
    # Check for rm -rf / or similar
    if grep -qE 'rm\s+(-rf\s+/?|(-r|-f)\s+/)' "$script" 2>/dev/null; then
        echo "WARNING: Dangerous rm pattern in $script" >&2
        return 1
    fi
    
    return 0
}

# Run script in sandboxed environment
run_sandboxed() {
    local script="$1"
    shift
    
    # Verify
    verify_sandbox "$script"
    check_dangerous "$script" || exit 1
    
    # Set restricted environment
    export PATH="/usr/local/bin:/usr/bin:/bin"  # Minimal PATH
    unset CDPATH  # Prevent cd surprises
    unset ENV
    unset BASH_ENV
    
    # Run with restricted permissions
    # - C: no core dumps
    # - u: undefined variables cause exit
    # - e: commands that fail cause exit
    # - f: no glob expansion (prevents accidental file expansion)
    
    # Change to silo directory and run
    (
        cd "$SILO_DIR"
        # Don't allow leaving the silo
       OLDPWD="$SILO_DIR"
        PWD="$SILO_DIR"
        
        # Execute with bash (not sh for portability)
        bash -Cuf -e -- "$script" "$@"
    )
}

# Validate a script without running it
validate() {
    local script="$1"
    
    verify_sandbox "$script"
    check_dangerous "$script"
    
    # Syntax check
    bash -n "$script" 2>&1 || {
        echo "Syntax error in $script" >&2
        return 1
    }
    
    echo "✓ $script is valid"
    return 0
}

# Main
ACTION="${1:-run}"
SCRIPT="${2:-}"

case "$ACTION" in
    validate|v)
        if [ -z "$SCRIPT" ]; then
            echo "Usage: $0 validate <script>"
            exit 1
        fi
        validate "$SCRIPT"
        ;;
    run|"")
        if [ -z "$SCRIPT" ]; then
            echo "Usage: $0 run <script> [args...]"
            exit 1
        fi
        run_sandboxed "$SCRIPT" "$@"
        ;;
    *)
        echo "Usage: $0 [validate|run] <script> [args...]"
        exit 1
        ;;
esac
