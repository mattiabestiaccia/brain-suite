# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — Brain Suite MVP

**Shipped:** 2026-03-09
**Phases:** 7 | **Plans:** 14 | **Sessions:** ~10 (estimated)

### What Was Built
- Complete Claude Code slash-command framework for structured brainstorming (13 commands, 3 agents)
- Voice-first interactive exploration across 6 built-in dimensions with multiple questioning modes
- Session persistence across Claude Code restarts (IDEA.md + SESSION.md + dimension artifacts)
- brain-researcher agent with Exa MCP for real-time factual data injection during exploration
- Cross-dimensional synthesis pipeline (analyze → synthesize → handoff) producing GSD-ready HANDOFF.md
- Symlink-based install/uninstall system with collision detection and manifest tracking

### What Worked
- **Markdown-as-prompt pattern**: Commands defined as markdown files work reliably; no code execution needed for v1
- **Reference file centralization**: voice-interaction.md, questioning.md, frameworks.md reused across all commands — single source of truth
- **Phase-based audit cycle**: Running `/gsd:audit-milestone` before marking complete surfaced a critical install bug (templates/ not symlinked) before user harm
- **Thin delegation pattern**: Shortcut commands delegating to explore.md via Read tool is clean and DRY
- **GSD pipeline discipline**: discuss → plan → verify cycle kept scope tight; no scope creep across 7 phases

### What Was Inefficient
- **Missing templates/ symlink discovered only at audit**: install.sh was built in Phase 1 and the gap wasn't caught until audit — earlier E2E testing of install would have caught this
- **Phase 7 was entirely preventable**: The post-audit fixes phase added a full extra cycle; better install validation in Phase 1 acceptance criteria would have prevented it
- **Summary-extract CLI incompatibility**: gsd-tools summary-extract didn't work with the frontmatter format in these SUMMARY.md files — required manual accomplishment extraction

### Patterns Established
- **RESUME_CMD Read-tool pattern**: Command delegation via `RESUME_CMD=$(echo $HOME/.claude/commands/brain/resume.md)` + Read instruction — consistent across all Brain Suite commands
- **Manifest-based symlink management**: link_dir + MANIFEST file tracks all symlinks for clean uninstall — carry to v1.5 install work
- **Runtime reference loading**: Reference files loaded at start of each command execution, not embedded inline — keeps commands lean and references updatable without reinstall

### Key Lessons
1. **Test E2E install in Phase 1 acceptance criteria**: The install script is foundational — any gap found later requires an extra phase to fix. Include `bash -n install.sh && test -L ~/.claude/brain-suite/templates` as explicit Phase 1 verification
2. **Audit before milestone completion, not after**: The audit → gap phase cycle added overhead; build E2E smoke tests into phase verification instead
3. **Markdown-as-prompt scales well for config-only v1**: Zero code, zero dependencies, ships in days — valid architecture for Claude Code tooling at this scale
4. **Voice-first constraint as design forcing function**: The constraint "one question at a time, short responses" improved overall UX beyond just voice users — apply to future conversational commands

### Cost Observations
- Model mix: ~100% Sonnet 4.6 (quality profile throughout)
- Sessions: ~10 estimated
- Notable: 7 phases, 14 plans, 90 files, ~15,400 lines in 5 calendar days — markdown-as-prompt enabled very fast iteration

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 7 | 14 | Initial milestone — GSD pipeline applied to Claude Code tooling |

### Cumulative Quality

| Milestone | Audit Score | Gaps Found | Gaps Closed |
|-----------|-------------|------------|-------------|
| v1.0 | 33+26+3/35+28+4 | 4 | 4 (Phase 7) |

### Top Lessons (Verified Across Milestones)

1. E2E install verification should be a first-class acceptance criterion in infrastructure phases
2. Markdown-as-prompt is a valid and fast architecture for Claude Code command tooling
