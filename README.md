# claude-addons

Give Claude Code a long-term memory that actually works.

```bash
git clone https://github.com/sathwick-p/claude-addons.git && cd claude-addons && ./install.sh
```

Or open the repo in Claude Code and say `set me up`.

![demo](demo/claude-addons.gif)

---

## The problem

Claude Code forgets everything between sessions. Your preferences, your corrections, your project context — gone. You end up repeating yourself constantly.

## The fix

**`/dream`** is a memory consolidation skill that reviews your recent sessions and distills them into durable, well-organized memories. Future sessions orient instantly — Claude knows your preferences, your project context, and what you've told it before.

<details>
<summary>Example output</summary>

```
> /dream

Phase 1 — Orient
  Memory directory: ~/.claude/projects/.../memory/
  Found 8 memories across 4 topics

Phase 2 — Gather
  Scanning 3 recent session transcripts...
  Found 2 new signals worth persisting

Phase 3 — Consolidate
  Updated: user_role.md (added React experience)
  Created: project_api_migration.md (API v2 deadline: 2026-04-15)
  Merged: feedback_testing.md + feedback_mocks.md → feedback_testing.md

Phase 4 — Prune
  Removed stale: project_old_deadline.md
  Index: 7 memories, 6 lines in MEMORY.md

Dream complete: 7 memories | 1 created, 1 updated, 1 merged, 1 pruned.
```

</details>

### What gets remembered

- Your corrections and confirmed approaches (so you never repeat yourself)
- Role, expertise, and preference signals
- Project decisions, deadlines, and context
- External system pointers (dashboards, trackers, docs)

### What doesn't

- Code patterns, architecture, file paths (derivable from the code)
- Git history (that's what `git log` is for)
- Debugging solutions (the fix is in the code)

### Enhanced auto-extraction

For Claude to proactively save memories during normal work (not just during `/dream`), enable enhanced memory extraction:

```bash
./install.sh --memory /path/to/your/project   # per project
./install.sh --memory ~/.claude                # global
```

This makes Claude watch for and save signals automatically — corrections, role mentions, project decisions, external system pointers — without you asking.

## Install

```bash
git clone https://github.com/sathwick-p/claude-addons.git
cd claude-addons
./install.sh
```

### Remote install (no clone needed)

```bash
curl -fsSL https://raw.githubusercontent.com/sathwick-p/claude-addons/main/install.sh | bash
```

### What gets installed

```
~/.claude/skills/dream/SKILL.md    <- /dream slash command
```

One file. Nothing else modified.

### Check what's installed

```bash
./install.sh --status
```

### Update after pulling new changes

```bash
./install.sh --update
```

### Uninstall

```bash
./uninstall.sh
```

## What's inside

```
claude-addons/
├── addons/
│   └── dream/
│       ├── CLAUDE.md                          # Enhanced memory extraction
│       └── skills/dream/SKILL.md             # /dream skill
├── demo/                                      # Demo assets
├── .claude/agents/setup.md                    # "set me up" agent
├── install.sh                                 # Installer (with --status, --update, --memory)
├── uninstall.sh                               # Uninstaller
├── test.sh                                    # Install/uninstall smoke tests
├── VERSION                                    # Semver version
├── LICENSE                                    # MIT license
├── CLAUDE.md
└── README.md
```

## Origin

The Dream workflow in this repo is described in and imported from [instructkr/claw-code](https://github.com/instructkr/claw-code).

**Dream** packages the Dream workflow as a manual `/dream` skill, plus optional `CLAUDE.md` instructions that make the main agent proactively extract memories inline.

## Requirements

- Claude Code 2.0+ (custom skills support)

## License

MIT
