# Phase 2: New Session Flow - Research

**Researched:** 2026-03-05
**Domain:** Claude Code command prompt engineering, interactive conversational flows, markdown artifact generation
**Confidence:** HIGH

## Summary

Phase 2 delivers the first vertical slice of Brain Suite: the user runs `/brain:new` and engages in a free-flowing brainstorming conversation that produces `.brainstorm/IDEA.md` and `.brainstorm/SESSION.md`. The core technical challenge is not code but **prompt engineering** -- crafting the `commands/brain/new.md` file so that Claude conducts a natural Socratic conversation while internally tracking coverage of three core points (problem, target audience, rough solution), then distills the conversation into clean, emergent-structure artifacts.

The architecture is deliberately simple: a single command `.md` file contains all instructions. No agent spawning, no orchestrator, no tool chain. Claude reads reference files (voice-interaction.md, questioning.md) at the start of the conversation and follows them throughout. The command also handles edge cases: existing session detection, archival of previous sessions, and session closure with recap-confirm-save-suggest flow.

The highest-risk element is **prompt quality** -- getting the conversational behavior right so it feels like brainstorming, not a questionnaire. The reference files from Phase 1 (voice-interaction.md, questioning.md) already define the voice and methodology. Phase 2's job is to wire them into a concrete command prompt with clear state tracking, conversation flow, and artifact generation instructions.

**Primary recommendation:** Implement `/brain:new` as a single comprehensive command `.md` file that loads reference files via Read tool at runtime, guides multi-turn Socratic conversation with internal coverage tracking, and produces emergent-structure IDEA.md + SESSION.md on session closure. No subagent, no external tooling.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Architecture**
- `/brain:new` is a direct command (skill), NOT an agent spawn. Claude conducts the conversation directly, loading reference files (voice-interaction.md, questioning.md, dimensions-guide.md) into context
- brain-explorer agent is NOT used in this phase -- multi-turn conversation with a subagent is impractical (context loss, latency, breaks natural flow)
- brain-explorer agent may be reconsidered for Phase 3 (`/brain:explore`) where tasks could be more autonomous

**Initial questioning flow**
- **Open canvas** start -- Claude opens with an open question ("What's the idea?"), user leads
- **Soft coverage** on 3 core points: problem, target audience, rough solution. Claude tracks these internally but does NOT follow a rigid structure -- the conversation is free-flowing brainstorming
- The user may not even realize they're covering these points. Claude extracts them from natural conversation
- When Claude judges all 3 points are understood (even roughly), it proposes to save. If the user wants to keep brainstorming, conversation continues without pressure

**Idea evolution tracking**
- If the idea mutates during conversation, Claude tracks the evolution -- both starting point and where it ended up
- If Claude notices a significant divergence, it signals it lightly (a brief note, not a formal intervention)
- This is not a strict rule -- if the divergence is obvious, document it. If not, don't force it

**Conversation flow**
- Follows the flusso: if the user spontaneously enters dimensional territory (competitors, tech, market), Claude follows the conversation naturally
- No file dimensionali separati are produced -- everything goes into IDEA.md
- The conversation is brainstorming, not an interview. The user may discover what they need along the way

**Session closure**
- **Recap + confirm** before saving -- Claude shows a summary of what it understood, user can correct or add, then save
- **Save + suggest** -- After saving, Claude suggests which dimension to explore first, based on what emerged in the conversation (not a fixed order)

**Existing session handling**
- If `.brainstorm/` already exists when `/brain:new` is called, Claude asks the user: start fresh or continue with existing idea?
- **Start fresh** -- archives previous session to `.brainstorm/archive/` before creating new files
- **Continue** -- redirects to `/brain:resume` (fallback, no duplication of resume logic)
- **One idea at a time** -- `.brainstorm/` always contains a single active idea. Previous ideas go to archive

**IDEA.md format**
- **Emergent structure** -- sections reflect what actually came out of the conversation, not a fixed template. If the user talked mostly about the problem and barely about the solution, the file reflects that
- **Distilled** -- clean, concise, substance only. Conversational noise removed. Not raw transcript
- **Evolution section** -- dedicated section documenting how the idea evolved during the session, if it changed
- **Dimensional hints** -- if dimensional topics (market, tech, competitors) emerged naturally, they're captured in a "spunti emersi" section without forcing dimensional structure

**SESSION.md**
- Claude's discretion on structure and content for Phase 2, with awareness that Phase 3 and 4 will need to read it

### Claude's Discretion

- SESSION.md structure and content (must be readable by Phase 3 and 4)
- Exact prompt wording for the command file
- How reference files are loaded into context
- Internal coverage tracking mechanism
- Archive directory naming/structure
- Opening question wording

### Deferred Ideas (OUT OF SCOPE)

- brain-explorer as spawned agent for dimension exploration -- Phase 3 consideration
- Multiple simultaneous ideas -- out of scope, one active idea at a time
- `/brain:resume` implementation -- Phase 4

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CORE-01 | User can start a brainstorming session with `/brain:new` that creates `.brainstorm/` with IDEA.md and SESSION.md through interactive Socratic questioning | Command `.md` file guides multi-turn conversation. Write tool creates artifacts. Existing session detection and archival logic included. |
| CORE-07 | All interactions follow voice-first patterns: responses short and scannable, one question at a time, summary before question, tolerance for informal spoken input | Reference file `voice-interaction.md` (already authored in Phase 1) defines all patterns. Command loads this file at startup and instructs Claude to follow it. |
| AGT-01 | brain-explorer agent guides interactive Socratic exploration with voice-first patterns and assumption challenging | Per CONTEXT.md locked decision: in Phase 2, the "brain-explorer" behavior is embedded directly in the `/brain:new` command, not spawned as a subagent. The brain-explorer agent file will be updated with the conversational instructions so it's available for Phase 3. |
| SESS-01 | Session state persists in `.brainstorm/SESSION.md` tracking explored dimensions, dates, and notes | SESSION.md is created at session close with structured state. Must be readable by future phases (resume, status, explore). |

</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Claude Code command `.md` | Current | Interactive conversation prompt with full behavioral instructions | Native mechanism for Claude Code slash commands -- no external dependencies |
| Read tool | Built-in | Load reference files (voice-interaction.md, questioning.md) into context at runtime | Standard Claude Code tool for file reading. Used because `@` references require absolute paths which are user-specific |
| Write tool | Built-in | Create `.brainstorm/IDEA.md` and `.brainstorm/SESSION.md` at session close | Standard Claude Code tool for file creation |
| Bash tool | Built-in | Check directory existence, create archive directories, move files | Used for filesystem operations (mkdir, mv, test) |
| Glob tool | Built-in | Detect existing `.brainstorm/` content for session handling | Used to check for existing session artifacts |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Grep tool | Built-in | Search existing IDEA.md/SESSION.md for content | Only during existing session detection |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Read tool for references | `@` static file includes | `@` requires absolute paths (`@/home/user/.claude/...`) which are user-specific. Symlinked command files can't contain hardcoded user paths. Read tool resolves symlinks at runtime. |
| Direct command (skill) | Agent spawn (brain-explorer) | CONTEXT.md locked: subagent would lose multi-turn context, add latency, break conversational flow. Direct command is correct for Phase 2. |
| Emergent IDEA.md structure | Fixed template | CONTEXT.md locked: sections reflect what came out of conversation, not a predefined template. More natural, better represents actual brainstorming output. |

**Installation:** No additional installation. All tools are Claude Code built-ins. Reference files installed in Phase 1.

## Architecture Patterns

### Recommended Project Structure

```
commands/brain/
└── new.md                      # Full command prompt (the primary deliverable)

agents/
└── brain-explorer.md           # Updated with behavioral instructions (for Phase 3 reuse)

.brainstorm/                    # Created at runtime by /brain:new
├── IDEA.md                     # Distilled idea definition (emergent structure)
├── SESSION.md                  # Session state (dates, dimensions list, notes)
└── archive/                    # Previous sessions (created on "start fresh")
    └── <timestamp>/            # Archived IDEA.md + SESSION.md
        ├── IDEA.md
        └── SESSION.md
```

### Pattern 1: Command as Conversational Prompt

**What:** The command `.md` file contains the full behavioral instructions for a multi-turn interactive conversation. Claude reads it when the user invokes `/brain:new` and follows the instructions throughout the entire conversation.

**When to use:** Any Claude Code command that needs to guide extended user interaction (not just single-response commands).

**Key structure:**
```markdown
# /brain:new

[Command metadata and description]

<execution_context>
[Instructions to load reference files via Read tool]
</execution_context>

<conversation_flow>
[Phase-by-phase instructions: startup checks, opening, questioning, tracking, closure]
</conversation_flow>

<behavioral_rules>
[Voice-first patterns, one question rule, coverage tracking]
</behavioral_rules>

<artifact_generation>
[IDEA.md structure, SESSION.md structure, how to distill conversation]
</artifact_generation>
```

**Critical insight:** The command file is the ONLY prompt Claude has. It must be self-contained and comprehensive. Unlike a program with runtime logic, there is no fallback -- if the instructions are ambiguous, Claude will improvise (which may not match user expectations).

### Pattern 2: Runtime Reference Loading

**What:** Instead of `@` static file includes (which require absolute paths), the command instructs Claude to Read reference files at conversation start. Files are located via the stable symlink path `~/.claude/brain-suite/references/`.

**Why:** Brain Suite commands are symlinked from the repo. The repo file can't contain hardcoded absolute paths like `@/home/brusc/.claude/brain-suite/references/voice-interaction.md` because that path is user-specific. GSD solves this by installing real files (not symlinks) with processed paths. Brain Suite uses symlinks, so it must use runtime resolution.

**Implementation:**
```markdown
## Setup

Before starting the conversation, load the methodology reference files:

1. Read `~/.claude/brain-suite/references/voice-interaction.md` — voice and interaction patterns
2. Read `~/.claude/brain-suite/references/questioning.md` — questioning methodology

Follow these references throughout the entire conversation.
```

**Alternative approach:** Use the known repo path derived from the symlink. The command could instruct Claude to resolve the repo path via `readlink ~/.claude/brain-suite/references` and then read files from the repo directly. This is more complex but avoids hardcoding `~/.claude/` paths.

**Recommended approach:** Use `$HOME/.claude/brain-suite/references/` since this is the stable install path per Phase 1. The `~` tilde expands correctly in Read tool paths.

### Pattern 3: Internal Coverage Tracking

**What:** Claude internally tracks which of the 3 core points (problem, target audience, rough solution) have been covered during conversation, without exposing the tracking to the user.

**When to use:** Any conversational flow that needs to ensure certain topics are covered without imposing a rigid structure.

**How it works in the prompt:**
```markdown
## Internal Coverage Tracking

Track these 3 core points internally. Do NOT show this tracking to the user or follow a rigid order:

1. **Problem**: What pain point or need does this idea address?
2. **Target audience**: Who would use/benefit from this?
3. **Rough solution**: What's the general approach or concept?

As the conversation flows naturally, note when a point is sufficiently covered (even roughly or implicitly). The user may cover these spontaneously without being asked directly.

When all 3 points are covered to a reasonable degree, you MAY propose saving. But:
- If the user is still actively brainstorming, let them continue
- If the user seems to be winding down, suggest saving
- Never pressure or rush toward closure
```

### Pattern 4: Recap-Confirm-Save Flow

**What:** Before creating artifacts, Claude shows a summary of what it understood, the user can correct or add, then save happens.

**Why:** Prevents artifacts from containing misunderstandings. Gives the user one last chance to adjust.

**Flow:**
1. Claude proposes saving (when coverage is reached or user signals done)
2. Claude shows a structured recap of key points understood
3. User reviews: confirms, corrects, or adds
4. If corrections: Claude incorporates and shows updated recap
5. On confirmation: Claude creates IDEA.md and SESSION.md

### Pattern 5: Existing Session Detection and Archival

**What:** On startup, check if `.brainstorm/` exists. If it does, offer choices.

**Flow:**
```
IF .brainstorm/ exists AND contains IDEA.md:
  → Ask user: "Start fresh or continue with existing idea?"
  → Start fresh:
    - Create .brainstorm/archive/<ISO-date>/
    - Move IDEA.md and SESSION.md to archive
    - Also move dimensions/ and sessions/ if they exist
    - Proceed with new session
  → Continue:
    - Tell user to use /brain:resume instead
    - End command
ELSE:
  → Create .brainstorm/ and start new session
```

### Anti-Patterns to Avoid

- **Questionnaire mode:** Never ask "What's the problem? What's the audience? What's the solution?" as a sequence. The conversation is free-flowing. These points emerge naturally.
- **Over-structured IDEA.md:** Don't force sections for all 3 core points if one wasn't discussed much. Emergent structure means the file reflects reality.
- **Hardcoded `@` paths in symlinked commands:** `@/home/user/...` paths break on other machines. Use Read tool instead.
- **Raw transcript in IDEA.md:** IDEA.md is distilled, not a conversation log. Remove all conversational noise (greetings, filler, "um", repetition).
- **Multiple questions per response:** The one-question rule from voice-interaction.md is non-negotiable. Even when coverage seems low.
- **Formal tone:** "Let us explore your value proposition" is wrong. "So what actually makes this different?" is right.
- **Agent spawn for Phase 2:** CONTEXT.md explicitly locks this as a direct command. Do not spawn brain-explorer.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Conversation state machine | Custom JSON state tracking between turns | Claude's natural conversation memory within a session | Claude maintains context within a single session. No external state needed during conversation. |
| IDEA.md templating engine | Markdown template with variable substitution | Claude's natural language generation with structural guidance | Emergent structure means no template. Claude distills based on what was discussed. |
| Session archival logic | Complex backup/restore system | Simple `mkdir + mv` via Bash tool | Archive is just moving files to a timestamped subdirectory. |
| Reference file caching | Preloading mechanism or context injection | Read tool at conversation start | Claude Code's Read tool handles this natively. |

**Key insight:** This phase produces no executable code. The entire deliverable is markdown prompt engineering. The "stack" is Claude Code's built-in tools. The complexity is in prompt quality, not software architecture.

## Common Pitfalls

### Pitfall 1: Prompt Loses Effectiveness Over Long Conversations

**What goes wrong:** After many turns of brainstorming, Claude "forgets" the voice-first patterns and starts giving long monologues, asking multiple questions, or using formal tone.

**Why it happens:** Initial instructions drift in importance as the conversation grows and fills the context window.

**How to avoid:**
- Keep the behavioral rules section prominent and concise in the command file
- Use strong imperative language: "ALWAYS one question. NEVER two." not "Try to keep to one question."
- Include a self-check instruction: "Before each response, verify: (1) Is it under 8 lines before the question? (2) Is there exactly one question? (3) Am I adding value, not just parroting?"
- Place critical behavioral rules near the END of the command file (recency bias in LLM attention)

**Warning signs:** Responses grow longer over time. Multiple questions appear. Formal language creeps in.

### Pitfall 2: IDEA.md Becomes a Transcript Instead of a Distillation

**What goes wrong:** The generated IDEA.md reads like a slightly edited conversation log rather than a clean, distilled document.

**Why it happens:** Claude has the full conversation in context and may default to summarizing each exchange rather than synthesizing across the entire conversation.

**How to avoid:**
- Explicitly instruct: "Write IDEA.md as if someone who was NOT in the conversation needs to understand the idea. Remove all conversational artifacts."
- Provide structural guidance: "Each section should read as a standalone paragraph, not a Q&A pair."
- Include negative examples in the prompt: "NOT: 'The user mentioned that the problem is X.' YES: 'The core problem: X.'"

**Warning signs:** Phrases like "you mentioned", "we discussed", "as you said" in IDEA.md.

### Pitfall 3: Coverage Tracking Becomes Visible to User

**What goes wrong:** Claude starts asking directed questions that reveal it's tracking coverage: "We've talked about the problem and audience. Now let's discuss the solution."

**Why it happens:** The coverage tracking instructions are too prominent or too specific, causing Claude to treat them as a checklist.

**How to avoid:**
- Frame coverage as observational, not directional: "Note when these emerge, don't steer toward them"
- Use "soft coverage" language: "roughly understood" not "covered" or "checked off"
- Emphasize: "The user should never feel like they're going through a checklist"

**Warning signs:** Claude says "Let's move on to..." or explicitly names the core points.

### Pitfall 4: Dimension Suggestion Feels Generic

**What goes wrong:** After saving, Claude suggests exploring "product dimension" or uses a fixed order instead of basing the suggestion on what emerged in the conversation.

**Why it happens:** The prompt doesn't provide enough guidance on how to connect conversation content to dimension recommendations.

**How to avoid:**
- Instruction: "Suggest the dimension that most directly relates to what the user was most engaged with or where the biggest unknowns remain"
- Include examples: "If the user talked a lot about competitors, suggest competitors dimension. If they expressed uncertainty about tech, suggest tech."
- Reference dimensions-guide.md for the dimension descriptions so Claude can match conversation topics to dimensions

**Warning signs:** Same dimension always suggested. Suggestion doesn't reference anything from the conversation.

### Pitfall 5: Existing Session Archival Loses Dimension Files

**What goes wrong:** When archiving an existing session, only IDEA.md and SESSION.md are moved but `.brainstorm/dimensions/` and `.brainstorm/sessions/` are left behind, creating a messy state.

**Why it happens:** The archival instructions only mention the core files.

**How to avoid:** Explicitly list all possible artifacts to archive:
```
Move to archive/:
- IDEA.md
- SESSION.md
- dimensions/ (if exists)
- sessions/ (if exists)
- SYNTHESIS.md (if exists)
- HANDOFF.md (if exists)
```

**Warning signs:** After "start fresh", old dimension files are mixed with new session.

### Pitfall 6: `$HOME` or `~` Path Resolution in Read Tool

**What goes wrong:** The Read tool might not resolve `~` or `$HOME` in paths, causing reference file loading to fail.

**Why it happens:** `~` is a shell expansion, not a filesystem concept. The Read tool may expect absolute paths.

**How to avoid:**
- Test empirically: does `Read("~/.claude/brain-suite/references/voice-interaction.md")` work?
- Fallback: instruct Claude to resolve the path via Bash first: `echo $HOME/.claude/brain-suite/references/` and then use the resolved absolute path with Read
- Alternative: Use the known repo path. Since the command file itself is in the repo (symlinked), Claude could derive the repo path from the command file location

**Warning signs:** "File not found" errors when loading reference files.

## Code Examples

### Example 1: Command File Structure for /brain:new

```markdown
# /brain:new

Start a new brainstorming session. Creates `.brainstorm/` with IDEA.md
and SESSION.md through interactive Socratic questioning.

## Setup

Before starting the conversation:

1. Resolve reference file path:
   ```bash
   BRAIN_SUITE_REF="$HOME/.claude/brain-suite/references"
   ```
2. Read the reference files:
   - Read `$BRAIN_SUITE_REF/voice-interaction.md`
   - Read `$BRAIN_SUITE_REF/questioning.md`
   - Read `$BRAIN_SUITE_REF/dimensions-guide.md`
3. Check if `.brainstorm/` exists [existing session handling logic]

## Conversation

[behavioral rules, coverage tracking, flow instructions]

## Session Closure

[recap-confirm-save-suggest flow, artifact generation]
```

### Example 2: SESSION.md Structure (Recommended)

```markdown
# Brainstorming Session

**Idea:** [one-line summary from IDEA.md]
**Started:** 2026-03-05
**Last updated:** 2026-03-05
**Status:** initial-brainstorm

## Explored Dimensions

| Dimension | Status | Date | Notes |
|-----------|--------|------|-------|
| product | not started | - | - |
| tech | not started | - | - |
| market | not started | - | - |
| business | not started | - | - |
| competitors | not started | - | - |
| users | not started | - | - |

## Session Notes

- Initial brainstorming session via /brain:new
- [Key observations from the conversation]
- Suggested next: [dimension] (based on conversation)

## Idea Evolution

[If the idea changed during the session, brief note here]
```

### Example 3: IDEA.md Emergent Structure

```markdown
# [Idea Name]

> [One-sentence elevator pitch distilled from conversation]

## The Problem

[Distilled description of the pain point, who feels it, severity.
Written as a standalone section, not a conversation summary.]

## Who It's For

[Target audience as understood from the conversation.
May be broad or specific depending on how much was discussed.]

## The Approach

[Rough solution concept. Level of detail matches what was discussed.
If the user stayed high-level, this stays high-level.]

## How the Idea Evolved

[Only if the idea mutated during conversation.
Documents starting point and where it ended up.
Omit this section entirely if the idea was stable.]

## Emerging Threads

[Dimensional hints that came up naturally.
"The user mentioned competitors X and Y"
"Tech constraint Z was flagged"
These are seeds for future dimension exploration.]

---
*Generated by /brain:new on 2026-03-05*
*Source: interactive brainstorming session*
```

### Example 4: Archive Directory Structure

```bash
# When user chooses "start fresh" with existing session:
.brainstorm/
└── archive/
    └── 2026-03-01T14-30-00/     # ISO timestamp (colons replaced for filesystem)
        ├── IDEA.md
        ├── SESSION.md
        ├── dimensions/          # if existed
        └── sessions/            # if existed
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Agent-based conversation | Direct command with loaded references | Phase 2 CONTEXT.md decision | Avoids context loss, latency, and unnatural flow from subagent |
| Fixed IDEA.md template | Emergent structure reflecting conversation | Phase 2 CONTEXT.md decision | More honest representation of brainstorming output |
| Separate dimension files from /brain:new | Everything in IDEA.md with dimensional hints | Phase 2 CONTEXT.md decision | Simpler Phase 2 output. Dimension files come in Phase 3 |

**Validated as current (2026-03-05):**
- Claude Code commands support multi-turn conversation natively -- the command `.md` content persists as system-level instructions throughout the session
- `@` file includes support both relative paths (from CWD) and absolute paths
- Symlinked command files are read transparently by Claude Code (filesystem follows symlinks)
- `$ARGUMENTS` in command files captures full input after the command name
- Read tool can load files through symlinks

## Open Questions

1. **`~` expansion in Read tool paths**
   - What we know: Bash expands `~` to `$HOME`. Read tool may or may not.
   - What's unclear: Whether `Read("~/.claude/brain-suite/references/voice-interaction.md")` works directly.
   - Recommendation: In the command prompt, instruct Claude to resolve the path via Bash `echo $HOME/...` first, then use the absolute path with Read. Alternatively, use `$HOME` directly if Read tool supports environment variable expansion. **Validate empirically during implementation.**

2. **Context window budget for reference files**
   - What we know: voice-interaction.md is ~84 lines, questioning.md is ~125 lines, dimensions-guide.md is ~161 lines. Total ~370 lines (~5-7K tokens estimated).
   - What's unclear: Whether loading all 3 reference files at startup leaves sufficient context for a long brainstorming conversation.
   - Recommendation: Load voice-interaction.md (essential for tone) and a condensed version of the coverage guidance. questioning.md full content is more relevant to Phase 3 (dimension exploration with modes). For Phase 2, only the Socratic mode section is needed. dimensions-guide.md is needed at closure (for dimension suggestion) but could be loaded at that point rather than at startup.

3. **brain-explorer.md agent file update**
   - What we know: Phase 2 CONTEXT.md says brain-explorer is NOT used as a subagent. But AGT-01 requires the brain-explorer agent to exist with behavioral instructions.
   - What's unclear: Should Phase 2 update brain-explorer.md with the full conversational behavior (for Phase 3 reuse), or keep it as a stub and let Phase 3 fill it in?
   - Recommendation: Update brain-explorer.md with the core behavioral instructions (voice patterns, questioning approach, coverage tracking). This satisfies AGT-01 and gives Phase 3 a head start. The `/brain:new` command file and brain-explorer.md can share the same behavioral core, with the command adding Phase-2-specific logic (session creation, archival, etc.).

## Sources

### Primary (HIGH confidence)

- Phase 1 delivered files: `references/voice-interaction.md`, `references/questioning.md`, `references/dimensions-guide.md`, `references/frameworks.md` -- directly inspected (2026-03-05)
- Phase 1 `install.sh` -- verified symlink architecture: `~/.claude/brain-suite/references/` is the stable path for reference files
- Phase 2 `02-CONTEXT.md` -- all locked decisions directly sourced from this file
- GSD command file patterns (`discuss-phase.md`, `new-project.md`, `execute-phase.md`) -- analyzed for `@` reference syntax, `$ARGUMENTS`, and multi-turn conversation patterns
- Live system analysis: GSD commands at `~/.claude/commands/gsd/` -- confirmed `@` reference syntax with both absolute and relative paths

### Secondary (MEDIUM confidence)

- GSD agent patterns (`gsd-executor.md`) -- analyzed for agent prompt structure and behavioral instruction patterns
- Context window budget estimation for reference files -- based on line counts, not empirical token measurement

### Tertiary (LOW confidence)

- `~` tilde expansion in Read tool -- assumed to work based on general Unix behavior, but not empirically validated within Claude Code's Read tool implementation
- Long conversation instruction drift -- based on general LLM behavior patterns, not Brain Suite-specific testing

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all tools are Claude Code built-ins, no external dependencies
- Architecture patterns: HIGH -- command-as-prompt pattern validated via GSD analysis, reference loading via Read tool is straightforward
- Artifact generation (IDEA.md, SESSION.md): HIGH -- Write tool is standard, emergent structure is well-defined in CONTEXT.md
- Prompt engineering quality: MEDIUM -- the behavioral instructions are well-defined in reference files, but actual effectiveness requires empirical testing during brainstorming sessions
- Pitfalls: MEDIUM -- based on LLM interaction patterns and prompt engineering experience, not Brain Suite-specific testing

**Research date:** 2026-03-05
**Valid until:** 2026-06-05 (stable domain -- Claude Code command system + prompt engineering)
