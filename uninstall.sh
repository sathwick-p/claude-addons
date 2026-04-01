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

# --- Remove skills and agents ---
if [ -f "${CLAUDE_DIR}/skills/dream/SKILL.md" ]; then
  rm "${CLAUDE_DIR}/skills/dream/SKILL.md"
  rmdir "${CLAUDE_DIR}/skills/dream" 2>/dev/null || true
  echo -e "  ${RED}-${NC} Removed /dream skill"
else
  echo -e "  ${DIM}skipped${NC} /dream skill (not found)"
fi

if [ -f "${CLAUDE_DIR}/skills/verify/SKILL.md" ]; then
  rm "${CLAUDE_DIR}/skills/verify/SKILL.md"
  rmdir "${CLAUDE_DIR}/skills/verify" 2>/dev/null || true
  echo -e "  ${RED}-${NC} Removed /verify skill"
else
  echo -e "  ${DIM}skipped${NC} /verify skill (not found)"
fi

if [ -f "${CLAUDE_DIR}/agents/verify.md" ]; then
  rm "${CLAUDE_DIR}/agents/verify.md"
  echo -e "  ${RED}-${NC} Removed verification agent"
else
  echo -e "  ${DIM}skipped${NC} verification agent (not found)"
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
    # Remove the memory consolidation block (from its header to end of file or next top-level heading)
    # The block starts with "# Memory Consolidation" and is typically appended at the end
    if command -v python3 &>/dev/null; then
      python3 -c "
import re, sys
content = open('$GLOBAL_CLAUDE').read()
# Remove the Memory Consolidation section (it's typically the whole file or appended at end)
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
      # Fallback: use sed to remove from the header to end of file
      sed -i.bak '/^# Memory Consolidation — Enhanced Auto-Memory Behavior/,$d' "$GLOBAL_CLAUDE"
      rm -f "${GLOBAL_CLAUDE}.bak"
      # Remove trailing whitespace
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
