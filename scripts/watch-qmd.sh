#!/usr/bin/env bash
# watch-qmd.sh - Auto-refresh QMD index/embeddings when volatile markdown changes
#
# Watches:
#   - briefs/
#   - debriefs/
#   - briefs_archive/
#   - debriefs_archive/
#
# On each relevant file change/move/delete, runs:
#   just qmd-refresh
#
# Requirements:
#   - watchexec
#   - just
#   - qmd (via just qmd-refresh)

set -euo pipefail

if ! command -v watchexec >/dev/null 2>&1; then
  echo "watch-qmd: watchexec is required. Install with: brew install watchexec"
  exit 1
fi

if ! command -v just >/dev/null 2>&1; then
  echo "watch-qmd: just is required. Install with: brew install just"
  exit 1
fi

echo "watch-qmd: watching briefs/debriefs + archive folders for markdown changes..."
echo "watch-qmd: press Ctrl-C to stop"

# Debounce slightly so bursty move/write events only trigger one refresh.
watchexec \
  --watch briefs \
  --watch debriefs \
  --watch briefs_archive \
  --watch debriefs_archive \
  --exts md,markdown \
  --debounce 1200ms \
  --restart \
  --shell bash \
  -- 'just qmd-refresh'
