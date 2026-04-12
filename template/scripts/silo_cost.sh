#!/usr/bin/env bash
# silo_cost.sh — Append a cost ledger entry to pipeline/history.jsonl
#
# Usage: just silo-cost-log agent="name" task="description" model="minimax-2.7-4k" status="done"
#
# Writes one JSON line to pipeline/history.jsonl
# Cost estimation uses OpenRouter published rates (Apr 2026):
#   minimax-2.7-4k:   $0.05/M input  $0.10/M output  (128k context)
#   gpt-4o-mini:      $0.15/M input  $0.60/M output
#   claude-3.5-sonnet: $3.00/M input $15.00/M output
# Estimates assume: 2k input + 800 output tokens per typical task.
# Toggle ESTIMATE=1 for rough cost, ESTIMATE=0 for free (log only).
#
set -euo pipefail

LEDGER="${LEDGER:-pipeline/history.jsonl}"

agent="${1:-}"
task="${2:-}"
model="${3:-unknown}"
status="${4:-done}"
duration_s="${5:-0}"
ESTIMATE="${ESTIMATE:-1}"

mkdir -p "$(dirname "$LEDGER")"

# --- Cost estimation per model (per 1k tokens) ---
cost_per_1k_input() {
  case "$1" in
    minimax-2.7-4k)   echo "0.05" ;;
    gpt-4o-mini)       echo "0.15" ;;
    gpt-4o)            echo "2.50" ;;
    claude-3.5-sonnet) echo "3.00" ;;
    claude-opus-4)     echo "15.00" ;;
    *)                 echo "0.10" ;;
  esac
}
cost_per_1k_output() {
  case "$1" in
    minimax-2.7-4k)   echo "0.10" ;;
    gpt-4o-mini)      echo "0.60" ;;
    gpt-4o)           echo "10.00" ;;
    claude-3.5-sonnet) echo "15.00" ;;
    claude-opus-4)     echo "75.00" ;;
    *)                 echo "0.20" ;;
  esac
}

# Estimate: 2k input + 800 output tokens per task
INPUT_TOKENS=2000
OUTPUT_TOKENS=800
RATE_IN=$(cost_per_1k_input "$model")
RATE_OUT=$(cost_per_1k_output "$model")

if [ "$ESTIMATE" = "1" ]; then
  cost_usd=$(printf "%.6f" "$(echo "scale=10; ($INPUT_TOKENS/1000*$RATE_IN) + ($OUTPUT_TOKENS/1000*$RATE_OUT)" | bc -l)")
else
  cost_usd="0.000000"
fi

ts=$(date -Iseconds)

entry=$(jq -n \
  --arg ts "$ts" \
  --arg agent "$agent" \
  --arg task "$task" \
  --arg model "$model" \
  --arg status "$status" \
  --argjson duration_s "$duration_s" \
  --argjson cost_usd "$cost_usd" \
  --argjson input_tokens "$INPUT_TOKENS" \
  --argjson output_tokens "$OUTPUT_TOKENS" \
  '{
    ts: $ts,
    agent: $agent,
    task: $task,
    model: $model,
    status: $status,
    duration_s: $duration_s,
    input_tokens: $input_tokens,
    output_tokens: $output_tokens,
    cost_usd: ($cost_usd | tonumber)
  }')

echo "$entry" >> "$LEDGER"
echo "LOGGED: $agent | $model | \$$cost_usd | ${duration_s}s | $status"
