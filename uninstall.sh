#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo "claude-addons uninstaller"
echo "========================="
echo ""

if [ -f "${CLAUDE_DIR}/skills/dream/SKILL.md" ]; then
  rm "${CLAUDE_DIR}/skills/dream/SKILL.md"
  rmdir "${CLAUDE_DIR}/skills/dream" 2>/dev/null || true
  echo -e "  ${RED}-${NC} Removed /dream skill"
else
  echo "  /dream skill not found, skipping"
fi

if [ -f "${CLAUDE_DIR}/skills/verify/SKILL.md" ]; then
  rm "${CLAUDE_DIR}/skills/verify/SKILL.md"
  rmdir "${CLAUDE_DIR}/skills/verify" 2>/dev/null || true
  echo -e "  ${RED}-${NC} Removed /verify skill"
else
  echo "  /verify skill not found, skipping"
fi

if [ -f "${CLAUDE_DIR}/agents/verify.md" ]; then
  rm "${CLAUDE_DIR}/agents/verify.md"
  echo -e "  ${RED}-${NC} Removed verification agent"
else
  echo "  Verification agent not found, skipping"
fi

echo ""
echo -e "${GREEN}Done.${NC} Addons removed."
echo ""
echo "Note: Any CLAUDE.md changes you made to projects must be removed manually."
echo ""
