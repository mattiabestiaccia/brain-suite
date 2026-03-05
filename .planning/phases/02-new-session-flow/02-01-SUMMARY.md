---
phase: 02-new-session-flow
plan: 01
subsystem: commands
tags: [slash-command, socratic, brainstorming, voice-first, interactive, markdown-prompt]

# Dependency graph
requires:
  - phase: 01-infrastructure-foundations
    provides: "Reference files (voice-interaction.md, questioning.md, dimensions-guide.md), install scripts, repo structure"
provides:
  - "Complete /brain:new command prompt with full behavioral instructions for interactive brainstorming"
  - "Session initialization flow (existing session detection, archival, fresh start)"
  - "Artifact generation spec (IDEA.md with emergent structure, SESSION.md with dimension tracking)"
affects: [02-new-session-flow, 03-dimension-exploration, 04-session-management]

# Tech tracking
tech-stack:
  added: []
  patterns: [markdown-as-prompt, runtime-reference-loading, invisible-coverage-tracking, recap-confirm-save]

key-files:
  created:
    - commands/brain/new.md
  modified: []

key-decisions:
  - "Runtime reference loading via Read tool with resolved $HOME path instead of @ file references (symlink compatibility)"
  - "Invisible coverage tracking: 3 core points (problem, audience, solution) tracked internally without revealing to user"
  - "Emergent structure for IDEA.md: sections reflect conversation content, not a fixed template"
  - "Dimensions-guide.md loaded only at closure time to save context window budget"
  - "Auto-invoke /brain:resume instead of suggesting it when user chooses to continue existing session"

patterns-established:
  - "Markdown-as-prompt: entire command file is a behavioral prompt for Claude, not executable code"
  - "Recap-confirm-save flow: show recap, user confirms/corrects, then save artifacts"
  - "Voice-first conversation rules: under 8 lines, one question, expand short answers"

requirements-completed: [CORE-01, CORE-07, SESS-01]

# Metrics
duration: 8min
completed: 2026-03-05
---

# Phase 2 Plan 01: Complete /brain:new Command Summary

**Interactive Socratic brainstorming command with voice-first patterns, invisible coverage tracking, and emergent-structure artifact generation (IDEA.md + SESSION.md)**

## Performance

- **Duration:** ~8 min (across checkpoint)
- **Started:** 2026-03-05
- **Completed:** 2026-03-05
- **Tasks:** 2 (1 auto + 1 human-verify checkpoint)
- **Files modified:** 1

## Accomplishments
- Replaced 2-line stub with 299-line comprehensive command prompt covering the full interactive brainstorming flow
- Implemented voice-first conversation patterns: short responses, one question per turn, informal tone tolerance
- Designed invisible coverage tracking for 3 core points (problem, target audience, rough solution)
- Specified emergent-structure artifact generation (IDEA.md reflects actual conversation, not a rigid template)
- Built session lifecycle: existing session detection, archival to timestamped directory, fresh start flow
- Added behavioral reinforcement section at end of file for LLM recency bias

## Task Commits

Each task was committed atomically:

1. **Task 1: Write complete /brain:new command file** - `39b6fc0` (feat)
2. **Task 2: Verify /brain:new interactive behavior** - checkpoint:human-verify, approved by user

**Plan metadata:** TBD (this commit)

## Files Created/Modified
- `commands/brain/new.md` - Complete /brain:new command prompt (299 lines) replacing the 2-line stub. Contains all behavioral instructions for interactive Socratic brainstorming, session management, artifact generation, and next-dimension suggestion.

## Decisions Made
- **Runtime reference loading via Read tool**: Used `Bash` to resolve `$HOME` path then `Read` tool for reference files, avoiding hardcoded `@` paths that break with symlinks
- **Invisible coverage tracking**: 3 core points tracked observationally ("note when these emerge") rather than steered ("ask about X next")
- **Emergent IDEA.md structure**: Sections reflect what was discussed, with barely-touched topics relegated to "Seeds/Open Questions" section
- **Delayed dimensions-guide.md loading**: Only loaded at closure time for dimension suggestion, saving context window during conversation
- **Auto-invoke /brain:resume**: When user chooses to continue existing session, Claude auto-invokes `/brain:resume` instead of just suggesting it (orchestrator fix post-Task 1)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Auto-invoke /brain:resume instead of suggesting it**
- **Found during:** Post-Task 1 orchestrator review
- **Issue:** Original implementation told user to "use /brain:resume instead" but didn't invoke it automatically
- **Fix:** Changed to auto-invoke `/brain:resume` command directly when user chooses to continue
- **Files modified:** commands/brain/new.md
- **Verification:** Reviewed updated file content
- **Committed in:** separate commit by orchestrator (after 39b6fc0)

---

**Total deviations:** 1 auto-fixed (1 bug fix)
**Impact on plan:** Minor UX improvement. No scope creep.

## Issues Encountered
None - plan executed cleanly.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `/brain:new` command is fully functional and verified by user
- Ready for Plan 02-02 (brain-explorer agent behavioral specification)
- IDEA.md and SESSION.md format established, consumable by Phase 3 (/brain:explore) and Phase 4 (/brain:resume, /brain:status)
- Voice-first patterns validated in live testing

## Self-Check: PASSED

- [x] commands/brain/new.md exists (299 lines)
- [x] 02-01-SUMMARY.md exists
- [x] Commit 39b6fc0 exists in git history

---
*Phase: 02-new-session-flow*
*Completed: 2026-03-05*
