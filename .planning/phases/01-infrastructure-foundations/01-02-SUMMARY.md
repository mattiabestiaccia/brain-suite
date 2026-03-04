---
phase: 01-infrastructure-foundations
plan: 02
subsystem: infra
tags: [bash, install-scripts, symlinks, manifest, documentation]

# Dependency graph
requires:
  - phase: 01-01
    provides: 26 source files (13 commands, 3 agents, 4 references, 6 templates) for symlink targets
provides:
  - install.sh with symlink-based installation, collision detection, and manifest
  - uninstall.sh with manifest-based safe removal
  - README.md with installation, usage, and full command reference
  - ~/.claude/.brain-suite-manifest tracking all installed symlinks
affects: [02-new-session-flow, user-onboarding]

# Tech tracking
tech-stack:
  added: []
  patterns: [manifest-based-install, collision-detection, idempotent-symlinks, ln-sfn-for-directories]

key-files:
  created:
    - install.sh
    - uninstall.sh
    - README.md
  modified: []

key-decisions:
  - "Manifest is plain text (one absolute path per line), not JSON -- simplest format for bash read/write"
  - "ln -sfn used for directory symlinks (not ln -sf) to avoid nested symlink creation on re-run"
  - "Collision detection checks readlink target prefix to distinguish Brain Suite symlinks from user files"

patterns-established:
  - "Manifest pattern: install writes all created paths to ~/.claude/.brain-suite-manifest, uninstall reads it for precise removal"
  - "Collision detection: if target exists and readlink does not start with REPO_DIR, skip with warning"
  - "Idempotent install: truncate manifest on each run, update existing symlinks silently"

requirements-completed: [INFRA-01, INFRA-02, INFRA-03, INFRA-04, INFRA-05]

# Metrics
duration: 3min
completed: 2026-03-04
---

# Phase 1 Plan 02: Install Scripts & README Summary

**Symlink-based install/uninstall scripts with manifest tracking, collision detection, and idempotent behavior, plus comprehensive README documentation**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-04T16:02:56Z
- **Completed:** 2026-03-04T16:06:03Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Created install.sh that symlinks commands/brain/, 3 agent files, and brain-suite/references/ with manifest tracking and collision detection
- Created uninstall.sh that reads manifest for precise removal, leaving GSD and other extensions untouched
- Created README.md with installation instructions, 13-command reference table, exploration modes, session artifacts documentation

## Task Commits

Each task was committed atomically:

1. **Task 1: Create install.sh with symlinks, collision detection, and manifest** - `b8f50bf` (feat)
2. **Task 2: Create uninstall.sh with manifest-based safe removal** - `0960efd` (feat)
3. **Task 3: Create README.md with installation, usage, and command reference** - `5aa4150` (feat)

## Files Created/Modified
- `install.sh` - Symlink-based installer: creates commands/brain/, agent symlinks, brain-suite/references/, writes manifest, handles collisions
- `uninstall.sh` - Manifest-based uninstaller: reads manifest, removes exactly those entries, handles missing-manifest gracefully
- `README.md` - Project documentation: installation, quick start, 13-command reference table, exploration modes, session artifacts, requirements

## Decisions Made
- Manifest uses plain text format (one absolute path per line) for simplest bash read/write
- `ln -sfn` used for directory symlinks instead of `ln -sf` to prevent nested symlink bug on re-run
- Collision detection distinguishes Brain Suite symlinks by checking if readlink target starts with REPO_DIR

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 1 complete: all 26 source files exist and are installable via `./install.sh`
- Users can now `git clone` + `./install.sh` for full Brain Suite availability in Claude Code
- Ready for Phase 2: `/brain:new` session flow implementation

## Self-Check: PASSED

All 3 created files verified on disk. All 3 task commits (b8f50bf, 0960efd, 5aa4150) verified in git log.

---
*Phase: 01-infrastructure-foundations*
*Completed: 2026-03-04*
