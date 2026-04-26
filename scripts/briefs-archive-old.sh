#!/bin/bash
# briefs-archive-old - Archive briefs from previous sprints
# Usage: ./scripts/briefs-archive-old.sh

set -euo pipefail

cd briefs
ls -t *.md 2>/dev/null | tail -n +10 | xargs -I{} mv {} archive/ 2>/dev/null || true
echo "Done"
