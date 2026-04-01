# claude-addons

Features extracted from Claude Code's internal build, packaged for the public release.

| Addon | What it does | How to use |
|---|---|---|
| **Dream** | 4-phase memory consolidation + proactive memory extraction | `/dream` |
| **Verify** | Read-only verification agent that tries to break your code | `/verify` |

## Install

### Option A — Let Claude do it (recommended)

Open this repo in Claude Code and say:

```
> set me up
```

The built-in setup agent handles everything — copies the files to `~/.claude/`, verifies the install, and optionally enables enhanced memory extraction in a project of your choice.

### Option B — Shell script

```bash
git clone https://github.com/YOUR_USERNAME/claude-addons.git
cd claude-addons
./install.sh
```

### What gets installed

```
~/.claude/skills/dream/SKILL.md    <- /dream slash command
~/.claude/skills/verify/SKILL.md   <- /verify slash command
~/.claude/agents/verify.md         <- verification agent (natural language trigger)
```

Three files copied. Nothing else modified. Both addons are immediately available in every Claude Code session.

### Uninstall

```bash
./uninstall.sh
```

## Usage

### Dream — Memory Consolidation

Run `/dream` in any Claude Code session to consolidate your memories:

```
> /dream
```

The agent performs a 4-phase pass:
1. **Orient** — reads existing memory files and MEMORY.md index
2. **Gather** — scans for new signal from recent sessions and drifted facts
3. **Consolidate** — merges duplicates, updates stale entries, creates new memories
4. **Prune** — keeps the index under 200 lines, resolves contradictions

**For enhanced auto-extraction** (Claude proactively saves memories during normal work without being asked), append the dream CLAUDE.md to your project:

```bash
cat addons/dream/CLAUDE.md >> /path/to/your/project/CLAUDE.md
```

This makes Claude watch for and save:
- User corrections and confirmed approaches (feedback)
- Role, expertise, and preference signals (user)
- Project decisions, deadlines, and context (project)
- External system pointers like dashboards and trackers (reference)

### Verify — Verification Skill + Agent

After completing implementation work, run `/verify`:

```
> /verify
```

Or with context about what changed:

```
> /verify added user registration endpoint with email/password validation
```

You can also trigger it with natural language (uses the agent):

```
> verify the changes you just made
```

Either way, Claude:
1. Reads CLAUDE.md/README for build and test commands
2. Runs the build (broken build = automatic FAIL)
3. Runs the test suite and linters
4. Applies type-specific verification (11 strategies for different change types)
5. Runs adversarial probes (concurrency, boundary values, idempotency, orphan ops)
6. Returns `VERDICT: PASS`, `VERDICT: FAIL`, or `VERDICT: PARTIAL` with command-run evidence

The verification agent **cannot modify your project**. It can only read files and run commands. This is enforced by `disallowedTools` in the agent config.

#### Verification strategies

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

#### Anti-rationalization guards

The verify prompt teaches Claude to recognize and override its own excuses:
- "The code looks correct based on my reading" — reading is not verification. Run it.
- "The implementer's tests already pass" — the implementer is an LLM. Verify independently.
- "This is probably fine" — probably is not verified. Run it.
- "This would take too long" — not your call.

## What's inside

```
claude-addons/
├── .claude/agents/setup.md                    # "set me up" agent
├── install.sh                                 # Shell installer
├── uninstall.sh                               # Shell uninstaller
├── addons/
│   ├── dream/
│   │   ├── CLAUDE.md                          # Enhanced memory extraction
│   │   └── skills/dream/SKILL.md             # /dream skill
│   └── verify/
│       ├── skills/verify/SKILL.md            # /verify skill
│       └── agents/verify.md                  # Verification agent
├── CLAUDE.md
└── README.md
```

## Origin

These features exist in Claude Code's internal Anthropic build but are compiled out of the public npm release via build-time `feature()` flags.

**Dream** is based on the internal auto-dream system (`services/autoDream/`) which runs a forked subagent after every session to consolidate memories. The internal version triggers automatically; this version provides the same consolidation prompt as a manual `/dream` skill, plus CLAUDE.md instructions that make the main agent proactively extract memories inline.

**Verify** is based on the internal verification agent (`tools/AgentTool/built-in/verificationAgent.ts`) gated behind `feature('VERIFICATION_AGENT')`. The system prompt is reproduced verbatim. The `/verify` skill auto-detects what changed via `git diff` and runs the same verification inline. The agent definition enables natural language triggering ("verify the changes").

## Requirements

- Claude Code 2.0+ (tested on 2.1.x)
- Custom agents support (`~/.claude/agents/` directory)
- Custom skills support (`~/.claude/skills/` directory)

## License

MIT
