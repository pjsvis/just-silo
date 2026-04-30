#!/usr/bin/env bash
# =============================================================================
# llama-fetch-models.sh — Download known-good GGUFs for llama.cpp
# =============================================================================
# Usage:
#   ./scripts/llama-fetch-models.sh [model]
#
# Models:
#   qwen35    Qwen 3.5 27B (Q4_K_M) — ~16.7 GB
#   gemma4    Gemma 4 26B A4B IT (Q4_K_M) — ~16 GB
#   all       Both
#
# Downloads to: ~/models/ (override with MODELS_DIR)
# Requires: `hf` CLI (https://huggingface.co/docs/huggingface_hub/main/en/guides/cli)
#           brew install hf  # macOS
# =============================================================================

set -euo pipefail

MODELS_DIR="${MODELS_DIR:-${HOME}/models}"
mkdir -p "$MODELS_DIR"

REQUEST="${1:-all}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

download_hf() {
  local repo="$1"
  local file="$2"
  local dest="${MODELS_DIR}/${file}"

  if [[ -f "$dest" ]]; then
    echo "  Already exists: ${dest}"
    echo "  Run with MODELS_DIR=/other/path to download elsewhere."
    return 0
  fi

  echo "  Downloading from: ${repo}/${file}"
  echo "  Destination:      ${MODELS_DIR}/"
  echo "  Size:             see progress below"
  echo ""

  if ! command -v hf >/dev/null 2>&1; then
    echo "Error: 'hf' CLI not found." >&2
    echo "  Install: brew install hf  # macOS" >&2
    echo "  Or:      pip install huggingface-hub  # then use 'hf' not 'huggingface-cli'" >&2
    exit 1
  fi

  # Use hf download — files go directly to --local-dir (no symlinks)
  hf download "$repo" \
    --include "${file}" \
    --local-dir "$MODELS_DIR"
}

# ---------------------------------------------------------------------------
# Gemma 4 26B A4B IT — Q4_K_M (Unsloth UD variant)
# ---------------------------------------------------------------------------
fetch_gemma4() {
  echo "=== Gemma 4 26B A4B IT (Q4_K_M) ==="
  download_hf "unsloth/gemma-4-26B-A4B-it-GGUF" "gemma-4-26B-A4B-it-UD-Q4_K_M.gguf"
}

# ---------------------------------------------------------------------------
# Qwen 3.5 27B — Q4_K_M
# ---------------------------------------------------------------------------
fetch_qwen35() {
  echo "=== Qwen 3.5 27B (Q4_K_M) ==="
  download_hf "unsloth/Qwen3.5-27B-GGUF" "Qwen3.5-27B-Q4_K_M.gguf"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

case "$REQUEST" in
  qwen35|qwen)
    fetch_qwen35
    ;;
  gemma4|gemma)
    fetch_gemma4
    ;;
  all)
    fetch_gemma4
    echo ""
    fetch_qwen35
    ;;
  *)
    echo "Usage: $0 [qwen35|gemma4|all]"
    echo ""
    echo "Downloads known-good GGUFs to: ${MODELS_DIR}"
    echo "Requires: hf CLI (brew install hf)"
    echo ""
    echo "Current models:"
    ls -1 "${MODELS_DIR}/" 2>/dev/null | grep -E "gemma|qwen|Qwen" | sed 's/^/  /' || echo "  (none)"
    exit 1
    ;;
esac

echo ""
echo "=== Done ==="
echo "Models in ${MODELS_DIR}:"
ls -lh "${MODELS_DIR}/" | grep -E "gemma|qwen|Qwen|total"
echo ""
echo "Set environment variables to use them:"
echo "  export GEMMA4_MODEL=${MODELS_DIR}/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf"
echo "  export QWEN35_MODEL=${MODELS_DIR}/Qwen3.5-27B-Q4_K_M.gguf"
