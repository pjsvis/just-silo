#!/bin/bash
# story-scan.sh — Extract wee stories from documentation
# Usage: ./story-scan.sh [path]
#
# Extracts narrative elements from docs and creates stories.jsonl entries.
# Stories answer: How did we get here? What did we learn? Why does this work?
#
# Features:
# - Auto-tags from source path (topic extraction)
# - Quality heuristics for narrative coherence
# - Better story type detection
# - Noise filtering (TOC, list items, etc.)

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
TYPE_UNKNOWN="unknown"

# Generate UUID
generate_uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# Extract topic tags from source path
# e.g., "briefs/gemma4/2026-04-07-blog-post-01.md" → ["gemma4", "blog-post"]
extract_topic_tags() {
    local source="$1"
    local tmpfile=$(mktemp)
    
    # Skip if in root briefs/ (individual files, not in folders)
    if [[ "$source" =~ ^briefs/([^/]+)/ ]]; then
        local folder="${BASH_REMATCH[1]}"
        
        # Skip date folders (too generic)
        if [[ ! "$folder" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            echo "\"$folder\"" >> "$tmpfile"
        fi
        
        # Extract brief topic from filename
        if [[ "$source" =~ brief-([a-zA-Z0-9_-]+)\.md$ ]]; then
            local topic="${BASH_REMATCH[1]}"
            # Skip if it's just a date reference
            if [[ ! "$topic" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                echo "\"$topic\"" >> "$tmpfile"
            fi
        fi
    fi
    
    # Convert to jq array format
    if [ ! -s "$tmpfile" ]; then
        rm -f "$tmpfile"
        echo '[]'
    else
        local result=$(jq -n '['$(cat "$tmpfile" | tr '\n' ',' | sed 's/,$//')']')
        rm -f "$tmpfile"
        echo "$result"
    fi
}

# Calculate narrative quality score (0.0 - 1.0)
# Higher = more likely to be a real story
narrative_quality_score() {
    local narrative="$1"
    local score="0.0"
    local narrative_lower=$(echo "$narrative" | tr '[:upper:]' '[:lower:]')
    
    # Has story markers (+0.15 each, max 0.6)
    # More flexible patterns to catch variations
    if echo "$narrative_lower" | grep -qE "(we|i|they) (discovered|found|learned|built|created|realized)"; then
        score=$(echo "$score + 0.2" | bc)
    fi
    if echo "$narrative_lower" | grep -qE "(the|a) (fix was|solution was|lesson|answer)"; then
        score=$(echo "$score + 0.2" | bc)
    fi
    if echo "$narrative_lower" | grep -qE "(turned out|here's|this is why|the secret)"; then
        score=$(echo "$score + 0.2" | bc)
    fi
    if echo "$narrative_lower" | grep -qE "(we had a|we encountered|we faced|we struggled|we dealt with)"; then
        score=$(echo "$score + 0.2" | bc)
    fi
    
    # Has story structure indicators (+0.1 each)
    # Setup (because/while/during)
    if echo "$narrative_lower" | grep -qE "(because|while|during|after|before)"; then
        score=$(echo "$score + 0.1" | bc)
    fi
    # Conflict (problem/issue/failure/bug)
    if echo "$narrative_lower" | grep -qE "(problem|issue|failure|bug|crash|error|challenge|complexity)"; then
        score=$(echo "$score + 0.1" | bc)
    fi
    # Resolution (now|finally|eventually|so we)
    if echo "$narrative_lower" | grep -qE "(now |finally|eventually|so we |the result|as a result)"; then
        score=$(echo "$score + 0.1" | bc)
    fi
    
    # Length bonus
    if [ ${#narrative} -gt 100 ]; then
        score=$(echo "$score + 0.1" | bc)
    fi
    
    # Penalize TOC-style patterns
    if [[ "$narrative" =~ ^[0-9]+\.?[[:space:]]*[a-z]?$ ]]; then
        score="0.1"
    fi
    
    # Ensure score is in valid range
    local lt_result=$(echo "$score < 0.15" | bc -l)
    if [ "$lt_result" = "1" ]; then
        score="0.15"
    fi
    local gt_result=$(echo "$score > 1.0" | bc -l)
    if [ "$gt_result" = "1" ]; then
        score="1.0"
    fi
    
    printf "%.2f" "$score"
}

# Determine story type with better detection
determine_story_type() {
    local line="$1"
    local line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    # Origin: first-person discovery (broader pattern)
    if echo "$line_lower" | grep -qE "(we|i|they) (discovered|found|learned|built|created|realized|started|encountered)"; then
        echo "$TYPE_ORIGIN"
    # Lesson: explicit learning
    elif echo "$line_lower" | grep -qE "(lesson|learned|mistake|failure|got wrong|went wrong|should have|caution|we tried|we failed)"; then
        echo "$TYPE_LESSON"
    # Anti-pattern: warning language
    elif echo "$line_lower" | grep -qE "^(avoid|don't|should not|anti-pattern|never|warning|caution|instead of)"; then
        echo "$TYPE_ANTIPATTERN"
    # Insight: explicit insight markers
    elif echo "$line_lower" | grep -qE "(turned out|here's|this is why|the secret|key insight|finally|eventually|the solution)"; then
        echo "$TYPE_INSIGHT"
    # Origin: concept emergence
    elif echo "$line_lower" | grep -qE "^(the|this) [a-z]+ (emerged|began|started|evolved|created|introduced)"; then
        echo "$TYPE_ORIGIN"
    else
        echo "$TYPE_UNKNOWN"
    fi
}

# Should we include this narrative?
should_include() {
    local narrative="$1"
    local score="$2"
    
    # Quality threshold (relaxed)
    local lt_result=$(echo "$score < 0.15" | bc -l)
    if [ "$lt_result" = "1" ]; then
        return 1
    fi
    
    # Skip very short narratives
    if [ ${#narrative} -lt 60 ]; then
        return 1
    fi
    
    return 0
}

# Extract stories from a file
extract_stories() {
    local file="$1"
    local source_file="${file#$PWD/}"
    local count=0
    local included=0
    
    # Skip non-doc files
    if [[ ! "$file" =~ \.(md|mdx)$ ]]; then
        return 0
    fi
    
    echo "Scanning: $source_file" >&2
    
    # Get topic tags for this file
    local topic_tags=$(extract_topic_tags "$source_file")
    
    # Look for story markers in content
    while IFS= read -r line; do
        # Clean the line
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Skip if too short or too long
        len=${#line}
        if [ "$len" -lt 40 ] || [ "$len" -gt 400 ]; then
            continue
        fi
        
        # Skip headers (H1-H6)
        if [[ "$line" =~ ^# ]]; then
            continue
        fi
        
        # Skip code blocks
        if [[ "$line" =~ ^\`\`\` ]]; then
            continue
        fi
        
        # Skip list items at start of line
        if [[ "$line" =~ ^[[:space:]]*[-*•][[:space:]] ]]; then
            continue
        fi
        
        # Skip numbered list items that look like TOC
        if [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]]*[a-z]?$ ]]; then
            continue
        fi
        
        # Skip blockquote-only lines
        if [[ "$line" == ">"* ]]; then
            continue
        fi
        
        # Extract narrative (first sentence if multiple)
        narrative=$(echo "$line" | sed 's/\..*$/./' | cut -c1-250)
        
        # Calculate quality score
        local score=$(narrative_quality_score "$narrative")
        
        # Check if we should include
        if ! should_include "$narrative" "$score"; then
            continue
        fi
        
        # Determine type
        local TYPE=$(determine_story_type "$line")
        if [ "$TYPE" = "$TYPE_UNKNOWN" ]; then
            TYPE="$TYPE_INSIGHT"
        fi
        
        # Create story entry (JSONL format)
        printf '%s\n' "$(jq -n \
            --arg id "$(generate_uuid)" \
            --arg source "$source_file" \
            --arg type "$TYPE" \
            --arg narrative "$narrative" \
            --argjson tags "$topic_tags" \
            --argjson quality "$score" \
            --arg usefulness "medium" \
            --arg created "$(date -Iseconds)" \
            '{id: $id, source: $source, type: $type, narrative: $narrative, tags: $tags, quality: $quality, usefulness: $usefulness, created: $created}')"
            
        count=$((count + 1))
        included=$((included + 1))
        
    done < <(grep -E "\." "$file" 2>/dev/null | head -150 || true)
    
    echo "Extracted $count/$included stories from $source_file" >&2
}

# Scan directory for stories
scan_directory() {
    local dir="${1:-.}"
    local total=0
    local included=0
    local tmpfile=$(mktemp)
    
    > "$STORIES_FILE"
    
    for file in $(find "$dir" -type f \( -name "*.md" -o -name "*.mdx" \) 2>/dev/null | grep -v node_modules | grep -v archive | grep -v _posts); do
        while IFS= read -r story; do
            echo "$story" >> "$tmpfile"
            total=$((total + 1))
        done < <(extract_stories "$file")
    done
    
    # Deduplicate using jq
    if [ -s "$tmpfile" ]; then
        jq -n '[inputs] | group_by(.source + .narrative) | map(.[0]) | .[]' "$tmpfile" > "$STORIES_FILE"
        included=$(jq -n '[inputs] | length' "$STORIES_FILE" 2>/dev/null || echo 0)
    fi
    rm -f "$tmpfile"
    
    echo "Extracted $total stories (included: $included after filtering)"
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
