#!/usr/bin/env bash
set -euo pipefail

# --- Resolve script directory (handles symlinks and spaces) ---
resolve_dir() {
  local source="${BASH_SOURCE[0]}"
  while [ -L "$source" ]; do
    local dir
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ "$source" != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")" && pwd
}

SCRIPT_DIR="$(resolve_dir)"
CLAUDE_DIR="${HOME}/.claude"
VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo "unknown")"

# --- Remote install support ---
# If addon files aren't present (e.g., piped from curl), clone the repo first
REPO_URL="${CLAUDE_ADDONS_REPO:-https://github.com/sathwickp/claude-addons.git}"
if [ ! -d "${SCRIPT_DIR}/addons" ]; then
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  echo "Downloading claude-addons..."
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null
  SCRIPT_DIR="$TEMP_DIR"
  VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo "unknown")"
fi

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# --- File definitions ---
# Each addon: name, source files, destination files
declare -A DREAM_FILES=(
  ["addons/dream/skills/dream/SKILL.md"]="skills/dream/SKILL.md"
)

declare -A VERIFY_FILES=(
  ["addons/verify/skills/verify/SKILL.md"]="skills/verify/SKILL.md"
  ["addons/verify/agents/verify.md"]="agents/verify.md"
)

# --- Helper functions ---
file_checksum() {
  if command -v md5sum &>/dev/null; then
    md5sum "$1" 2>/dev/null | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    md5 -q "$1" 2>/dev/null
  else
    # Fallback: use file size + mtime
    stat -f "%z%m" "$1" 2>/dev/null || stat -c "%s%Y" "$1" 2>/dev/null
  fi
}

is_current() {
  local src="$1" dest="$2"
  [ -f "$dest" ] && [ "$(file_checksum "$src")" = "$(file_checksum "$dest")" ]
}

install_addon_files() {
  local -n files_map=$1

  for src in "${!files_map[@]}"; do
    local dest="${CLAUDE_DIR}/${files_map[$src]}"
    local dest_dir
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ "$ACTION" = "update" ] && is_current "${SCRIPT_DIR}/${src}" "$dest"; then
      echo -e "  ${DIM}=${NC} ${files_map[$src]} ${DIM}(up to date)${NC}"
    else
      cp "${SCRIPT_DIR}/${src}" "$dest"
      echo -e "  ${GREEN}+${NC} ${files_map[$src]}"
    fi
  done

  return 0
}

show_status() {
  echo ""
  echo -e "${BLUE}claude-addons${NC} v${VERSION}"
  echo ""

  # Dream
  echo -e "${BOLD}Dream${NC} (/dream)"
  for src in "${!DREAM_FILES[@]}"; do
    local dest="${CLAUDE_DIR}/${DREAM_FILES[$src]}"
    if [ ! -f "$dest" ]; then
      echo -e "  ${RED}✗${NC} ${DREAM_FILES[$src]} — not installed"
    elif is_current "${SCRIPT_DIR}/${src}" "$dest"; then
      echo -e "  ${GREEN}✓${NC} ${DREAM_FILES[$src]} — current"
    else
      echo -e "  ${YELLOW}~${NC} ${DREAM_FILES[$src]} — outdated"
    fi
  done
  echo ""

  # Verify
  echo -e "${BOLD}Verify${NC} (/verify)"
  for src in "${!VERIFY_FILES[@]}"; do
    local dest="${CLAUDE_DIR}/${VERIFY_FILES[$src]}"
    if [ ! -f "$dest" ]; then
      echo -e "  ${RED}✗${NC} ${VERIFY_FILES[$src]} — not installed"
    elif is_current "${SCRIPT_DIR}/${src}" "$dest"; then
      echo -e "  ${GREEN}✓${NC} ${VERIFY_FILES[$src]} — current"
    else
      echo -e "  ${YELLOW}~${NC} ${VERIFY_FILES[$src]} — outdated"
    fi
  done
  echo ""

  # Enhanced memory
  if [ -f "${HOME}/.claude/CLAUDE.md" ] && grep -q "Memory Consolidation" "${HOME}/.claude/CLAUDE.md" 2>/dev/null; then
    echo -e "${BOLD}Enhanced memory${NC}: ${GREEN}active globally${NC} (~/.claude/CLAUDE.md)"
  else
    echo -e "${BOLD}Enhanced memory${NC}: ${DIM}not configured${NC}"
  fi
  echo ""
}

show_help() {
  echo ""
  echo -e "${BLUE}claude-addons installer${NC} v${VERSION}"
  echo ""
  echo "Usage: ./install.sh [options] [addon...]"
  echo ""
  echo "Addons:"
  echo "  dream                   Install only the /dream skill"
  echo "  verify                  Install only the /verify skill + agent"
  echo "  (none)                  Install all addons"
  echo ""
  echo "Options:"
  echo "  --status                Show what's installed and whether it's current"
  echo "  --update                Re-install only changed files"
  echo "  --memory <path>         Append enhanced memory extraction to a project's CLAUDE.md"
  echo "  --version, -v           Print version"
  echo "  --help, -h              Show this help"
  echo ""
  echo "Remote install:"
  echo "  curl -fsSL https://raw.githubusercontent.com/sathwickp/claude-addons/main/install.sh | bash"
  echo ""
  echo "Set CLAUDE_ADDONS_REPO to use a different repo URL for remote install."
  echo ""
}

# --- Parse arguments ---
ACTION="install"
ADDONS=()
MEMORY_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)        ACTION="status"; shift ;;
    --update)        ACTION="update"; shift ;;
    --memory)
      if [ -z "${2:-}" ]; then
        echo "Error: --memory requires a project path"
        exit 1
      fi
      MEMORY_PATH="$2"; shift 2 ;;
    --help|-h)       show_help; exit 0 ;;
    --version|-v)    echo "claude-addons v${VERSION}"; exit 0 ;;
    dream|verify)    ADDONS+=("$1"); shift ;;
    *)               echo "Unknown option: $1"; echo "Run ./install.sh --help for usage."; exit 1 ;;
  esac
done

# --- Status mode ---
if [ "$ACTION" = "status" ]; then
  show_status
  exit 0
fi

# Default: install all addons
if [ ${#ADDONS[@]} -eq 0 ]; then
  ADDONS=("dream" "verify")
fi

# --- Install ---
echo ""
echo -e "${BLUE}claude-addons installer${NC} v${VERSION}"
echo "======================"
echo ""

STEP=1
TOTAL_STEPS=${#ADDONS[@]}
[ -n "$MEMORY_PATH" ] && TOTAL_STEPS=$((TOTAL_STEPS + 1))

for addon in "${ADDONS[@]}"; do
  case "$addon" in
    dream)
      echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Dream — Memory Consolidation${NC}"
      install_addon_files DREAM_FILES "dream"
      echo ""
      ;;
    verify)
      echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Verify — Verification Skill + Agent${NC}"
      install_addon_files VERIFY_FILES "verify"
      echo ""
      ;;
  esac
  STEP=$((STEP + 1))
done

# --- Enhanced memory ---
if [ -n "$MEMORY_PATH" ]; then
  echo -e "${YELLOW}[${STEP}/${TOTAL_STEPS}] Enhanced Memory Extraction${NC}"
  DREAM_CLAUDE="${SCRIPT_DIR}/addons/dream/CLAUDE.md"
  TARGET_CLAUDE="${MEMORY_PATH}/CLAUDE.md"

  if [ ! -f "$DREAM_CLAUDE" ]; then
    echo -e "  ${RED}!${NC} Source file not found: addons/dream/CLAUDE.md"
  elif [ -f "$TARGET_CLAUDE" ] && grep -q "Memory Consolidation" "$TARGET_CLAUDE" 2>/dev/null; then
    echo -e "  ${DIM}=${NC} Already present in ${TARGET_CLAUDE}"
  else
    # Append with a blank line separator
    if [ -f "$TARGET_CLAUDE" ]; then
      echo "" >> "$TARGET_CLAUDE"
    fi
    cat "$DREAM_CLAUDE" >> "$TARGET_CLAUDE"
    echo -e "  ${GREEN}+${NC} Appended to ${TARGET_CLAUDE}"
  fi
  echo ""
fi

# --- Done ---
echo -e "${GREEN}Done.${NC} Addons are now available in every Claude Code session."
echo ""
echo "Quick start:"
for addon in "${ADDONS[@]}"; do
  case "$addon" in
    dream)  echo "  /dream    — Run memory consolidation" ;;
    verify) echo "  /verify   — Verify your code changes actually work" ;;
  esac
done
echo ""
echo -e "${DIM}Run ./install.sh --status to check installed addons at any time.${NC}"
echo ""
