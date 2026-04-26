#!/bin/bash
# dev-tests - Run integration and unit tests with logging
# Usage: ./scripts/dev-tests.sh

set -euo pipefail

PROJECT_NAME="${PROJECT_NAME:-just-silo}"
SILO_LOG_DIR=".silo/logs"

mkdir -p "$SILO_LOG_DIR"

echo "=== Integration Tests ==="
set +e
./scripts/silo-integration-test
INT_EXIT=$?
set -e

echo ""
echo "=== Unit Tests ==="
set +e
bun test
TEST_EXIT=$?
set -e

if [ "$TEST_EXIT" = "0" ] && [ "$INT_EXIT" = "0" ]; then
    SILO_LOG_DIR="$SILO_LOG_DIR" SILO_NAME="$PROJECT_NAME" bash scripts/silo-log.sh info "Tests passed" action=dev-tests status=success
else
    SILO_LOG_DIR="$SILO_LOG_DIR" SILO_NAME="$PROJECT_NAME" bash scripts/silo-log.sh error "Tests failed" action=dev-tests status=failure exit_code="$TEST_EXIT"
fi

exit "$TEST_EXIT"
