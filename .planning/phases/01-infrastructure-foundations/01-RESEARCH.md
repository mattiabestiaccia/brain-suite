# Phase 1: Infrastructure & Foundations - Research

**Researched:** 2026-03-04
**Domain:** Bash scripting, Claude Code command/agent system, symlink management, reference file authoring
**Confidence:** HIGH

## Summary

Phase 1 delivers the installable skeleton of Brain Suite: a git-clone-and-run experience that creates all necessary symlinks in `~/.claude/`, produces the reference files that define the brainstorming methodology, and provides README documentation. This phase has no external library dependencies — it is pure bash scripting and markdown authoring on top of well-understood Claude Code primitives.

The critical architectural decisions have already been locked in CONTEXT.md (flat repo layout, symlink-based install, manifest-driven uninstall). The primary research value here is validating the mechanics of those decisions: confirming that directory symlinks work for Claude Code command namespacing, verifying idempotency of `ln -sfn`, and understanding the agent stub requirement that makes `install.sh` testable end-to-end in Phase 1.

**Primary recommendation:** Build a single `install.sh` with collision detection and a manifest at `~/.claude/.brain-suite-manifest`, stub agent files in `agents/` to make the full symlink set testable from day one, and author reference files with opinionated, actionable content (not generic documentation).

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Reference files & methodology**
- Hybrid questioning style per dimension: Socratic default, challenger for market/competitors, creative for product
- Explorer voice: thinking partner — casual but sharp, like brainstorming with a co-founder. Direct, occasionally challenges, never patronizing
- Frameworks included: Lean Canvas, JTBD, Value Proposition Canvas (startup-oriented, problem-solution fit focused)
- Dimension templates: predefined structured sections per dimension (e.g., product: Problem, Solution, Key Features, Differentiators). Explorer uses sections as conversation anchors

**Repo layout**
- Flat by type at repo root: `commands/`, `agents/`, `references/`, `templates/`
- One template file per dimension: `templates/product.md`, `templates/tech.md`, etc.
- Reference files in `references/`: `voice-interaction.md`, `questioning.md`, `frameworks.md`, `dimensions-guide.md`
- Templates are NOT symlinked — agents read them directly from repo path (registered in manifest)

**Symlink targets in ~/.claude/**
- Commands: `~/.claude/commands/brain/` — creates `/brain:` namespace automatically
- Agents: individual symlinks in `~/.claude/agents/` — `brain-explorer.md`, `brain-researcher.md`, `brain-synthesizer.md`
- References: `~/.claude/brain-suite/references/` — dedicated directory for Brain Suite reference files

**Session data location**
- `.brainstorm/` created in current project root at runtime (by `/brain:new`)
- Session logs named `<dimension>-<YYYY-MM-DD>.md` in `.brainstorm/sessions/`
- Dimension outputs in `.brainstorm/dimensions/<dimension>.md`

**Install behavior**
- Progress output with summary: shows ✓/✗ per symlink, then summary ("12 files linked, 0 errors")
- Re-install: overwrite existing symlinks silently, log "updated" instead of "created"
- Pre-checks: verify `~/.claude/` exists (create if not), verify repo source files present. Fail fast on missing files
- Creates `~/.claude/.brain-suite-manifest` listing all symlinks created — used by uninstall

**Uninstall behavior**
- No confirmation prompt — direct removal with summary of what was removed
- Reads manifest to know exactly what to remove
- Removes `commands/brain/` directory if empty after symlink removal; preserves if user added custom files
- Never touches GSD files, other agents, or anything not in manifest

**GSD coexistence**
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

### Deferred Ideas (OUT OF SCOPE)

- None — discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFRA-01 | `install.sh` creates symlinks from `~/.claude/` to repo files (commands, agents, brainstorm framework) | Verified: `ln -sfn` for directories, `ln -sf` for individual files. Manifest approach confirmed via GSD pattern |
| INFRA-02 | `uninstall.sh` removes symlinks without touching repo or other `~/.claude/` files | Verified: manifest-based removal, collision detection via `readlink` comparison |
| INFRA-03 | Install handles coexistence with GSD (symlink individual agent files, not agents directory) | Verified: GSD uses real files in `agents/`; individual file symlinks avoid directory collision |
| INFRA-04 | Install is idempotent (running twice produces same result) | Verified empirically: `ln -sfn` and `ln -sf` are idempotent by design — overwrite existing symlinks silently |
| INFRA-05 | README.md with installation instructions, usage guide, and command reference | Standard markdown authoring — no technical constraints |

</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| bash | 5.x (Linux), 3.2+ (macOS) | install.sh / uninstall.sh scripting | Pre-installed on all target platforms; no runtime deps |
| `ln` | POSIX | Creating symlinks | Standard Unix symlink tool |
| `readlink` | GNU/BSD | Verifying symlink targets for collision detection | Available on all platforms |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| ANSI color codes | — | Progress output (✓/✗, summary) | In install.sh output only |
| `tput` | — | Terminal capability detection | Optional: fallback to no color if not available |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `ln -sfn` (directory symlinks) | Copying files | Copies break auto-update on repo pull; symlinks always reflect current repo state |
| Manifest file for uninstall | Scanning ~/.claude/ for brain-suite symlinks at uninstall time | Scanning is fragile — manifest is authoritative and fast |
| JSON manifest | Plain-text manifest (one path per line) | Plain text is simpler, no parser dependency; JSON adds no value here |

**Installation:** No package installation required. All tools are system-provided.

## Architecture Patterns

### Recommended Project Structure

```
brain-suite/                    # repo root
├── commands/brain/             # /brain: namespace — .md files per command
├── agents/                     # brain-*.md agent files (stubs in Phase 1)
├── references/                 # methodology reference files (created in Phase 1)
│   ├── voice-interaction.md
│   ├── questioning.md
│   ├── frameworks.md
│   └── dimensions-guide.md
├── templates/                  # per-dimension output templates (Phase 3)
├── install.sh                  # creates symlinks + manifest
├── uninstall.sh                # reads manifest, removes symlinks
└── README.md
```

**Note:** The existing `config/` directory structure (from pre-discussion planning) is superseded by this flat layout. Phase 1 must remove the `config/` directory scaffolding or leave it empty and ignored.

### Pattern 1: Symlink Namespace for Commands

**What:** `~/.claude/commands/brain/` is a symlink to `REPO/commands/brain/`. Claude Code automatically maps `commands/<subdir>/<file>.md` to `/<subdir>:<file>` slash commands.

**Verification:** The GSD extension uses `~/.claude/commands/gsd/` as a real directory containing command `.md` files. The command `gsd/new-project.md` becomes `/gsd:new-project`. Therefore `brain/new.md` → `/brain:new`. This is confirmed by Context7 docs: "subdirectory name becomes the namespace."

**When to use:** Any time a set of related commands needs a namespace prefix.

```bash
# Source: empirical validation on live system
# ~/.claude/commands/gsd/new-project.md → /gsd:new-project (confirmed working)
# Therefore:
ln -sfn "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain"
# Creates /brain: namespace with all files in commands/brain/ as /brain:<filename>
```

### Pattern 2: Individual File Symlinks for Agents

**What:** Agent files are symlinked individually (`~/.claude/agents/brain-explorer.md → REPO/agents/brain-explorer.md`), not as a directory symlink. This avoids collision with existing agents from GSD and other tools.

**Why individual, not directory:** `~/.claude/agents/` contains GSD agents (`gsd-executor.md`, etc.). A directory symlink would replace the entire `agents/` directory. Individual file symlinks coexist safely.

```bash
# Source: GSD pattern analysis (agents are real files in ~/.claude/agents/)
# Brain Suite adds individual symlinks alongside them
for f in "$REPO_DIR/agents/brain-"*.md; do
    target="$HOME/.claude/agents/$(basename "$f")"
    if [ -L "$target" ] && [[ "$(readlink "$target")" == "$REPO_DIR"* ]]; then
        ln -sf "$f" "$target"   # our symlink — safe to update
        echo "  updated: $(basename "$target")"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        echo "  WARN: $target exists (not ours) — skipping"
    else
        ln -sf "$f" "$target"   # fresh install
        echo "  linked: $(basename "$target")"
    fi
done
```

### Pattern 3: Manifest-Based Uninstall

**What:** `install.sh` writes every created symlink path to `~/.claude/.brain-suite-manifest` (one path per line). `uninstall.sh` reads this file and removes exactly those paths.

**Why:** Scanning `~/.claude/` for Brain Suite symlinks at uninstall time is fragile. The manifest is authoritative, fast, and safe.

```bash
# Manifest format: one absolute path per line
# ~/.claude/commands/brain
# ~/.claude/agents/brain-explorer.md
# ~/.claude/agents/brain-researcher.md
# ~/.claude/agents/brain-synthesizer.md
# ~/.claude/brain-suite/references

# Uninstall reads it:
while IFS= read -r path; do
    if [ -L "$path" ]; then
        rm "$path"
        echo "  removed: $path"
    fi
done < "$HOME/.claude/.brain-suite-manifest"
rm "$HOME/.claude/.brain-suite-manifest"
```

### Pattern 4: References Directory via Intermediate Real Directory

**What:** `install.sh` creates `~/.claude/brain-suite/` as a real directory, then symlinks `~/.claude/brain-suite/references/` → `REPO/references/`. This gives a stable namespace for Brain Suite framework files without polluting `~/.claude/` root.

**Why not symlink `~/.claude/brain-suite` → repo root:** Agents referencing `~/.claude/brain-suite/references/` need a stable path. If `brain-suite` is a full repo symlink, it exposes all repo internals (including `.planning/`, `.git/`, etc.) under `~/.claude/brain-suite/`. A real directory with only `references/` inside is cleaner.

```bash
mkdir -p "$HOME/.claude/brain-suite"
ln -sfn "$REPO_DIR/references" "$HOME/.claude/brain-suite/references"
```

### Pattern 5: Stub Agents for Phase 1 Install Completeness

**What:** Phase 1 creates minimal stub `.md` files in `agents/` so that `install.sh` can succeed end-to-end (success criterion 1). Stubs have valid frontmatter but placeholder content.

**Why needed:** CONTEXT.md specifies "verify repo source files present. Fail fast on missing files." If `agents/brain-explorer.md` doesn't exist, install fails. Phase 2 fills in the actual agent content — the symlink already points to the right file.

```markdown
---
name: brain-explorer
description: Guides interactive brainstorming exploration (implementation in progress)
tools: Read, Write, Bash
---
# Brain Explorer

Coming in Phase 2. This agent guides structured brainstorming exploration.
```

### Anti-Patterns to Avoid

- **Symlinking ~/.claude/agents/ as a directory:** Wipes out GSD and other agents. Use individual file symlinks.
- **Symlinking ~/.claude/commands/ entirely:** Same problem — wipes all existing commands.
- **Using absolute hardcoded paths in agent files:** Agent stubs should not hardcode the repo path. Future phases can resolve REPO_DIR via `~/.claude/.brain-suite-manifest` or `~/.claude/brain-suite/`.
- **`set -e` without error handling in install.sh:** `ln` returning non-zero on collision stops the script. Use explicit collision detection and `set -e` only for truly fatal errors.
- **Manifest tracking real directories (not symlinks):** Only track symlinks in the manifest. Real dirs (`~/.claude/brain-suite/`) need special handling — check emptiness before removal, don't blindly rm.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Cross-platform `realpath` | Custom path resolution | `cd "$(dirname "${BASH_SOURCE[0]}")" && pwd` | Works on bash 3.2+ (macOS) and bash 5+ (Linux) without GNU coreutils |
| Collision detection | Substring matching on file paths | `readlink` + prefix check against REPO_DIR | readlink is atomic and accurate |
| Idempotent directory creation | Check-then-create | `mkdir -p` | Built-in, race-condition safe |

**Key insight:** The entire install/uninstall problem is solved by three POSIX tools (`ln`, `readlink`, `mkdir`) and a flat text manifest. No scripting framework is warranted.

## Common Pitfalls

### Pitfall 1: `ln -sfn` vs `ln -sf` for Directories

**What goes wrong:** `ln -sf dir_target dir_link` when `dir_link` already exists as a directory (not a symlink) creates a new symlink INSIDE `dir_link` instead of replacing it.

**Why it happens:** `ln -sf` treats an existing directory as a target container. `-n` (no-dereference) prevents this.

**How to avoid:** Always use `ln -sfn` for directory symlinks. Use `ln -sf` only for individual file symlinks.

**Warning signs:** After re-install, `ls -la ~/.claude/commands/brain` shows `brain -> ../brain` (nested symlink) instead of the expected target.

```bash
# CORRECT for directories:
ln -sfn "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain"

# WRONG (may nest on re-run):
ln -sf "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain"
```

### Pitfall 2: `readlink` Behavior Differences (Linux vs macOS)

**What goes wrong:** `readlink -f` (follow all symlinks to absolute canonical path) is GNU-specific and does not exist on macOS's BSD `readlink`.

**Why it happens:** macOS ships with BSD userland, not GNU coreutils.

**How to avoid:** Use `readlink` without `-f` for checking symlink targets (it returns the stored target, which is sufficient for collision detection). Use `cd ... && pwd` for resolving the script's own directory.

```bash
# Cross-platform: get script's absolute directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cross-platform: check if symlink points to our repo
readlink "$target"   # returns stored target path — sufficient for prefix check
```

### Pitfall 3: Removing `~/.claude/commands/brain` on Uninstall Breaks Namespace

**What goes wrong:** If user added their own files to `~/.claude/commands/brain/` (which is our symlink), removing the symlink removes their files too.

**Why it happens:** The symlink points to `REPO/commands/brain/`. Their files ARE in that directory. On uninstall we remove the symlink but the user's files stay in the repo.

**How to avoid:** This is actually not a problem — the symlink just disappears. The user's files are in the repo, not in `~/.claude/`. The namespace goes away, but no files are lost.

**But:** If the user created a real directory at `~/.claude/commands/brain/` (instead of our symlink), uninstall should not touch it. The manifest check (`[ -L "$path" ]`) handles this — only remove if it's a symlink.

### Pitfall 4: Commands Not Appearing in `/help` After Install

**What goes wrong:** User runs `install.sh`, symlinks exist, but `/brain:new` doesn't appear in Claude Code.

**Why it happens:** Claude Code may cache the command list at startup. Symlinks created after startup won't appear until restart.

**How to avoid:** Document in README: "Restart Claude Code after installation for commands to appear." This is expected behavior, not a bug.

**Warning signs:** `ls ~/.claude/commands/brain/` shows files, but `/help` doesn't list `/brain:*` commands.

### Pitfall 5: Manifest Path Inconsistency

**What goes wrong:** Manifest written with relative paths; uninstall run from different directory fails to find files.

**Why it happens:** `$HOME` expansion or `~` usage inconsistency between install and uninstall contexts.

**How to avoid:** Always write absolute paths to the manifest. Expand `$HOME` at write time.

```bash
# CORRECT: write absolute path
echo "$HOME/.claude/commands/brain" >> "$HOME/.claude/.brain-suite-manifest"

# WRONG: write relative or unexpanded
echo "~/.claude/commands/brain" >> ...  # ~ not expanded in echo
```

## Code Examples

Verified patterns from live system analysis and empirical testing:

### Idempotent Directory Symlink

```bash
# Source: empirical validation (2026-03-04)
# ln -sfn is idempotent: running twice yields identical result
ln -sfn "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain"
# Second run: silently overwrites, same result ✓
```

### Script Directory Resolution (Cross-Platform)

```bash
# Source: pattern used by ralph/install.sh and GSD install
# Works on bash 3.2+ (macOS) and bash 5+ (Linux)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### Collision Detection for Agent File Symlinks

```bash
# Source: empirical validation (2026-03-04)
link_agent() {
    local src="$1"
    local target="$2"
    local name
    name="$(basename "$src")"

    if [ -L "$target" ] && [[ "$(readlink "$target")" == "$REPO_DIR"* ]]; then
        # Our symlink — safe to update
        ln -sf "$src" "$target"
        echo "  ✓ updated: $name"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        # Exists and is not ours — skip
        echo "  ✗ WARN: $target already exists (not Brain Suite) — skipping"
        return 1
    else
        # Fresh install
        ln -sf "$src" "$target"
        echo "  ✓ linked: $name"
    fi
}
```

### Manifest Write and Read

```bash
# Write (install.sh):
MANIFEST="$HOME/.claude/.brain-suite-manifest"
> "$MANIFEST"  # truncate/create
append_manifest() {
    echo "$1" >> "$MANIFEST"
}

# Read (uninstall.sh):
while IFS= read -r path; do
    [ -z "$path" ] && continue
    if [ -L "$path" ]; then
        rm "$path"
        echo "  ✓ removed: $path"
    else
        echo "  - skipped (not a symlink): $path"
    fi
done < "$MANIFEST"
```

### Install Progress Output Pattern

```bash
# Source: inspired by ralph/install.sh pattern
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

linked=0
warned=0
failed=0

# ... after all linking:
echo ""
echo "Brain Suite installation complete."
echo "  ${GREEN}${linked} files linked${NC}  ${YELLOW}${warned} skipped${NC}  ${RED}${failed} errors${NC}"
echo ""
echo "Restart Claude Code for commands to appear."
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Copy files to ~/.claude/ (GSD approach) | Symlink from ~/.claude/ to repo | Brain Suite design choice | Files always reflect latest repo pull without re-running install |
| Single install.sh for install+uninstall | Separate install.sh and uninstall.sh | Design decision | Cleaner, more discoverable, uninstall.sh stands alone |
| Directory symlink for agents | Individual file symlinks | Design decision | Coexistence with GSD and other tools |

**Validated as current (2026-03-04):**
- Claude Code reads through symlinked `.md` files for agents — standard filesystem access, symlinks are transparent
- `~/.claude/commands/<subdir>/<file>.md` → `/<subdir>:<file>` namespace (confirmed via GSD live system)
- `$ARGUMENTS` in command files captures the entire input following the command name, including multi-word arguments

## Open Questions

1. **Template path resolution for agents**
   - What we know: Templates are NOT symlinked per CONTEXT.md. Agents need to find them at runtime.
   - What's unclear: The "registered in manifest" phrasing is ambiguous — the manifest (`.brain-suite-manifest`) lists symlinks for uninstall, not template paths for agents.
   - Recommendation: Phase 2 will resolve this. The planner should note that `~/.claude/brain-suite/` (the real directory) can be extended with a `config.json` storing `REPO_DIR`, or agents can derive REPO_DIR from the `references` symlink target. **This does not block Phase 1** since no agent content is authored in Phase 1 (only stubs).

2. **Hot reload for symlinked files**
   - What we know: Claude Code reads files at command/agent invocation time.
   - What's unclear: Whether there is startup-time caching of command file contents (vs. just path discovery).
   - Recommendation: Document in README that restart is required after install. For development, a change to a symlinked file should take effect on next invocation without restart (file content is read dynamically). **Flag for empirical validation in Phase 2.**

3. **config/ directory cleanup**
   - What we know: An old `config/` directory structure exists at repo root (pre-discussion scaffolding), now superseded by flat layout per CONTEXT.md.
   - What's unclear: Whether to delete it, rename it, or leave it.
   - Recommendation: Delete `config/` as part of Phase 1 repo structure work. It's empty scaffolding that contradicts the locked layout decision. A `git rm -r config/` is clean.

## Sources

### Primary (HIGH confidence)

- Live system analysis: `~/.claude/commands/gsd/` → `/gsd:*` namespace (empirical, 2026-03-04)
- Empirical test: `ln -sfn` idempotency on Linux bash 5.2.21 (2026-03-04)
- Empirical test: Directory symlink read-through (file content accessible via symlinked directory)
- Empirical test: Collision detection logic via `readlink` + prefix comparison
- `/home/brusc/.claude/gsd-file-manifest.json` — GSD manifest pattern (SHA256 hashes, not symlink paths)
- CONTEXT.md — locked user decisions (2026-03-04)

### Secondary (MEDIUM confidence)

- Context7 `/anthropics/claude-code`: "subdirectory name becomes the namespace" for commands — confirmed by live GSD behavior
- Context7 `/websites/code_claude`: "$ARGUMENTS captures entire input following command name" — consistent with GSD `execute-phase.md` which uses `Phase: $ARGUMENTS`
- `ralph/install.sh` — reference for bash install script patterns (color output, dependency checks, SCRIPT_DIR resolution)

### Tertiary (LOW confidence)

- Hot reload behavior for symlinked files: assumed to work (standard filesystem), unconfirmed empirically — needs Phase 2 validation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all tools are POSIX standard, behavior empirically validated
- Architecture patterns: HIGH — symlink mechanics validated, namespace behavior confirmed via live GSD system
- Install/uninstall logic: HIGH — idempotency and collision detection empirically tested
- Reference file content: MEDIUM — framework content (Lean Canvas, JTBD, VPC) is well-known; exact phrasing and structure is Claude's discretion per CONTEXT.md
- Hot reload behavior: LOW — inferred, not empirically validated

**Research date:** 2026-03-04
**Valid until:** 2026-06-04 (stable domain — bash scripting + Claude Code command system)
