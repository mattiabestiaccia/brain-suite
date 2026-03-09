# Phase 7: Post-Audit Fixes - Research

**Researched:** 2026-03-09
**Domain:** Shell scripting (install/uninstall), Claude Code command patterns, YAML frontmatter
**Confidence:** HIGH

## Summary

Phase 7 closes gaps identified by the v1.0 milestone audit (`v1.0-MILESTONE-AUDIT.md`). The work is purely corrective -- no new features, no new libraries, no architectural changes. All fixes are well-scoped edits to existing files with clear before/after states.

The critical fix is `install.sh` missing the `templates/` symlink, which breaks the entire E2E flow on fresh installs. The remaining items are stale reference cleanup (resume.md pointing to wrong command), a non-standard delegation pattern in new.md, and a minor tech debt item around `frameworks.md` being installed but never loaded at runtime.

**Primary recommendation:** Fix install.sh first (it unblocks the E2E flow), then sweep the remaining items in order of severity. All fixes are independent and can be parallelized.

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFRA-01 | `install.sh` creates symlinks from `~/.claude/` to repo files (commands, agents, brainstorm framework) | Finding 1: install.sh missing `templates/` symlink. Fix is adding 2 lines (link_dir + manifest entry) following the existing `references/` pattern at lines 127-130. uninstall.sh needs no change -- manifest-based removal handles new entries automatically. |
| CORE-02 | User can explore any dimension interactively via `/brain:explore <dimension>` with guided Socratic dialogue | Finding 1: explore.md resolves templates via `$HOME/.claude/brain-suite/templates` which does not exist post-install. Once install.sh symlinks `templates/`, this requirement is fully satisfied. No changes needed in explore.md itself. |

</phase_requirements>

## Standard Stack

Not applicable -- this phase modifies existing bash scripts and markdown command files. No new libraries, tools, or dependencies are introduced.

## Architecture Patterns

### Pattern 1: Symlink Creation in install.sh

**What:** The install.sh script uses two helpers: `link_file` for individual files and `link_dir` for directories. Directories use `ln -sfn` to avoid nested symlink bugs on re-runs. Each created symlink path is appended to the manifest file.

**Current state:** install.sh creates symlinks for:
- `commands/brain/` (directory, via `link_dir`)
- `agents/brain-*.md` (individual files, via `link_file`)
- `references/` (directory, via `link_dir`, under `brain-suite/`)

**What's missing:** `templates/` directory is not symlinked. The pattern to add is identical to the `references/` block (lines 127-130):
```bash
# references pattern (existing, lines 127-130):
link_dir "$REPO_DIR/references" "$HOME/.claude/brain-suite/references" "brain-suite/references/"
echo "$HOME/.claude/brain-suite/references" >> "$MANIFEST"

# templates pattern (to add, same structure):
link_dir "$REPO_DIR/templates" "$HOME/.claude/brain-suite/templates" "brain-suite/templates/"
echo "$HOME/.claude/brain-suite/templates" >> "$MANIFEST"
```

**Confidence:** HIGH -- direct inspection of install.sh confirmed the gap and the exact insertion point.

### Pattern 2: Read-Tool Delegation (Standard Command Pattern)

**What:** Shortcut commands (product.md, tech.md, etc.) and the resume hub delegate to explore.md by resolving its path via Bash, reading the file via Read tool, then executing its instructions. This is the established delegation pattern used across all 6 shortcuts and resume.md's explore actions.

**Current violation in new.md (line 53):**
```
Invoke `/brain:resume` automatically using the Skill tool: `skill: "brain:resume"`.
```

**Standard pattern (from product.md, lines 7-15):**
```
1. Resolve the explore command path:
   EXPLORE_CMD=$(echo $HOME/.claude/commands/brain/explore.md)
2. Read the explore command file:
   Read `$EXPLORE_CMD` for the complete exploration instructions.
3. Execute ALL instructions from the explore command with dimension set to **product**.
```

**Fix:** Replace the Skill tool invocation in new.md with the Read-tool delegation pattern, resolving the resume command path and reading its instructions.

**Confidence:** HIGH -- direct comparison of 7+ command files confirms the standard pattern.

### Pattern 3: Manifest-Based Uninstall

**What:** `uninstall.sh` reads `~/.claude/.brain-suite-manifest` and removes each listed path. It does NOT hardcode what to remove -- it trusts the manifest. This means adding the `templates/` symlink to the manifest (during install) is sufficient. No changes are needed in `uninstall.sh` itself.

**Confidence:** HIGH -- confirmed by reading uninstall.sh lines 49-70 (while-read loop over manifest).

### Anti-Patterns to Avoid

- **Editing uninstall.sh to hardcode templates removal:** Unnecessary. The manifest pattern handles it. Adding templates to uninstall.sh would bypass the architectural pattern.
- **Changing explore.md's template path resolution:** The path `$HOME/.claude/brain-suite/templates` is correct. The bug is in install.sh not creating the symlink, not in explore.md resolving the wrong path.

## Don't Hand-Roll

Not applicable -- all fixes are edits to existing files, no new functionality to build.

## Common Pitfalls

### Pitfall 1: Inserting templates symlink in wrong position in install.sh

**What goes wrong:** Placing the templates symlink before the `mkdir -p "$HOME/.claude/brain-suite"` line (line 127) would fail because the parent directory doesn't exist yet.
**Why it happens:** install.sh creates the `brain-suite/` directory as part of the references block. The templates block must come after this mkdir.
**How to avoid:** Insert the templates symlink block AFTER the references block (after line 130), before the `brain-suite` directory entry is written to the manifest (line 131). The `$HOME/.claude/brain-suite` directory already exists at that point.
**Warning signs:** `mkdir -p` at line 127 creates `brain-suite/`. Inserting templates before line 127 = parent directory missing.

### Pitfall 2: Not adding templates path to manifest

**What goes wrong:** install.sh creates the symlink but doesn't record it in the manifest. On uninstall, the templates symlink is orphaned.
**Why it happens:** Forgetting the `echo ... >> "$MANIFEST"` line that follows every link operation.
**How to avoid:** Follow the exact same 2-line pattern: `link_dir` + `echo >> "$MANIFEST"`.

### Pitfall 3: Confusing requirements-completed with requirements_completed

**What goes wrong:** The audit reports SUMMARY.md files "lack `requirements_completed` frontmatter field" but all 13 SUMMARY files already have `requirements-completed` (with hyphens, YAML convention).
**Why it happens:** The audit used underscore notation; the actual files use hyphen notation. This is a false positive.
**How to avoid:** Verify the actual field names in SUMMARY.md frontmatter before making changes. All 13 files already have the field populated correctly.
**Evidence:** Grep for `requirements-completed` across `.planning/phases/` returns matches in all 13 SUMMARY.md files. The audit's claim of "0/13 have `requirements_completed`" was a string-matching error (searched for underscores, files use hyphens).

### Pitfall 4: Removing frameworks.md from install without checking agent references

**What goes wrong:** Removing frameworks.md from the installed references might break future agent behavior if the brain-explorer was designed to load it.
**Why it happens:** The audit flags frameworks.md as "never loaded at runtime" -- which is technically correct (no command or agent explicitly reads it). However, frameworks.md IS referenced as a "reference file for the brain-explorer agent" (line 1 of frameworks.md) and was designed as conceptual background for the agent's behavior.
**How to avoid:** The correct fix depends on the decision: (a) add a Read instruction for frameworks.md to explore.md's setup (making it loaded at runtime), or (b) accept that it's conceptual reference material that the agent internalizes from training and remove it from install. Both are valid. See Open Questions.

## Code Examples

### Fix 1: install.sh - Add templates symlink

Insert after the references symlink block (after line 130, before line 131):

```bash
# ── Symlink: templates/ directory ─────────────────────
link_dir "$REPO_DIR/templates" "$HOME/.claude/brain-suite/templates" "brain-suite/templates/"
echo "$HOME/.claude/brain-suite/templates" >> "$MANIFEST"
```

The `$HOME/.claude/brain-suite` directory already exists from `mkdir -p` at line 127.

### Fix 2: resume.md - Change /brain:synthesize to /brain:analyze

Line 114 currently reads:
```
   - If all explored: completion message with /brain:synthesize suggestion
```

Change to:
```
   - If all explored: completion message with /brain:analyze suggestion
```

This matches the fix already applied to status.md and explore.md in 06-02 (commit d359139).

### Fix 3: new.md - Replace Skill tool with Read-tool delegation

Line 53 currently reads:
```
     - Invoke `/brain:resume` automatically using the Skill tool: `skill: "brain:resume"`. This hands off control to the resume command. End this command here — do NOT continue with the new session flow.
```

Replace with Read-tool delegation pattern:
```
     - Resolve the resume command path:
       ```bash
       RESUME_CMD=$(echo $HOME/.claude/commands/brain/resume.md)
       ```
     - Read the resume command file via Read tool: Read `$RESUME_CMD` for the complete resume instructions.
     - Execute ALL instructions from the resume command. End this command here -- do NOT continue with the new session flow.
```

## State of the Art

Not applicable -- no evolving technology domain. All fixes target stable file formats (bash, markdown).

## Open Questions

1. **frameworks.md: load or remove?**
   - What we know: frameworks.md (134 lines, Lean Canvas + JTBD + Value Proposition Canvas) was created in Phase 1 as a reference file for the brain-explorer. It is installed to `~/.claude/brain-suite/references/frameworks.md` but no command or agent explicitly loads it via Read tool at runtime. The brain-explorer agent spec (brain-explorer.md) does not reference it either.
   - What's unclear: Was this intentional (conceptual reference baked into agent training) or an oversight (should have been loaded in explore.md setup)?
   - Options: (a) Add `Read $BRAIN_REF/frameworks.md` to explore.md Step 3 (load at runtime, costs ~134 lines of context per exploration session). (b) Remove the file from references/ and from install.sh (accept it as unused). (c) Leave as-is (it exists but is not loaded -- a minor inconsistency that has no functional impact).
   - Recommendation: Option (a) is the cleanest resolution -- it was designed to be used by the explorer and costs minimal context. Load it in explore.md after reading questioning.md, analogous to how new.md loads voice-interaction.md. This satisfies the success criterion: "frameworks.md is either loaded at runtime or removed from install."

2. **SUMMARY.md requirements_completed: false positive?**
   - What we know: All 13 SUMMARY.md files already contain `requirements-completed` in YAML frontmatter with correct values. The audit report searched for `requirements_completed` (underscores) and found 0 matches -- a string matching error.
   - What's unclear: Should the frontmatter field be renamed to use underscores (matching the audit's expectation) or should the success criterion be considered already met (hyphens are standard YAML convention)?
   - Recommendation: The field already exists with correct data in all 13 files. This success criterion is already satisfied. No changes needed. The success criterion text says "SUMMARY.md files include `requirements_completed` frontmatter field" -- the intent (tracking which requirements each plan completed) is met. The field name uses YAML convention (hyphens), which is the standard used throughout all SUMMARY.md files.

## Sources

### Primary (HIGH confidence)
- `install.sh` -- directly inspected (139 lines). Confirmed: symlinks commands/, agents/, references/ but NOT templates/
- `uninstall.sh` -- directly inspected (82 lines). Confirmed: manifest-based removal, no hardcoded paths
- `commands/brain/explore.md` -- directly inspected (457 lines). Confirmed: resolves templates at `$HOME/.claude/brain-suite/templates` (line 19)
- `commands/brain/resume.md` -- directly inspected (169 lines). Confirmed: line 114 references `/brain:synthesize` (should be `/brain:analyze`)
- `commands/brain/new.md` -- directly inspected (301 lines). Confirmed: line 53 uses Skill tool pattern
- `commands/brain/product.md` -- directly inspected (19 lines). Confirmed: Read-tool delegation is the standard pattern
- `references/frameworks.md` -- directly inspected (135 lines). Confirmed: never loaded by any command or agent spec
- `.planning/v1.0-MILESTONE-AUDIT.md` -- directly inspected (190 lines). Source of all gap findings
- All 13 SUMMARY.md files -- grep confirmed `requirements-completed` field present in all

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- no new technology, all fixes are to existing files
- Architecture: HIGH -- all patterns directly observed in codebase, no speculation
- Pitfalls: HIGH -- verified through direct code inspection and cross-referencing

**Research date:** 2026-03-09
**Valid until:** indefinite (no external dependencies or evolving technology)
