---
phase: 05-research-integration
plan: 02
subsystem: commands
tags: [research-integration, explore, brain-researcher, background-research, exa-mcp]

# Dependency graph
requires:
  - phase: 05-research-integration
    provides: brain-researcher agent spec with query formulation and result format
  - phase: 03-dimension-exploration
    provides: explore.md command structure and brain-explorer agent spec
provides:
  - Research integration in explore.md (trigger detection, permission flow, spawning, polling, result re-integration)
  - Research awareness behavioral guidance in brain-explorer agent spec
  - "Dati e Ricerche" section in dimension artifact template
affects: [06-synthesis-handoff]

# Tech tracking
tech-stack:
  added: []
  patterns: [fire-and-forget-research, permission-once-then-autonomous, invisible-state-tracking, casual-result-integration]

key-files:
  created: []
  modified: [commands/brain/explore.md, agents/brain-explorer.md]

key-decisions:
  - "Research state tracking uses 5 invisible variables (RESEARCH_ENABLED, RESEARCH_COUNT, RESEARCH_REFUSED, PENDING_RESULTS, INTEGRATED_RESULTS)"
  - "Permission asked once -- subsequent research triggers are autonomous"
  - "Result polling uses Glob before every response; integration is casual 1-2 sentences"
  - "Dimension artifacts include 'Dati e Ricerche' section with source attribution"
  - "Task tool anti-pattern refined: conversation delegation banned, background research permitted"

patterns-established:
  - "Fire-and-forget research: spawn, notice briefly, continue immediately"
  - "Permission-once pattern: first trigger asks, rest are autonomous"
  - "Research result lifecycle: pending -> integrated -> dimension file"

requirements-completed: [RES-01, RES-02, RES-04]

# Metrics
duration: 3min
completed: 2026-03-08
---

# Phase 5 Plan 02: Research Integration in Explorer Summary

**Background research wired into explore.md: trigger detection, permission-once flow, fire-and-forget spawning via brain-researcher, Glob-based result polling, casual re-integration, and "Dati e Ricerche" dimension artifact section**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-08T15:04:40Z
- **Completed:** 2026-03-08T15:07:15Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added complete research integration to explore.md with state tracking, trigger detection, permission flow, researcher spawning, result polling, and session closure handling
- Added "Dati e Ricerche" section to dimension artifact template for persistent research data with source attribution
- Added Research Awareness behavioral guidance to brain-explorer.md with trigger heuristics and conversation handling rules
- Refined Task tool anti-pattern: conversation delegation remains banned, background research via brain-researcher is permitted

## Task Commits

Each task was committed atomically:

1. **Task 1: Add research integration to explore.md** - `9f73c7d` (feat)
2. **Task 2: Add research detection guidance to brain-explorer.md** - `c51754e` (feat)

## Files Created/Modified
- `commands/brain/explore.md` - Research Integration section (state, triggers, permission, spawning, polling), closure integration, dimension artifact "Dati e Ricerche" section, refined behavioral reinforcement rules
- `agents/brain-explorer.md` - Research Awareness section, over-triggering anti-pattern, factual claim self-check

## Decisions Made
- Research state uses 5 invisible variables tracked throughout the conversation (mirrors the invisible template tracking pattern from Phase 3)
- Permission-once pattern: first trigger asks user, subsequent triggers are autonomous (up to max 3)
- Result re-integration is casual and brief (1-2 sentences), never a data dump
- Task tool rule refined rather than replaced -- the original intent (no conversation delegation) is preserved while enabling background research

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Research integration is complete -- explore.md can detect claims, spawn brain-researcher, poll for results, and integrate them naturally
- All shortcut commands (product.md, tech.md, etc.) inherit changes automatically via delegation to explore.md
- Phase 6 (Synthesis) can reference INTEGRATED_RESULTS and "Dati e Ricerche" sections in dimension files

## Self-Check: PASSED

- FOUND: commands/brain/explore.md
- FOUND: agents/brain-explorer.md
- FOUND: 05-02-SUMMARY.md
- FOUND: 9f73c7d
- FOUND: c51754e

---
*Phase: 05-research-integration*
*Completed: 2026-03-08*
