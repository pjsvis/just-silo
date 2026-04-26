#!/bin/bash
# blog-search - Search stories by tag
# Usage: ./scripts/blog-search.sh [tag]

set -euo pipefail

TAG="${1:-}"

if [ -z "$TAG" ]; then
    echo "Usage: just blog-search <tag>"
else
    bash scripts/story-list.sh --tag "$TAG"
fi
