#!/bin/bash
# Fetch data from APIs and append to JSONL

set -e

SCRATCH_DIR="scratchpad"
OUTPUT_FILE="$SCRATCH_DIR/api_metrics.jsonl"

mkdir -p "$SCRATCH_DIR"

echo "=== FETCH PHASE ==="
echo ""

# GitHub API for just-silo
echo "📊 Fetching GitHub metrics..."

response=$(curl -s -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/pjsvis/just-silo" 2>/dev/null)

if [ -z "$response" ] || echo "$response" | jq -e '.message' >/dev/null 2>&1; then
    echo "⚠️  GitHub API rate limited or error"
    echo "   Using unauthenticated fallback..."
    response=$(curl -s "https://api.github.com/repos/pjsvis/just-silo")
fi

# Parse metrics
stars=$(echo "$response" | jq -r '.stargazers_count // 0')
forks=$(echo "$response" | jq -r '.forks_count // 0')
open_issues=$(echo "$response" | jq -r '.open_issues_count // 0')
subscribers=$(echo "$response" | jq -r '.subscribers_count // 0')

echo "   ⭐ Stars: $stars"
echo "   🍴 Forks: $forks"
echo "   📋 Open Issues: $open_issues"
echo "   👀 Watchers: $subscribers"

# Write JSONL (append to file)
jq -n \
    --arg ts "$(date -Iseconds)" \
    --arg repo "pjsvis/just-silo" \
    --argjson stars "$stars" \
    --argjson forks "$forks" \
    --argjson issues "$open_issues" \
    --argjson watchers "$subscribers" \
    '{ timestamp: $ts, repo: $repo, stars: $stars, forks: $forks, open_issues: $issues, watchers: $watchers }' | jq -c '.' >> "$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
echo ""
echo "✅ Metrics appended to $OUTPUT_FILE ($count entries)"
