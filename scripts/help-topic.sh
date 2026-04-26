#!/bin/bash
# help-topic - Show help for a topic, or general help
# Usage: ./scripts/help-topic.sh [topic]

set -euo pipefail

TOPIC="${1:-}"

if [ -z "$TOPIC" ]; then
    ./scripts/help.sh
else
    ./scripts/help.sh "$TOPIC"
fi
