#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}claude-addons installer${NC}"
echo "======================"
echo ""

# --- Dream: Memory Consolidation ---
echo -e "${YELLOW}[1/2] Dream — Memory Consolidation${NC}"

SKILLS_DIR="${CLAUDE_DIR}/skills/dream"
mkdir -p "$SKILLS_DIR"
cp "${SCRIPT_DIR}/addons/dream/skills/dream/SKILL.md" "$SKILLS_DIR/SKILL.md"
echo -e "  ${GREEN}+${NC} Installed /dream skill to ${SKILLS_DIR}/SKILL.md"

echo ""
echo "  The dream CLAUDE.md (enhanced memory extraction instructions) is at:"
echo "    ${SCRIPT_DIR}/addons/dream/CLAUDE.md"
echo ""
echo "  To use it, copy or append it to your project's CLAUDE.md:"
echo "    cat ${SCRIPT_DIR}/addons/dream/CLAUDE.md >> /path/to/your/project/CLAUDE.md"
echo ""

# --- Verify: Skill + Agent ---
echo -e "${YELLOW}[2/2] Verify — Verification Skill + Agent${NC}"

VERIFY_SKILLS_DIR="${CLAUDE_DIR}/skills/verify"
mkdir -p "$VERIFY_SKILLS_DIR"
cp "${SCRIPT_DIR}/addons/verify/skills/verify/SKILL.md" "$VERIFY_SKILLS_DIR/SKILL.md"
echo -e "  ${GREEN}+${NC} Installed /verify skill to ${VERIFY_SKILLS_DIR}/SKILL.md"

AGENTS_DIR="${CLAUDE_DIR}/agents"
mkdir -p "$AGENTS_DIR"
cp "${SCRIPT_DIR}/addons/verify/agents/verify.md" "$AGENTS_DIR/verify.md"
echo -e "  ${GREEN}+${NC} Installed verification agent to ${AGENTS_DIR}/verify.md"

echo ""
echo -e "${GREEN}Done.${NC} All addons are now available in every Claude Code session."
echo ""
echo "Quick start:"
echo "  /dream    — Run memory consolidation"
echo "  /verify   — Verify your code changes actually work"
echo ""
