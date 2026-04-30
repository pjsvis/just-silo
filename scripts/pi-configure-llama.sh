#!/usr/bin/env bash
# =============================================================================
# pi-configure-llama.sh — Wire pi coding agent to llama.cpp local models
# =============================================================================
# Usage:
#   ./scripts/pi-configure-llama.sh
#
# What it does:
#   - Adds a "llama" provider to ~/.pi/agent/models.json
#   - Sets pi default provider to "llama" and default model to Gemma 4 E4B
#   - Backs up existing config files
#
# Requirements:
#   - llama.cpp server running on port 1234 (just llama-gemma4)
#   - jq (brew install jq)
#
# To switch back to another provider in pi:
#   /model  → pick from list
#   /settings → change default provider
# =============================================================================

set -euo pipefail

PI_DIR="${HOME}/.pi/agent"
MODELS_FILE="${PI_DIR}/models.json"
SETTINGS_FILE="${PI_DIR}/settings.json"

if [[ ! -d "$PI_DIR" ]]; then
  echo "Error: pi agent directory not found at ${PI_DIR}" >&2
  echo "  Is pi installed? npm install -g @mariozechner/pi-coding-agent" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  echo "  brew install jq" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Backup existing configs
# ---------------------------------------------------------------------------
for f in "$MODELS_FILE" "$SETTINGS_FILE"; do
  if [[ -f "$f" ]]; then
    backup="${f}.pre-llama-$(date +%Y%m%dT%H%M%S)"
    cp "$f" "$backup"
    echo "Backed up: ${f} → ${backup}"
  fi
done

# ---------------------------------------------------------------------------
# Create llama provider in models.json
# ---------------------------------------------------------------------------
echo ""
echo "Adding 'llama' provider to ${MODELS_FILE}..."

# Read existing or create empty
if [[ -f "$MODELS_FILE" ]]; then
  existing=$(cat "$MODELS_FILE")
else
  existing='{"providers":{}}'
fi

# Merge in the llama provider (preserve existing providers)
new_models=$(echo "$existing" | jq '
  .providers.llama = {
    "api": "openai-completions",
    "apiKey": "llama",
    "baseUrl": "http://127.0.0.1:1234/v1",
    "models": [
      {
        "id": "Gemma-4-E4B-It",
        "name": "Gemma 4 E4B",
        "reasoning": true,
        "input": ["text", "image"],
        "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
        "contextWindow": 32768,
        "maxTokens": 8192,
        "compat": {
          "supportsDeveloperRole": false,
          "maxTokensField": "max_tokens",
          "requiresToolResultName": false
        }
      },
      {
        "id": "Qwen3.5-27B",
        "name": "Qwen 3.5 27B",
        "reasoning": true,
        "input": ["text", "image"],
        "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
        "contextWindow": 32768,
        "maxTokens": 8192,
        "compat": {
          "supportsDeveloperRole": false,
          "maxTokensField": "max_tokens",
          "requiresToolResultName": false
        }
      }
    ]
  }
')

echo "$new_models" > "$MODELS_FILE"
echo "  ✓ llama provider added"

# ---------------------------------------------------------------------------
# Update settings.json default
# ---------------------------------------------------------------------------
echo ""
echo "Updating ${SETTINGS_FILE}..."

if [[ -f "$SETTINGS_FILE" ]]; then
  new_settings=$(cat "$SETTINGS_FILE" | jq '
    .defaultProvider = "llama"
    | .defaultModel = "Gemma-4-E4B-It"
  ')
else
  new_settings='{
    "defaultProvider": "llama",
    "defaultModel": "Gemma-4-E4B-It",
    "defaultThinkingLevel": "medium"
  }'
fi

echo "$new_settings" > "$SETTINGS_FILE"
echo "  ✓ Default provider → llama, model → Gemma-4-E4B-It"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Configuration complete ==="
echo ""
echo "Start a llama.cpp server, then launch pi:"
echo ""
echo "  just llama-gemma4      # Gemma 4 E4B (port 1234)"
echo "  just llama-qwen35-think # Qwen 3.5 with thinking (port 1234)"
echo "  just llama-qwen35-fast  # Qwen 3.5 direct mode (port 1234)"
echo ""
echo "  pi                     # launches with default model"
echo ""
echo "Switch models in pi:"
echo "  /model                 # pick llama → Gemma-4-E4B-It or Qwen3.5-27B"
echo ""
echo "Switch back to cloud providers:"
echo "  /model                 # pick opencode, anthropic, openai, etc."
echo ""
echo "Config files:"
echo "  ${MODELS_FILE}"
echo "  ${SETTINGS_FILE}"
