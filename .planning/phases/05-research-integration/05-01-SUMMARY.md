---
phase: 05-research-integration
plan: 01
subsystem: agents
tags: [exa-mcp, research, subagent, brain-researcher]

# Dependency graph
requires:
  - phase: 01-infrastructure-foundations
    provides: agent stubs and symlink infrastructure
provides:
  - Complete brain-researcher agent spec with Exa MCP query patterns and structured output format
affects: [05-research-integration, 06-synthesis-handoff]

# Tech tracking
tech-stack:
  added: [mcp__exa__web_search_exa, mcp__exa__get_code_context_exa]
  patterns: [non-conversational-background-agent, file-based-result-exchange, query-formulation-table]

key-files:
  created: []
  modified: [agents/brain-researcher.md]

key-decisions:
  - "Researcher uses 5-type query formulation table mapping claim types to Exa tool strategies"
  - "Result file uses 4-status model (found_data, no_relevant_data, partial_data, error) for explorer consumption"
  - "Agent writes only to .brainstorm/.research-pending/ with timestamp-based filenames"

patterns-established:
  - "Non-conversational agent spec: role, execution flow, output format, error handling, constraints"
  - "Query formulation table: claim type -> query strategy -> Exa tool mapping"

requirements-completed: [AGT-02, RES-03]

# Metrics
duration: 1min
completed: 2026-03-08
---

# Phase 5 Plan 01: Brain-Researcher Agent Spec Summary

**Complete brain-researcher agent spec with Exa MCP query formulation table, structured result format, and 4-status error handling**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-08T15:00:38Z
- **Completed:** 2026-03-08T15:01:33Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Replaced 12-line stub with complete 85-line agent spec defining a non-conversational background worker
- Defined query formulation table mapping 5 claim types (market, competitor, tech, user, pricing) to Exa MCP query strategies
- Established structured result file format with 4 status types and source attribution pattern

## Task Commits

Each task was committed atomically:

1. **Task 1: Write complete brain-researcher agent spec** - `c882dd6` (feat)

## Files Created/Modified
- `agents/brain-researcher.md` - Complete agent spec: role, execution flow, query formulation, result format, error handling, constraints

## Decisions Made
- Query formulation table uses 5 claim types with specific Exa tool recommendations per type
- Result file format uses 4-status model so the explorer can handle all outcomes uniformly
- Agent writes exclusively to `.brainstorm/.research-pending/` to maintain clean separation from session artifacts

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- brain-researcher.md is complete and ready for Plan 02 to wire up spawning from explore.md
- The result file format contract is established: explorer knows what to expect in `.brainstorm/.research-pending/`
- Error handling covers all edge cases including Exa MCP unavailability

## Self-Check: PASSED

- FOUND: agents/brain-researcher.md
- FOUND: 05-01-SUMMARY.md
- FOUND: c882dd6

---
*Phase: 05-research-integration*
*Completed: 2026-03-08*
