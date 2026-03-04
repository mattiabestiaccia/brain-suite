# Phase 2: New Session Flow - Context

**Gathered:** 2026-03-04
**Status:** Ready for planning

<domain>

## Phase Boundary

User runs `/brain:new` and goes through interactive Socratic questioning to define their idea, producing `.brainstorm/IDEA.md` and `.brainstorm/SESSION.md`. This phase delivers the first vertical slice: a complete brainstorming session from scratch to saved artifacts. Dimension exploration (`/brain:explore`) and session resume (`/brain:resume`) are separate phases.

</domain>

<decisions>

## Implementation Decisions

### Architecture
- `/brain:new` is a direct command (skill), NOT an agent spawn. Claude conducts the conversation directly, loading reference files (voice-interaction.md, questioning.md, dimensions-guide.md) into context
- brain-explorer agent is NOT used in this phase — multi-turn conversation with a subagent is impractical (context loss, latency, breaks natural flow)
- brain-explorer agent may be reconsidered for Phase 3 (`/brain:explore`) where tasks could be more autonomous

### Initial questioning flow
- **Open canvas** start — Claude opens with an open question ("What's the idea?"), user leads
- **Soft coverage** on 3 core points: problem, target audience, rough solution. Claude tracks these internally but does NOT follow a rigid structure — the conversation is free-flowing brainstorming
- The user may not even realize they're covering these points. Claude extracts them from natural conversation
- When Claude judges all 3 points are understood (even roughly), it proposes to save. If the user wants to keep brainstorming, conversation continues without pressure

### Idea evolution tracking
- If the idea mutates during conversation, Claude tracks the evolution — both starting point and where it ended up
- If Claude notices a significant divergence, it signals it lightly (a brief note, not a formal intervention)
- This is not a strict rule — if the divergence is obvious, document it. If not, don't force it

### Conversation flow
- Follows the flusso: if the user spontaneously enters dimensional territory (competitors, tech, market), Claude follows the conversation naturally
- No file dimensionali separati are produced — everything goes into IDEA.md
- The conversation is brainstorming, not an interview. The user may discover what they need along the way

### Session closure
- **Recap + confirm** before saving — Claude shows a summary of what it understood, user can correct or add, then save
- **Save + suggest** — After saving, Claude suggests which dimension to explore first, based on what emerged in the conversation (not a fixed order)

### Existing session handling
- If `.brainstorm/` already exists when `/brain:new` is called, Claude asks the user: start fresh or continue with existing idea?
- **Start fresh** → archives previous session to `.brainstorm/archive/` before creating new files
- **Continue** → redirects to `/brain:resume` (fallback, no duplication of resume logic)
- **One idea at a time** — `.brainstorm/` always contains a single active idea. Previous ideas go to archive

### IDEA.md format
- **Emergent structure** — sections reflect what actually came out of the conversation, not a fixed template. If the user talked mostly about the problem and barely about the solution, the file reflects that
- **Distilled** — clean, concise, substance only. Conversational noise removed. Not raw transcript
- **Evolution section** — dedicated section documenting how the idea evolved during the session, if it changed
- **Dimensional hints** — if dimensional topics (market, tech, competitors) emerged naturally, they're captured in a "spunti emersi" section without forcing dimensional structure

### SESSION.md
- Claude's discretion on structure and content for Phase 2, with awareness that Phase 3 and 4 will need to read it

</decisions>

<specifics>

## Specific Ideas

- The first phase should feel like brainstorming, not a questionnaire. Even the user might not know what they need at the start — the conversation helps them figure it out
- IDEA.md that documents idea evolution serves a concrete purpose: the user can re-read and choose between the original direction and where they ended up
- The dimensional suggestion at the end should feel natural, like "you were already talking about competitors, maybe start there" — not a generic "start with product"

</specifics>

<deferred>

## Deferred Ideas

- brain-explorer as spawned agent for dimension exploration — Phase 3 consideration
- Multiple simultaneous ideas — out of scope, one active idea at a time
- `/brain:resume` implementation — Phase 4

</deferred>

---

*Phase: 02-new-session-flow*
*Context gathered: 2026-03-04*
