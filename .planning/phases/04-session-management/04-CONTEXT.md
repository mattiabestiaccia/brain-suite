# Phase 4: Session Management - Context

**Gathered:** 2026-03-07
**Status:** Ready for planning

<domain>

## Phase Boundary

User can resume previous sessions, track progress across dimensions, revisit already-explored dimensions (deepen or restart), add custom dimensions, and receive guidance on what to explore next. Commands: `/brain:status`, `/brain:resume`, `/brain:add-dimension`. Plus re-exploration flow in `/brain:explore` and proactive next-dimension suggestions.

</domain>

<decisions>

## Implementation Decisions

### Status display
- Enriched view: emoji indicators per dimension status, ASCII progress bar, next-dimension suggestion at the bottom
- Show idea title + one-liner from IDEA.md at the top for immediate context
- Keep dimension notes brief (1-2 words from SESSION.md) — status is a compass, not a report
- When no dimensions are explored yet, show empty grid without suggestion (suggestion already comes from `/brain:new`)

### Resume experience
- Show a narrative summary on re-entry ("Stavi esplorando X, hai coperto Y e Z, manca W") — different tone from status grid
- Propose the next dimension to explore directly after the summary
- If user accepts the proposal, launch `/brain:explore <dimension>` automatically — zero friction
- If user deviates ("no, voglio rivedere competitors", "fammi vedere lo status"), handle the intent internally — resume acts as an intelligent hub, no bouncing between commands

### Re-exploration flow
- When user launches explore on an already-explored dimension, ask directly upfront: "Hai già esplorato X. Vuoi approfondire o ricominciare?"
- **Deepen:** load the previous dimension file into context and resume as a continuation, naturally steering toward weak spots — no explicit report of what's missing
- **Restart:** archive the previous dimension file (e.g., `dimensions/archive/`) before starting fresh — nothing is ever lost
- Deepening produces an updated file that replaces the previous one (single source of truth per dimension). Session logs in `sessions/` preserve history.

### Custom dimensions
- Input required: dimension name + brief description (1-2 sentences of what the user wants to explore)
- Generated template is freeform — few generic headings, not the rigid structure of built-in templates. Custom dimensions exist because the user wants to go off-script.
- Flexible naming: multiple words allowed, any language, automatic slug for file paths (e.g., "supply chain" -> `supply-chain.md`)
- Custom dimensions are explorable only via `/brain:explore <name>`, no shortcut commands. Shortcuts stay reserved for the 6 built-in dimensions.

### Claude's Discretion
- Exact emoji choices and ASCII progress bar design for status
- How the narrative resume summary is structured internally
- How the explorer identifies weak spots when deepening a dimension
- Template section structure for custom dimension generation
- Slug generation logic for multi-word dimension names

</decisions>

<specifics>

## Specific Ideas

- Resume should feel like reopening a conversation with a collaborator who remembers where you left off — not like loading a save file
- Status is a dashboard/compass — compact, scannable, actionable
- Archive pattern for re-exploration should be consistent with `/brain:new`'s archive behavior (both archive before replacing)
- Custom dimensions are deliberately less structured than built-in ones — the user adds them precisely because the standard dimensions don't cover their angle

</specifics>

<deferred>

## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-session-management*
*Context gathered: 2026-03-07*
