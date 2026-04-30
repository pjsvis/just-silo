#!/usr/bin/env bash
# =============================================================================
# pi-restore-llama.sh — Restore pi config from pre-llama backup
# =============================================================================
# Usage:
#   ./scripts/pi-restore-llama.sh
#
# Restores the most recent .pre-llama-* backup of models.json and settings.json.
# If no backup exists, warns and exits.
# =============================================================================

set -euo pipefail

PI_DIR="${HOME}/.pi/agent"

for base in models.json settings.json; do
  file="${PI_DIR}/${base}"
  backup=$(ls -1t "${PI_DIR}/${base}".pre-llama-* 2>/dev/null | head -1 || true)

  if [[ -z "$backup" ]]; then
    echo "Warning: no pre-llama backup found for ${base}" >&2
    continue
  fi

  cp "$backup" "$file"
  echo "  ✓ Restored ${base} ← ${backup}"
done

echo ""
echo "Current default provider/model:"
grep -E 'defaultProvider|defaultModel' "${PI_DIR}/settings.json" 2>/dev/null | sed 's/^/  /'

echo ""
echo "Providers:"
jq -r '.providers | keys[]' "${PI_DIR}/models.json" 2>/dev/null | sed 's/^/  /' || echo "  (could not parse models.json)"
