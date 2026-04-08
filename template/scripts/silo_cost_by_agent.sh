#!/usr/bin/env bash
# silo_cost_by_agent.sh — group ledger by agent, show counts and totals
set -euo pipefail

LEDGER="${LEDGER:-pipeline/history.jsonl}"

if [ ! -f "$LEDGER" ]; then
  echo "  (no ledger)"
  exit 0
fi

agents=$(jq -r '.agent' "$LEDGER" | sort | uniq)

while IFS= read -r agent; do
  count=$(jq -s "[.[] | select(.agent == \"$agent\")] | length" "$LEDGER")
  total=$(jq -s "[.[] | select(.agent == \"$agent\")] | map(.cost_usd) | add" "$LEDGER")
  printf "  %4s runs | $%s | %s\n" "$count" "$total" "$agent"
done <<< "$agents"
