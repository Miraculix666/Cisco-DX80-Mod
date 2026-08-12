#!/usr/bin/env bash
# ============================================================
# FILE: .agent/tests/test-lock-manager.sh
# PURPOSE: Tests for the lock-manager.sh script
# AUTHOR: Jules
# VERSION: 1.0.0
# DEPENDENCIES: .agent/scripts/lock-manager.sh
# USAGE: bash .agent/tests/test-lock-manager.sh
# ============================================================

set -euo pipefail

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK_MANAGER_SCRIPT="$SCRIPT_DIR/../scripts/lock-manager.sh"

echo "🧪 Running lock-manager.sh tests..."

echo -n "   Testing invalid lock type error path... "

set +e
output=$(bash "$LOCK_MANAGER_SCRIPT" lock "test/path" "INVALID" "agent-1" "reason" 2>&1)
exit_code=$?
set -e

if [[ $exit_code -ne 1 ]]; then
    echo -e "${RED}FAILED${NC}"
    echo "Expected return code 1, got $exit_code"
    exit 1
fi

if ! echo "$output" | grep -q "Invalid lock type: INVALID"; then
    echo -e "${RED}FAILED${NC}"
    echo "Expected output to contain 'Invalid lock type: INVALID'"
    echo "Actual output: $output"
    exit 1
fi

echo -e "${GREEN}PASSED${NC}"
echo "✅ All tests passed!"
