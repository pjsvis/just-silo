#!/bin/bash
# Scrape web pages using agent-browser or curl fallback

set -e

SCRATCH_DIR="scratchpad"
TARGETS_FILE="context/targets.md"

mkdir -p "$SCRATCH_DIR"

echo "=== SCRAPE PHASE ==="
echo ""

# Extract URLs from markdown
URLS=$(grep -oE 'https?://[^ )]+' "$TARGETS_FILE" 2>/dev/null | sort -u)

if [ -z "$URLS" ]; then
    echo "⚠️  No URLs found in $TARGETS_FILE"
    echo "   Add URLs to context/targets.md"
    exit 0
fi

count=1
for url in $URLS; do
    echo "📄 Scraping: $url"
    
    # Sanitize URL for filename
    slug=$(echo "$url" | sed -E 's|https?://||;s|/|_|g;s|\.||g;s|:||g' | cut -c1-30)
    output_file="$SCRATCH_DIR/scrape_$(printf "%02d" $count)_${slug}.md"
    
    # Use agent-browser for HTML pages, curl for API endpoints
    if [[ "$url" == *"api.github"* ]]; then
        # API: use curl
        {
            echo "# $url"
            echo "Scraped: $(date -Iseconds)"
            echo ""
            echo "## API Response"
            echo '```json'
            curl -sL "$url" 2>/dev/null | head -100
            echo '```'
        } > "$output_file"
        echo "   ✅ → $output_file (curl)"
    else
        # HTML: use agent-browser if available, else curl
        if command -v agent-browser >/dev/null 2>&1; then
            agent-browser open "$url" >/dev/null 2>&1 &
            sleep 2  # Give browser time to load
            
            title=$(timeout 5 agent-browser get title 2>/dev/null | head -1 || echo "Page")
            
            {
                echo "# $title"
                echo "URL: $url"
                echo "Scraped: $(date -Iseconds)"
                echo ""
                echo "## Snapshot"
                echo '```'
                timeout 10 agent-browser snapshot 2>/dev/null | head -60 || echo "(browser unavailable)"
                echo '```'
            } > "$output_file"
            
            agent-browser close >/dev/null 2>&1 || true
            echo "   ✅ → $output_file"
        else
            # Fallback: curl
            {
                echo "# $url"
                echo "Scraped: $(date -Iseconds)"
                echo ""
                echo "## Content"
                echo '```'
                curl -sL "$url" 2>/dev/null | head -50
                echo '```'
            } > "$output_file"
            echo "   ✅ → $output_file (curl)"
        fi
    fi
    
    count=$((count + 1))
done

echo ""
echo "✅ Scraped $(($count - 1)) pages to $SCRATCH_DIR/"
