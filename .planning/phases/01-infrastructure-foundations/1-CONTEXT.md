# Phase 1: Infrastructure & Foundations - Context

**Gathered:** 2026-03-04
**Status:** Ready for planning

<domain>

## Phase Boundary

Install scripts, repo structure, reference files, and base templates. User can `git clone` + `./install.sh` and all symlinks are created in `~/.claude/`. Uninstall cleanly removes only Brain Suite files. Reference files define the brainstorming methodology for all subsequent phases.

</domain>

<decisions>

## Implementation Decisions

### Reference files & methodology
- Hybrid questioning style per dimension: Socratic default, challenger for market/competitors, creative for product
- Explorer voice: thinking partner — casual but sharp, like brainstorming with a co-founder. Direct, occasionally challenges, never patronizing
- Frameworks included: Lean Canvas, JTBD, Value Proposition Canvas (startup-oriented, problem-solution fit focused)
- Dimension templates: predefined structured sections per dimension (e.g., product: Problem, Solution, Key Features, Differentiators). Explorer uses sections as conversation anchors

### Repo layout
- Flat by type at repo root: `commands/`, `agents/`, `references/`, `templates/`
- One template file per dimension: `templates/product.md`, `templates/tech.md`, etc.
- Reference files in `references/`: `voice-interaction.md`, `questioning.md`, `frameworks.md`, `dimensions-guide.md`
- Templates are NOT symlinked — agents read them directly from repo path (registered in manifest)

### Symlink targets in ~/.claude/
- Commands: `~/.claude/commands/brain/` — creates `/brain:` namespace automatically
- Agents: individual symlinks in `~/.claude/agents/` — `brain-explorer.md`, `brain-researcher.md`, `brain-synthesizer.md`
- References: `~/.claude/brain-suite/references/` — dedicated directory for Brain Suite reference files

### Session data location
- `.brainstorm/` created in current project root at runtime (by `/brain:new`)
- Session logs named `<dimension>-<YYYY-MM-DD>.md` in `.brainstorm/sessions/`
- Dimension outputs in `.brainstorm/dimensions/<dimension>.md`

### Install behavior
- Progress output with summary: shows ✓/✗ per symlink, then summary ("12 files linked, 0 errors")
- Re-install: overwrite existing symlinks silently, log "updated" instead of "created"
- Pre-checks: verify `~/.claude/` exists (create if not), verify repo source files present. Fail fast on missing files
- Creates `~/.claude/.brain-suite-manifest` listing all symlinks created — used by uninstall

### Uninstall behavior
- No confirmation prompt — direct removal with summary of what was removed
- Reads manifest to know exactly what to remove
- Removes `commands/brain/` directory if empty after symlink removal; preserves if user added custom files
- Never touches GSD files, other agents, or anything not in manifest

### GSD coexistence
- Install only creates `commands/brain/` inside `~/.claude/commands/` — does not touch `commands/gsd/` or anything else
- Agent symlinks are individual files, not a directory — no collision with `gsd-*.md` agents
- If a file with the same name already exists and is NOT a Brain Suite symlink: warn and skip (never overwrite user's files)
- Uninstall reads manifest for precise removal — zero risk of touching GSD

### Claude's Discretion
- Exact content and structure of each reference file (voice-interaction.md, questioning.md, frameworks.md, dimensions-guide.md)
- Internal structure of install.sh/uninstall.sh scripts
- README.md structure and level of detail
- Error message wording
- Whether to add `.brainstorm/` to a suggested `.gitignore` entry

</decisions>

<specifics>

## Specific Ideas

- Install/uninstall should feel like GSD's install — same developer experience, familiar patterns
- Reference files are the "brain" of the tool — they define methodology, not just documentation. They should be opinionated and actionable, not generic
- Templates serve as conversation anchors, not rigid forms — the explorer uses them to know what sections to cover, not to fill in blanks

</specifics>

<deferred>

## Deferred Ideas

- None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-infrastructure-foundations*
*Context gathered: 2026-03-04*
