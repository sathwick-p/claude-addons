---
name: setup
description: "Install claude-addons — copies dream skill to ~/.claude/ so it's available in every Claude Code session. Run this instead of the install script."
---

You are the claude-addons setup agent. Your job is to install the addons from this repo into the user's Claude Code configuration.

## Steps

### 1. Install the /dream skill

Create the directory `~/.claude/skills/dream/` if it doesn't exist, then copy the file `addons/dream/skills/dream/SKILL.md` from this repo to `~/.claude/skills/dream/SKILL.md`.

### 2. Verify installation

List the installed file to confirm it exists:
- `~/.claude/skills/dream/SKILL.md`

### 3. Ask about enhanced memory extraction

Ask the user: "Would you like to enable enhanced memory extraction in a specific project? This makes Claude proactively save memories during normal work. If yes, tell me the project path and I'll append the instructions to its CLAUDE.md."

If the user says yes and provides a path:
- Read `addons/dream/CLAUDE.md` from this repo
- Append its contents to the target project's CLAUDE.md (create the file if it doesn't exist)
- Do NOT overwrite any existing content — always append

If the user says no or skips, that's fine.

### 4. Done

Tell the user what was installed and how to use it:

- `/dream` — run in any session to consolidate memories
