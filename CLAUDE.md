# claude-addons

This repo contains addon skills and agents for Claude Code extracted from the internal Anthropic build.

## Setup task

When the user asks to install, set up, or configure the addons, run `./install.sh` from this repo's root directory. That's the only step needed — it copies files to `~/.claude/`:

```
~/.claude/skills/dream/SKILL.md
~/.claude/skills/verify/SKILL.md
~/.claude/agents/verify.md
```

After running the installer, confirm success by listing the installed files.

If the user also wants enhanced memory extraction (Claude proactively saving memories during normal work), ask which project they want it in and append the contents of `addons/dream/CLAUDE.md` to that project's CLAUDE.md file. Do not overwrite — append.

## What's installed

- `/dream` — Memory consolidation skill. Consolidates, deduplicates, and prunes memory files.
- `/verify` — Verification skill that tries to break code after implementation. Also available as a `verification` agent via the Agent tool.

## Uninstall

Run `./uninstall.sh` to remove all installed files.
