# /brain:quick

Fast brainstorming pipeline. Captures and structures an idea in a single session (~20-30 minutes), producing IDEA.md + dimension files + HANDOFF.md in one shot.

---

## Setup

Before starting the conversation, load the methodology reference files and parse arguments.

1. **Resolve reference path** (tilde may not expand in Read tool):
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   ```
   Use the resolved absolute path for all subsequent Read calls.

2. **Read reference files:**
   - Read `$BRAIN_REF/voice-interaction.md` -- voice and interaction patterns. Follow these throughout the ENTIRE conversation. They are non-negotiable.
   - Read `$BRAIN_REF/questioning.md` -- read ONLY the **Socratic Mode** section (from "### Socratic Mode" to the next "###" heading).

3. **Parse `$ARGUMENTS` → build SELECTED_DIMENSIONS:**
   - **Empty or not provided:** use all 6 built-in dimensions in canonical order: `[product, users, market, competitors, business, tech]`
   - **With args (e.g., "product tech"):** lowercase, validate each word against the 6 built-ins. Eliminate duplicates. Apply canonical order regardless of argument order.
   - **Canonical order:** product → users → market → competitors → business → tech
   - **Unrecognized dimension name:** print error message listing valid dimensions and STOP. Do not proceed.

4. **Existing session check:**
   - Use Glob to check if `.brainstorm/IDEA.md` exists.
   - **If `.brainstorm/IDEA.md` exists:**
     - Tell the user there is an existing brainstorming session.
     - Ask: do they want to **start fresh** (archive and begin a new one) or **stop**?
     - **If start fresh:**
       ```bash
       ARCHIVE_DIR=".brainstorm/archive/$(date +%Y-%m-%d--%H-%M-%S)"
       mkdir -p "$ARCHIVE_DIR"
       ```
       ```bash
       mv .brainstorm/IDEA.md "$ARCHIVE_DIR/"
       [ -f .brainstorm/SESSION.md ] && mv .brainstorm/SESSION.md "$ARCHIVE_DIR/"
       [ -d .brainstorm/dimensions ] && mv .brainstorm/dimensions "$ARCHIVE_DIR/"
       [ -d .brainstorm/sessions ] && mv .brainstorm/sessions "$ARCHIVE_DIR/"
       [ -f .brainstorm/SYNTHESIS.md ] && mv .brainstorm/SYNTHESIS.md "$ARCHIVE_DIR/"
       [ -f .brainstorm/HANDOFF.md ] && mv .brainstorm/HANDOFF.md "$ARCHIVE_DIR/"
       [ -f .brainstorm/ANALYSIS.md ] && mv .brainstorm/ANALYSIS.md "$ARCHIVE_DIR/"
       ```
       Confirm archival briefly, then proceed.
     - **If stop:** end here.
     - **If user wants to continue an existing quick session:** do NOT launch `/brain:resume`. Instead, suggest using `/brain:explore <dim>` to deepen individual dimensions.
   - **If `.brainstorm/IDEA.md` does NOT exist:**
     - `mkdir -p .brainstorm`
     - Proceed.

---

## Conversation — 4 Internal Phases

The phases are internal navigation aids. The user never sees them. The conversation feels like one continuous exploration.

---

### Phase 1 — Idea Capture (3-5 exchanges)

Start the conversation with a single, casual, open-ended question. Identical opening to `/brain:new`.

- One question. No preamble. No explanation of what will happen.
- Casual tone: smart friend, not corporate consultant.
- If `$ARGUMENTS` were specified: do NOT mention them. Start with an open question about the idea regardless.

**Internal tracking (invisible to user):**
- Problem / Need
- Target Audience
- Rough Solution / Approach

Track these 3 points observationally. Do NOT steer toward them. A point is covered when you have enough to write a coherent paragraph about it.

**Advance trigger:** All 3 points roughly covered + user is not actively riffing. Use the last response as a natural bridge into the first dimension in SELECTED_DIMENSIONS. Do NOT announce the transition.

---

### Phase 2 — Dimension Sweep

For each dimension in SELECTED_DIMENSIONS (canonical order):

**Rules:**
- 2-3 questions per dimension. No more.
- Auto-advance after 2-3 questions regardless of user pace (circular answers, brief answers, natural topic exhaustion).
- Bridge between dimensions using the user's last response. Never announce "ora passiamo a X".
- Content from Phase 1 counts. Do not revisit what is already clear.
- No brain-researcher. Factual claims that cannot be verified are annotated INTERNALLY as: `Claim: [X] — unverified`. They appear in Quick Session Notes in the dimension file, not as interruptions.

**Internal guide questions per dimension** (adapt to conversation context — never ask verbatim):

**product:**
- What urgent problem does this solve, and how do people handle it today?
- What is the solution and what is the key insight that makes it different?
- What is explicitly out of scope for v1?

**users:**
- Who is the single most concrete person this is built for?
- How does that person solve this problem today without this product?

**market:**
- Where do you find the first 100 users?
- What is the price point and why that number specifically?

**competitors:**
- Who competes with this (including the status quo)?
- What advantage cannot be copied in 3 months?

**business:**
- Who pays, how much, how often?
- What is the north-star number for the first 6 months?

**tech:**
- What stack are you considering, or is that open?
- What do you build first to validate the core assumption?

---

### Phase 3 — Gap Check (1-2 exchanges)

After the dimension sweep, ask 1-2 questions about the most relevant gaps. Not a mechanical checklist.

- Surface only the gaps that feel critical based on what emerged.
- One optional closing question: "Qualcosa di critico che non abbiamo toccato?" — only if it is not obvious from context.

---

### Phase 4 — Session Closure

**Step 1: Propose saving** (casual)
- "Penso di avere un quadro solido. Salvo quello che abbiamo?"
- If the user says not yet, continue exploring. No pressure.

**Step 2: Show recap**
Present a compact recap organized by dimension (not by topic). One concise point per dimension covered. End with: "Va bene così o vuoi correggere qualcosa?"

**Step 3: Handle corrections**
Incorporate any corrections or additions and confirm.

**Step 4: Generate artifacts** (see below)

---

## Artifact Generation

### `.brainstorm/IDEA.md`

Same structure and writing rules as `/brain:new`. Standalone prose, emergent sections, no conversation noise.

**Footer:**
```
---
*Generated by /brain:quick on YYYY-MM-DD*
*Source: quick brainstorming session*
```

---

### `.brainstorm/dimensions/<dim>.md`

For each dimension in SELECTED_DIMENSIONS, write a dimension file using the Write tool.

**Structure rules:**
- Follow the full template heading structure (same headings as the dimension template → compatible with `/brain:explore`).
- **Sections covered in conversation:** distilled prose, 1-2 paragraphs. Standalone, no "you mentioned."
- **Sections not covered:** placeholder format:
  ```
  Not yet explored. Consider:
  - [guiding question 1]
  - [guiding question 2]
  ```
- **No `## Dati e Ricerche` section** — brain-researcher was not used.
- **No `## Cross-Dimensional Notes`** unless connections emerged naturally during conversation.

**Append at the end of every dimension file (after all template sections):**
```markdown
## Quick Session Notes

*Explored in quick mode (~2-3 questions). Key gaps:*
- [gap 1 specific to this dimension]
- [gap 2 specific to this dimension]
[list any unverified claims noted internally: "Claim: [X] — unverified"]
*Deepen with `/brain:explore <dimension>` for full coverage.*
```

**Footer:**
```
---
*Quick-explored via /brain:quick on YYYY-MM-DD*
```

**Do NOT create** `.brainstorm/sessions/<dim>-<date>.md` — no session log files in quick mode.

---

### `.brainstorm/SESSION.md`

```markdown
# Brainstorming Session

**Idea:** [one-line summary matching IDEA.md]
**Started:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD
**Status:** quick-complete

## Explored Dimensions

| Dimension | Status | Date | Notes |
|-----------|--------|------|-------|
| product | [quick or not started] | [date or -] | [1-2 words or -] |
| users | [quick or not started] | [date or -] | [1-2 words or -] |
| market | [quick or not started] | [date or -] | [1-2 words or -] |
| competitors | [quick or not started] | [date or -] | [1-2 words or -] |
| business | [quick or not started] | [date or -] | [1-2 words or -] |
| tech | [quick or not started] | [date or -] | [1-2 words or -] |

## Session Notes

- Quick brainstorming session via /brain:quick
- [2-3 key observations from the conversation]
- Gaps for deepening: [list dimension(s) with most critical unresolved questions]
- Recommended next: `/brain:explore <dimension>` — [brief reason]

## Idea Evolution

[If idea mutated significantly during conversation: brief note.]
[If stable: "Idea remained stable during quick session."]
```

**Status values:**
- `quick` — explored in this quick session (dimension file exists)
- `not started` — not in SELECTED_DIMENSIONS (no dimension file)

**Note on `/brain:explore` compatibility:** The gate for explore is the existence of `.brainstorm/dimensions/<dim>.md`. A dimension with status `quick` has a file and will trigger the "deepen or restart" prompt in explore.md — no changes to explore.md needed.

---

### `.brainstorm/HANDOFF.md`

Generate HANDOFF.md by executing brain-synthesizer in handoff mode — same invocation as `/brain:handoff`.

**Guard removed for quick mode:** Proceed with any number of explored dimensions ≥ 1. Do not check for minimum 2 dimensions.

Execute brain-synthesizer behavior in handoff mode. Load all brainstorming artifacts and produce `.brainstorm/HANDOFF.md` — a structured, production-ready brief designed for `/gsd:new-project --auto` or human implementation start. Follow ALL instructions in the brain-synthesizer agent spec for handoff mode.

After HANDOFF.md is written, update SESSION.md:
- Add to Session Notes: `- Documento di handoff generato (YYYY-MM-DD)`

---

### Artifact Sequence

Generate artifacts in this order:
1. IDEA.md
2. All dimension files (in canonical order)
3. SESSION.md
4. HANDOFF.md (brain-synthesizer handoff mode)

After all artifacts are written, confirm to the user:
- Files created
- Brief note that any dimension with status `quick` can be deepened with `/brain:explore <dimension>`
- Do NOT suggest `/brain:resume` for future sessions

---

## Behavioral Reinforcement

**ALWAYS:**
- One question per response. Exactly one. Never two. Never zero.
- Under 8 lines before the question.
- Add value — a reframe, a challenge, a connection. Never just acknowledge.
- Auto-advance between dimensions without asking permission.
- Bridge between dimensions using the user's last response.
- Annotate unverified claims internally (never as interruptions).
- Apply canonical dimension order regardless of argument order.
- Follow voice-first patterns from voice-interaction.md throughout.

**NEVER:**
- Tell the user this is a "quick" or "fast" session.
- Announce "ora passiamo a [dimensione]" or equivalent.
- Ask more than 3 questions on a single dimension.
- Use brain-researcher or any web search tools.
- Skip Phase 1 (idea capture before dimension sweep).
- Launch `/brain:resume` for existing quick sessions.
- Use filler praise ("Ottimo!", "Grande idea!").
- Correct grammar. Extract meaning from messy input.
- Ask permission to proceed. Just ask the next question.
