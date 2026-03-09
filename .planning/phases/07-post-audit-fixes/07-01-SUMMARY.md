---
phase: 07-post-audit-fixes
plan: "01"
subsystem: install-and-commands
tags: [install, symlink, pipeline, explore, templates, frameworks]
requirements-completed: [INFRA-01, CORE-02]

dependency-graph:
  requires: []
  provides:
    - templates-symlink-on-install
    - correct-pipeline-entry-point-in-resume
    - read-tool-delegation-in-new
    - frameworks-md-loaded-at-runtime
  affects:
    - install.sh
    - commands/brain/resume.md
    - commands/brain/new.md
    - commands/brain/explore.md

tech-stack:
  added: []
  patterns:
    - Read-tool delegation for command handoff (RESUME_CMD pattern)
    - link_dir + manifest entry pattern for install symlinks

key-files:
  created: []
  modified:
    - install.sh
    - commands/brain/resume.md
    - commands/brain/new.md
    - commands/brain/explore.md

decisions:
  - install.sh: templates/ symlink placed after references block, before brain-suite directory manifest entry
  - new.md: RESUME_CMD Read-tool pattern adopted (consistent with all other command delegation patterns)
  - resume.md: /brain:analyze confirmed as pipeline entry point (aligns with 06-02 fix d359139)
  - explore.md: frameworks.md added as last entry in Step 3 load block

metrics:
  duration: 1min
  completed: "2026-03-09"
  tasks: 3
  files: 4
---

# Phase 07 Plan 01: Post-Audit Gap Closure Summary

**One-liner:** Closed all 4 v1.0 audit gaps — critical install bug (templates/ not symlinked), two stale pipeline references (resume.md + new.md), and tech debt (frameworks.md never loaded at runtime).

## What Was Built

Four targeted edits restore full E2E functionality after the v1.0 milestone audit:

1. **install.sh** — Added `link_dir` call and manifest entry for `templates/` directory symlink. Fresh install now creates `~/.claude/brain-suite/templates/` pointing to `$REPO_DIR/templates`, which `/brain:explore` requires for dimension templates. Uninstall is automatic via manifest loop.

2. **resume.md** — Replaced `/brain:synthesize` with `/brain:analyze` in the "all explored" completion suggestion (line 114 of the status display section). Aligns with the pipeline entry point fix already applied to status.md and explore.md in phase 06-02.

3. **new.md** — Replaced Skill tool invocation (`skill: "brain:resume"`) with standard Read-tool delegation pattern. Now uses `RESUME_CMD=$(echo $HOME/.claude/commands/brain/resume.md)` followed by a Read tool call, matching the delegation pattern used across all other Brain Suite commands.

4. **explore.md** — Added `Read $BRAIN_REF/frameworks.md` instruction at end of Step 3 (after `questioning.md`). Frameworks.md (134 lines: Lean Canvas, JTBD, Value Proposition Canvas) is now explicitly loaded at runtime during every dimension exploration session.

## Tasks Completed

| Task | Description | Commit | Files |
|------|-------------|--------|-------|
| 1 | Fix install.sh — add templates/ symlink | 1a73138 | install.sh |
| 2 | Fix resume.md + new.md — stale references | 221b27b | commands/brain/resume.md, commands/brain/new.md |
| 3 | Fix explore.md — load frameworks.md at runtime | 88a7f52 | commands/brain/explore.md |

## Verification Results

All 6 plan verification checks passed:

1. `bash -n install.sh` → exit 0
2. `grep "link_dir.*templates\|templates.*MANIFEST" install.sh` → 2 lines in correct order
3. `grep "brain:synthesize" resume.md | grep "all explored"` → no matches
4. `grep "Skill tool\|skill:" new.md` → no matches
5. `grep "RESUME_CMD" new.md` → 2 matches (path resolution + Read instruction)
6. `grep "frameworks.md" explore.md` → 1 match in Step 3

## Deviations from Plan

None - plan executed exactly as written.

## Audit Items Closed

| Audit Item | Severity | Status |
|------------|----------|--------|
| templates/ directory not symlinked on install | CRITICAL | Closed |
| resume.md suggests /brain:synthesize (should be /brain:analyze) | MEDIUM | Closed |
| new.md uses deprecated Skill tool for resume invocation | MINOR | Closed |
| frameworks.md never loaded at runtime in explore.md | MINOR | Closed |
| requirements-completed underscore vs hyphen (false positive) | — | Pre-satisfied (no change needed) |

## Self-Check: PASSED

- FOUND: .planning/phases/07-post-audit-fixes/07-01-SUMMARY.md
- FOUND: commit 1a73138 (install.sh templates symlink)
- FOUND: commit 221b27b (resume.md + new.md stale references)
- FOUND: commit 88a7f52 (explore.md frameworks.md runtime loading)
