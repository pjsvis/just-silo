#!/usr/bin/env bash
# =============================================================================
# llama-launch.sh — llama.cpp server configs for Gemma 4 and Qwen 3.5
# =============================================================================
# Usage:
#   ./scripts/llama-launch.sh <profile>
#
# Profiles:
#   gemma4        — Gemma 4 agent (definitive stable config)
#   qwen35-think  — Qwen 3.5 with thinking mode (deep reasoning, coding)
#   qwen35-fast   — Qwen 3.5 without thinking mode (direct responses)
#
# Environment:
#   GEMMA4_MODEL    path to Gemma 4 GGUF (auto-detected from Ollama if unset)
#   QWEN35_MODEL    path to Qwen 3.5 GGUF (auto-detected from Ollama if unset)
#   PORT            server port (default: 1234)
#   NGL             GPU layers to offload (default: 99)
#   CTX             context size override (optional)
# =============================================================================

set -euo pipefail

PROFILE="${1:-}"
PORT="${PORT:-1234}"
NGL="${NGL:-99}"

OLLAMA_MODELS="${OLLAMA_MODELS:-${HOME}/.ollama/models}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Read an Ollama manifest and return the path to the model weights blob.
# Args: <registry> <namespace> <model> <tag>
ollama_blob_path() {
  local registry="${1:-registry.ollama.ai}"
  local namespace="${2:-library}"
  local model="$3"
  local tag="${4:-latest}"
  local manifest="${OLLAMA_MODELS}/manifests/${registry}/${namespace}/${model}/${tag}"

  if [[ ! -f "$manifest" ]]; then
    return 1
  fi

  # The first layer with mediaType "application/vnd.ollama.image.model" is the GGUF
  local digest
  digest=$(jq -r '.layers[] | select(.mediaType == "application/vnd.ollama.image.model") | .digest' "$manifest" 2>/dev/null || true)

  if [[ -z "$digest" || "$digest" == "null" ]]; then
    return 1
  fi

  # Digest is "sha256:<hex>"; blob filename is "sha256-<hex>"
  local blob_name
  blob_name=$(echo "$digest" | sed 's/:/-/')
  local blob_path="${OLLAMA_MODELS}/blobs/${blob_name}"

  if [[ ! -f "$blob_path" ]]; then
    return 1
  fi

  # Sanity-check magic bytes
  if ! xxd -l 4 "$blob_path" 2>/dev/null | grep -q "GGUF"; then
    return 1
  fi

  echo "$blob_path"
}

# Resolve a model path:
#   1. Explicit env var
#   2. Downloaded GGUF in ~/models/ (from llama-fetch-models.sh)
#   3. Ollama blob (Gemma 4 works; Qwen 3.5 may have metadata issues)
#   4. Literal file in working directory
#   5. Fail with helpful message
detect_model() {
  local env_var="$1"
  local registry="$2"
  local namespace="$3"
  local model="$4"
  local tag="$5"
  local default_file="$6"
  local known_name="$7"   # e.g., Qwen3.5-27B-Instruct-Q4_K_M.gguf

  # 1. Explicit env var
  if [[ -n "${!env_var:-}" && -f "${!env_var}" ]]; then
    echo "${!env_var}"
    return 0
  fi

  # 2. Downloaded GGUF in ~/models/ — try exact name first, then glob patterns
  local downloaded="${HOME}/models/${known_name}"
  if [[ -f "$downloaded" ]]; then
    echo "$downloaded"
    return 0
  fi

  # Also try glob matches (e.g., UD-Q4_K_M variants)
  local glob_match
  glob_match=$(ls -1 "${HOME}/models/" 2>/dev/null | grep -i "${model//3.5/}" | grep -i "q4_k_m\|Q4_K_M" | head -1) || true
  if [[ -n "$glob_match" && -f "${HOME}/models/${glob_match}" ]]; then
    echo "${HOME}/models/${glob_match}"
    return 0
  fi

  # 3. Ollama blob
  local blob
  if blob=$(ollama_blob_path "$registry" "$namespace" "$model" "$tag" 2>/dev/null); then
    # Qwen 3.5 Ollama blobs are known to have rope.dimension_sections metadata
    # that some llama.cpp builds reject. Warn but still return the path.
    if [[ "$model" == "qwen3.5" ]]; then
      echo "Warning: Ollama-bundled Qwen 3.5 may fail to load in llama.cpp" >&2
      echo "  (rope.dimension_sections mismatch). Download a fresh GGUF:" >&2
      echo "  just llama-fetch qwen35" >&2
      echo "  # or: export QWEN35_MODEL=~/models/${known_name}" >&2
      echo "" >&2
    fi
    echo "$blob"
    return 0
  fi

  # 4. Literal file in working directory
  if [[ -f "$default_file" ]]; then
    echo "$default_file"
    return 0
  fi

  # 5. Fail with helpful message
  echo "Error: could not find ${model} model." >&2
  echo "  Tried: \$${env_var}=${!env_var:-(unset)}" >&2
  echo "  Tried: ~/models/${known_name}" >&2
  echo "  Tried: Ollama blob for ${namespace}/${model}:${tag}" >&2
  echo "  Tried: ./${default_file}" >&2
  echo "" >&2
  echo "Fix one of:" >&2
  echo "  export ${env_var}=/path/to/your/${model}.gguf" >&2
  echo "  just llama-fetch ${model/3.5/}   # download known-good GGUF" >&2
  echo "  ollama pull ${model}:${tag}" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if ! command -v llama-server >/dev/null 2>&1; then
  echo "Error: llama-server not found in PATH." >&2
  echo "  Build or install llama.cpp first: https://github.com/ggerganov/llama.cpp" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to read Ollama manifests." >&2
  echo "  brew install jq  # macOS" >&2
  exit 1
fi

# Lazy model resolution — only detect when the profile actually needs it
gemma4_model() {
  # Gemma 4 — try 26B A4B first (what llama-fetch downloads), then E4B
  local f
  f="${HOME}/models/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf"
  if [[ -f "$f" ]]; then echo "$f"; return 0; fi
  f="${HOME}/models/gemma-4-E4B-it-Q4_K_M.gguf"
  if [[ -f "$f" ]]; then echo "$f"; return 0; fi
  # Fall through to detect_model for env var / Ollama / working dir
  detect_model GEMMA4_MODEL registry.ollama.ai library gemma4 26b gemma-4-26B-A4B-it-UD-Q4_K_M.gguf gemma-4-26B-A4B-it-UD-Q4_K_M.gguf
}
qwen35_model() {
  detect_model QWEN35_MODEL registry.ollama.ai library qwen3.5 latest Qwen3.5-27B-Q4_K_M.gguf Qwen3.5-27B-Q4_K_M.gguf
}

case "$PROFILE" in
  gemma4)
    GEMMA4_MODEL=$(gemma4_model)
    # -------------------------------------------------------------------------
    # Gemma 4 E4B — Definitive Stable Config
    # Source: "I Built a Gemma 4 AI Agent. It Kept Looping Until I Fixed This."
    # E4B = Efficient 4B variant (~4.6 GB Q4_K_M vs ~16 GB for 26B A4B).
    # -------------------------------------------------------------------------
    # Critical: --jinja enables proper chat template parser for tool results.
    #           Without this, the agent infinite-loops on the same tool call.
    # Critical: temp 1.0 prevents unclosed reasoning tags.
    #           Lower temps reinforce the thinking loop.
    # Context: 32K is the sweet spot. 256K max exists but collapse occurs ~80K.
    # Build:   llama.cpp b3000+ (or b3447+ for flash attention).
    #           Older builds cause random typos in output.
    # -------------------------------------------------------------------------
    CTX="${CTX:-32768}"
    echo "=== Launching Gemma 4 Agent ==="
    echo "  Model:  $GEMMA4_MODEL"
    echo "  Port:   $PORT"
    echo "  Ctx:    $CTX"
    echo "  Temp:   1.0  (exact — do not change)"
    echo "  Build:  ensure llama.cpp >= b3000"
    echo ""
    exec llama-server \
      -m "$GEMMA4_MODEL" \
      --port "$PORT" \
      -ngl "$NGL" \
      -c "$CTX" \
      --jinja \
      -ctk q8_0 \
      -ctv q8_0 \
      --temp 1.0 \
      --top-k 40 \
      --top-p 0.95 \
      --repeat-penalty 1.1
    ;;

  qwen35-think)
    # -------------------------------------------------------------------------
    # Qwen 3.5 — Thinking Mode (Deep Reasoning / Coding)
    # -------------------------------------------------------------------------
    # Use for: multi-step debugging, complex planning, math, code generation.
    # Thinking is ON by default on 27B+. The model emits chain-of-thought tags.
    # Temperature 0.6 keeps reasoning chains deterministic and reproducible.
    # Context: scale to VRAM — 16384 for 24GB, 32768 for 32GB+, 65536 for 48GB+.
    # -------------------------------------------------------------------------
    QWEN35_MODEL=$(qwen35_model)
    CTX="${CTX:-32768}"
    echo "=== Launching Qwen 3.5 (Thinking Mode) ==="
    echo "  Model:  $QWEN35_MODEL"
    echo "  Port:   $PORT"
    echo "  Ctx:    $CTX"
    echo "  Temp:   0.6"
    echo "  Mode:   enable_thinking = true (default)"
    echo ""
    exec llama-server \
      -m "$QWEN35_MODEL" \
      --port "$PORT" \
      -ngl "$NGL" \
      -c "$CTX" \
      --jinja \
      --temp 0.6 \
      --top-k 20 \
      --top-p 0.95 \
      --presence-penalty 0.0 \
      --repeat-penalty 1.0
    ;;

  qwen35-fast)
    # -------------------------------------------------------------------------
    # Qwen 3.5 — Non-Thinking Mode (Fast / Direct Responses)
    # -------------------------------------------------------------------------
    # Use for: simple Q&A, formatting, text manipulation, quick chat.
    # Explicitly disables chain-of-thought via chat-template-kwargs.
    # Lower top_p (0.8) constrains output to more likely tokens.
    # Presence penalty 1.5 prevents repetitive output.
    # -------------------------------------------------------------------------
    QWEN35_MODEL=$(qwen35_model)
    CTX="${CTX:-32768}"
    echo "=== Launching Qwen 3.5 (Non-Thinking Mode) ==="
    echo "  Model:  $QWEN35_MODEL"
    echo "  Port:   $PORT"
    echo "  Ctx:    $CTX"
    echo "  Temp:   0.7"
    echo "  Mode:   enable_thinking = false"
    echo ""
    exec llama-server \
      -m "$QWEN35_MODEL" \
      --port "$PORT" \
      -ngl "$NGL" \
      -c "$CTX" \
      --jinja \
      --temp 0.7 \
      --top-k 20 \
      --top-p 0.8 \
      --presence-penalty 1.5 \
      --repeat-penalty 1.0 \
      --reasoning off
    ;;

  *)
    echo "Usage: $0 <profile>"
    echo ""
    echo "Profiles:"
    echo "  gemma4        Gemma 4 agent (temp 1.0, --jinja, 32K ctx)"
    echo "  qwen35-think  Qwen 3.5 with thinking (temp 0.6, deep reasoning)"
    echo "  qwen35-fast   Qwen 3.5 without thinking (temp 0.7, direct output)"
    echo ""
    # Help mode: try to detect models but don't fail if missing
    echo "Detected model paths:"
    GEMMA4_MODEL=$(gemma4_model 2>/dev/null) || true
    QWEN35_MODEL=$(qwen35_model 2>/dev/null) || true
    echo "  Gemma 4:  ${GEMMA4_MODEL:-(not found — run 'just llama-fetch gemma4' or set GEMMA4_MODEL)}"
    echo "  Qwen 3.5: ${QWEN35_MODEL:-(not found — run 'just llama-fetch qwen35' or set QWEN35_MODEL)}"
    echo ""
    echo "Environment overrides:"
    echo "  GEMMA4_MODEL=path/to/gemma.gguf"
    echo "  QWEN35_MODEL=path/to/qwen.gguf"
    echo "  PORT=1234"
    echo "  NGL=99"
    echo "  CTX=16384"
    exit 0
    ;;
esac
