#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
NC='\033[0m'

# Parse flags
AUTO_YES=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true; shift ;;
    *) shift ;;
  esac
done

echo ""
echo "claude-addons uninstaller"
echo "========================="
echo ""

# --- Remove dream skill ---
if [ -f "${CLAUDE_DIR}/skills/dream/SKILL.md" ]; then
  rm "${CLAUDE_DIR}/skills/dream/SKILL.md"
  rmdir "${CLAUDE_DIR}/skills/dream" 2>/dev/null || true
  echo -e "  ${RED}-${NC} Removed /dream skill"
else
  echo -e "  ${DIM}skipped${NC} /dream skill (not found)"
fi

echo ""

# --- Clean up enhanced memory from global CLAUDE.md ---
GLOBAL_CLAUDE="${CLAUDE_DIR}/CLAUDE.md"
if [ -f "$GLOBAL_CLAUDE" ] && grep -q "Memory Consolidation — Enhanced Auto-Memory Behavior" "$GLOBAL_CLAUDE" 2>/dev/null; then
  echo -e "${YELLOW}Enhanced memory extraction detected in ~/.claude/CLAUDE.md${NC}"
  if [ "$AUTO_YES" = true ]; then
    REPLY="y"
  else
    read -p "  Remove it? (y/N) " -n 1 -r
    echo ""
  fi
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v python3 &>/dev/null; then
      python3 -c "
import re, sys
content = open('$GLOBAL_CLAUDE').read()
pattern = r'\n?# Memory Consolidation — Enhanced Auto-Memory Behavior.*'
cleaned = re.sub(pattern, '', content, flags=re.DOTALL).rstrip()
if cleaned:
    open('$GLOBAL_CLAUDE', 'w').write(cleaned + '\n')
else:
    import os
    os.remove('$GLOBAL_CLAUDE')
    print('  (file was empty after removal, deleted)')
"
    else
      sed -i.bak '/^# Memory Consolidation — Enhanced Auto-Memory Behavior/,$d' "$GLOBAL_CLAUDE"
      rm -f "${GLOBAL_CLAUDE}.bak"
      if [ ! -s "$GLOBAL_CLAUDE" ]; then
        rm "$GLOBAL_CLAUDE"
        echo "  (file was empty after removal, deleted)"
      fi
    fi
    echo -e "  ${RED}-${NC} Removed enhanced memory extraction from ~/.claude/CLAUDE.md"
  else
    echo -e "  ${DIM}skipped${NC}"
  fi
  echo ""
fi

echo -e "${GREEN}Done.${NC} Addons removed."
echo ""
echo -e "${DIM}Note: Enhanced memory extraction in project-level CLAUDE.md files must be removed manually.${NC}"
echo -e "${DIM}Look for the \"# Memory Consolidation\" section and delete it.${NC}"
echo ""
