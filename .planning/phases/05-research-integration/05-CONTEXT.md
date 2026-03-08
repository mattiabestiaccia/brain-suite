# Phase 5: Research Integration - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>

## Phase Boundary

During dimension exploration, the explorer identifies when real data would strengthen the analysis (market data, competitor info, tech feasibility) and spawns a brain-researcher agent in the background. The researcher fetches factual data via Exa MCP and returns structured results that the explorer integrates naturally into the ongoing conversation. User explicitly confirms research capability once per session.

</domain>

<decisions>

## Implementation Decisions

### Research Triggers
- Explorer intercepts vague claims: "il mercato è grande", "credo ci siano competitor", "dovrebbe essere fattibile"
- Researcher runs in background/parallel — conversation NEVER pauses to wait for results
- Explorer gives a brief inline notice ("Intanto verifico quel dato...") then continues with the next question immediately
- Maximum 2-3 parallel research requests per session to prevent result flooding

### Confirmation Flow
- No upfront permission — confirmation happens at the first trigger
- First time the explorer spots a vague claim, it asks permission: "Posso cercare dati su X in background?" From that point forward, the explorer is autonomous
- If user refuses, explorer retries once later only if the moment is highly relevant
- User can refine research scope (e.g., "cerca solo il mercato italiano, non globale") — explorer passes refinement to the researcher's query

### Researcher Output Format
- 3-5 synthetic bullet points, each with key data point + source (name + year + URL)
- 2-3 queries per research request to triangulate data from different angles
- Results are integrated into the dimension file at session closure — no separate research files
- Sources with name + URL for verifiability

### Re-integration into Conversation
- Explorer inserts results at the first natural opportunity: "A proposito, i dati dicono che..."
- If the topic has moved on, explorer inserts anyway with a brief bridge ("A proposito di prima...")
- If no relevant data found, explorer says so openly — "non ho trovato dati" is useful information
- If data contradicts what the user said, explorer signals it transparently
- Research results influence subsequent questions only when naturally relevant, not forced
- Multiple results arriving simultaneously: grouped if correlated, separated if not

### Claude's Discretion
- Exact threshold for what constitutes a "vague claim" worth researching
- How to formulate Exa MCP queries from conversational context
- Phrasing of the inline research notice and result insertion
- How to handle edge cases (Exa MCP unavailable, rate limits)

</decisions>

<specifics>

## Specific Ideas

- "L'obiettivo principale è rendere la conversazione quanto più scorrevole e realistica possibile per fare brainstorming. Un'interruzione per attendere i risultati di un altro agente rovinerebbe l'esperienza."
- The conversation session must be preserved intact — the researcher is a background service, not a conversation participant
- The explorer maintains its conversational thread regardless of research activity

</specifics>

<deferred>

## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-research-integration*
*Context gathered: 2026-03-08*
