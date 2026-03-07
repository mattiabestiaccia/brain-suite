---
phase: 04-session-management
plan: 02
subsystem: commands
tags: [markdown-as-prompt, re-exploration, deepen-restart, custom-dimensions, next-dimension-suggestion]

# Dependency graph
requires:
  - phase: 03-dimension-exploration
    provides: "/brain:explore command (312 lines) with exploration lifecycle and artifact generation"
  - phase: 01-infrastructure-foundations
    provides: "dimension templates, reference files, dimensions-guide.md"
provides:
  - "Re-exploration flow in /brain:explore: deepen (load previous, invisible tracking, merged output) or restart (archive + fresh start)"
  - "Custom dimension support in /brain:explore: two-step validation against SESSION.md, template loading from .brainstorm/templates/"
  - "Enhanced next-dimension suggestion at closure: conversation signals > dimension relationships > gap filling"
  - "All-explored detection with /brain:synthesize suggestion"
affects: [04-03-resume, 05-research-integration, 06-synthesis-generation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Two-step dimension validation: hardcoded built-ins + dynamic SESSION.md lookup"
    - "IS_CUSTOM flag for template path branching (reference vs session templates)"
    - "Deepen mode: invisible tracking of thin sections from previous exploration"
    - "Archive pattern for dimension files: .brainstorm/dimensions/archive/<dim>-<timestamp>.md"
    - "Systematic suggestion priority: conversation > relationships > gaps"

key-files:
  created: []
  modified:
    - "commands/brain/explore.md"

key-decisions:
  - "Custom dimensions default to socratic mode (most versatile for open-ended exploration)"
  - "Deepen mode uses same invisible tracking principle from Phase 3 -- never reveals which sections are thin"
  - "Archive path for dimensions is .brainstorm/dimensions/archive/ (separate from /brain:new archives in .brainstorm/archive/)"
  - "Next-dimension suggestion checks for all-explored state and suggests /brain:synthesize as placeholder"
  - "Custom dimension shortcuts not supported -- only /brain:explore <slug> works for custom dimensions"

patterns-established:
  - "Two-step validation pattern: hardcoded list + dynamic registry fallback"
  - "IS_CUSTOM flag pattern for branching behavior based on dimension type"
  - "Priority-based suggestion: strongest signal > structural relationships > simple gaps"

requirements-completed: [SESS-03, DIM-05]

# Metrics
duration: 4min
completed: 2026-03-07
---

# Phase 4 Plan 02: Re-exploration + Custom Dimensions + Enhanced Suggestions Summary

**Deepen/restart re-exploration flow, custom dimension validation via SESSION.md, and systematic next-dimension suggestion in explore.md (351 lines)**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-07T17:52:18Z
- **Completed:** 2026-03-07T17:56:21Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Replaced the Phase 4 placeholder in explore.md Step 6 with full deepen/restart re-exploration flow including archive pattern
- Extended dimension validation to accept custom dimensions registered in SESSION.md with correct template path branching
- Enhanced closure suggestion to be systematic: conversation signals > dimension relationships > gap filling, with all-explored detection

## Task Commits

Each task was committed atomically:

1. **Task 1: Modify explore.md with re-exploration, custom dimensions, and enhanced suggestions** - `25ee177` (feat)

**Plan metadata:** (see final commit below)

## Files Created/Modified

- `commands/brain/explore.md` - Updated from 312 to 351 lines. Changes: (1) Step 2 now performs two-step validation -- checks built-in list first, then SESSION.md for custom dimensions, sets IS_CUSTOM flag; (2) Step 3 loads templates from .brainstorm/templates/ for custom dimensions; (3) Step 6 replaced with full deepen/restart flow -- deepen loads previous file with invisible tracking, restart archives to dimensions/archive/; (4) Opening section adds socratic default for custom dimensions; (5) Closure Step 5 enhanced with systematic suggestion priority, SESSION.md gap check, and all-explored detection.

## Decisions Made

- **Socratic default for custom dimensions:** Custom dimensions are inherently open-ended, so socratic mode (build on answers, lead toward gaps) is the most versatile default.
- **Separate archive paths:** Dimension archives go to `.brainstorm/dimensions/archive/` (not `.brainstorm/archive/` which is for `/brain:new` session archives) to avoid confusion between the two archive types.
- **IS_CUSTOM flag over separate validation logic:** A single internal flag tracks the dimension type, keeping the branching logic clean in subsequent steps (template loading, mode defaults).

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- explore.md is ready for custom dimensions created by /brain:add-dimension (Plan 04-01)
- Re-exploration flow is complete for both deepen and restart paths
- Enhanced suggestion system works with both built-in and custom dimensions
- Phase 5 (Research) and Phase 6 (Synthesis) can reference the re-exploration pattern

## Self-Check: PASSED

- FOUND: commands/brain/explore.md
- FOUND: 04-02-SUMMARY.md
- FOUND: 25ee177

---
*Phase: 04-session-management*
*Completed: 2026-03-07*
