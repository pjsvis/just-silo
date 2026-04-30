---
date: 2026-04-29
tags: [debrief, llama.cpp, gemma4, qwen3.5, pi-coding-agent, local-inference]
---

# Debrief: Wire pi Coding Agent to llama.cpp with Gemma 4 & Qwen 3.5

## Context
Set up local inference for the pi coding agent using llama.cpp as the backend, with Gemma 4 E4B and Qwen 3.5 27B as active models. Previously pi was configured for cloud providers (opencode, anthropic, etc.) and Ollama. The goal was a fully local, reproducible setup with correct model-specific parameters.

## Accomplishments

- **Created `scripts/llama-launch.sh`**: Three profiles with empirically-tuned parameters:
  - `gemma4`: `temp=1.0` (exact), `--jinja`, `repeat_penalty=1.1`, `ctx=32768` — the definitive stable config from Kuldeepsinh Jadeja's guide.
  - `qwen35-think`: `temp=0.6`, `top_p=0.95`, thinking enabled — deep reasoning / coding mode.
  - `qwen35-fast`: `temp=0.7`, `top_p=0.8`, `--reasoning off` — direct fast responses.
- **Auto-detection of model paths**: Script resolves `GEMMA4_MODEL` / `QWEN35_MODEL` env vars → `~/models/*.gguf` → Ollama blob (with GGUF magic-byte validation). Lazy resolution prevents `llama-help` from crashing when one model is missing.
- **Added `just llama-*` recipes**: `llama-gemma4`, `llama-qwen35-think`, `llama-qwen35-fast`, `llama-help`, `llama-fetch`.
- **Created `scripts/llama-fetch-models.sh`**: Downloads known-good GGUFs via `hf` CLI from `unsloth/` repos. Handles the `hf` CLI's current API (no `--local-dir-use-symlinks`).
- **Downsized Gemma 4**: Replaced 26B A4B (~16 GB) with E4B (~4.6 GB Q4_K_M), freeing ~11.4 GB. Verified E4B loads correctly: `model type = E4B`, `params = 7.52 B`.
- **Downloaded Qwen 3.5 27B**: `Qwen3.5-27B-Q4_K_M.gguf` (~16.7 GB) from `unsloth/Qwen3.5-27B-GGUF`.
- **Configured pi for llama.cpp**: Added `"llama"` provider to `~/.pi/agent/models.json` with `openai-completions` API, `baseUrl: http://127.0.0.1:1234/v1`, and both models. Set `defaultProvider: "llama"`, `defaultModel: "Gemma-4-E4B-It"`.
- **Added restore verb**: `just pi-llama-restore` reads the most recent `.pre-llama-*` backup and reverts `models.json` + `settings.json`.
- **End-to-end verified**: All three server profiles start, respond on their ports, and return valid OpenAI-compatible `/v1/models` and `/v1/chat/completions` responses.

## Problems

- **Ollama Qwen 3.5 blob incompatible with llama.cpp**: The Ollama-bundled Qwen 3.5 GGUF has `rope.dimension_sections` metadata that llama.cpp build b8960 rejected (`expected 4, got 3`). Ollama's conversion diverged from upstream. **Fix**: Downloaded a fresh GGUF from `unsloth/Qwen3.5-27B-GGUF`.
- **Eager model resolution crashed `llama-help`**: The script resolved both models at startup, so `llama-help` failed when Qwen 3.5 wasn't downloaded yet. **Fix**: Restructured to lazy resolution — `gemma4_model()` and `qwen35_model()` functions only called when the specific profile needs them.
- **`hf` CLI API drift**: `huggingface-cli` is deprecated; `hf` CLI removed `--local-dir-use-symlinks`. `--include` requires quoted patterns to avoid shell glob expansion. **Fix**: Updated `llama-fetch-models.sh` to use `hf download` with bare `--local-dir` and double-quoted `--include`.
- **Stale download lock files**: Previous failed `hf download` attempts left lock files in `~/models/.cache/huggingface/download/`, blocking subsequent downloads. **Fix**: Manually killed processes and removed lock files.
- **Port collision on test**: A previous test server was still holding port 1234, causing `llama-gemma4` to fail with "couldn't bind HTTP server socket." **Fix**: Killed the process via `lsof -ti:1234`.
- **Deprecated llama.cpp flag**: `--chat-template-kwargs '{"enable_thinking": false}'` triggered a deprecation warning. **Fix**: Replaced with `--reasoning off`.

## Lessons Learned

- **Ollama blobs ≠ upstream GGUFs**: Ollama may rewrite metadata during conversion. For llama.cpp compatibility, download GGUFs directly from the source (Unsloth, Bartowski, official repos).
- **Model parameters are not transferable**: Gemma 4 requires `temp=1.0` to escape thinking loops. Qwen 3.5 needs `temp=0.6–0.7`. Copying parameters across model families creates incoherent behavior.
- **`hf` CLI replaces `huggingface-cli`**: The old Python CLI is deprecated. The new Rust-based `hf` has a different flag set — verify with `hf <command> --help` before scripting.
- **Lazy evaluation prevents cascading failures**: In multi-model scripts, resolve each model only when its profile is invoked. A missing model for profile B should not crash the help text for profile A.
- **llama.cpp `--jinja` is non-negotiable for Gemma 4 tool use**: Without it, the agent calls the same tool in an infinite loop because tool results aren't parsed back into the model's expected format.

## Verification

- `just llama-help` — exits 0, shows both detected model paths.
- `just llama-gemma4` — server starts, `curl /v1/models` returns E4B, chat completion returns text.
- `just llama-qwen35-think` — server starts, `model type = 27B`, responds on port.
- `just llama-qwen35-fast` — server starts, `--reasoning off` with no deprecation warnings.
- `just pi-llama` — adds `"llama"` provider, sets defaults, backs up originals.
- `just pi-llama-restore` — reverts to `opencode` / `kimi-k2.6` and `ollama` provider.
- Round-trip tested: apply → restore → re-apply → verify config state.
