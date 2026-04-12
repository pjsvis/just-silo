#!/bin/bash
# story-scan.sh — Extract wee stories from documentation
# Usage: ./story-scan.sh [path]
#
# Extracts narrative elements from docs and creates stories.jsonl entries.
# Stories answer: How did we get here? What did we learn? Why does this work?

set -euo pipefail

STORIES_DIR="${STORIES_DIR:-stories}"
STORIES_FILE="$STORIES_DIR/stories.jsonl"
ARCHIVE_DIR="$STORIES_DIR/_archive"

mkdir -p "$STORIES_DIR" "$ARCHIVE_DIR"

# Story types
TYPE_ORIGIN="origin"
TYPE_LESSON="lesson"
TYPE_INSIGHT="insight"
TYPE_ANTIPATTERN="anti-pattern"

# Generate UUID
generate_uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# Extract stories from a file
extract_stories() {
    local file="$1"
    local source_file="${file#$PWD/}"
    local count=0
    
    # Skip non-doc files
    if [[ ! "$file" =~ \.(md|mdx)$ ]]; then
        return 0
    fi
    
    echo "Scanning: $source_file" >&2
    
    # Look for story markers in content
    # Pattern: lines containing key phrases that indicate a story
    while IFS= read -r line; do
        # Clean the line
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Skip if too short or too long
        len=${#line}
        if [ "$len" -lt 60 ] || [ "$len" -gt 300 ]; then
            continue
        fi
        
        # Skip headers, code, lists
        if [[ "$line" =~ ^# ]] || [[ "$line" =~ ^\`\`\` ]] || [[ "$line" =~ ^[[:space:]]*[-*] ]]; then
            continue
        fi
        
        # Determine type
        local TYPE="$TYPE_INSIGHT"
        if echo "$line" | grep -qiE "^(we|they|i|a|the) (discovered|found|realized|learned|built|created|made)"; then
            TYPE="$TYPE_ORIGIN"
        elif echo "$line" | grep -qiE "(lesson|learned|mistake|failure|got wrong|went wrong)"; then
            TYPE="$TYPE_LESSON"
        elif echo "$line" | grep -qiE "^(key insight|important|turns out|the thing about|here's the|this is why)"; then
            TYPE="$TYPE_INSIGHT"
        elif echo "$line" | grep -qiE "^(avoid|don't|should not|anti-pattern|never|warning|caution)"; then
            TYPE="$TYPE_ANTIPATTERN"
        fi
        
        # Extract key phrases (first sentence if multiple)
        narrative=$(echo "$line" | sed 's/\..*$/./' | cut -c1-250)
        
        # Create story entry (JSONL format)
        printf '%s\n' "$(jq -n \
            --arg id "$(generate_uuid)" \
            --arg source "$source_file" \
            --arg type "$TYPE" \
            --arg narrative "$narrative" \
            --argjson tags '[]' \
            --arg usefulness "medium" \
            --arg created "$(date -Iseconds)" \
            '{id: $id, source: $source, type: $type, narrative: $narrative, tags: $tags, usefulness: $usefulness, created: $created}')"
            
        count=$((count + 1))
        
    done < <(grep -E "\." "$file" 2>/dev/null | head -100 || true)
    
    echo "Extracted $count stories from $source_file" >&2
}

# Scan directory for stories
scan_directory() {
    local dir="${1:-.}"
    local total=0
    local tmpfile=$(mktemp)
    
    > "$STORIES_FILE"
    
    for file in $(find "$dir" -type f \( -name "*.md" -o -name "*.mdx" \) 2>/dev/null | grep -v node_modules | grep -v archive | grep -v _posts); do
        while IFS= read -r story; do
            echo "$story" >> "$tmpfile"
            total=$((total + 1))
        done < <(extract_stories "$file")
    done
    
    # Deduplicate using jq (sort breaks multi-line JSON)
    # Group by source+narrative to find duplicates, then output unique objects
    if [ -s "$tmpfile" ]; then
        jq -n '[inputs] | group_by(.source + .narrative) | map(.[0]) | .[]' "$tmpfile" > "$STORIES_FILE"
    fi
    rm -f "$tmpfile"
    
    echo "Extracted $total stories (deduped: $(wc -l < "$STORIES_FILE"))"
}

# Main
main() {
    local target="${1:-briefs}"
    
    echo "=== Story Scanner ==="
    echo "Source: $target"
    echo "Output: $STORIES_FILE"
    echo ""
    
    if [ -f "$target" ]; then
        extract_stories "$target"
    elif [ -d "$target" ]; then
        scan_directory "$target"
    else
        echo "Error: $target not found"
        exit 1
    fi
    
    echo ""
    echo "Stories saved to: $STORIES_FILE"
    echo "Total: $(wc -l < "$STORIES_FILE") stories"
}

main "$@"
