# claude-addons

Power-ups for Claude Code — extracted from the internal Anthropic build.

```bash
git clone https://github.com/sathwickp/claude-addons.git && cd claude-addons && ./install.sh
```

Or open the repo in Claude Code and say `set me up`.

![demo](demo/claude-addons.gif)

---

| Addon | What it does | Command |
|---|---|---|
| **Dream** | 4-phase memory consolidation + proactive memory extraction | `/dream` |
| **Verify** | Read-only agent that tries to break your code before you ship it | `/verify` |

## What it looks like

### `/dream` — Memory Consolidation

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

Claude reviews your recent sessions and distills them into durable, well-organized memories. Future sessions orient instantly — Claude knows your preferences, your project context, and what you've told it before.

**What gets remembered:**
- Your corrections and confirmed approaches (so you never repeat yourself)
- Role, expertise, and preference signals
- Project decisions, deadlines, and context
- External system pointers (dashboards, trackers, docs)

**What doesn't:**
- Code patterns, architecture, file paths (derivable from the code)
- Git history (that's what `git log` is for)
- Debugging solutions (the fix is in the code)

### `/verify` — Verification Agent

<details>
<summary>Example output</summary>

```
> /verify added user registration endpoint with email validation

### Check: Build
**Command run:** npm run build
**Output:** Build succeeded (2.1s)
**Result: PASS**

### Check: Test suite
**Command run:** npm test
**Output:** 47 tests passed, 0 failed
**Result: PASS**

### Check: POST /api/register — valid input
**Command run:** curl -s -X POST localhost:3000/api/register -H 'Content-Type: application/json' -d '{"email":"test@example.com","password":"Str0ng!Pass"}'
**Output:** {"id":"usr_abc123","email":"test@example.com"} (201)
**Result: PASS**

### Check: POST /api/register — duplicate email
**Command run:** curl -s -X POST localhost:3000/api/register -H 'Content-Type: application/json' -d '{"email":"test@example.com","password":"Str0ng!Pass"}'
**Output:** {"error":"Email already registered"} (409)
**Result: PASS**

### Check: POST /api/register — weak password
**Command run:** curl -s -X POST localhost:3000/api/register -H 'Content-Type: application/json' -d '{"email":"new@example.com","password":"123"}'
**Output:** {"error":"Password must be at least 8 characters"} (400)
**Result: PASS**

### Check: Adversarial — concurrent duplicate registration
**Command run:** for i in {1..5}; do curl -s -X POST localhost:3000/api/register ... &; done; wait
**Output:** 1 success (201), 4 conflicts (409) — no duplicate rows created
**Result: PASS**

VERDICT: PASS
```

</details>

After you implement something, `/verify` tries to break it. It can't modify your code (enforced via `disallowedTools`) — it can only read files and run commands. Every check shows the exact command run and its output. No hand-waving.

**What it checks:**
1. Build passes
2. Test suite passes
3. Linters and type-checkers pass
4. Type-specific verification (10 strategies — see below)
5. Adversarial probes (concurrency, boundary values, idempotency)

**Anti-rationalization guards** teach Claude to recognize its own excuses:
- *"The code looks correct based on my reading"* — reading is not verification. Run it.
- *"The implementer's tests already pass"* — the implementer is an LLM. Verify independently.
- *"This is probably fine"* — probably is not verified. Run it.

<details>
<summary>Verification strategies by change type</summary>

| Change type | Strategy |
|---|---|
| Frontend | Dev server + browser automation + curl subresources + frontend tests |
| Backend/API | Start server + curl endpoints + verify response shapes + error handling |
| CLI/scripts | Run with inputs + edge cases + verify help output |
| Infrastructure | Syntax validation + dry-run + env var reference check |
| Library/package | Build + test suite + exercise public API as consumer |
| Bug fixes | Reproduce bug + verify fix + regression tests + side effects |
| Mobile | Clean build + simulator + UI tree dump + persistence + crash logs |
| Data/ML | Sample input + output schema + empty/NaN handling + row count |
| DB migrations | Up + verify schema + down (reversibility) + existing data |
| Refactoring | Existing tests unchanged + public API surface diff + behavior check |

</details>

## Install

### Quick install

```bash
git clone https://github.com/sathwickp/claude-addons.git
cd claude-addons
./install.sh
```

### Remote install (no clone needed)

```bash
curl -fsSL https://raw.githubusercontent.com/sathwickp/claude-addons/main/install.sh | bash
```

### Selective install

```bash
./install.sh dream       # just /dream
./install.sh verify      # just /verify
```

### What gets installed

```
~/.claude/skills/dream/SKILL.md    <- /dream slash command
~/.claude/skills/verify/SKILL.md   <- /verify slash command
~/.claude/agents/verify.md         <- verification agent (natural language trigger)
```

Three files. Nothing else modified.

### Enable enhanced memory extraction

For Claude to proactively save memories during normal work (not just during `/dream`), append the memory instructions to a project:

```bash
./install.sh --memory /path/to/your/project
```

Or globally:

```bash
./install.sh --memory ~/.claude
```

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
│   ├── dream/
│   │   ├── CLAUDE.md                          # Enhanced memory extraction
│   │   └── skills/dream/SKILL.md             # /dream skill
│   └── verify/
│       ├── skills/verify/SKILL.md            # /verify skill
│       └── agents/verify.md                  # Verification agent
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

The Dream and Verify workflows in this repo are described in and imported from [instructkr/claw-code](https://github.com/instructkr/claw-code).

**Dream** packages the Dream workflow as a manual `/dream` skill, plus optional `CLAUDE.md` instructions that make the main agent proactively extract memories inline.

**Verify** packages the Verify workflow as a `/verify` skill and a `verification` agent. The `/verify` skill auto-detects what changed via `git diff` and runs the same verification inline.

## Requirements

- Claude Code 2.0+ (custom agents and skills support)

## License

MIT
