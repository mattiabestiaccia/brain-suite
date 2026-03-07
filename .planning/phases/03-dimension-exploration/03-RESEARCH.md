# Phase 3: Dimension Exploration - Research

**Researched:** 2026-03-07
**Domain:** Claude Code interactive command prompts, multi-file artifact generation, cross-context awareness, conversational mode selection
**Confidence:** HIGH

## Summary

Phase 3 delivers the core exploration loop of Brain Suite: the user runs `/brain:explore product` (or any of 6 dimensions, or a shortcut like `/brain:product`) and engages in a guided conversation that produces two artifacts -- a structured dimension document (`dimensions/<dimension>.md`) and a cleaned session log (`sessions/<dimension>-<date>.md`). The conversation follows the same voice-first patterns established in Phase 2, but adds dimension-specific behavior: mode selection per dimension (Socratic/Challenger/Creative), template-guided section coverage with hybrid depth gating, cross-dimensional awareness from previously explored dimensions, and a richer closure flow with pre-save summary and user correction.

The primary implementation challenge is the `/brain:explore` command file itself. Like `/brain:new` (Phase 2), this is a **markdown-as-prompt** pattern -- the command `.md` file contains the full behavioral instructions for a multi-turn interactive conversation. It is NOT a subagent spawn. Claude reads the command file when the user invokes `/brain:explore <dimension>` and follows the instructions throughout the entire conversation. The brain-explorer agent file (`agents/brain-explorer.md`) serves as a behavioral specification reference but is NOT spawned via the Task tool -- spawning would break multi-turn conversation context (same conclusion as Phase 2, validated empirically).

The shortcut commands (`/brain:product`, `/brain:tech`, etc.) should delegate to `/brain:explore` by embedding the dimension name and invoking the explore command's behavior. This avoids duplicating the entire exploration logic across 6 files.

**Primary recommendation:** Implement `/brain:explore` as a single comprehensive command `.md` file (the primary deliverable). It loads IDEA.md, SESSION.md, all existing dimension files, reference files, and the target dimension template at startup. The shortcut commands are thin wrappers that set the dimension name and delegate to the explore behavior. SESSION.md is updated on completion to track explored dimensions.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Apertura e flusso dell'esplorazione
- L'explorer apre con un riepilogo di cio che IDEA.md dice sulla dimensione corrente, poi parte con la prima domanda mirata
- Flusso di conversazione libero iniziale; dopo qualche passaggio, l'explorer copre esplicitamente le sezioni del template non ancora toccate
- L'explorer suggerisce la chiusura quando i punti chiave sono coperti (hybrid depth gating), ma l'utente decide se continuare o chiudere
- Prima del salvataggio: l'explorer presenta un riepilogo finale e chiede conferma ("Va bene cosi o vuoi aggiustare qualcosa?"), poi salva

#### Formato degli artefatti dimensionali
- Il documento dimensionale (`dimensions/<dimension>.md`) usa il template completo con tutte le sezioni sempre presenti
- Sezioni discusse: popolate con il contenuto emerso dal dialogo
- Sezioni non discusse: placeholder con 1-2 domande-spunto dal template per ricordare cosa andrebbe coperto
- Il session log (`sessions/<dimension>-<date>.md`) e un transcript distillato in formato Q&A -- rimuove cortesie, ripetizioni e rumore, mantiene tutti i contenuti sostanziali
- Le correzioni fatte dall'utente nel riepilogo pre-salvataggio si riflettono solo nel documento dimensionale; il session log resta fedele alla conversazione originale

#### Esperienza cross-dimensionale
- L'explorer carica tutto il contesto disponibile prima di iniziare: IDEA.md + tutti i documenti dimensionali gia completati
- Connessioni e contraddizioni tra dimensioni vengono fatte emergere in modo reattivo, quando e naturale nel flusso della conversazione (non forzate)
- Quando una contraddizione viene identificata: l'explorer la segnala, la annota, e suggerisce una possibile risoluzione o quale dimensione rivisitare
- Le note cross-dimensionali compaiono sia inline (dove emergono) sia raccolte in una sezione dedicata "Cross-dimensional notes" a fine documento

#### Selezione e switch delle modalita
- All'inizio dell'esplorazione, l'explorer menziona brevemente la modalita default (es. "Per Product partiamo in modalita creativa -- ci stai?")
- L'explorer puo proporre uno switch di modalita quando lo ritiene utile (es. "Stai dando molto per scontato -- vuoi che faccia il challenger per un momento?")
- Gli switch sono temporanei per default: 2-3 scambi nella modalita alternativa, poi ritorno al default
- La modalita usata non viene tracciata negli artefatti -- conta il contenuto, non il processo

### Claude's Discretion
- Quanti scambi di dialogo libero prima di passare alla copertura esplicita delle sezioni mancanti
- Formulazione esatta dei placeholder per sezioni non esplorate
- Quando e come far emergere le connessioni cross-dimensionali (judgment call contestuale)
- Formato esatto del riepilogo pre-salvataggio

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CORE-02 | User can explore any dimension interactively via `/brain:explore <dimension>` with guided Socratic dialogue | `/brain:explore` command file guides multi-turn conversation with dimension-specific template loading. `$ARGUMENTS` captures dimension name. Voice-first patterns and questioning modes from reference files and brain-explorer agent spec. |
| CORE-03 | User can explore dimensions in any order, skip dimensions, and revisit already-explored dimensions (non-linear) | No enforced ordering. Command checks SESSION.md for dimension status but does not restrict exploration order. Revisitation detection (already explored) is Phase 4 scope (SESS-03), but the command should note if a dimension file already exists and proceed normally (overwrite with new content). |
| CORE-04 | Explorer challenges user's assumptions constructively during exploration (assumption challenging mode) | brain-explorer agent spec (205 lines, Phase 2 output) already contains assumption challenging behavior section. `/brain:explore` command references this behavior. Challenger mode provides systematic assumption testing. |
| CORE-05 | Explorer suggests when key points of a dimension are covered, but user decides to continue or stop (hybrid depth gating) | Template sections serve as coverage anchors. Explorer tracks which sections have been touched with substantive content. When all key sections are covered, suggests moving to closure. User decides. |
| CORE-06 | User can choose exploration mode (Socratic, devil's advocate, creative/divergent) per dimension | Per-dimension default modes defined in brain-explorer agent spec. Explorer announces default at conversation start, user can accept or change. User can also request mode switches mid-conversation. |
| DIM-01 | 6 built-in dimensions available: product, tech, market, business, competitors, users | Templates already exist (Phase 1 output): `templates/product.md`, `templates/tech.md`, etc. Dimensions-guide.md documents all 6 with key questions and purpose. |
| DIM-02 | Each dimension has a dedicated template that defines structured output sections | Templates authored in Phase 1. Each has 5-6 sections as conversation anchors. Templates are read at runtime by the explore command. |
| DIM-03 | User can launch dimension shortcuts (`/brain:product`, `/brain:tech`, `/brain:market`, `/brain:business`, `/brain:competitors`, `/brain:users`) | Shortcut command files exist as stubs (Phase 1 output). Phase 3 replaces stubs with thin wrappers that delegate to `/brain:explore` behavior. |
| ART-01 | Each dimension exploration produces a structured markdown file in `.brainstorm/dimensions/<dimension>.md` | Write tool creates dimension file at session closure. Structure follows the dimension template with all sections present. Discussed sections populated, undiscussed sections get placeholder questions. |
| ART-02 | Each exploration session produces a cleaned session log in `.brainstorm/sessions/<dimension>-<date>.md` (conversational noise removed, content intact) | Write tool creates session log at closure. Q&A distilled format: removes cortesie/ripetizioni/rumore, keeps substantive content. User corrections from recap go to dimension file only, not session log (per CONTEXT.md). |

</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Claude Code command `.md` | Current | Interactive conversation prompt with full behavioral instructions | Same pattern as `/brain:new` in Phase 2. Native mechanism, no external dependencies. |
| Read tool | Built-in | Load IDEA.md, SESSION.md, existing dimension files, reference files, and target template at startup | Standard file reading. Context loading is critical for cross-dimensional awareness. |
| Write tool | Built-in | Create `dimensions/<dimension>.md`, `sessions/<dimension>-<date>.md`, and update `SESSION.md` | Standard file creation. Three artifacts generated per exploration session. |
| Bash tool | Built-in | Resolve `$HOME` path, create directories, get current date | Used for path resolution and directory creation (`mkdir -p`). |
| Glob tool | Built-in | Detect existing dimension files, check `.brainstorm/` structure | Used to discover which dimensions have been explored (cross-dimensional loading). |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Grep tool | Built-in | Search SESSION.md for dimension status | Only during startup to determine dimension state |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Direct command (embedded behavior) | Task tool subagent spawn (brain-explorer) | Subagent via Task tool creates a separate context -- the subagent gets a single prompt, executes, and returns. It CANNOT maintain a multi-turn conversation with the user. Phase 2 validated this: direct command is the correct pattern for interactive brainstorming. |
| Full template in dimension file | Only populate discussed sections | CONTEXT.md locked: all sections always present. Undiscussed sections get placeholder questions. |
| Single `/brain:explore` file with all logic | 6 separate dimension command files | Duplication nightmare. Shortcut commands should delegate to explore, not copy its logic. |

**Installation:** No additional installation. All tools are Claude Code built-ins. Reference files and templates installed in Phase 1.

## Architecture Patterns

### Recommended Project Structure

```
commands/brain/
├── explore.md              # Primary explore command (the main deliverable)
├── product.md              # Shortcut → delegates to explore behavior
├── tech.md                 # Shortcut → delegates to explore behavior
├── market.md               # Shortcut → delegates to explore behavior
├── business.md             # Shortcut → delegates to explore behavior
├── competitors.md          # Shortcut → delegates to explore behavior
└── users.md                # Shortcut → delegates to explore behavior

agents/
└── brain-explorer.md       # Behavioral spec (updated, NOT spawned as subagent)

templates/
├── product.md              # Already exists (Phase 1)
├── tech.md                 # Already exists
├── market.md               # Already exists
├── business.md             # Already exists
├── competitors.md          # Already exists
└── users.md                # Already exists

.brainstorm/                # Created at runtime
├── IDEA.md                 # From Phase 2 (/brain:new)
├── SESSION.md              # Updated by explore on completion
├── dimensions/             # Created by explore
│   └── <dimension>.md      # Structured output per dimension
└── sessions/               # Created by explore
    └── <dimension>-<date>.md  # Cleaned session log
```

### Pattern 1: Command as Conversation Prompt with Context Loading

**What:** The `/brain:explore` command file contains the full behavioral instructions for dimension exploration. At startup, it loads ALL available context (IDEA.md, SESSION.md, existing dimension files, reference files, target template) to enable cross-dimensional awareness.

**Why:** Cross-dimensional awareness requires that Claude has read all previously explored dimensions before starting the new one. This means the setup phase is heavier than `/brain:new` -- potentially loading 3-5 files before the first question.

**Context budget concern:** With IDEA.md (~100 lines), SESSION.md (~30 lines), up to 5 existing dimension files (~100-150 lines each), plus reference files (~200 lines), the pre-loaded context could reach ~1000-1200 lines. This is manageable within Claude's 200k context window but worth monitoring. The reference files (voice-interaction.md, questioning.md) should be loaded selectively -- the brain-explorer agent spec already codifies the behavioral rules, so the command can reference the agent's patterns without re-loading the full reference files.

**Implementation:**
```markdown
## Setup

1. Resolve the reference and template paths:
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   BRAIN_TPL=$(echo $HOME/.claude/brain-suite/templates)
   ```

2. Determine which dimension to explore:
   - $ARGUMENTS contains the dimension name
   - Validate against: product, tech, market, business, competitors, users
   - If invalid or missing: tell user the valid options and stop

3. Load context:
   - Read `.brainstorm/IDEA.md` (REQUIRED -- fail if not found, tell user to run /brain:new first)
   - Read `.brainstorm/SESSION.md` (REQUIRED)
   - Read `$BRAIN_TPL/<dimension>.md` (the target dimension template)
   - Read `$BRAIN_REF/questioning.md` (questioning modes for current dimension)
   - Use Glob to find existing dimension files: `.brainstorm/dimensions/*.md`
   - Read ALL existing dimension files (for cross-dimensional context)

4. Create output directories: `mkdir -p .brainstorm/dimensions .brainstorm/sessions`
```

### Pattern 2: Shortcut Command Delegation

**What:** Shortcut commands (`/brain:product`, `/brain:tech`, etc.) are thin wrappers that embed the dimension name and reference the full explore logic. Two approaches are possible:

**Approach A: Inline the dimension and reference explore.md**

Each shortcut file contains a brief instruction that sets the dimension and tells Claude to follow the explore.md behavior. This avoids duplicating the entire explore command but requires that Claude can follow cross-file instructions.

```markdown
# /brain:product

Shortcut for exploring the **product** dimension. Follow the EXACT same process as `/brain:explore product`.

Set `dimension = product` and execute the full exploration flow as defined in the `/brain:explore` command.
```

**Approach B: Full self-contained logic with dimension hardcoded**

Each shortcut contains the complete explore logic with the dimension name embedded. This is more robust (no cross-file reference needed) but creates massive duplication across 6 files.

**Recommended: Approach A.** Claude Code loads the command file as instructions. The shortcut file instructs Claude to behave identically to `/brain:explore <dimension>`. Since both command files are available to Claude (symlinked in `~/.claude/commands/brain/`), Claude can read the explore command and follow it. The shortcut file can include a Read instruction for the explore command.

**Most robust variant of Approach A:**

```markdown
# /brain:product

Explore the **product** dimension. This is a shortcut for `/brain:explore product`.

Read the file at `~/.claude/commands/brain/explore.md` (resolve `~` via Bash first if needed) and follow ALL its instructions with dimension set to `product`.
```

This ensures the shortcut command explicitly loads the explore command's instructions, eliminating any ambiguity.

### Pattern 3: Hybrid Exploration Flow (Free then Structured)

**What:** The conversation starts free-flowing (following user's thread), then transitions to explicit coverage of template sections not yet discussed. This is the core flow from CONTEXT.md.

**Flow:**

```
1. OPENING
   - Summarize what IDEA.md says about this dimension
   - Announce default mode briefly ("Per Product partiamo in modalita creativa -- ci stai?")
   - Ask first targeted question based on IDEA.md seeds

2. FREE EXPLORATION (several exchanges)
   - Follow user's thread naturally
   - Apply appropriate questioning mode
   - Surface cross-dimensional connections reactively
   - Challenge assumptions constructively
   - Track which template sections are being covered

3. STRUCTURED COVERAGE (when free flow winds down)
   - Identify template sections not yet touched
   - Guide conversation toward uncovered sections naturally
   - "We haven't talked about [section topic] yet -- want to touch on that?"

4. DEPTH GATING
   - When all key sections covered, suggest closure
   - "We've hit the main angles. Want to go deeper anywhere, or wrap up?"
   - User decides to continue or stop

5. CLOSURE
   - Show summary of what emerged
   - User confirms or corrects
   - Corrections go to dimension file only
   - Generate dimension document + session log
   - Update SESSION.md
```

### Pattern 4: Dimension Artifact Generation with Full Template

**What:** The dimension document always contains ALL template sections, even undiscussed ones. This differs from IDEA.md (Phase 2) which uses emergent structure.

**CONTEXT.md locked decision:** "Il documento dimensionale usa il template completo con tutte le sezioni sempre presenti."

**Implementation:**

For a dimension like `product`, the output file `dimensions/product.md` follows `templates/product.md` structure:

```markdown
# Product

> [One-sentence summary of the product dimension, distilled from conversation]

## Problem Statement

[If discussed: distilled content from conversation]
[If NOT discussed: placeholder with guiding questions from template]

## Proposed Solution

[If discussed: distilled content]
[If NOT discussed: "Not yet explored. Consider: What is the core concept? How does it address the problem?"]

... (all template sections present)

## Cross-Dimensional Notes

[Connections, contradictions, and insights that emerged relative to other dimensions]

---
*Explored via /brain:explore product on YYYY-MM-DD*
*Mode: creative (default)*
```

### Pattern 5: Session Log as Distilled Q&A Transcript

**What:** The session log removes conversational noise but preserves all substantive content in a Q&A format.

**CONTEXT.md locked decision:** "Il session log e un transcript distillato in formato Q&A."

**Format:**

```markdown
# Product Exploration - Session Log

**Dimension:** product
**Date:** 2026-03-07
**Duration:** ~15 exchanges
**Mode:** creative (default), with brief challenger switch

## Key Themes

- [Theme 1]
- [Theme 2]

## Transcript (Distilled)

**Q:** [Explorer's question, cleaned up]
**A:** [User's answer, cleaned up -- meaning preserved, noise removed]

**Q:** [Next question]
**A:** [Answer]

[...]

---
*Session log for /brain:explore product on 2026-03-07*
*Noise removed: greetings, filler, repetitions. Substance preserved.*
```

### Pattern 6: SESSION.md Update on Exploration Complete

**What:** After dimension exploration completes, SESSION.md is updated to reflect the explored dimension's new status.

**Implementation:**

```markdown
## What to update in SESSION.md:

1. Read current SESSION.md
2. In the "Explored Dimensions" table:
   - Change the target dimension's Status from "not started" to "explored"
   - Set the Date to today's date
   - Add brief Notes from the exploration (1-2 word summary)
3. Update "Last updated" date in header
4. Add entry to Session Notes with key insights from this exploration
5. Write updated SESSION.md
```

### Anti-Patterns to Avoid

- **Subagent spawn for conversation:** Do NOT use Task tool to spawn brain-explorer for interactive exploration. Task creates a separate context -- the subagent cannot have a multi-turn conversation with the user.
- **Duplicated logic in shortcut commands:** Do NOT copy the full explore logic into each shortcut file. Use delegation pattern.
- **Emergent structure for dimension files:** Unlike IDEA.md (Phase 2), dimension files follow the FULL template structure (CONTEXT.md locked decision). All sections present, even undiscussed ones.
- **Loading ALL reference files at startup:** Do NOT load voice-interaction.md and questioning.md at startup if the explore command embeds the behavioral rules directly. Only load what is needed (the dimension template, IDEA.md, existing dimensions).
- **Tracking mode in artifacts:** CONTEXT.md explicitly says "La modalita usata non viene tracciata negli artefatti -- conta il contenuto, non il processo." Do not add mode information to dimension documents. Session log can note it for reference.
- **Forcing cross-dimensional connections:** Connections should emerge reactively ("when it's natural"), not as a forced section check. However, the "Cross-dimensional notes" section at the end IS required (CONTEXT.md decision).
- **Modifying session log with user corrections:** User corrections in the pre-save summary go to the dimension document only. Session log stays faithful to the original conversation (CONTEXT.md locked decision).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dimension validation | Custom dimension registry | Hardcoded list of 6 valid names + check against templates/ directory | Only 6 built-in dimensions in v1. Custom dimensions are Phase 4 (DIM-04). |
| Template section tracking | JSON state machine | Claude's natural conversation memory + template sections as checklist | Same pattern as Phase 2 coverage tracking. Claude tracks internally which sections have been discussed. |
| Cross-dimensional context | Context aggregation service | Read tool loading all existing dimension files at startup | Claude reads files, holds them in context, and references them naturally during conversation. |
| Session log distillation | Separate distillation pass | Claude distills during artifact generation at closure | Claude has the full conversation in context and can distill it directly. No separate tool or pass needed. |
| Mode selection UI | Interactive menu system | Brief natural language announcement at conversation start | "Per Product partiamo in modalita creativa -- ci stai?" No menu, no selection prompt. |

**Key insight:** Like Phase 2, this phase produces no executable code. The deliverables are markdown command prompts and behavioral specifications. The "stack" is Claude Code's built-in tools. The complexity is in prompt engineering -- getting the conversation flow, mode switching, cross-dimensional awareness, and artifact generation right.

## Common Pitfalls

### Pitfall 1: Context Window Overload from Cross-Dimensional Loading

**What goes wrong:** Loading IDEA.md + SESSION.md + 5 existing dimension files + reference files + target template fills too much of the context window, leaving insufficient space for the actual conversation.

**Why it happens:** Each dimension file could be 100-150 lines. Loading 5 existing dimensions = 500-750 lines just for cross-dimensional context. Plus reference files, template, IDEA.md, SESSION.md, and the command file itself.

**How to avoid:**
- Do NOT load full reference files (voice-interaction.md, questioning.md) at startup. The explore command should embed the critical behavioral rules directly, referencing the brain-explorer agent spec patterns.
- Load the dimension template for the current dimension (required for section tracking).
- Load existing dimension files but instruct Claude to read them for context, not to quote them verbatim.
- If context becomes an issue, load only the "Cross-Dimensional Notes" section of existing dimensions rather than the full files.
- Load frameworks.md only if the dimension calls for it (market -> Lean Canvas, product -> Value Prop Canvas, users -> JTBD).

**Warning signs:** Claude's responses become less sharp or start ignoring voice-first patterns late in conversation. Responses lose connection to earlier dimension content.

### Pitfall 2: Template Section Tracking Becomes Visible

**What goes wrong:** Claude starts asking "Now let's cover your Revenue Model" instead of guiding the conversation naturally toward uncovered sections.

**Why it happens:** The template section tracking instructions are too directive, making Claude treat them as a checklist to work through.

**How to avoid:**
- Frame section tracking as observational: "Note which template sections are touched during natural conversation"
- Transition to structured coverage should feel natural: "There's one angle we haven't hit yet -- [topic]. Worth exploring?"
- Never name the template section heading. Ask about the topic in conversational language.
- The free-form phase should last several exchanges before any structured coverage begins.

**Warning signs:** Claude says "Let's move to the Problem Statement section" or references template headings directly.

### Pitfall 3: Mode Switches Become Jarring

**What goes wrong:** Mode switches feel like personality changes -- the conversation tone shifts dramatically mid-flow.

**Why it happens:** The mode definitions are written as distinct behavioral specs. Claude may interpret a switch as a complete personality change.

**How to avoid:**
- Frame switches as micro-interventions: "Let me push back on that for a second" (2-3 exchanges), then return naturally.
- The default mode sets the base tone. Switches are brief departures, not full resets.
- After a switch, explicitly return: "OK, good -- that holds up. Back to exploring..."
- CONTEXT.md says switches are "temporanei per default: 2-3 scambi nella modalita alternativa."

**Warning signs:** After a challenger switch, Claude stays in aggressive mode for the rest of the conversation. Or the switch is announced too formally: "Switching to Challenger Mode."

### Pitfall 4: Session Log Becomes a Raw Transcript

**What goes wrong:** The session log is too faithful -- it includes every exchange verbatim, making it a wall of text rather than a useful reference.

**Why it happens:** Instructions to "preserve all substantive content" are interpreted as "keep everything."

**How to avoid:**
- Define what "noise" means explicitly: greetings ("ciao", "ok grazie"), filler ("uhm", "so basically"), repetitions (user restating the same point multiple times), acknowledgments ("yeah that makes sense"), meta-conversation ("wait let me think").
- Q&A format means Claude should merge related exchanges: if a topic spans 3 back-and-forths, it becomes one Q&A pair with the synthesized answer.
- The session log is a reference document for future sessions, not a verbatim record.

**Warning signs:** Session log is 3x longer than the actual substantive content warrants.

### Pitfall 5: Shortcut Commands Don't Behave Identically to Explore

**What goes wrong:** `/brain:product` has subtly different behavior from `/brain:explore product` because the delegation pattern doesn't fully transfer context.

**Why it happens:** The shortcut file instructs Claude to "follow explore.md" but Claude may not load or follow it completely.

**How to avoid:**
- The shortcut command should explicitly instruct Claude to Read the explore.md file and follow it.
- Include the resolved path instruction: resolve `$HOME` via Bash, then Read the explore command file.
- The shortcut file should be minimal (under 20 lines) -- just set the dimension and delegate.
- Test both paths during verification.

**Warning signs:** Shortcut commands skip the mode announcement, don't load cross-dimensional context, or produce different artifact formats.

### Pitfall 6: Dimension File Overwrites Without Warning on Re-exploration

**What goes wrong:** User explores `product` twice. The second exploration silently overwrites the first `dimensions/product.md` without any warning or preservation.

**Why it happens:** The command doesn't check if the dimension file already exists before writing.

**How to avoid:**
- Check if `dimensions/<dimension>.md` exists at startup.
- If it exists: note this to the user. "You've already explored product. The previous exploration will be updated with this session's content." (Full re-exploration handling with "deepen or start fresh" choice is Phase 4 SESS-03, but basic awareness should exist in Phase 3.)
- Session logs are date-stamped, so previous session logs are NOT overwritten (each gets a unique `<dimension>-<YYYY-MM-DD>.md` filename).
- For the dimension file: overwriting is acceptable in Phase 3. Phase 4 adds the "deepen or start fresh" flow.

**Warning signs:** User loses their first exploration without knowing. Or session log gets overwritten because same dimension explored on same day (need time component or sequence number in filename).

### Pitfall 7: Opening Summary from IDEA.md is Too Long

**What goes wrong:** The opening riepilogo of what IDEA.md says about the current dimension becomes a monologue that violates the 8-line rule before the first question.

**Why it happens:** IDEA.md may contain substantial content (especially the "Emerging Threads" section), and the explorer tries to summarize all of it.

**How to avoid:**
- The opening should be 2-3 sentences max summarizing what IDEA.md reveals about this dimension specifically.
- If IDEA.md has a lot of relevant content: pick the most relevant insight, summarize it, and ask the first question.
- The opening is not a comprehensive review -- it's a conversation starter.

**Warning signs:** First response is 10+ lines before the question. Or it reads like a report instead of a conversation opener.

## Code Examples

### Example 1: `/brain:explore` Command File Structure

```markdown
# /brain:explore

Explore a dimension interactively. Usage: `/brain:explore <dimension>`
where dimension is: product, tech, market, business, competitors, users.

Dimension name is captured via `$ARGUMENTS`.

---

## Setup

1. **Resolve paths:**
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   BRAIN_TPL=$(echo $HOME/.claude/brain-suite/templates)
   ```

2. **Validate dimension:**
   - Extract dimension from $ARGUMENTS (first word, lowercase)
   - Valid: product, tech, market, business, competitors, users
   - If invalid or missing: list valid dimensions and stop

3. **Load context:**
   - Read `.brainstorm/IDEA.md` (REQUIRED)
   - Read `.brainstorm/SESSION.md` (REQUIRED)
   - Read `$BRAIN_TPL/<dimension>.md` (target template)
   - Read `$BRAIN_REF/questioning.md` (for mode details)
   - Use Glob: `.brainstorm/dimensions/*.md`
   - Read ALL existing dimension files for cross-dimensional context

4. **Create directories:** `mkdir -p .brainstorm/dimensions .brainstorm/sessions`

5. **Check existing exploration:**
   - If `dimensions/<dimension>.md` exists: note to user briefly

---

## Opening

[Opening behavior: IDEA.md summary + mode announcement + first question]

---

## Conversation Flow

[Voice-first rules, mode behavior, template coverage, depth gating]

---

## Session Closure

[Summary, confirmation, corrections, artifact generation]

---

## Artifact: dimensions/<dimension>.md

[Full template structure, all sections present, discussed/undiscussed handling]

---

## Artifact: sessions/<dimension>-<date>.md

[Distilled Q&A transcript, noise removal rules]

---

## SESSION.md Update

[Update dimension table, add session notes]

---

## Behavioral Reinforcement

[Critical rules restated at end of file for LLM recency bias]
```

### Example 2: Shortcut Command Structure

```markdown
# /brain:product

Explore the **product** dimension. This is a shortcut for `/brain:explore product`.

## Execution

1. Resolve the explore command path:
   ```bash
   EXPLORE_CMD=$(echo $HOME/.claude/commands/brain/explore.md)
   ```

2. Read the explore command file:
   Read `$EXPLORE_CMD` for the complete exploration instructions.

3. Execute ALL instructions from the explore command with dimension set to **product**.

The dimension is `product`. Do NOT ask the user which dimension to explore --
it is already determined. Proceed directly with the exploration flow.
```

### Example 3: Dimension Document Output

```markdown
# Product

> A structured brainstorming tool for Claude Code that guides
> interactive idea exploration across multiple dimensions.

## Problem Statement

Developers and solo founders skip structured thinking before building.
They jump from idea to code without validating assumptions, understanding
the market, or mapping the competitive landscape. The result is wasted
effort building things nobody needs or that already exist.

## Proposed Solution

A CLI-native brainstorming framework that uses Socratic questioning to
guide the user through systematic idea exploration. Each dimension
(product, tech, market, business, competitors, users) gets dedicated
exploration with structured output.

## Key Features

**MVP:**
- Interactive Socratic exploration per dimension
- Structured output documents for each dimension
- Session persistence and resumption

**Future:**
- Research agent for factual data injection
- Cross-dimensional synthesis
- GSD handoff for implementation

## Differentiators

Not yet explored. Consider:
- What can this do that existing brainstorming tools cannot?
- Why would someone use this instead of a whiteboard or document?

## User Experience Vision

Not yet explored. Consider:
- How should a brainstorming session feel?
- What is the ideal workflow from idea to structured output?

## Assumptions & Risks

The core assumption is that structured questioning produces better
outcomes than unstructured brainstorming. Risk: users may find
the structure constraining rather than helpful, especially for
highly creative or divergent thinking phases.

## Cross-Dimensional Notes

- **Product <-> Users:** The target user is a solo developer or small
  team founder. Product features should prioritize single-user
  workflows over collaboration.
- **Product <-> Tech:** CLI-native constraint means no GUI -- the
  interaction model is purely conversational.

---
*Explored via /brain:explore product on 2026-03-07*
```

### Example 4: Session Log Output

```markdown
# Product Exploration - Session Log

**Dimension:** product
**Date:** 2026-03-07
**Duration:** ~12 exchanges

## Key Themes

- Problem validation: developers skip structured thinking
- MVP scope: dimension-by-dimension exploration with persistence
- Differentiation challenge: competing against "just use a document"

## Transcript (Distilled)

**Q:** IDEA.md mentions developers skipping validation before building.
What does that actually look like in practice -- when does the pain hit?

**A:** Usually after weeks of building. You realize the thing you built
doesn't match what people need, or someone already built it better.
The waste isn't just time -- it's motivation. Hard to restart after that.

**Q:** So the real cost isn't time but energy and motivation. That
reframes the value prop from "save time" to "protect your drive to
build." Is that how you see it?

**A:** Yeah exactly. It's about confidence that what you're building
matters before you invest deeply.

[...]

---
*Session log for /brain:explore product on 2026-03-07*
*Noise removed: greetings, filler, repetitions. Substance preserved.*
```

### Example 5: SESSION.md After Exploration

```markdown
# Brainstorming Session

**Idea:** Structured brainstorming framework for Claude Code
**Started:** 2026-03-06
**Last updated:** 2026-03-07
**Status:** exploring

## Explored Dimensions

| Dimension | Status | Date | Notes |
|-----------|--------|------|-------|
| product | explored | 2026-03-07 | Problem validated, MVP scope defined |
| tech | not started | - | - |
| market | not started | - | - |
| business | not started | - | - |
| competitors | not started | - | - |
| users | not started | - | - |

## Session Notes

- Initial brainstorming session via /brain:new
- Product dimension explored: problem is motivation waste, not time waste
- Cross-dimensional note: CLI-native constraint shapes UX significantly
- Suggested next: users -- to validate the "solo developer" persona

## Idea Evolution

Idea remained stable during initial session.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Agent-based exploration (spawn brain-explorer) | Direct command with embedded behavior | Phase 2 decision, validated empirically | Subagent via Task tool cannot maintain multi-turn conversation with user. Direct command is the only viable pattern. |
| Emergent structure for all artifacts | Full template for dimension files, emergent for IDEA.md | Phase 3 CONTEXT.md decision | Dimension files always have all sections. Undiscussed sections get placeholder questions, not omission. |
| Reference files loaded separately | Brain-explorer agent spec embeds behavioral core | Phase 2 Plan 02 | Agent spec (205 lines) already codifies voice-first patterns, questioning modes, assumption challenging. Explore command can reference these patterns without re-loading the source reference files. |

**Validated as current (from Phase 2):**
- Claude Code commands support multi-turn conversation natively -- the command `.md` content persists as system-level instructions throughout the session
- `$ARGUMENTS` captures full input after the command name (validated in Phase 1)
- Read tool works with resolved `$HOME` paths through symlinks
- Write tool creates files in the project directory
- Behavioral reinforcement at end of prompt file helps with instruction adherence (LLM recency bias)

**Validated architecture decisions from Phase 2:**
- **markdown-as-prompt:** Entire command file is behavioral prompt, not executable code
- **runtime-reference-loading:** Read tool with resolved `$HOME` path (via Bash) for symlink-compatible file loading
- **recap-confirm-save flow:** Show summary, user confirms/corrects, then save artifacts
- **invisible-coverage-tracking:** Track section coverage internally without revealing to user

## Open Questions

1. **Shortcut command delegation reliability**
   - What we know: The shortcut command can instruct Claude to Read the explore.md file and follow its instructions. `/brain:new` already uses a similar delegation pattern (invoking `/brain:resume` via Skill tool).
   - What's unclear: Whether Claude reliably follows a Read-and-execute-that-file pattern for a 200+ line command file loaded dynamically.
   - Recommendation: Test the delegation pattern empirically during implementation. Fallback: if delegation is unreliable, each shortcut command can contain the full explore logic with the dimension name hardcoded. This creates duplication but guarantees correctness. A pragmatic middle ground: shortcuts contain a condensed version of the critical setup and opening, referencing the explore command for the full behavioral rules.

2. **Session log date collision**
   - What we know: Session logs are named `<dimension>-<YYYY-MM-DD>.md`. If a user explores the same dimension twice on the same day, the second log would overwrite the first.
   - What's unclear: Whether this is an edge case worth handling now or can wait for Phase 4.
   - Recommendation: Use a more specific filename pattern: `<dimension>-<YYYY-MM-DD-HHMM>.md` with time component. This prevents collision without adding complexity. Or check for existing file and append a sequence number.

3. **Context window budget for 5+ dimensions loaded**
   - What we know: With all 6 dimensions explored, loading all dimension files at startup for cross-dimensional context could be ~900-1000 lines.
   - What's unclear: Whether this leaves sufficient context for a full exploration conversation (~20-30 exchanges).
   - Recommendation: This should not be a problem for Claude's 200k context window. Even with generous estimates (command file ~300 lines, loaded files ~1200 lines, conversation ~5000 lines = ~6500 lines / ~10k tokens), the total is well within limits. Monitor during testing but don't optimize prematurely.

4. **Dimension file handling on re-exploration (before Phase 4)**
   - What we know: Phase 4 (SESS-03) adds the "deepen or start fresh" flow for re-exploring a dimension. Phase 3 needs to handle the case where a dimension file already exists.
   - What's unclear: Whether Phase 3 should simply overwrite, warn and overwrite, or prevent re-exploration entirely.
   - Recommendation: Warn and overwrite. Tell the user "You've already explored product. This session will replace the previous exploration." This is minimal and correct behavior. Phase 4 will add the more nuanced handling. Previous session logs are preserved (date-stamped filenames).

## Sources

### Primary (HIGH confidence)

- `agents/brain-explorer.md` -- directly inspected (205 lines, Phase 2 output). Contains voice identity, questioning modes, per-dimension defaults, assumption challenging, depth gating, cross-dimension awareness, anti-patterns. This is the canonical behavioral spec.
- `commands/brain/new.md` -- directly inspected (299 lines, Phase 2 output). Validated pattern: markdown-as-prompt, runtime reference loading, recap-confirm-save, invisible coverage tracking.
- `templates/*.md` -- all 6 dimension templates inspected (Phase 1 output). Each contains 5-6 structured sections used as conversation anchors.
- `references/dimensions-guide.md` -- directly inspected (161 lines, Phase 1 output). Contains dimension relationships, suggested exploration order, revisitation signals.
- `references/questioning.md` -- directly inspected (125 lines, Phase 1 output). Three questioning modes with per-dimension defaults.
- `references/frameworks.md` -- directly inspected (135 lines, Phase 1 output). Lean Canvas, JTBD, Value Prop Canvas with per-dimension mapping.
- `03-CONTEXT.md` -- Phase 3 user decisions, directly sourced.
- Phase 2 verification report (`02-VERIFICATION.md`) -- confirmed all Phase 2 patterns work correctly.

### Secondary (MEDIUM confidence)

- GSD `debug.md` command pattern -- analyzed for Task tool subagent spawning mechanics. Confirmed: Task tool creates separate context (NOT suitable for multi-turn user conversation).
- Phase 2 `02-RESEARCH.md` -- analyzed for architecture patterns and pitfalls relevant to Phase 3. Most patterns carry over directly.
- Phase 2 `02-01-SUMMARY.md` and `02-02-SUMMARY.md` -- confirmed Phase 2 decisions and patterns.

### Tertiary (LOW confidence)

- Shortcut command delegation pattern -- untested. Based on understanding of Claude Code's command loading mechanism, but needs empirical validation.
- Context window budget estimation for full cross-dimensional loading -- estimated from file sizes, not empirically measured.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- identical to Phase 2, all tools are Claude Code built-ins
- Architecture patterns: HIGH -- extends validated Phase 2 patterns (markdown-as-prompt, runtime loading, recap-confirm-save). New patterns (shortcut delegation, cross-dimensional loading) are straightforward extensions.
- Artifact generation (dimension doc, session log, SESSION.md update): HIGH -- well-specified in CONTEXT.md, template structures already exist
- Shortcut command delegation: MEDIUM -- pattern is sound but untested; fallback approach available
- Context window budget: HIGH -- conservative estimates well within 200k limit
- Pitfalls: MEDIUM -- based on Phase 2 experience and LLM interaction patterns

**Research date:** 2026-03-07
**Valid until:** 2026-06-07 (stable domain -- Claude Code command system + prompt engineering)
