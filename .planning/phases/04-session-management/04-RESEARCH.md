# Phase 4: Session Management - Research

**Researched:** 2026-03-07
**Domain:** Claude Code command prompts for session tracking, resumption, re-exploration, custom dimensions, and proactive guidance
**Confidence:** HIGH

## Summary

Phase 4 adds session management capabilities to Brain Suite: the user can check progress (`/brain:status`), resume a previous session (`/brain:resume`), re-explore an already-explored dimension with "deepen or restart" options (modification to `/brain:explore`), add custom dimensions (`/brain:add-dimension`), and receive proactive next-dimension suggestions. All five deliverables are **markdown-as-prompt** command files -- the same pattern validated in Phases 2 and 3. No executable code, no external libraries. The "stack" remains Claude Code's built-in tools (Read, Write, Bash, Glob).

The main implementation complexity is in three areas: (1) `/brain:resume` acting as an "intelligent hub" that loads full session context, presents a narrative summary, proposes next steps, AND handles user deviations without bouncing between commands; (2) the re-exploration flow in `/brain:explore` that detects an already-explored dimension, asks deepen/restart, and either loads previous content for continuation or archives before starting fresh; (3) `/brain:add-dimension` which must create a freeform template, register the custom dimension in SESSION.md, AND modify explore.md's validation logic to accept custom dimensions beyond the hardcoded 6.

The critical cross-cutting concern is that **`/brain:explore` must be modified** to support both custom dimensions and the re-exploration flow. Currently it hardcodes 6 valid dimensions and gives a brief warning when re-exploring. Phase 4 must: (a) extend validation to accept any dimension name registered in SESSION.md, (b) replace the brief re-exploration warning with the full deepen/restart flow, and (c) handle custom dimension template loading (from `.brainstorm/templates/` instead of the reference templates directory).

**Primary recommendation:** Implement as 3-4 plans: (1) `/brain:status` command, (2) `/brain:resume` command, (3) re-exploration flow + custom dimensions (modifications to `/brain:explore` and new `/brain:add-dimension` command), (4) proactive next-dimension enhancement to explore closure. Plans 3 and 4 modify the same file (explore.md) so they must be sequenced carefully.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Status display
- Enriched view: emoji indicators per dimension status, ASCII progress bar, next-dimension suggestion at the bottom
- Show idea title + one-liner from IDEA.md at the top for immediate context
- Keep dimension notes brief (1-2 words from SESSION.md) -- status is a compass, not a report
- When no dimensions are explored yet, show empty grid without suggestion (suggestion already comes from `/brain:new`)

#### Resume experience
- Show a narrative summary on re-entry ("Stavi esplorando X, hai coperto Y e Z, manca W") -- different tone from status grid
- Propose the next dimension to explore directly after the summary
- If user accepts the proposal, launch `/brain:explore <dimension>` automatically -- zero friction
- If user deviates ("no, voglio rivedere competitors", "fammi vedere lo status"), handle the intent internally -- resume acts as an intelligent hub, no bouncing between commands

#### Re-exploration flow
- When user launches explore on an already-explored dimension, ask directly upfront: "Hai gia esplorato X. Vuoi approfondire o ricominciare?"
- **Deepen:** load the previous dimension file into context and resume as a continuation, naturally steering toward weak spots -- no explicit report of what's missing
- **Restart:** archive the previous dimension file (e.g., `dimensions/archive/`) before starting fresh -- nothing is ever lost
- Deepening produces an updated file that replaces the previous one (single source of truth per dimension). Session logs in `sessions/` preserve history.

#### Custom dimensions
- Input required: dimension name + brief description (1-2 sentences of what the user wants to explore)
- Generated template is freeform -- few generic headings, not the rigid structure of built-in templates. Custom dimensions exist because the user wants to go off-script.
- Flexible naming: multiple words allowed, any language, automatic slug for file paths (e.g., "supply chain" -> `supply-chain.md`)
- Custom dimensions are explorable only via `/brain:explore <name>`, no shortcut commands. Shortcuts stay reserved for the 6 built-in dimensions.

### Claude's Discretion
- Exact emoji choices and ASCII progress bar design for status
- How the narrative resume summary is structured internally
- How the explorer identifies weak spots when deepening a dimension
- Template section structure for custom dimension generation
- Slug generation logic for multi-word dimension names

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ART-03 | `/brain:status` shows overview of session: which dimensions explored, which remain, dates, overall progress | Status command reads IDEA.md header + SESSION.md, displays enriched grid with emoji indicators and ASCII progress bar. Architecture pattern: read-format-display, no artifacts produced. |
| SESS-02 | User can resume a previous session with `/brain:resume` that loads IDEA.md + SESSION.md + all explored dimensions into context | Resume command loads full context, generates narrative summary, proposes next dimension, handles user deviations internally (intelligent hub pattern). Can auto-launch explore. |
| SESS-03 | When re-exploring an already-explored dimension, user is asked: deepen existing content or start fresh | Modification to `/brain:explore`: detect existing dimension file, present deepen/restart choice, archive on restart, load previous content on deepen. Archive pattern consistent with `/brain:new`. |
| DIM-04 | User can add custom dimensions via `/brain:add-dimension` with template creation and SESSION.md registration | New command: collects name + description, generates slug, creates freeform template in `.brainstorm/templates/`, registers in SESSION.md dimension table. Explore.md validation extended to accept registered custom dimensions. |
| DIM-05 | Explorer suggests which dimension to explore next based on what was discussed and gaps identified (proactive next-step) | Enhancement to explore closure flow AND resume command. Gap analysis based on SESSION.md status + conversation content. Dimensions-guide.md loaded for relationship-based suggestions. |

</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Claude Code command `.md` | Current | Interactive command prompts for status, resume, add-dimension | Same pattern as Phases 2-3. Native mechanism, no external dependencies. |
| Read tool | Built-in | Load IDEA.md, SESSION.md, dimension files, dimension templates | Standard file reading. Essential for context loading in resume and re-exploration. |
| Write tool | Built-in | Create custom templates, update SESSION.md, update dimension files on deepen | Standard file writing. Used by add-dimension and deepen flow. |
| Bash tool | Built-in | Path resolution, directory creation, file archival (mv), slug generation | Used for `$HOME` resolution, `mkdir -p`, archive operations, date commands. |
| Glob tool | Built-in | Discover explored dimensions, find template files, detect archive directory | Used by status, resume, and explore for discovering session state. |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Grep tool | Built-in | Parse SESSION.md for dimension status | When checking specific dimension status without reading entire file |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Reading IDEA.md header for title | Parsing SESSION.md "Idea" field | Both contain the idea summary. IDEA.md is the canonical source but SESSION.md has the one-liner. Use SESSION.md for status (lighter read), IDEA.md for resume (need full context). |
| File-based archive (mv to archive/) | Git-based versioning | File archive is simpler, visible to user, consistent with `/brain:new` pattern. Git would be invisible and add complexity. |
| Custom templates in `.brainstorm/templates/` | Custom templates in repo `templates/` | `.brainstorm/` is the session workspace. Custom templates belong there, not in the installed reference templates. Also avoids modifying symlinked directories. |

**Installation:** No additional installation. All tools are Claude Code built-ins.

## Architecture Patterns

### Recommended Project Structure

```
commands/brain/
├── status.md              # NEW: Session status dashboard
├── resume.md              # NEW: Session resumption hub
├── add-dimension.md       # NEW: Custom dimension creation
├── explore.md             # MODIFIED: Re-exploration flow + custom dimension support
├── new.md                 # Existing (minor: auto-invoke resume uses Read pattern)
├── product.md             # Existing shortcut (unchanged)
├── tech.md                # Existing shortcut (unchanged)
├── market.md              # Existing shortcut (unchanged)
├── business.md            # Existing shortcut (unchanged)
├── competitors.md         # Existing shortcut (unchanged)
└── users.md               # Existing shortcut (unchanged)

.brainstorm/                    # Runtime session workspace
├── IDEA.md                     # From /brain:new
├── SESSION.md                  # MODIFIED: custom dimensions added to table
├── dimensions/
│   ├── product.md              # Built-in dimension output
│   ├── supply-chain.md         # Custom dimension output (example)
│   └── archive/                # NEW: archived dimension files on restart
│       └── product-2026-03-07-1430.md
├── sessions/
│   └── product-2026-03-07-1430.md
└── templates/                  # NEW: custom dimension templates
    └── supply-chain.md         # Generated by /brain:add-dimension
```

### Pattern 1: Read-Format-Display (Status Command)

**What:** `/brain:status` reads SESSION.md and IDEA.md, formats a rich display with emoji indicators and ASCII progress bar, and outputs it directly. No artifacts produced, no user interaction required.

**When to use:** Commands that display information without modification.

**Implementation approach:**
```markdown
## Execution

1. Read `.brainstorm/SESSION.md` -- REQUIRED. If missing, tell user to run `/brain:new` first.
2. Read `.brainstorm/IDEA.md` -- extract title and one-liner (first heading + blockquote).
3. Format and display the status dashboard.

## Display Format

[idea title]
> [one-liner from IDEA.md blockquote]

Progresso: [====------] 2/6 dimensioni

| Dimensione   | Stato | Data       | Note              |
|--------------|-------|------------|-------------------|
| product      | [e]   | 2026-03-07 | Problem validated |
| tech         | [e]   | 2026-03-07 | Stack defined     |
| market       | [ ]   | -          | -                 |
| business     | [ ]   | -          | -                 |
| competitors  | [ ]   | -          | -                 |
| users        | [ ]   | -          | -                 |
| supply-chain | [e]   | 2026-03-08 | Logistics mapped  |  # custom dim

[emoji] = status indicator per dimension
[suggestion only when 1+ dimensions explored]
```

**Key details:**
- Emoji indicators: use simple markers that render well in terminal (checkmark for explored, empty circle for not started, or similar)
- ASCII progress bar: fraction format (e.g., `[====------] 2/6`) based on explored count vs total count
- Custom dimensions appear in the same table, after the 6 built-ins
- When 0 dimensions explored: show grid without next-dimension suggestion (CONTEXT.md decision)
- When 1+ explored: show suggestion at the bottom based on SESSION.md "Suggested next" or gap analysis

### Pattern 2: Intelligent Hub (Resume Command)

**What:** `/brain:resume` loads full session context, presents a narrative summary different from the status grid, proposes the next dimension, and acts as a hub handling user deviations without redirecting to other commands.

**When to use:** Commands that need to present context and then respond to varied user intents.

**Critical design point:** Resume is NOT a one-shot display. It is the start of an interactive conversation. After presenting the summary and proposal, it must listen to the user's response and act accordingly:
- User accepts proposal -> auto-launch `/brain:explore <dimension>` via Read tool delegation (same pattern as shortcuts)
- User asks for a different dimension -> launch that dimension's exploration
- User asks to see status -> display status inline (not redirect to `/brain:status`)
- User asks to review a specific dimension -> load and show that dimension file
- User wants to add a custom dimension -> handle inline or suggest `/brain:add-dimension`

**Implementation approach:**
```markdown
## Setup

1. Read `.brainstorm/IDEA.md` -- REQUIRED
2. Read `.brainstorm/SESSION.md` -- REQUIRED
3. Use Glob to find `.brainstorm/dimensions/*.md` and read ALL existing dimension files
4. Read dimensions-guide.md for relationship-based suggestions

## Narrative Summary

Present a conversational summary:
- What the idea is (brief)
- What has been explored so far (narrative, not table)
- What emerged from explored dimensions (key insights, not full content)
- What remains unexplored
- Suggest the next dimension to explore (based on gaps + what was discussed)

Tone: "Stavi esplorando [idea]. Hai coperto [dimensions] -- da [X] e emerso [insight],
da [Y] e emerso [insight]. Mancano ancora [remaining]. Ti suggerisco [next] perche
[reason based on conversation content]."

## User Response Handling

After presenting the summary:
- If user accepts: load explore.md via Read tool, execute with proposed dimension
- If user names a different dimension: load explore.md, execute with that dimension
- If user asks for status: display inline status (use status format)
- If user asks to review: show the relevant dimension file content
- Otherwise: respond conversationally and guide toward next action
```

### Pattern 3: Deepen vs Restart (Re-exploration Flow)

**What:** When `/brain:explore` detects an existing dimension file, it asks the user whether to deepen or restart, then branches into the appropriate flow.

**Deepen flow:**
1. Load the existing dimension file into context
2. Proceed with the normal exploration flow, but with awareness of what was already covered
3. The explorer naturally steers toward weak spots (undiscussed sections, placeholder sections, thin content)
4. At closure, the updated dimension file REPLACES the previous one (single source of truth)
5. A new session log is created (date-stamped, does not conflict)

**Restart flow:**
1. Archive the existing dimension file to `.brainstorm/dimensions/archive/<dimension>-<date-time>.md`
2. Proceed with the standard fresh exploration flow
3. A new dimension file is created from scratch
4. A new session log is created

**Archive pattern:** Consistent with `/brain:new` which archives to `.brainstorm/archive/`. For dimensions, use `.brainstorm/dimensions/archive/` to keep dimension archives co-located with dimension files.

**Implementation in explore.md (replaces step 6 "Check for previous exploration"):**
```markdown
6. **Check for previous exploration:**
   - If `.brainstorm/dimensions/<dimension>.md` already exists:
     - Ask: "Hai gia esplorato [dimension]. Vuoi approfondire o ricominciare?"
     - **If deepen:**
       - Read the existing dimension file into context
       - Note internally which sections have substantive content vs placeholders
       - Proceed with the Opening but adapt: acknowledge previous exploration briefly
       - During conversation, naturally steer toward sections with placeholders or thin content
       - At closure: write an updated dimension file that merges previous + new content
     - **If restart:**
       - Archive the existing dimension file:
         ```bash
         mkdir -p .brainstorm/dimensions/archive
         TIMESTAMP=$(date +%Y-%m-%d-%H%M)
         mv .brainstorm/dimensions/<dimension>.md .brainstorm/dimensions/archive/<dimension>-$TIMESTAMP.md
         ```
       - Proceed with standard fresh exploration
   - If dimension file does NOT exist: proceed with standard fresh exploration (no change)
```

### Pattern 4: Custom Dimension Registration

**What:** `/brain:add-dimension` collects a name and description, generates a slug, creates a freeform template, and registers the custom dimension in SESSION.md.

**Slug generation:** Convert the dimension name to a file-system-friendly slug:
- Lowercase
- Replace spaces with hyphens
- Remove special characters
- Handle accented characters (transliterate or keep)
- Examples: "Supply Chain" -> `supply-chain`, "analisi costi" -> `analisi-costi`

**Template generation:** Freeform template with few generic headings. NOT the rigid structure of built-in templates. The user adds custom dimensions precisely to go off-script.

```markdown
# [Dimension Name]

> Template for `.brainstorm/dimensions/[slug].md`
> Explorer uses these sections as conversation anchors during exploration.

## Overview

[Description provided by user]. What are the key aspects to explore?

## Key Considerations

What factors are most important? What constraints or opportunities exist?

## Connections to Other Dimensions

How does this dimension relate to and influence the other dimensions of the idea?
```

**SESSION.md registration:** Add a new row to the Explored Dimensions table:

```markdown
| [slug] | not started | - | - | custom |
```

The "custom" marker in Notes (or a separate column) helps distinguish custom dimensions in status display.

**Explore.md validation extension:** Currently explore.md hardcodes 6 valid dimensions. After Phase 4, it must also accept any dimension whose slug appears in SESSION.md's dimension table. The validation logic becomes:
1. Check if dimension is one of the 6 built-ins -> valid, load template from `$BRAIN_TPL/`
2. If not built-in, check SESSION.md for a matching dimension row -> valid, load template from `.brainstorm/templates/`
3. If neither -> invalid, show available dimensions (built-in + custom) and STOP

### Pattern 5: Proactive Next-Dimension Suggestion (DIM-05)

**What:** The explorer proactively suggests which dimension to explore next based on what was discussed and gaps identified. This enhances the existing closure flow in explore.md.

**Already partially implemented:** Explore.md Step 5 (Suggest Next Dimension) already suggests a next dimension based on conversation content. The enhancement for DIM-05 is to make this more systematic and gap-aware:
1. Load dimensions-guide.md at closure (already done)
2. Check SESSION.md for which dimensions are explored vs not started
3. Prioritize based on:
   - Dimensions mentioned or hinted at during conversation (strongest signal)
   - Dimension relationships from dimensions-guide.md (e.g., after product -> suggest users)
   - Simple gap filling (unexplored dimensions)
4. The suggestion must reference conversation content (already a requirement in explore.md)

This same logic powers the resume command's next-dimension proposal.

### Anti-Patterns to Avoid

- **Status as a report:** Status is a compact compass. Do NOT load and display full dimension content. Only show what is in SESSION.md (1-2 word notes, dates, status).
- **Resume as a save-file loader:** Resume should feel like reopening a conversation with a collaborator who remembers where you left off, not like loading a save file (CONTEXT.md specific idea).
- **Explicit weak-spot reporting in deepen mode:** When deepening, do NOT say "These sections are missing: X, Y, Z." Instead, naturally steer the conversation toward weak spots through questions.
- **Rigid custom templates:** Custom dimension templates should be freeform (3-4 generic sections), not rigid like built-in templates with 5-6 specific sections.
- **Redirecting from resume to other commands:** Resume is an intelligent hub. Handle status display, dimension review, and exploration launch inline. Do NOT tell the user "Run `/brain:status` for that."
- **Modifying symlinked directories:** Custom templates go in `.brainstorm/templates/`, NOT in the installed `~/.claude/brain-suite/templates/` (which is a symlink to the repo).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Slug generation | Complex Unicode-aware slug library | Simple bash: `echo "$name" \| tr '[:upper:]' '[:lower:]' \| tr ' ' '-' \| tr -cd 'a-z0-9-'` | Only needs basic slug for file paths. Edge cases (Unicode, emoji) can be handled with simple transliteration. |
| Progress calculation | Stateful progress tracker | Count "explored" rows vs total rows in SESSION.md table | SESSION.md is the single source of truth for progress. Just count. |
| Archive management | Archive registry or index file | Timestamped filenames in archive/ directory | The archive is a safety net, not a feature. Timestamped filenames are sufficient. User can browse manually if needed. |
| Next-dimension suggestion algorithm | Weighted scoring system | Conversational judgment based on SESSION.md state + dimensions-guide.md relationships | The suggestion is a natural language recommendation, not an algorithmic output. Claude reads the state and makes a judgment call. |
| Custom dimension validation | Dimension registry JSON file | SESSION.md dimension table as registry | SESSION.md already tracks all dimensions. Adding a row is registration. Checking the table is validation. No separate registry needed. |

**Key insight:** The SESSION.md file is the single source of truth for ALL session state -- explored dimensions, custom dimensions, dates, notes, progress. Every command reads it. No separate state files needed.

## Common Pitfalls

### Pitfall 1: Resume Summary Becomes a Data Dump

**What goes wrong:** The resume narrative summary tries to cover everything from every explored dimension, becoming a long monologue that defeats the purpose of a quick re-entry.

**Why it happens:** Multiple dimension files are loaded into context and Claude tries to summarize all of them comprehensively.

**How to avoid:**
- The narrative summary should be 4-6 sentences maximum, covering high-level trajectory not detailed findings
- Extract ONE key insight per explored dimension, not a full summary
- The summary is a conversation starter, not a report. "From product emerged X, from users emerged Y, these connect because Z."
- Keep it under 10 lines total (including the next-dimension proposal)

**Warning signs:** Resume output is longer than a status display. User has to scroll. It reads like a document, not a conversation opener.

### Pitfall 2: Deepen Mode Reveals Internal Tracking

**What goes wrong:** When deepening an already-explored dimension, Claude explicitly lists which sections are thin or missing: "I see that Differentiators and User Experience Vision were not covered. Let's start there."

**Why it happens:** The instruction to "steer toward weak spots" is interpreted as "report weak spots."

**How to avoid:**
- Frame the deepen instruction as: "Note internally which sections have substantive content vs placeholders. During conversation, naturally guide the discussion toward areas with less content -- through questions, not reports."
- The opening for a deepen session should acknowledge previous work briefly ("Hai gia esplorato [dimension] -- riprendiamo da li") and ask a question that targets a weak spot without naming it
- NEVER list missing sections. NEVER say "last time we didn't cover X."
- Same invisible tracking principle from Phase 3

**Warning signs:** Claude says "Last time you didn't discuss Assumptions & Risks. Let's cover that." Or opens with a checklist of what needs to be covered.

### Pitfall 3: Custom Dimension Template Loaded from Wrong Location

**What goes wrong:** Explore.md tries to load a custom dimension's template from the reference templates directory (`$BRAIN_TPL/`) instead of `.brainstorm/templates/`, and fails silently or uses a wrong template.

**Why it happens:** The template loading logic in explore.md hardcodes the reference path for templates.

**How to avoid:**
- The validation logic must branch: built-in dimensions load from `$BRAIN_TPL/`, custom dimensions load from `.brainstorm/templates/`
- Custom dimension detection: if the dimension is not in the hardcoded 6, check SESSION.md for a matching row, then load from `.brainstorm/templates/<slug>.md`
- If the custom template file is missing (somehow), tell the user and suggest running `/brain:add-dimension` again

**Warning signs:** Custom dimension exploration starts but has no template sections to track. Or it uses a built-in template for a custom dimension name.

### Pitfall 4: Archive Directory Collision with /brain:new Archive

**What goes wrong:** Dimension archive goes to `.brainstorm/archive/` (same path as `/brain:new` session archive), creating confusion about what was archived and why.

**Why it happens:** Using the same archive path for different purposes.

**How to avoid:**
- `/brain:new` archives full sessions to `.brainstorm/archive/<date>/` (whole directories)
- `/brain:explore` archives individual dimension files to `.brainstorm/dimensions/archive/<dimension>-<date>.md` (individual files)
- These are separate concerns with separate paths. Keep them distinct.

**Warning signs:** User finds dimension files mixed in with full session archives, or vice versa.

### Pitfall 5: Resume Doesn't Handle Edge Cases

**What goes wrong:** Resume crashes or produces incoherent output when: (a) no dimensions explored yet, (b) only IDEA.md exists with no explored dimensions, (c) SESSION.md has custom dimensions.

**Why it happens:** Resume assumes at least some dimensions are explored for its narrative summary.

**How to avoid:**
- Handle the zero-explored case: "Hai un'idea registrata ma non hai ancora esplorato nessuna dimensione. Vuoi partire con [suggested first dimension]?"
- The narrative summary only covers explored dimensions. If none: skip narrative, go straight to suggestion.
- Custom dimensions should be included in the narrative summary just like built-in ones.

**Warning signs:** Resume produces empty or generic output when called with a fresh session (only IDEA.md).

### Pitfall 6: Explore.md Validation Rejects Custom Dimensions

**What goes wrong:** User adds a custom dimension via `/brain:add-dimension`, then tries `/brain:explore supply-chain`, and explore.md rejects it because "supply-chain" is not in the hardcoded list of 6 valid dimensions.

**Why it happens:** Explore.md validation is not updated to check SESSION.md for registered custom dimensions.

**How to avoid:**
- The validation logic in explore.md MUST be updated as part of Phase 4
- Two-step validation: (1) check hardcoded list, (2) if not found, check SESSION.md for a row with matching dimension slug
- If found in SESSION.md: load template from `.brainstorm/templates/<slug>.md`
- List BOTH built-in and custom dimensions in the error message when dimension is invalid

**Warning signs:** `/brain:explore custom-dimension` returns "Invalid dimension. Valid: product, tech, market, business, competitors, users."

## Code Examples

### Example 1: Status Command Output

```markdown
## Status Display (terminal output)

# My SaaS Idea
> A tool that helps solo founders validate ideas before building

Progresso: [======----] 3/6 dimensioni

| Dimensione   |      | Data       | Note              |
|--------------|------|------------|-------------------|
| product      | [OK] | 2026-03-07 | Problem validated |
| tech         | [OK] | 2026-03-07 | Stack defined     |
| market       | [  ] | -          | -                 |
| business     | [  ] | -          | -                 |
| competitors  | [OK] | 2026-03-08 | 3 direct found    |
| users        | [  ] | -          | -                 |

Prossima: **users** -- da product e emerso che il target e "solo developer",
vale la pena validare questa persona piu a fondo.
```

### Example 2: Resume Command Narrative

```markdown
## Resume Output (conversational, not tabular)

Stavi lavorando su **My SaaS Idea** -- un tool per validare idee prima di costruire.

Hai esplorato 3 dimensioni finora: da **product** e emerso che il vero pain point
e la perdita di motivazione, non di tempo. Da **tech** hai definito un approccio CLI-native
con Claude Code. Da **competitors** sono emersi 3 competitor diretti, ma nessuno
con un focus su brainstorming strutturato.

Mancano ancora: market, business, users.

Ti suggerisco **users** -- hai menzionato "solo developer" come target ma non
l'hai ancora validato come persona. Partiamo?
```

### Example 3: Re-exploration Deepen Opening

```markdown
## Deepen mode opening (explore.md)

Hai gia esplorato **product** qualche giorno fa. Riprendiamo da li e
approfondiamo. Dalla scorsa volta era emerso che il pain point principale
e la perdita di motivazione -- ma non avevamo parlato molto di come
dovrebbe sentirsi l'esperienza d'uso.

Come immagini il momento in cui l'utente apre il tool per la prima volta?
```

### Example 4: Custom Dimension Template Generation

```markdown
## Generated template: .brainstorm/templates/supply-chain.md

# Supply Chain

> Template for `.brainstorm/dimensions/supply-chain.md`
> Explorer uses these sections as conversation anchors during exploration.

## Overview

Logistics and supply chain management for the product. How do materials,
components, or services flow from source to end user?

## Key Considerations

What are the critical factors, constraints, and opportunities in this area?

## Implications & Tradeoffs

What decisions in this dimension affect other aspects of the idea?

## Open Questions

What needs further investigation or validation?

---
*Template: .brainstorm/templates/supply-chain.md (custom dimension)*
```

### Example 5: SESSION.md After Custom Dimension Added

```markdown
## Explored Dimensions

| Dimension    | Status      | Date       | Notes             |
|--------------|-------------|------------|-------------------|
| product      | explored    | 2026-03-07 | Problem validated |
| tech         | not started | -          | -                 |
| market       | not started | -          | -                 |
| business     | not started | -          | -                 |
| competitors  | not started | -          | -                 |
| users        | not started | -          | -                 |
| supply-chain | not started | -          | custom            |
```

### Example 6: Slug Generation via Bash

```bash
# Slug generation for custom dimension names
DIMENSION_NAME="Supply Chain Analysis"
SLUG=$(echo "$DIMENSION_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
# Result: supply-chain-analysis
```

### Example 7: Explore.md Validation Extension

```markdown
## Validate the dimension (updated for Phase 4):

2. **Validate the dimension:**
   - Extract dimension from `$ARGUMENTS` (first word or full argument, lowercase).
   - Built-in dimensions: product, tech, market, business, competitors, users.
   - If the dimension matches a built-in: load template from `$BRAIN_TPL/<dimension>.md`.
   - If NOT built-in: read `.brainstorm/SESSION.md` and check the Explored Dimensions table for a row with a matching dimension slug.
     - If found: this is a registered custom dimension. Load template from `.brainstorm/templates/<slug>.md`.
     - If NOT found: list all available dimensions (built-in + any custom from SESSION.md) and STOP.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Hardcoded 6 dimensions in explore.md | Dynamic validation against SESSION.md + hardcoded list | Phase 4 | Enables custom dimensions without modifying explore.md for each one |
| Simple overwrite on re-exploration | Deepen/restart choice with archive | Phase 4 | Preserves previous work, enables incremental deepening |
| Status/resume as stubs | Full interactive commands | Phase 4 | Enables session continuity and progress tracking |
| Next-dimension suggestion only at explore closure | Suggestion in status, resume, AND explore closure | Phase 4 | Proactive guidance across all touchpoints |

**Validated patterns carrying forward from Phase 3:**
- markdown-as-prompt for all command files
- Runtime reference loading via Bash `echo $HOME` then Read tool
- Recap-confirm-save closure flow (used in deepen mode)
- Behavioral reinforcement at end of prompt file
- Invisible coverage tracking (critical for deepen mode)
- Archive pattern from `/brain:new` (adapted for dimension files)
- Shortcut delegation via Read tool (resume auto-launches explore via same mechanism)

## Open Questions

1. **Slug generation for non-ASCII dimension names**
   - What we know: Users may name custom dimensions in Italian or other languages with accented characters ("analisi costi", "strategia di prezzo")
   - What's unclear: Whether `tr -cd 'a-z0-9-'` strips accented characters too aggressively, producing empty or confusing slugs
   - Recommendation: Accept accented characters in slugs (extend character class to include common accented letters) OR use a simple transliteration. Test with Italian names during implementation. A pragmatic approach: keep the simple `tr` pipeline and accept that "strategia di prezzo" becomes "strategia-di-prezzo" (accented e stripped to nothing if using strict ASCII). Better approach: use `iconv` for transliteration if available: `echo "$name" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-'`

2. **Resume auto-launch mechanism**
   - What we know: `/brain:new` auto-invokes `/brain:resume` via "Skill tool: brain:resume". Shortcuts use Read tool to load explore.md.
   - What's unclear: Which delegation mechanism is most reliable for resume to auto-launch explore -- Skill tool invocation or Read-and-execute pattern?
   - Recommendation: Use the Read-and-execute pattern (same as shortcuts). Resume resolves the explore.md path via Bash, reads it via Read tool, and executes with the proposed dimension. This is the pattern already validated in Phase 3 shortcuts.

3. **Deepen mode: merging previous + new content in dimension file**
   - What we know: Deepening produces an updated file that replaces the previous one. The explorer should merge new conversation content with previous exploration.
   - What's unclear: Whether Claude can reliably merge content -- keeping previously-covered sections intact while updating thin/placeholder sections with new content.
   - Recommendation: Load the previous dimension file during deepen setup. At closure, write a new dimension file that incorporates BOTH the previous content (for untouched sections) and new conversation content (for discussed sections). Claude has both in context and can merge naturally. The session log captures only the new conversation, preserving history.

4. **How many custom dimensions should be supported?**
   - What we know: CONTEXT.md does not specify a limit. SESSION.md table grows with each custom dimension.
   - What's unclear: Whether adding many custom dimensions degrades status display or context loading.
   - Recommendation: No hard limit. The status display and SESSION.md table scale naturally. In practice, users are unlikely to add more than 3-5 custom dimensions. If the table gets long, it still works -- just a longer table.

## Sources

### Primary (HIGH confidence)

- `commands/brain/explore.md` -- directly inspected (312 lines, Phase 3 output). Contains the current dimension validation, re-exploration warning, closure flow, and artifact generation patterns that Phase 4 must modify.
- `commands/brain/new.md` -- directly inspected (300 lines, Phase 2 output). Contains the archive pattern (`.brainstorm/archive/<date>`) and auto-invoke resume pattern that Phase 4 should be consistent with.
- `commands/brain/product.md` -- directly inspected (18 lines, Phase 3 output). Shortcut delegation pattern via Read tool that resume should reuse for auto-launching explore.
- `agents/brain-explorer.md` -- directly inspected (206 lines, Phase 2 output). Behavioral spec relevant to deepen mode (steering toward weak spots, cross-dimensional awareness).
- `04-CONTEXT.md` -- Phase 4 user decisions, directly sourced. All locked decisions constrain implementation.
- `.planning/REQUIREMENTS.md` -- directly inspected. ART-03, SESS-02, SESS-03, DIM-04, DIM-05 requirement definitions.
- `references/dimensions-guide.md` -- directly inspected (161 lines, Phase 1 output). Dimension relationships and suggested exploration order used for next-dimension suggestions.
- `templates/product.md` -- directly inspected. Built-in template structure (6 sections with conversation anchors). Custom templates should be simpler.
- `install.sh` -- directly inspected. Templates are symlinked from repo via `references/` directory. Custom templates go in `.brainstorm/templates/` (NOT in the symlinked location).
- Phase 3 RESEARCH.md -- directly inspected. Architecture patterns, pitfalls, and validated decisions that carry forward.

### Secondary (MEDIUM confidence)

- Phase 2 and Phase 3 SUMMARY files -- confirmed patterns: markdown-as-prompt, runtime reference loading, recap-confirm-save, behavioral reinforcement, shortcut delegation.
- `.planning/STATE.md` -- project state and accumulated decisions.

### Tertiary (LOW confidence)

- Slug generation with `iconv` transliteration -- assumed available on Linux/WSL2 but not verified for all edge cases with Italian text.
- Deepen mode merge reliability -- based on understanding of Claude's context handling capabilities, not empirically validated.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- identical to Phases 2-3, all tools are Claude Code built-ins
- Architecture patterns (status, resume, add-dimension): HIGH -- straightforward read-format-display and command patterns building on validated Phase 2-3 work
- Architecture patterns (re-exploration flow): HIGH -- archive pattern consistent with `/brain:new`, deepen/restart choice is well-specified in CONTEXT.md
- Architecture patterns (custom dimensions): MEDIUM -- SESSION.md as registry works, but explore.md validation extension needs careful implementation and testing
- Pitfalls: HIGH -- based on direct inspection of existing code and Phase 2-3 experience
- Slug generation: MEDIUM -- simple bash pipeline works for basic cases, edge cases with Unicode need validation

**Research date:** 2026-03-07
**Valid until:** 2026-06-07 (stable domain -- Claude Code command system + prompt engineering)
