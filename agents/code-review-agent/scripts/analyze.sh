#!/usr/bin/env bash
# analyze.sh — FAFCAS code analysis
# Usage: ./analyze.sh [target] [scope]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(dirname "$SCRIPT_DIR")"
DONE_DIR="$AGENT_DIR/markers/done"
SCRATCH_DIR="$AGENT_DIR/.scratch"

mkdir -p "$DONE_DIR" "$SCRATCH_DIR"

TARGET="${1:-HEAD~1..HEAD}"
SCOPE="${2:-incremental}"
LOG_FILE="$DONE_DIR/analysis.jsonl"

# Initialize
> "$LOG_FILE"

log() { echo "[$(date -Iseconds)] [analyze] $*" >&2; }

log "Starting analysis of $TARGET (scope: $SCOPE)"

# Get changed files
case "$SCOPE" in
    full)
        FILES=$(git diff --name-only "$TARGET" 2>/dev/null || echo "")
        ;;
    incremental|single)
        FILES=$(git diff --name-only "$TARGET" 2>/dev/null | head -20 || echo "")
        ;;
    *)
        FILES=""
        ;;
esac

if [ -z "$FILES" ]; then
    log "No files to analyze"
    exit 0
fi

# Analyze each file
for file in $FILES; do
    log "Analyzing: $file"
    
    # Skip non-text files
    [[ "$file" =~ \.(png|jpg|gif|ico|woff|woff2|eot|ttf|mp3|mp4|zip|gz)$ ]] && continue
    
    # Get the diff
    DIFF=$(git diff "$TARGET" -- "$file" 2>/dev/null || echo "")
    
    if [ -z "$DIFF" ]; then
        continue
    fi
    
    # Analyze diff line by line
    LINE_NUM=0
    while IFS= read -r line; do
        LINE_NUM=$((LINE_NUM + 1))
        
        # Skip diff headers
        [[ "$line" =~ ^diff\ |^index\ |^\+\+\+\ |^---\  ]] && continue
        [[ "$line" == +* ]] || continue  # Only look at additions
        
        CLEAN=${line#+}  # Remove leading +
        
        # Check for markers
        if [[ "$CLEAN" =~ TODO|FIXME|HACK|XXX ]]; then
            echo "{\"dimension\":\"actionable\",\"severity\":2,\"file\":\"$file\",\"line\":$LINE_NUM,\"type\":\"marker\",\"text\":\"Marker found\"}" >> "$LOG_FILE"
        fi
        
        # Check for debug code
        if [[ "$CLEAN" =~ console\.log|debugger|print\(|\.print\(|logger\.|\.debug ]]; then
            echo "{\"dimension\":\"complete\",\"severity\":3,\"file\":\"$file\",\"line\":$LINE_NUM,\"type\":\"debug\",\"text\":\"Debug code detected\"}" >> "$LOG_FILE"
        fi
        
        # Check for potential secrets
        if [[ "$CLEAN" =~ password|token|secret|api_key|apikey ]] && [[ ! "$CLEAN" =~ example|placeholder|test|__|fake|demo ]]; then
            echo "{\"dimension\":\"accurate\",\"severity\":4,\"file\":\"$file\",\"line\":$LINE_NUM,\"type\":\"security\",\"text\":\"Potential secret exposure\"}" >> "$LOG_FILE"
        fi
        
        # Check for TODOs in removals too
        if [[ "$line" == -* ]] && [[ "$line" =~ TODO|FIXME|HACK ]]; then
            echo "{\"dimension\":\"actionable\",\"severity\":1,\"file\":\"$file\",\"line\":$LINE_NUM,\"type\":\"resolved-marker\",\"text\":\"Resolved TODO/FIXME\"}" >> "$LOG_FILE"
        fi
        
    done <<< "$DIFF"
done

# Count findings
TOTAL=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
log "Analysis complete: $TOTAL findings"

echo "$TOTAL"
