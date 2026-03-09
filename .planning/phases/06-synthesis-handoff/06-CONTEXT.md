# Phase 6: Synthesis & Handoff - Context

**Gathered:** 2026-03-09
**Status:** Ready for planning

<domain>

## Phase Boundary

Deliver three commands — `/brain:analyze`, `/brain:synthesize`, `/brain:handoff` — and the `brain-synthesizer` agent that powers them. All three are fully automatic (no interactive conversation). The flow is: analyze → synthesize → handoff, where analyze is required before synthesize, and synthesize is recommended but not required before handoff. Minimum 2 explored dimensions for all three commands.

Note: the original requirements scoped `/brain:synthesize` to cover both analysis and synthesis. User decision splits this into two distinct commands with different purposes. `/brain:analyze` is a new command not in the original requirements — plan accordingly.

</domain>

<decisions>

## Implementation Decisions

### Command flow and prerequisites
- Three commands: `/brain:analyze`, `/brain:synthesize`, `/brain:handoff`
- All three are fully automatic — launch, agent reads dimensions, produces output, shows result. Zero interaction
- Sequential chain: analyze → synthesize → handoff
- `/brain:analyze` requires 2+ explored dimensions, produces ANALYSIS.md
- `/brain:synthesize` requires ANALYSIS.md as input, produces SYNTHESIS.md
- `/brain:handoff` prefers SYNTHESIS.md but works without it (produces a more basic handoff from dimensions alone). Requires 2+ explored dimensions

### ANALYSIS.md — cross-dimensional analysis
- Organized by theme, not by dimension pairs — patterns often cross 3+ dimensions
- Themes emerge from the content (not predefined categories)
- Internal structure within each theme at Claude's discretion (may include pattern description, dimensions involved, type classification — whatever serves clarity)
- More rigorous gap signaling: flags missing dimensions AND which specific sections within explored dimensions are thin

### SYNTHESIS.md — narrative synthesis
- Narrative, discursive document — tells the story of the idea seen from all angles
- Intended audience: non-technical stakeholders (client, co-founder, investor). Readable, not structured for machines
- Cohesive vision, not a list of recommendations or priorities
- Length adapts to richness of explored dimensions (Claude decides)
- Gap signaling: generic note about missing dimensions at the end (less detailed than analysis)

### HANDOFF.md — GSD-ready brief
- Production-ready document, structured for `/gsd:new-project` consumption
- Opinionated: where brainstorming produced a clear direction, HANDOFF.md declares it as a decision. Where ambiguity remains, flags it explicitly
- 6 fixed sections always present: Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model
- Additional sections allowed if brainstorming produced relevant content that doesn't fit the 6 base sections
- No indication of source level (synthesis vs dimensions only) — the document stands on its own
- Gap signaling: same as synthesis (note about missing dimensions)

### Claude's Discretion
- Internal structure of analysis themes
- Length and depth of SYNTHESIS.md based on content richness
- Which additional sections to add to HANDOFF.md (if any)
- How to handle dimensions with very thin content in each document
- Whether brain-synthesizer is one agent handling all three commands or has distinct modes

</decisions>

<specifics>

## Specific Ideas

- SYNTHESIS.md is the "client-facing" document — the one you'd show to a non-technical person to discuss the idea
- HANDOFF.md is the "builder-facing" document — opinionated, structured, ready to feed into GSD pipeline
- ANALYSIS.md is the "working document" — systematic cross-dimensional analysis that feeds into synthesis

</specifics>

<deferred>

## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-synthesis-handoff*
*Context gathered: 2026-03-09*
