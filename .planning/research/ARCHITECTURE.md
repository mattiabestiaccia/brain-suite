# Architecture Patterns

**Domain:** Claude Code Extension Suite (brainstorming framework)
**Researched:** 2026-03-04
**Confidence:** HIGH (based on direct analysis of Claude Code runtime model + GSD reference architecture)

## Recommended Architecture

### System Overview

Brain Suite follows a **Prompt-as-Software** architecture: all logic lives in markdown files that Claude Code reads at runtime. There is no compiled code, no server, no framework -- just structured prompts organized by role, distributed via symlinks.

```
User Input (slash command)
       |
       v
  +-----------+       +-------------+       +---------------+
  | COMMAND   | ----> | WORKFLOW    | ----> | AGENT         |
  | (entry    |       | (orchestr.) |       | (execution    |
  |  point)   |       |             |       |  persona)     |
  +-----------+       +------+------+       +-------+-------+
                             |                      |
                    +--------+--------+    +--------+--------+
                    | REFERENCE       |    | TEMPLATE        |
                    | (shared rules)  |    | (output struct) |
                    +-----------------+    +-----------------+
                                                    |
                                                    v
                                          +-----------------+
                                          | ARTIFACTS       |
                                          | (.brainstorm/)  |
                                          +-----------------+
```

### Component Boundaries

| Component | Location (repo) | Location (runtime) | Responsibility | Communicates With |
|-----------|-----------------|---------------------|---------------|-------------------|
| **Commands** | `config/commands/brain/` | `~/.claude/commands/brain/` | Entry points. User-facing slash commands. Minimal logic -- delegate to workflows/agents. | Workflows, Agents |
| **Agents** | `config/agents/` | `~/.claude/agents/brain-*.md` | Execution personas. Define HOW to behave (tone, strategy, tool access, constraints). Stateless between invocations. | Workflows (read), References (read), Templates (read), Artifacts (read/write) |
| **Workflows** | `config/brainstorm/workflows/` | `~/.claude/brainstorm/workflows/` | Orchestration scripts. Define WHAT to do step-by-step. Sequence of operations with conditionals. | Commands (invoked by), Agents (dispatches to), Templates (uses), References (consults), Artifacts (reads state) |
| **Templates** | `config/brainstorm/templates/` | `~/.claude/brainstorm/templates/` | Output structure. Define the SHAPE of generated artifacts. Markdown skeletons with sections and placeholders. | Agents (consumed by), Workflows (referenced by) |
| **References** | `config/brainstorm/references/` | `~/.claude/brainstorm/references/` | Shared knowledge. Domain rules, questioning techniques, framework catalogs. Centralized source of truth consumed by multiple workflows/agents. | Agents (consulted by), Workflows (consulted by) |
| **Artifacts** | N/A (not in repo) | `<project>/.brainstorm/` | Per-project generated data. IDEA.md, SESSION.md, dimension files, session logs, synthesis, handoff. Created at runtime, persisted on disk. | Agents (create/update), Workflows (read state), Commands (trigger creation) |
| **Install Scripts** | repo root | repo root | Distribution. Create/remove symlinks between repo and `~/.claude/`. | All components (enables runtime access) |

### Data Flow

#### Primary Flow: New Session

```
1. User types: /brain:new
2. Claude Code loads: ~/.claude/commands/brain/new.md
3. Command instructs: read workflow ~/.claude/brainstorm/workflows/new-session.md
4. Workflow instructs:
   a. Read reference ~/.claude/brainstorm/references/questioning.md
   b. Engage user with Socratic questioning (interactive loop)
   c. Read template ~/.claude/brainstorm/templates/idea.md
   d. Write artifact .brainstorm/IDEA.md (populated template)
   e. Read template ~/.claude/brainstorm/templates/session.md
   f. Write artifact .brainstorm/SESSION.md (initialized state)
5. Command suggests next step: /brain:product or /brain:explore
```

#### Primary Flow: Dimension Exploration

```
1. User types: /brain:product (or /brain:explore product)
2. Command loads -> delegates to workflow explore-dimension.md
3. Workflow:
   a. Read .brainstorm/SESSION.md -> check if dimension already explored
   b. If explored: ask user (deepen or restart)
   c. Read .brainstorm/IDEA.md -> load context
   d. Read reference questioning.md + dimensions-guide.md
   e. Spawn agent brain-explorer with dimension context
4. Agent (brain-explorer):
   a. Interactive Socratic exploration (multiple turns)
   b. Consults references for questioning techniques
   c. When coverage gate triggers: suggest wrapping up
   d. If real data needed: suggest spawning brain-researcher
   e. Read template dimension-product.md
   f. Write .brainstorm/dimensions/product.md
   g. Write .brainstorm/sessions/product-<timestamp>.md (session log)
   h. Update .brainstorm/SESSION.md (mark dimension explored)
```

#### Primary Flow: Synthesis

```
1. User types: /brain:synthesize
2. Command -> workflow synthesize.md
3. Workflow:
   a. Read .brainstorm/SESSION.md -> verify 2+ dimensions explored
   b. Read all .brainstorm/dimensions/*.md
   c. Read .brainstorm/IDEA.md
   d. Spawn agent brain-synthesizer
4. Agent (brain-synthesizer):
   a. Cross-dimensional pattern analysis
   b. Identify conflicts, synergies, gaps
   c. Read template synthesis.md
   d. Write .brainstorm/SYNTHESIS.md
```

#### Secondary Flow: Resume Session

```
1. User types: /brain:resume
2. Command -> workflow resume-session.md
3. Workflow:
   a. Read .brainstorm/SESSION.md -> session state
   b. Read .brainstorm/IDEA.md -> core idea
   c. Read all .brainstorm/dimensions/*.md -> explored dimensions
   d. Read .brainstorm/SYNTHESIS.md if exists
   e. Reconstruct context and present status
   f. Suggest next steps based on what's explored vs. missing
```

#### Agent Spawning Flow: Explorer -> Researcher

```
1. brain-explorer identifies need for factual data during exploration
2. Explorer suggests to user: "This needs market data. Shall I research?"
3. User confirms
4. Explorer spawns brain-researcher (SubAgent)
5. brain-researcher:
   a. Performs web searches (Exa MCP tools)
   b. Writes findings to temporary context or directly to dimension
   c. Returns control to brain-explorer
6. Explorer integrates research into ongoing exploration
```

## Patterns to Follow

### Pattern 1: Command as Thin Entry Point

**What:** Commands contain minimal logic. They load context, validate preconditions, then delegate to a workflow or directly to an agent. Commands are user-facing documentation as much as they are instructions.

**When:** Every slash command.

**Why:** Users read command files to understand what's available. Keeping them thin makes them readable. Logic changes happen in workflows without touching commands.

**Example structure:**

```markdown
# /brain:product

Explore the product dimension of the current brainstorming session.

## Prerequisites
- Active brainstorm session (.brainstorm/ must exist with IDEA.md)

## Execution
1. Load workflow: ~/.claude/brainstorm/workflows/explore-dimension.md
2. Set dimension: product
3. Execute workflow

## Arguments
- None (dimension is hardcoded as "product")

## See also
- /brain:explore <dimension> for generic exploration
```

### Pattern 2: Workflow as Orchestration Script

**What:** Workflows define the sequence of operations, conditionals, and branching logic. They are the "business logic" of the suite. A workflow reads state, makes decisions, dispatches to agents, and ensures artifacts are properly created.

**When:** Any multi-step operation that involves state checking, agent dispatching, or artifact management.

**Why:** Separating orchestration from execution (agents) means you can change the flow without changing the persona. Separating orchestration from entry points (commands) means multiple commands can share the same workflow.

**Key principle:** Workflows should be re-entrant. If Claude Code restarts mid-workflow, reading SESSION.md should allow resumption.

### Pattern 3: Agent as Execution Persona

**What:** Agents define WHO does the work -- personality, strategy, tool access, constraints. They do NOT define WHAT to do (that's the workflow's job). An agent is a reusable persona that can be dispatched by different workflows.

**When:** Any task requiring a consistent behavioral profile across different contexts.

**Why:** The brain-explorer agent behaves the same way whether invoked via `/brain:product`, `/brain:tech`, or `/brain:explore custom-dim`. The workflow provides context; the agent provides behavior.

**Critical constraint:** Agents are registered globally in `~/.claude/agents/`. They MUST be prefixed (`brain-*`) to avoid namespace collisions with other suites (e.g., GSD agents like `gsd-project-researcher.md`).

### Pattern 4: Reference as Single Source of Truth

**What:** Reference files contain domain knowledge that multiple components need. Instead of duplicating questioning techniques in every agent prompt, put them in `questioning.md` and have agents/workflows read it.

**When:** Any knowledge shared across 2+ components. Rules, frameworks, style guides, domain definitions.

**Why:** DRY for prompts. Update once, all consumers get the change. Also enables the user to customize behavior by editing one file.

**Example references for Brain Suite:**
- `questioning.md` -- Socratic questioning techniques, probing patterns, depth signals
- `frameworks.md` -- Business analysis frameworks (SWOT, Porter's Five Forces, Jobs-to-be-Done, etc.)
- `dimensions-guide.md` -- What each dimension covers, depth expectations, example questions
- `voice-interaction.md` -- Voice-first interaction rules (brief responses, one question at a time, tolerance for informal speech)

### Pattern 5: Template as Output Contract

**What:** Templates define the structure of generated artifacts. They are markdown files with sections, placeholders, and guidance notes that agents fill in during execution.

**When:** Any artifact that needs consistent structure across sessions and dimensions.

**Why:** Without templates, agents produce inconsistent output. Templates are the "schema" for prompt-generated content. They also serve as documentation of what each artifact should contain.

**Key principle:** Templates should be self-documenting. Include guidance comments that the agent reads but removes from the final output.

### Pattern 6: Symlink Distribution

**What:** The repo contains all source files. `install.sh` creates POSIX symlinks from `~/.claude/` to the repo. No files are copied.

**When:** Always -- this is the distribution mechanism.

**Why:** Changes in the repo are immediately reflected in Claude Code. `git pull` updates everything. No rebuild step. No package manager.

**Critical details:**
- Commands directory: symlink the ENTIRE `brain/` directory (`ln -sfn`)
- Agents: symlink INDIVIDUAL files (`ln -sf` per file) -- because `~/.claude/agents/` is shared with other suites
- Brainstorm framework: symlink the ENTIRE `brainstorm/` directory
- Coexistence: never assume `~/.claude/agents/` belongs exclusively to this suite

### Pattern 7: State via Filesystem

**What:** All state lives in `.brainstorm/` as markdown files. SESSION.md tracks what's been explored. Dimension files track content. No database, no API, no in-memory state.

**When:** Always -- Claude Code sessions are ephemeral. State must survive session restarts.

**Why:** Claude Code has no persistent memory between sessions. The filesystem IS the database. Markdown files are human-readable, git-trackable, and trivially parseable by Claude.

**Key principle:** SESSION.md is the state machine. Its structure must support:
- Which dimensions have been explored (and when)
- Current session status (in-progress, paused, completed)
- Notes and bookmarks for resume
- Re-exploration tracking (version/iteration counts)

## Anti-Patterns to Avoid

### Anti-Pattern 1: Logic in Commands

**What:** Putting complex orchestration logic directly in command files.
**Why bad:** Commands become hard to maintain, can't be shared between entry points, and users can't easily understand what a command does by reading it.
**Instead:** Commands validate preconditions and delegate to workflows. Logic lives in workflows.

### Anti-Pattern 2: Agent State Assumptions

**What:** Assuming an agent remembers context from a previous invocation.
**Why bad:** Claude Code agents are stateless between sessions. An agent spawned for `/brain:product` knows nothing about a previous `/brain:users` exploration unless it explicitly reads the artifacts.
**Instead:** Always read state from `.brainstorm/` at the start of every workflow. Never rely on conversation history from previous sessions.

### Anti-Pattern 3: Duplicated Rules Across Agents

**What:** Copy-pasting the same interaction rules (voice-first guidelines, questioning techniques) into every agent prompt.
**Why bad:** One change requires updating multiple files. Drift is inevitable.
**Instead:** Put shared rules in reference files. Have agents/workflows explicitly read them via `Read ~/.claude/brainstorm/references/<file>.md`.

### Anti-Pattern 4: Monolithic Workflow

**What:** A single massive workflow file that handles all dimensions, synthesis, handoff, and resume.
**Why bad:** Impossible to maintain. Changes to one flow risk breaking others. Claude's context window gets polluted with irrelevant instructions.
**Instead:** One workflow per distinct operation. Workflows can share patterns via references but should be independently readable.

### Anti-Pattern 5: Hardcoded Paths in Prompts

**What:** Using absolute paths like `/home/brusc/Projects/brain-suite/...` in prompt files.
**Why bad:** Breaks for any other user or different installation path.
**Instead:** Use `~/.claude/` for framework files (stable convention). Use relative paths from project root for `.brainstorm/` artifacts. Use environment-relative references.

### Anti-Pattern 6: Template as Rigid Schema

**What:** Templates so rigid that agents can't adapt them to the actual content discovered during exploration.
**Why bad:** Every idea is different. A hardware product needs different dimension coverage than a SaaS product.
**Instead:** Templates should have required sections (always present) and optional sections (agent includes if relevant). Mark which is which.

## Component Dependency Graph

```
                    install.sh
                        |
           +------------+-------------+
           |            |             |
     commands/      agents/      brainstorm/
      brain/       brain-*.md    +-----------+
           |            |        |           |
           |            |    workflows/  templates/  references/
           |            |        |           |            |
           +-----+------+--------+           |            |
                 |                           |            |
           [Runtime: Claude Code]            |            |
                 |                           v            v
                 v                    (consumed at   (consulted at
           .brainstorm/               write time)    read time)
           (per-project)
```

### Build Order (Phase Dependencies)

The dependency graph dictates a strict build order:

```
Layer 0: References (no dependencies -- pure knowledge)
  questioning.md, frameworks.md, dimensions-guide.md, voice-interaction.md

Layer 1: Templates (depend on: reference definitions for section structure)
  idea.md, session.md, dimension-*.md, synthesis.md, handoff.md

Layer 2: Agents (depend on: references to consult, templates to fill)
  brain-explorer.md, brain-researcher.md, brain-synthesizer.md

Layer 3: Workflows (depend on: agents to dispatch, templates to reference, references to consult)
  new-session.md, explore-dimension.md, synthesize.md, resume-session.md, handoff.md

Layer 4: Commands (depend on: workflows to delegate to, agents to invoke)
  new.md, explore.md, product.md...users.md, synthesize.md, status.md, resume.md, handoff.md, add-dimension.md

Layer 5: Distribution (depends on: all above existing)
  install.sh, uninstall.sh
```

**Implication for roadmap:** Build bottom-up. References and templates first (Layer 0-1), then agents (Layer 2), then workflows (Layer 3), then commands (Layer 4), then install scripts (Layer 5). Each layer can be tested independently before the layer above is built.

**Exception:** A vertical slice approach (build one complete flow end-to-end, e.g., `/brain:new`) is preferable to strict layer-by-layer. The layers define dependency order WITHIN each vertical slice.

## Separation of Concerns Matrix

| Concern | Where It Lives | NOT Here |
|---------|---------------|----------|
| User-facing interface | Commands | Workflows, Agents |
| Step-by-step orchestration | Workflows | Commands, Agents |
| Behavioral persona (tone, strategy) | Agents | Commands, Workflows |
| Output structure | Templates | Agents (should not hardcode structure) |
| Domain knowledge / rules | References | Agents, Workflows (should not duplicate) |
| Session state | .brainstorm/SESSION.md | Agent memory, conversation history |
| Dimension content | .brainstorm/dimensions/*.md | Templates (templates define structure, not content) |
| Distribution mechanism | install.sh | Any prompt file |

## Namespace and Coexistence Strategy

Brain Suite must coexist with GSD and potentially other Claude Code suites in `~/.claude/`.

| Component | Strategy | Rationale |
|-----------|----------|-----------|
| Commands | Own subdirectory: `commands/brain/` | Claude Code namespaces commands by directory. `/brain:new` maps to `commands/brain/new.md`. No collision possible. |
| Agents | Prefix: `brain-*.md` in shared `agents/` | `~/.claude/agents/` is flat and shared. File prefix is the only namespace. Must never create a file without `brain-` prefix. |
| Framework | Own subdirectory: `brainstorm/` | `~/.claude/brainstorm/` is a new top-level directory. No collision with `~/.claude/get-shit-done/`. |
| Artifacts | Project-local: `.brainstorm/` | Analogous to `.planning/` for GSD. Different directory, no collision. |

## File Size and Context Window Considerations

Claude Code loads prompt files into the context window. File size matters.

| Component Type | Target Size | Rationale |
|---------------|-------------|-----------|
| Commands | < 50 lines | Thin entry points. Just preconditions + delegation. |
| Agents | 100-300 lines | Personality, strategy, constraints, tool permissions. Rich enough to be effective. |
| Workflows | 100-200 lines | Step-by-step procedures. Should be scannable. |
| Templates | 50-150 lines | Skeleton with section headers and guidance notes. |
| References | 100-400 lines | Dense knowledge. Larger is acceptable since they are consulted selectively. |

**Total context budget per operation:** A typical dimension exploration loads: 1 command (~50 lines) + 1 workflow (~150 lines) + 1 agent (~200 lines) + 2-3 references (~300 lines each) + 1 template (~100 lines) + existing artifacts. Target: under 2000 lines of prompt content per operation, leaving ample room for conversation.

## Scalability Considerations

| Concern | At v1 (6 dimensions) | At v1.5 (+ processing) | At v2+ (MCP + mobile) |
|---------|----------------------|------------------------|----------------------|
| Number of prompt files | ~37 files | ~39 files (+ 2 bridge commands) | Same (MCP is code, not prompts) |
| Custom dimensions | `add-dimension.md` creates new template + registers in SESSION.md | Same pattern | Same pattern |
| New agent types | Add `brain-*.md` file + reference in workflows | Same pattern | Same pattern |
| Processing integration | N/A (pure prompts) | Commands dispatch via `uv run` (Bash tool) | MCP tools replace Bash dispatch |
| State complexity | SESSION.md with dimension tracking | + transcript/recording metadata | + sync state for mobile |

## Sources

- Direct analysis of Claude Code runtime model (commands, agents, tool dispatch)
- GSD (Get Shit Done) suite architecture as reference implementation (examined via system prompt and agent definitions)
- Brain Suite project plan (`BRAIN_SUITE_PLAN.md`) for specific architectural decisions
- Claude Code documentation for `~/.claude/` directory conventions

**Confidence notes:**
- HIGH confidence on command/agent/workflow separation -- directly observed in GSD reference architecture
- HIGH confidence on symlink distribution -- confirmed by Claude Code's file resolution behavior
- HIGH confidence on namespace strategy -- `~/.claude/agents/` sharing pattern confirmed by GSD coexistence requirement in PROJECT.md
- MEDIUM confidence on context window budget -- based on training data knowledge of Claude Code's prompt loading, not measured empirically
