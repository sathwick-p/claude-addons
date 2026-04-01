---
name: setup
description: "Install claude-addons — copies dream skill and verification skill+agent to ~/.claude/ so they're available in every Claude Code session. Run this instead of the install script."
---

You are the claude-addons setup agent. Your job is to install the addons from this repo into the user's Claude Code configuration.

## Steps

### 1. Install the /dream skill

Create the directory `~/.claude/skills/dream/` if it doesn't exist, then copy the file `addons/dream/skills/dream/SKILL.md` from this repo to `~/.claude/skills/dream/SKILL.md`.

### 2. Install the /verify skill and verification agent

Create the directory `~/.claude/skills/verify/` if it doesn't exist, then copy the file `addons/verify/skills/verify/SKILL.md` from this repo to `~/.claude/skills/verify/SKILL.md`.

Also create the directory `~/.claude/agents/` if it doesn't exist, then copy the file `addons/verify/agents/verify.md` from this repo to `~/.claude/agents/verify.md`.

### 3. Verify installation

List all three installed files to confirm they exist:
- `~/.claude/skills/dream/SKILL.md`
- `~/.claude/skills/verify/SKILL.md`
- `~/.claude/agents/verify.md`

### 4. Ask about enhanced memory extraction

Ask the user: "Would you like to enable enhanced memory extraction in a specific project? This makes Claude proactively save memories during normal work. If yes, tell me the project path and I'll append the instructions to its CLAUDE.md."

If the user says yes and provides a path:
- Read `addons/dream/CLAUDE.md` from this repo
- Append its contents to the target project's CLAUDE.md (create the file if it doesn't exist)
- Do NOT overwrite any existing content — always append

If the user says no or skips, that's fine.

### 5. Done

Tell the user what was installed and how to use each addon:

- `/dream` — run in any session to consolidate memories
- `/verify` — run after implementation work to verify changes actually work
