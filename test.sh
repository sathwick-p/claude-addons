#!/usr/bin/env bash
set -euo pipefail

# Test suite for dream install/uninstall cycle
# Run: ./test.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
PASSED=0
FAILED=0
TOTAL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

assert() {
  local description="$1"
  local condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}PASS${NC} $description"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}FAIL${NC} $description"
    FAILED=$((FAILED + 1))
  fi
}

echo ""
echo "dream test suite"
echo "========================"
echo ""

# --- Test: Version file exists ---
echo "Version:"
assert "VERSION file exists" "[ -f '${SCRIPT_DIR}/VERSION' ]"
assert "VERSION is semver" "grep -qE '^[0-9]+\.[0-9]+\.[0-9]+' '${SCRIPT_DIR}/VERSION'"
echo ""

# --- Test: Source files exist ---
echo "Source files:"
assert "dream SKILL.md exists" "[ -f '${SCRIPT_DIR}/addons/dream/skills/dream/SKILL.md' ]"
assert "dream CLAUDE.md exists" "[ -f '${SCRIPT_DIR}/addons/dream/CLAUDE.md' ]"
echo ""

# --- Test: Full install ---
echo "Install:"
bash "${SCRIPT_DIR}/install.sh" >/dev/null 2>&1
assert "install.sh exits 0" "true"  # would have failed via set -e
assert "/dream skill installed" "[ -f '${CLAUDE_DIR}/skills/dream/SKILL.md' ]"
echo ""

# --- Test: Installed content matches source ---
echo "Content integrity:"
assert "dream SKILL.md matches source" "diff -q '${SCRIPT_DIR}/addons/dream/skills/dream/SKILL.md' '${CLAUDE_DIR}/skills/dream/SKILL.md' >/dev/null 2>&1"
echo ""

# --- Test: Status ---
echo "Status:"
STATUS_OUTPUT="$(bash "${SCRIPT_DIR}/install.sh" --status 2>&1)"
assert "--status exits 0" "true"
assert "--status mentions dream" "echo '${STATUS_OUTPUT}' | grep -qi 'dream'"
echo ""

# --- Test: Memory flag ---
echo "Memory flag:"
TEMP_PROJECT="$(mktemp -d)"
bash "${SCRIPT_DIR}/install.sh" --memory "$TEMP_PROJECT" >/dev/null 2>&1
assert "--memory creates CLAUDE.md in target" "[ -f '${TEMP_PROJECT}/CLAUDE.md' ]"
assert "--memory appends memory extraction content" "grep -q 'Memory Consolidation' '${TEMP_PROJECT}/CLAUDE.md' 2>/dev/null"
rm -rf "$TEMP_PROJECT"
echo ""

# --- Test: Uninstall ---
echo "Uninstall:"
bash "${SCRIPT_DIR}/uninstall.sh" --yes >/dev/null 2>&1
assert "dream skill removed" "[ ! -f '${CLAUDE_DIR}/skills/dream/SKILL.md' ]"
echo ""

# --- Test: Reinstall (for user's benefit — leave addons installed) ---
echo -e "${DIM}Reinstalling for your benefit...${NC}"
bash "${SCRIPT_DIR}/install.sh" >/dev/null 2>&1
echo ""

# --- Summary ---
echo "========================"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}ALL PASSED${NC}: ${PASSED}/${TOTAL} tests"
else
  echo -e "${RED}${FAILED} FAILED${NC}, ${PASSED} passed out of ${TOTAL} tests"
fi
echo ""

exit $FAILED
