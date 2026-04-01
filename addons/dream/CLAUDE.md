# Memory Consolidation — Enhanced Auto-Memory Behavior

This CLAUDE.md supplements the built-in auto memory system with stronger extraction behavior and a manual `/dream` consolidation skill.

## Proactive memory extraction

After completing a significant piece of work (multi-turn task, debugging session, code review, or any interaction longer than 3-4 turns), you should proactively check whether anything from the conversation is worth saving to memory. Do NOT wait for the user to ask you to remember — detect and save automatically.

### What to watch for and save immediately

**User corrections (feedback type):**
Any time the user says "no", "don't", "stop doing X", "not like that", "actually...", or otherwise redirects your approach — save it. Also watch for quieter confirmations: "yes exactly", "perfect", accepting an unusual choice without pushback. These are validated approaches worth recording.

Structure: rule itself, then **Why:** (the reason), then **How to apply:** (when this kicks in).

**User identity signals (user type):**
Role mentions ("I'm a data scientist"), expertise signals ("I've been writing Go for ten years"), preference expressions ("I prefer functional style"), responsibility signals ("I own the auth service"). Save these the moment you detect them.

**Project context (project type):**
Decisions ("we're going with PostgreSQL"), deadlines ("freeze merges after Thursday"), incidents ("the deploy broke because..."), stakeholder context ("legal flagged the token storage"). Always convert relative dates to absolute dates.

**External system pointers (reference type):**
Dashboard URLs, issue tracker projects, Slack channels, documentation links, API endpoints. Save these the moment they're mentioned.

### What NOT to save (strict exclusions)

- Code patterns, architecture, file paths, project structure — derivable from `grep`/`git`/reading code
- Git history or who-changed-what — `git log` / `git blame` are authoritative
- Debugging solutions — the fix is in the code; context is in the commit message
- Anything already in CLAUDE.md files
- Ephemeral task state, in-progress work, current conversation context
- PR lists or activity summaries — save only what was *surprising* or *non-obvious*

### How to save

1. Write each memory to its own file (e.g., `user_role.md`, `feedback_testing.md`) using this format:

```markdown
---
name: {{memory name}}
description: {{one-line description — be specific, this is used for future relevance matching}}
type: {{user, feedback, project, reference}}
---

{{content — for feedback/project types: rule/fact, then **Why:** and **How to apply:** lines}}
```

2. Add a pointer to `MEMORY.md` — one line under ~150 characters: `- [Title](file.md) — one-line hook`

### Memory quality rules

- Check existing memories BEFORE writing — update an existing file rather than creating a duplicate
- Keep `MEMORY.md` under 200 lines. It's an index, not a dump.
- Organize semantically by topic, not chronologically
- Delete contradicted facts at the source
- Convert all relative dates to absolute dates
- For feedback memories: always include **Why** (the reason behind the preference) — this lets you judge edge cases instead of blindly following rules

## Before recommending from memory

A memory that names a specific function, file, or flag is a claim that it existed *when the memory was written*. It may have been renamed, removed, or never merged. Before recommending it:

- If the memory names a file path: check the file exists.
- If the memory names a function or flag: grep for it.
- If the user is about to act on your recommendation (not just asking about history), verify first.

"The memory says X exists" is not the same as "X exists now."

A memory that summarizes repo state (activity logs, architecture snapshots) is frozen in time. If the user asks about *recent* or *current* state, prefer `git log` or reading the code over recalling the snapshot.

Memory records can become stale over time. Use memory as context for what was true at a given point in time. Before answering the user or building assumptions based solely on information in memory records, verify that the memory is still correct and up-to-date by reading the current state of the files or resources. If a recalled memory conflicts with current information, trust what you observe now — and update or remove the stale memory rather than acting on it.

## Manual consolidation

Run `/dream` to trigger a full 4-phase memory consolidation:
1. **Orient** — read existing memories and index
2. **Gather** — scan for new signal from recent sessions and drifted facts
3. **Consolidate** — merge, update, create memory files
4. **Prune** — clean up the index, remove stale entries, resolve contradictions

Run this periodically (every few days, or after a burst of intensive work) to keep memories well-organized and deduplicated.
