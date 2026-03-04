# Technology Stack

**Project:** Brain Suite
**Domain:** Claude Code extension framework (custom commands, agents, workflows, templates, reference files)
**Researched:** 2026-03-04
**Overall confidence:** HIGH (Claude Code extensibility is core Anthropic product — well-documented, stable conventions)

## Executive Summary

Brain Suite is a **prompt-engineering project**, not a software-engineering project. The "stack" is Claude Code's native extensibility system: markdown files that define slash commands, agent personas, workflow orchestration, output templates, and shared reference documents. There is no compilation, no runtime, no dependencies (for v1). The entire deliverable is structured markdown placed in specific directories under `~/.claude/`.

This makes the stack research fundamentally different from a typical project. The questions are not "which framework?" but rather "what are the exact file formats, naming conventions, directory structures, and interaction patterns that Claude Code supports?"

## Recommended Stack

### Core Platform

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Claude Code | Latest | Runtime platform | Only option — Brain Suite is a Claude Code extension | HIGH |
| Markdown (.md) | N/A | All config files | Claude Code reads commands, agents, workflows, and templates as markdown | HIGH |
| POSIX symlinks | N/A | Distribution mechanism | Link from `~/.claude/` to repo — edits reflected immediately, git-tracked source of truth | HIGH |
| Bash (install.sh) | POSIX sh | Install/uninstall scripts | Creates/removes symlinks. Minimal, no dependencies | HIGH |
| Git | Any | Version control + distribution | `git clone` + `./install.sh` is the entire install flow | HIGH |

### Claude Code Extension Points

These are the five extension mechanisms Claude Code provides. Each has specific conventions.

#### 1. Custom Slash Commands

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Location (user-global)** | `~/.claude/commands/` | HIGH |
| **Location (project-local)** | `.claude/commands/` in project root | HIGH |
| **File format** | Markdown (`.md`) | HIGH |
| **Naming convention** | `command-name.md` becomes `/command-name` | HIGH |
| **Nested commands** | `dir/command.md` becomes `/dir:command` | HIGH |
| **Arguments** | `$ARGUMENTS` placeholder in markdown body, receives user input after the command | HIGH |
| **Content** | System prompt injected when command is invoked | HIGH |
| **Max depth** | Subdirectories map to colon-separated namespaces (e.g., `brain/new.md` -> `/brain:new`) | HIGH |

**Key insight for Brain Suite:** Use `brain/` subdirectory under `commands/` so all commands appear as `/brain:*`. This avoids namespace collision with other extensions (like GSD's `gsd/` directory).

**File structure in repo:**
```
commands/brain/
  new.md              -> /brain:new
  explore.md          -> /brain:explore
  dimensions.md       -> /brain:dimensions
  dive.md             -> /brain:dive
  challenge.md        -> /brain:challenge
  research.md         -> /brain:research
  status.md           -> /brain:status
  synthesize.md       -> /brain:synthesize
  handoff.md          -> /brain:handoff
  resume.md           -> /brain:resume
  rethink.md          -> /brain:rethink
  reframe.md          -> /brain:reframe
  pivot.md            -> /brain:pivot
```

**Symlink strategy:** Symlink the entire `brain/` directory:
```bash
ln -s /path/to/brain-suite/commands/brain ~/.claude/commands/brain
```

This is safe because GSD uses `~/.claude/commands/gsd/` — no collision.

#### 2. Agent Definitions

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Location (user-global)** | `~/.claude/agents/` | HIGH |
| **File format** | Markdown (`.md`) | HIGH |
| **Naming convention** | `agent-name.md` — descriptive kebab-case | HIGH |
| **Spawning** | Agents are spawned by the main Claude session via the Agent tool | HIGH |
| **Content** | System prompt defining role, capabilities, constraints, and output format | HIGH |
| **Scope** | Each agent runs in an isolated sub-session with its own context window | HIGH |
| **Communication** | Agents return results to the spawning session — no inter-agent direct communication | HIGH |
| **File access** | Agents can read/write files in the working directory (same as main session) | HIGH |
| **Tool access** | Agents have the same tool access as the main session (Read, Write, Bash, Grep, Glob, etc.) | HIGH |

**Key insight for Brain Suite:** Agent files live flat in `~/.claude/agents/` (no subdirectories for namespacing). Use prefix `brain-` to avoid collision:
```
agents/
  brain-explorer.md
  brain-researcher.md
  brain-synthesizer.md
```

**Symlink strategy:** Symlink individual files (not directory), because GSD agents coexist in the same directory:
```bash
ln -s /path/to/brain-suite/agents/brain-explorer.md ~/.claude/agents/brain-explorer.md
ln -s /path/to/brain-suite/agents/brain-researcher.md ~/.claude/agents/brain-researcher.md
ln -s /path/to/brain-suite/agents/brain-synthesizer.md ~/.claude/agents/brain-synthesizer.md
```

#### 3. Workflows (Orchestration via Commands)

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Mechanism** | Workflows are implemented as commands that contain orchestration logic | HIGH |
| **Format** | Markdown with structured instructions for Claude | HIGH |
| **Agent spawning** | Workflow commands instruct Claude to spawn agents at specific points | HIGH |
| **State management** | Via files on disk (read/write markdown artifacts) | HIGH |
| **Flow control** | Described in natural language with conditional logic in the prompt | HIGH |

**Key insight:** Claude Code does not have a dedicated "workflow" file type. Workflows are commands (or agent instructions) that describe multi-step orchestration. The distinction is conceptual, not technical. A command like `/brain:new` IS a workflow — it instructs Claude to create files, ask questions, and potentially spawn agents.

**Pattern from GSD:** GSD implements workflows as command files that contain detailed step-by-step instructions with conditional branching, file I/O, and agent spawning directives. Brain Suite should follow the same pattern.

#### 4. Templates

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Mechanism** | Templates are markdown files read by commands/agents at runtime | MEDIUM |
| **Location** | In the repo, referenced by absolute or relative path from commands/agents | MEDIUM |
| **Format** | Markdown with placeholder patterns (not a templating engine — Claude fills them in) | MEDIUM |
| **Convention** | Store in a `templates/` directory in the repo, reference from command prompts | MEDIUM |

**Key insight:** Claude Code has no native "template" system. Templates are regular markdown files that commands/agents read and use as output structure guides. The command prompt says "read the template at [path] and fill it in based on [context]." Claude does the interpolation — there is no mustache/handlebars/jinja processing.

**Template location strategy:** Templates should live in the repo (not symlinked to `~/.claude/`) and be referenced by absolute path. Since the install script knows the repo path, it can write a small config file or the commands can use a known base path.

**Alternative (recommended):** Store templates in the repo under `templates/` and have the install script also symlink a templates directory to a known location that commands can reference. GSD uses `~/.claude/get-shit-done/templates/` for this purpose. Brain Suite should use a similar pattern:
```bash
ln -s /path/to/brain-suite/templates ~/.claude/brain-suite/templates
```

Then commands reference: `~/.claude/brain-suite/templates/idea.md`

#### 5. Reference Files (Shared Knowledge)

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Mechanism** | Markdown files containing rules, guidelines, frameworks that multiple commands/agents reference | MEDIUM |
| **Location** | In the repo, symlinked or referenced by path | MEDIUM |
| **Purpose** | Single source of truth for cross-cutting concerns (e.g., voice-first rules, questioning frameworks) | HIGH |
| **Convention** | Referenced in command/agent prompts with "Read the reference file at [path]" | MEDIUM |

**Storage strategy (same as templates):**
```bash
ln -s /path/to/brain-suite/reference ~/.claude/brain-suite/reference
```

Reference files for Brain Suite:
```
reference/
  questioning.md         # Socratic, challenger, creative questioning patterns
  frameworks.md          # Analysis frameworks (SWOT, Jobs-to-be-Done, etc.)
  dimensions-guide.md    # How to explore each dimension (product, tech, market, etc.)
  voice-interaction.md   # Voice-first interaction rules
```

### CLAUDE.md Integration

| Attribute | Value | Confidence |
|-----------|-------|------------|
| **Project-level** | `.claude/CLAUDE.md` in project root | HIGH |
| **User-level** | `~/.claude/CLAUDE.md` | HIGH |
| **Purpose** | Persistent instructions loaded into every Claude Code session | HIGH |
| **Brain Suite use** | NOT recommended for core logic — use commands/agents instead | HIGH |

**Key insight:** CLAUDE.md is for project-specific context that should always be present. Brain Suite should NOT put its logic in CLAUDE.md. Instead, the `.brainstorm/` directory artifacts serve as session context that commands load explicitly.

### Directory Structure in Repo

```
brain-suite/
├── commands/
│   └── brain/                    # All slash commands -> /brain:*
│       ├── new.md
│       ├── explore.md
│       ├── dive.md
│       ├── challenge.md
│       ├── research.md
│       ├── dimensions.md
│       ├── status.md
│       ├── synthesize.md
│       ├── handoff.md
│       ├── resume.md
│       ├── rethink.md
│       ├── reframe.md
│       └── pivot.md
├── agents/
│   ├── brain-explorer.md         # Interactive exploration agent
│   ├── brain-researcher.md       # Web research agent
│   └── brain-synthesizer.md      # Cross-dimensional synthesis agent
├── templates/
│   ├── idea.md                   # IDEA.md structure
│   ├── session.md                # SESSION.md structure
│   ├── dimension-product.md      # Product dimension output
│   ├── dimension-tech.md         # Tech dimension output
│   ├── dimension-market.md       # Market dimension output
│   ├── dimension-business.md     # Business dimension output
│   ├── dimension-competitors.md  # Competitors dimension output
│   ├── dimension-users.md        # Users dimension output
│   ├── synthesis.md              # SYNTHESIS.md structure
│   └── handoff.md                # HANDOFF.md structure
├── reference/
│   ├── questioning.md            # Questioning techniques
│   ├── frameworks.md             # Analysis frameworks
│   ├── dimensions-guide.md       # Dimension exploration guide
│   └── voice-interaction.md      # Voice-first rules
├── install.sh                    # Symlink creation
├── uninstall.sh                  # Symlink removal
└── README.md                     # Usage docs
```

### Per-Project Artifacts (Runtime Output)

```
<project-root>/
└── .brainstorm/
    ├── IDEA.md                   # Core idea definition
    ├── SESSION.md                # Current session state
    ├── dimensions/
    │   ├── product.md
    │   ├── tech.md
    │   ├── market.md
    │   ├── business.md
    │   ├── competitors.md
    │   └── users.md
    ├── sessions/
    │   ├── 2026-03-04-001.md     # Session log (cleaned)
    │   └── ...
    ├── SYNTHESIS.md              # Cross-dimensional synthesis
    └── HANDOFF.md                # GSD-ready handoff document
```

## Symlink Installation Strategy

### Approach: Hybrid (Directory + Individual Files)

```bash
#!/bin/bash
# install.sh

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Commands: symlink entire brain/ directory (safe — own namespace)
mkdir -p "$CLAUDE_DIR/commands"
ln -sfn "$REPO_DIR/commands/brain" "$CLAUDE_DIR/commands/brain"

# Agents: symlink individual files (shared namespace with GSD)
mkdir -p "$CLAUDE_DIR/agents"
for agent in "$REPO_DIR/agents/"brain-*.md; do
  ln -sf "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done

# Templates + Reference: symlink under brain-suite namespace
mkdir -p "$CLAUDE_DIR/brain-suite"
ln -sfn "$REPO_DIR/templates" "$CLAUDE_DIR/brain-suite/templates"
ln -sfn "$REPO_DIR/reference" "$CLAUDE_DIR/brain-suite/reference"

echo "Brain Suite installed. Commands: /brain:*"
```

**Why this approach:**
- Commands use directory symlink because `brain/` namespace is exclusive to Brain Suite
- Agents use file symlinks because `~/.claude/agents/` is shared with GSD (and potentially other tools)
- Templates/reference use a `brain-suite/` namespace directory to avoid any collision
- `ln -sfn` (force + no-dereference) ensures re-running install.sh is idempotent

## Command File Anatomy

### Standard Structure for a Brain Suite Command

```markdown
# Command description (for documentation, Claude reads this too)

<role>
[Who Claude should be when this command runs]
</role>

<context>
[What files to read for context, what state to check]

Read the following files if they exist:
- `.brainstorm/IDEA.md` - Current idea definition
- `.brainstorm/SESSION.md` - Current session state

Read the reference file at `~/.claude/brain-suite/reference/voice-interaction.md` for interaction rules.
</context>

<instructions>
[Step-by-step instructions for what to do]

1. Check if `.brainstorm/` exists
2. If not, [do X]
3. If yes, [do Y]
...
</instructions>

<output>
[What to produce, where to write it]

Write the output to `.brainstorm/[file].md` using the template at `~/.claude/brain-suite/templates/[template].md`.
</output>

<rules>
[Constraints and guidelines]

- Follow voice-first rules from the reference file
- One question at a time
- Keep responses under 3 sentences unless presenting structured analysis
</rules>
```

### Agent File Anatomy

```markdown
# Agent: Brain Explorer

<role>
You are the Brain Suite Explorer agent, specialized in interactive brainstorming...
</role>

<capabilities>
- Read and write files in `.brainstorm/`
- Ask probing questions one at a time
- Track coverage of key areas within a dimension
</capabilities>

<constraints>
- Voice-first: short responses, one question at a time
- Never make decisions for the user
- Suggest when key areas are covered, but let user decide to continue or stop
</constraints>

<output_format>
[How the agent should structure its outputs]
</output_format>
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Distribution | Symlinks | Copy files | Copies don't reflect edits, require re-install on every change |
| Distribution | Symlinks | npm package | Overkill for markdown files, adds Node.js dependency |
| Command namespace | `brain/` subdir | Flat files with prefix | Subdir gives clean `/brain:*` namespace; flat files would be `/brain-new`, `/brain-explore` — less elegant |
| Agent namespace | `brain-` prefix | Subdir | Agents dir is flat by convention, subdirs not supported for agent resolution |
| Templates | Markdown files read at runtime | Jinja/Handlebars | No template engine in Claude Code — Claude IS the template engine |
| State management | Files on disk (`.brainstorm/`) | Database/SQLite | Massive overkill for v1; files are human-readable, git-trackable, and Claude reads them natively |
| Install mechanism | Bash script | Makefile | Bash is simpler, no Make dependency, more portable |
| Install mechanism | Bash script | Python script | Python adds unnecessary dependency for symlinking |

## Version Compatibility Notes

| Concern | Status | Confidence |
|---------|--------|------------|
| Custom commands stable | YES — core feature since Claude Code GA | HIGH |
| Agent spawning stable | YES — core feature, used extensively by GSD | HIGH |
| `$ARGUMENTS` in commands | YES — documented, works reliably | HIGH |
| Nested command directories | YES — `dir/cmd.md` -> `/dir:cmd` is standard | HIGH |
| `~/.claude/` as config root | YES — standard location | HIGH |
| Agent isolation (sub-sessions) | YES — each spawned agent gets its own context | HIGH |

## Key Conventions to Follow

### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Commands | kebab-case, verb-first | `explore-dimension.md`, `new.md` |
| Agents | `brain-` prefix, role name | `brain-explorer.md` |
| Templates | noun, matches output file | `idea.md`, `synthesis.md` |
| Reference files | topic-focused, kebab-case | `voice-interaction.md` |
| Artifact files | UPPER_CASE for primary, lower for secondary | `IDEA.md`, `dimensions/product.md` |

### Content

| Rule | Rationale |
|------|-----------|
| Use XML-like tags in prompts (`<role>`, `<instructions>`, etc.) | Improves Claude's parsing — clear section boundaries |
| Keep commands focused (one responsibility) | Easier to maintain, clearer user intent |
| Reference files for shared rules, not copy-paste | Single source of truth — update once, all consumers get the change |
| Templates define structure, not behavior | Behavior lives in commands/agents; templates are output scaffolding |

### What NOT to Do

| Anti-pattern | Why | Instead |
|--------------|-----|---------|
| Put logic in CLAUDE.md | Loaded on every session even when Brain Suite isn't being used — pollutes context | Use commands that load context on-demand |
| Hardcode paths in commands | Breaks if repo is cloned to different location | Use `~/.claude/brain-suite/` as stable reference point |
| Copy-paste rules across commands | Drift, inconsistency, maintenance burden | Extract to reference files, instruct commands to read them |
| Giant monolithic commands | Exceeds useful context, hard to maintain | Split into focused commands + orchestrating workflow |
| Use agents for simple tasks | Agent spawn has overhead (new context window) | Use agents only when isolation or specialization needed |
| Store state in memory | Lost between sessions | Write everything to `.brainstorm/` files |
| Rely on conversation history | Context window limits, sessions end | Persist to disk, read back on resume |

## Installation

```bash
# Install
git clone https://github.com/[user]/brain-suite.git
cd brain-suite
./install.sh

# Uninstall
./uninstall.sh

# Update (no action needed — symlinks)
cd brain-suite && git pull
```

## Sources and Confidence Assessment

| Source | Type | Confidence |
|--------|------|------------|
| Claude Code official documentation (custom commands, CLAUDE.md) | Official docs | HIGH |
| GSD framework (existing working implementation of same patterns) | Production reference | HIGH |
| Claude Code agent spawning behavior | Direct product knowledge | HIGH |
| Template/reference file patterns | Inferred from GSD patterns + product behavior | MEDIUM |
| Nested command directory support | Verified via GSD `gsd/` subdirectory usage | HIGH |

**Note on verification:** Web search and Context7 tools were unavailable in this research session. Findings are based on Claude Code product documentation from training data and the GSD framework as a verified working reference implementation. The PROJECT.md explicitly states Brain Suite follows "the GSD pattern" (workflow orchestrate, reference files centralize rules, templates define structure, agents execute), which confirms these patterns are validated in practice.

**Gaps to verify in phase-specific research:**
- Exact behavior of `$ARGUMENTS` with multi-word input and special characters
- Whether agent files support any metadata beyond the markdown content
- Maximum practical size of command/agent markdown files before context degradation
- Behavior when symlinked command files are modified while Claude Code is running (hot reload vs restart required)
