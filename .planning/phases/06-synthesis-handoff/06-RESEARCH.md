# Phase 6: Synthesis & Handoff - Research

**Researched:** 2026-03-09
**Domain:** Cross-dimensional analysis, narrative synthesis, structured handoff document generation, markdown-as-prompt agent design for non-interactive document generation
**Confidence:** HIGH

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Command flow and prerequisites
- Three commands: `/brain:analyze`, `/brain:synthesize`, `/brain:handoff`
- All three are fully automatic -- launch, agent reads dimensions, produces output, shows result. Zero interaction
- Sequential chain: analyze -> synthesize -> handoff
- `/brain:analyze` requires 2+ explored dimensions, produces ANALYSIS.md
- `/brain:synthesize` requires ANALYSIS.md as input, produces SYNTHESIS.md
- `/brain:handoff` prefers SYNTHESIS.md but works without it (produces a more basic handoff from dimensions alone). Requires 2+ explored dimensions

#### ANALYSIS.md -- cross-dimensional analysis
- Organized by theme, not by dimension pairs -- patterns often cross 3+ dimensions
- Themes emerge from the content (not predefined categories)
- Internal structure within each theme at Claude's discretion (may include pattern description, dimensions involved, type classification -- whatever serves clarity)
- More rigorous gap signaling: flags missing dimensions AND which specific sections within explored dimensions are thin

#### SYNTHESIS.md -- narrative synthesis
- Narrative, discursive document -- tells the story of the idea seen from all angles
- Intended audience: non-technical stakeholders (client, co-founder, investor). Readable, not structured for machines
- Cohesive vision, not a list of recommendations or priorities
- Length adapts to richness of explored dimensions (Claude decides)
- Gap signaling: generic note about missing dimensions at the end (less detailed than analysis)

#### HANDOFF.md -- GSD-ready brief
- Production-ready document, structured for `/gsd:new-project` consumption
- Opinionated: where brainstorming produced a clear direction, HANDOFF.md declares it as a decision. Where ambiguity remains, flags it explicitly
- 6 fixed sections always present: Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model
- Additional sections allowed if brainstorming produced relevant content that doesn't fit the 6 base sections
- No indication of source level (synthesis vs dimensions only) -- the document stands on its own
- Gap signaling: same as synthesis (note about missing dimensions)

### Claude's Discretion
- Internal structure of analysis themes
- Length and depth of SYNTHESIS.md based on content richness
- Which additional sections to add to HANDOFF.md (if any)
- How to handle dimensions with very thin content in each document
- Whether brain-synthesizer is one agent handling all three commands or has distinct modes

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SYNTH-01 | User can generate cross-dimensional synthesis via `/brain:synthesize` (requires 2+ dimensions explored) | User decision splits this into analyze + synthesize. `/brain:analyze` handles cross-dimensional pattern extraction (new command). `/brain:synthesize` handles narrative synthesis from ANALYSIS.md. Both commands need the same validation gate (2+ explored dimensions). Command file pattern established in Phases 2-5. |
| SYNTH-02 | Synthesis identifies tensions, synergies, contradictions, and opportunities across dimensions | ANALYSIS.md covers this -- organized by emergent themes, not dimension pairs. Theme types include tensions, synergies, contradictions, and opportunities. The analyze command and agent spec must produce these. |
| SYNTH-03 | Synthesis output saved as `.brainstorm/SYNTHESIS.md` | Direct file write via Write tool. Same pattern as dimension artifacts in explore.md. |
| SYNTH-04 | User can generate GSD-ready handoff document via `/brain:handoff` | HANDOFF.md has 6 fixed sections. Must be compatible with `/gsd:new-project --auto @.brainstorm/HANDOFF.md`. Research below maps HANDOFF.md sections to GSD expectations. |
| SYNTH-05 | HANDOFF.md contains structured sections: Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model | These 6 sections are locked. Research below maps each to source dimensions and GSD consumption patterns. |
| AGT-03 | brain-synthesizer agent reads explored dimensions, identifies cross-dimensional patterns, generates SYNTHESIS.md and HANDOFF.md | Agent spec replaces Phase 1 stub. Needs tools: Read, Write, Bash, Glob. No Exa MCP (pure analysis from existing artifacts). Recommendation: single agent with mode parameter, not three separate agents. |

</phase_requirements>

## Summary

Phase 6 delivers three fully-automatic commands (`/brain:analyze`, `/brain:synthesize`, `/brain:handoff`) and the `brain-synthesizer` agent that powers all three. Unlike Phases 2-5 which built interactive conversational flows, this phase produces non-interactive document generators: the user launches a command, the agent reads all `.brainstorm/` artifacts, produces a document, and shows the result. No Socratic dialogue, no questions, no user interaction during execution.

The primary challenge is not technical (the tool chain is well-established) but intellectual: designing agent prompts that produce high-quality analytical, narrative, and structured outputs from varied dimension content. The three documents serve different audiences and purposes -- ANALYSIS.md is a working document for systematic pattern extraction, SYNTHESIS.md is a client-facing narrative, HANDOFF.md is a builder-facing brief for GSD consumption. The agent must understand these distinct modes and produce appropriate output for each.

A secondary challenge is GSD compatibility: HANDOFF.md must be directly consumable by `/gsd:new-project --auto @.brainstorm/HANDOFF.md`. This requires the handoff document to contain enough structured information for GSD's questioning/research/requirements/roadmap pipeline to work without interactive input.

**Primary recommendation:** Implement brain-synthesizer as a single agent with three modes (analyze/synthesize/handoff), each triggered by its respective command. Keep command files thin (validation + context loading + agent invocation pattern), put all intelligence in the agent spec. This follows the Phase 2 pattern where brain-explorer.md contains behavioral spec and command files handle setup/orchestration.

## Standard Stack

### Core

This phase uses no external libraries. The entire implementation is markdown-as-prompt files consumed by Claude Code.

| Component | Type | Purpose | Why Standard |
|-----------|------|---------|--------------|
| Command .md files | Slash command | `/brain:analyze`, `/brain:synthesize`, `/brain:handoff` | Established pattern from 12 existing commands in commands/brain/ |
| Agent .md file | Agent spec | brain-synthesizer behavioral prompt | Established pattern from brain-explorer.md and brain-researcher.md |
| Claude Code tools | Runtime | Read, Write, Bash, Glob | Same tool set as all previous phases |

### Supporting

| Component | Type | Purpose | When to Use |
|-----------|------|---------|-------------|
| YAML frontmatter | Agent metadata | name, description, tools declaration | Required for all agent .md files |
| Skill tool | Command invocation | Inter-command delegation | NOT needed -- all three commands are standalone, no delegation chain |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Single agent with modes | Three separate agents (brain-analyzer, brain-synthesizer, brain-handoff-generator) | Three agents means three files to maintain, three sets of tool declarations. Single agent with mode parameter is simpler and lets the agent share context understanding across modes. User decided this is at Claude's discretion -- recommendation is single agent. |
| Thin commands + fat agent | Fat commands with inline prompts | Phases 2-4 used fat commands with behavioral prompts inline. Phase 5 established the pattern of meaningful agent specs. For Phase 6, the agent does all the work (no interactive conversation logic in commands), so fat agent + thin commands is the right split. |

## Architecture Patterns

### Recommended Project Structure

After Phase 6, the file tree will be:

```
commands/brain/
  analyze.md          # NEW - validate + load + invoke brain-synthesizer (analyze mode)
  synthesize.md       # REPLACE stub - validate + load + invoke brain-synthesizer (synthesize mode)
  handoff.md          # REPLACE stub - validate + load + invoke brain-synthesizer (handoff mode)
  [existing 10 commands unchanged]

agents/
  brain-synthesizer.md  # REPLACE stub - complete agent spec with 3 modes
  [brain-explorer.md, brain-researcher.md unchanged]

.brainstorm/            # Runtime output (user's project, not brain-suite repo)
  ANALYSIS.md           # NEW - output of /brain:analyze
  SYNTHESIS.md          # NEW - output of /brain:synthesize
  HANDOFF.md            # NEW - output of /brain:handoff
```

### Pattern 1: Non-Interactive Command (New Pattern)

**What:** Commands that produce output without user interaction. This is new -- all previous commands either had interactive conversation (new, explore, resume) or were read-only dashboards (status).

**When to use:** When the command's job is to read existing artifacts, process them, and write output.

**How it works in the Brain Suite context:**

```markdown
# /brain:analyze (command file pattern)

## Setup

1. Resolve paths
2. Validate prerequisites:
   - .brainstorm/IDEA.md exists (session active)
   - .brainstorm/SESSION.md exists
   - Count explored dimensions (Glob .brainstorm/dimensions/*.md)
   - If < 2 explored dimensions: error message and STOP
3. Load all artifacts:
   - Read IDEA.md
   - Read SESSION.md
   - Read ALL dimension files
4. Generate output:
   - Apply brain-synthesizer agent behavior (analyze mode)
   - Write .brainstorm/ANALYSIS.md
5. Show result summary to user
```

This differs from the interactive pattern (explore.md) where the command sets up context and then enters a conversation loop. Here, setup flows directly into generation with no conversation.

### Pattern 2: Agent Mode Selection

**What:** Single agent spec that handles multiple commands via a mode parameter.

**When to use:** When multiple commands share the same input data and tool requirements but produce different outputs.

**How it works:**

The command file sets the mode context before the agent behavior kicks in. The agent spec defines shared behavior (loading dimensions, understanding cross-dimensional patterns) and mode-specific behavior (what output to produce).

```markdown
# brain-synthesizer.md (agent spec pattern)

## Role
[shared understanding of what a synthesizer does]

## Input Loading (shared)
[how to read and understand dimension files]

## Modes

### Analyze Mode
[produce ANALYSIS.md with cross-dimensional themes]

### Synthesize Mode
[produce SYNTHESIS.md as narrative document]

### Handoff Mode
[produce HANDOFF.md as GSD-ready brief]
```

Each command file passes the mode:
- analyze.md says "Execute brain-synthesizer in **analyze** mode"
- synthesize.md says "Execute brain-synthesizer in **synthesize** mode"
- handoff.md says "Execute brain-synthesizer in **handoff** mode"

### Pattern 3: Prerequisite Chain Validation

**What:** Commands that validate the output of a prior command exists before proceeding.

**When to use:** For the analyze -> synthesize -> handoff chain.

**Validation gates:**

| Command | Requires | Falls back to |
|---------|----------|---------------|
| `/brain:analyze` | 2+ explored dimensions | Error: "Esplora almeno 2 dimensioni prima di analizzare." |
| `/brain:synthesize` | ANALYSIS.md exists | Error: "Lancia prima `/brain:analyze` per generare l'analisi." |
| `/brain:handoff` | 2+ explored dimensions | Works without SYNTHESIS.md (more basic output) |

Note: `/brain:handoff` has a soft prerequisite on SYNTHESIS.md. If SYNTHESIS.md exists, it uses it for richer output. If only ANALYSIS.md exists, it uses that. If neither exists, it works from dimensions alone. The handoff always works as long as 2+ dimensions are explored -- it degrades gracefully.

### Anti-Patterns to Avoid

- **Delegating to a subagent via Task tool:** These commands are non-interactive. The agent spec is executed directly by the command (the command IS the prompt for the agent). No Task spawning needed -- unlike the researcher which runs in background during conversation, the synthesizer runs as the main thread.
- **Interactive flows in non-interactive commands:** Do not ask the user questions during analyze/synthesize/handoff. These are fire-and-forget: launch, generate, show result.
- **Hardcoded theme categories in ANALYSIS.md:** Themes must emerge from content. Do not predefine "Synergies", "Tensions", etc. as fixed sections. The agent discovers what themes exist.
- **Duplicating agent logic in command files:** Keep commands thin (validation + context loading). All generation intelligence belongs in the agent spec.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dimension file discovery | Custom file listing logic | Glob `.brainstorm/dimensions/*.md` | Same pattern used in explore.md (Step 4) and status.md |
| Dimension count validation | Parse SESSION.md table | Glob count of dimension files | File existence is the ground truth, SESSION.md could be stale |
| Date formatting | Manual date construction | `date +%Y-%m-%d` via Bash | Same pattern used in explore.md session log |
| Cross-dimensional pattern detection | Algorithmic extraction | LLM analysis via agent prompt | The agent IS the pattern detector -- prompt engineering, not code |

**Key insight:** This phase has zero algorithmic complexity. All "processing" is LLM reasoning guided by well-structured prompts. The quality of output depends entirely on the agent spec's clarity, not on code logic.

## Common Pitfalls

### Pitfall 1: Agent Prompt Too Vague for Document Structure

**What goes wrong:** The agent produces inconsistent output structure across runs because the prompt doesn't specify format clearly enough.
**Why it happens:** LLMs produce varied structures when given loose format guidance. "Write an analysis" will produce different structures each time.
**How to avoid:** Define explicit section structures in the agent spec. For ANALYSIS.md, specify the meta-structure (themes emerge, but each theme has a defined internal structure). For HANDOFF.md, the 6 sections are fixed -- specify their headings and what content goes in each.
**Warning signs:** Review the agent spec and check: could two different Claude instances produce structurally incompatible outputs from the same input?

### Pitfall 2: HANDOFF.md Not GSD-Compatible

**What goes wrong:** The handoff document looks good to a human but `/gsd:new-project --auto` can't extract structured information from it.
**Why it happens:** GSD's auto mode expects a document it can extract project context from. If HANDOFF.md uses inconsistent headings, buries key information in prose, or uses non-standard section names, GSD's questioning synthesis step may miss critical content.
**How to avoid:** Design HANDOFF.md sections to map directly to GSD's PROJECT.md template fields (see mapping below). Use clear ## headings. Put key decisions in declarative sentences, not buried in paragraphs.
**Warning signs:** Try mentally running `/gsd:new-project --auto @HANDOFF.md` and check: can GSD extract Core Value, Requirements, Constraints, and Context from the document?

### Pitfall 3: Thin Dimensions Producing Empty Analysis

**What goes wrong:** If only 2 dimensions are explored and both have thin content (placeholder sections), the analysis/synthesis is vapid.
**How to avoid:** The agent spec should handle thin content explicitly: note which sections are thin (have placeholder questions instead of content), use only substantive sections for analysis, and flag gaps clearly. The gap signaling in ANALYSIS.md should be rigorous ("Dimension X: sections Y and Z have only placeholder questions, no explored content").
**Warning signs:** Test mentally with 2 minimally-explored dimensions.

### Pitfall 4: Synthesize Becoming a Summary Instead of a Narrative

**What goes wrong:** SYNTHESIS.md reads like a bullet-point summary of findings instead of a cohesive narrative story.
**Why it happens:** LLMs default to structured/enumerated output. The prompt must actively push toward narrative prose.
**How to avoid:** The agent spec for synthesize mode should include explicit anti-patterns ("not a list", "not a summary", "not a report") and positive examples of narrative voice ("tell the story", "cohesive vision", "one continuous argument").
**Warning signs:** If the prompt says "synthesize the findings" without specifying narrative format, the output will be a structured summary.

### Pitfall 5: analyze.md Command Not in install.sh

**What goes wrong:** `/brain:analyze` is a new command not in the original Phase 1 requirements. The install.sh symlinks `commands/brain/` as a directory, so any new .md file in that directory is automatically available. No installer change needed.
**Why it happens:** Worry about missing installation steps.
**How to avoid:** Verify: install.sh uses `link_dir` for commands/brain/ (line 110), which symlinks the entire directory. New files appear automatically.
**Warning signs:** None -- this is already handled by the existing installer.

### Pitfall 6: Missing SESSION.md/Status Updates

**What goes wrong:** After running analyze/synthesize/handoff, SESSION.md doesn't reflect what happened.
**Why it happens:** Previous commands (explore, new) update SESSION.md. These new commands should too.
**How to avoid:** Each command should update SESSION.md with a note (e.g., "Analysis generated", "Synthesis generated", "Handoff generated"). Also update the Status field when handoff is complete.
**Warning signs:** Check if SESSION.md Session Notes section would have entries for these operations.

## Code Examples

Since this phase is pure markdown-as-prompt, "code examples" are command/agent file patterns.

### Command File Pattern (thin command)

Based on established patterns from product.md (shortcut) and explore.md (full command):

```markdown
# /brain:analyze

Generate cross-dimensional analysis from 2+ explored dimensions. Produces ANALYSIS.md.

## Setup

1. **Resolve paths:**
   [bash: BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)]

2. **Validate prerequisites:**
   - Read .brainstorm/SESSION.md -- REQUIRED. If missing: error + STOP.
   - Read .brainstorm/IDEA.md -- REQUIRED. If missing: error + STOP.
   - Glob .brainstorm/dimensions/*.md -- count files.
   - If < 2 dimension files: "Servono almeno 2 dimensioni esplorate. Usa /brain:explore." + STOP.

3. **Load all context:**
   - Read IDEA.md
   - Read SESSION.md
   - Read ALL dimension files found by Glob
   - [For synthesize: also read ANALYSIS.md]
   - [For handoff: read SYNTHESIS.md if exists, else ANALYSIS.md if exists]

4. **Generate output:**
   Execute brain-synthesizer behavior in [analyze/synthesize/handoff] mode.
   Write output to .brainstorm/[ANALYSIS/SYNTHESIS/HANDOFF].md

5. **Update SESSION.md:**
   Add note to Session Notes section.

6. **Show result:**
   Display brief summary of what was generated + suggest next command.
```

### Agent Spec: Analyze Mode (theme extraction)

```markdown
## Analyze Mode

Read ALL dimension files. Identify cross-dimensional themes.

A theme is a pattern, tension, synergy, contradiction, or opportunity
that spans 2+ dimensions. Themes emerge from the content --
do NOT use predefined categories.

For each theme:
- Theme name (concise, descriptive)
- Which dimensions contribute to this theme
- Description of the pattern
- Type: synergy | tension | contradiction | opportunity | gap
- Implications (what this means for the idea)

After themes, include a Gap Analysis section:
- List unexplored dimensions (from SESSION.md)
- For explored dimensions: list sections with only placeholder content
- Rate overall analysis confidence based on coverage
```

### Agent Spec: Handoff Mode (GSD mapping)

```markdown
## Handoff Mode

Produce a structured document with these 6 REQUIRED sections:

### Product Vision
Source: IDEA.md (elevator pitch + core concept) + product dimension
Maps to GSD: "What This Is" + "Core Value"

### Problem & Opportunity
Source: product dimension (Problem Statement) + market dimension (Market Dynamics)
Maps to GSD: "Context" section

### Target Users
Source: users dimension (Primary User Persona + User Jobs)
Maps to GSD: Requirements scoping, personas

### Technical Constraints
Source: tech dimension (Architecture, Stack, Constraints)
Maps to GSD: "Constraints" section

### Competitive Edge
Source: competitors dimension (Advantages + Positioning)
Maps to GSD: "Context" + differentiation in Requirements

### Revenue Model
Source: business dimension (Revenue Model + Key Metrics)
Maps to GSD: Business model context for Requirements
```

## HANDOFF.md to GSD Compatibility Mapping

This is the critical mapping that ensures HANDOFF.md works as input to `/gsd:new-project --auto`.

GSD's auto mode reads the provided document and extracts project context to synthesize PROJECT.md. The document must contain enough information for GSD to populate:

| GSD PROJECT.md Field | HANDOFF.md Source Section | Content Needed |
|---------------------|--------------------------|----------------|
| What This Is | Product Vision | 2-3 sentence product description |
| Core Value | Product Vision | The ONE thing that must work |
| Requirements > Active | All 6 sections | Actionable capability statements |
| Out of Scope | Any section's "explicitly deferred" items | What NOT to build |
| Context | Problem & Opportunity + Competitive Edge | Background for implementation |
| Constraints | Technical Constraints | Tech stack, timeline, dependencies |
| Key Decisions | Any section with clear decisions | Choices already made during brainstorming |

**Critical insight:** HANDOFF.md should use DECLARATIVE language ("The product is X", "Users are Y", "The stack uses Z") not exploratory language ("We explored X", "The user mentioned Y"). GSD needs decisions, not a record of brainstorming.

## Document Relationship Chain

```
IDEA.md + dimensions/*.md
        |
        v
   ANALYSIS.md  (systematic: themes, gaps, coverage)
        |
        v
   SYNTHESIS.md  (narrative: cohesive story for stakeholders)
        |
        v
   HANDOFF.md   (actionable: structured brief for builders)
```

Each document adds a layer of processing:
- ANALYSIS.md: raw cross-dimensional pattern extraction (working document)
- SYNTHESIS.md: narrative integration for human understanding (client document)
- HANDOFF.md: structured extraction for machine consumption (builder document)

The handoff can skip SYNTHESIS.md (works from ANALYSIS.md or dimensions directly) but the output will be less nuanced. The command should NOT indicate the source level in the output -- the document stands on its own.

## Install.sh Impact

**No changes needed.** The installer symlinks `commands/brain/` as a directory (line 110: `link_dir "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain" "commands/brain/"`). Any new .md file added to `commands/brain/` is automatically available after restart. The new `analyze.md` command file will be picked up automatically.

Similarly, `agents/brain-synthesizer.md` is already symlinked by the agent loop (lines 116-123: iterates over `agents/brain-*.md`). Replacing the stub content doesn't require any installer changes.

## brain:new Archive Step

The `/brain:new` command already archives SYNTHESIS.md and HANDOFF.md when starting fresh (lines 46-48 of new.md). ANALYSIS.md is NOT archived -- this needs to be added. The archive step should include:

```bash
[ -f .brainstorm/ANALYSIS.md ] && mv .brainstorm/ANALYSIS.md "$ARCHIVE_DIR/"
```

This is a small fix to an existing command, not a new command. Include it in the plan.

## SESSION.md Status Updates

The commands should update SESSION.md:
- After analyze: add "Analysis generated" to Session Notes
- After synthesize: add "Synthesis generated" to Session Notes
- After handoff: add "Handoff generated" to Session Notes, update Status from "exploring" to "handoff-complete"

This follows the pattern established by explore.md which updates SESSION.md after each dimension exploration.

## Status Command Reference

The `/brain:status` command's "all dimensions explored" message currently suggests `/brain:synthesize`. With the new command chain, this should be updated to suggest `/brain:analyze` first (since analyze is the prerequisite for synthesize). This is a minor update to an existing command.

## Open Questions

1. **SESSION.md Status field values**
   - What we know: Current values are "initial-brainstorm" and "exploring" (set by new.md and explore.md respectively).
   - What's unclear: Should the status progression be "exploring" -> "analyzing" -> "synthesizing" -> "handoff-complete"? Or simpler: "exploring" -> "handoff-complete"?
   - Recommendation: Keep it simple. Only add "handoff-complete" as a final status. The intermediate steps (analyze, synthesize) are tracked via Session Notes entries, not status transitions. This avoids complicating the state machine.

2. **Should /brain:status suggest /brain:analyze when all dimensions are explored?**
   - What we know: Currently status.md suggests `/brain:synthesize` when all dimensions are explored.
   - What's unclear: Should it suggest `/brain:analyze` instead (since analyze is the first step)?
   - Recommendation: Update to suggest `/brain:analyze` since that's the entry point of the chain. The user can always skip to `/brain:handoff` directly if they want.

3. **Should commands display the full generated document or just a summary?**
   - What we know: The commands are non-interactive. The user needs feedback on what was produced.
   - What's unclear: Showing a full multi-page SYNTHESIS.md in the terminal is unwieldy. Showing just "File created" is too terse.
   - Recommendation: Show a structured summary (key themes found, document length, gaps identified) plus the file path. Similar to how explore.md shows a riepilogo before writing artifacts. For HANDOFF.md specifically, show all 6 section headings with one-line summaries.

## Sources

### Primary (HIGH confidence)

- **Project codebase** -- Read all 13 command files, 3 agent files, 6 templates, 4 reference files. File patterns, tool usage, YAML frontmatter, validation gates, SESSION.md update patterns are all established and consistent.
- **GSD new-project workflow** -- Read `/home/brusc/.claude/get-shit-done/workflows/new-project.md` and `/home/brusc/.claude/get-shit-done/templates/project.md`. The auto mode document consumption pattern and PROJECT.md field structure are clear.
- **install.sh** -- Verified symlink strategy: commands/brain/ is a directory symlink, agents/brain-*.md are individual file symlinks. No installer changes needed.

### Secondary (MEDIUM confidence)

- **GSD compatibility** -- The mapping from HANDOFF.md sections to GSD PROJECT.md fields is inferred from the GSD workflow's auto mode behavior and the project template structure. HIGH confidence on the structure, MEDIUM confidence on exactly how GSD extracts content from freeform documents (it uses LLM synthesis, so exact formatting matters less than clear content).

### Tertiary (LOW confidence)

None. This phase is entirely internal to the project with no external dependencies.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- No external dependencies. Pure markdown-as-prompt files using established project patterns.
- Architecture: HIGH -- Three thin commands + one fat agent. Pattern well-established by Phases 2-5. Prerequisite chain is simple (file existence checks).
- Pitfalls: HIGH -- All pitfalls are prompt engineering concerns, not technical. Identified from analysis of what makes document generation prompts succeed or fail.
- GSD compatibility: MEDIUM -- HANDOFF.md to GSD mapping is inferred, not tested. The mapping logic is sound but real-world validation will confirm.

**Research date:** 2026-03-09
**Valid until:** No expiry -- internal project patterns, no external dependencies that could change.
