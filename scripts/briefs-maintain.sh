#!/bin/bash
# briefs-maintain - Full briefs maintenance: catalog, debriefs, sync
# Usage: ./scripts/briefs-maintain.sh

set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-just-silo}"
SILO_LOG_DIR=".silo/logs"

mkdir -p "$SILO_LOG_DIR"

SILO_LOG_DIR="$SILO_LOG_DIR" SILO_NAME="$PROJECT_NAME" bash scripts/silo-log.sh info "Starting briefs maintenance" action=briefs-maintain

./scripts/briefs.sh catalog
./scripts/briefs.sh debriefs
./scripts/briefs.sh sync

SILO_LOG_DIR="$SILO_LOG_DIR" SILO_NAME="$PROJECT_NAME" bash scripts/silo-log.sh info "Briefs maintenance complete" action=briefs-maintain status=success
