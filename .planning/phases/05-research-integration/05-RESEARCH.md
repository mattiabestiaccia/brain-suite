# Phase 5: Research Integration - Research

**Researched:** 2026-03-08
**Domain:** Claude Code subagent spawning during interactive conversation, Exa MCP search API, background task execution, result re-integration into conversational flow
**Confidence:** MEDIUM

## Summary

Phase 5 adds real-time factual data injection to dimension exploration. When the explorer detects vague claims ("il mercato è grande", "credo ci siano competitor"), it asks user permission once per session and then spawns a brain-researcher subagent in the background via the Task tool. The researcher executes 2-3 Exa MCP queries, produces 3-5 structured bullet points with sources, and writes results to a temporary file. The explorer reads the results at the next natural conversational pause and integrates them with a casual bridge ("A proposito, i dati dicono che...").

The primary architectural challenge is that the explorer is a **markdown-as-prompt interactive command** (not a spawned subagent) -- Phases 2-4 explicitly established that the Task tool should NOT be used to delegate the conversation itself. However, Phase 5 requires the explorer to **spawn a background Task** for research while continuing the conversation. This is a fundamentally different use case: the Task spawns a non-conversational worker (researcher), not a conversation delegate. Claude Code supports this via the Task tool with background execution -- the subagent runs independently, writes its results, and the parent agent (the explorer conversation) can read them later.

The critical design risk is **timing and re-integration**. The researcher subagent runs asynchronously. The explorer must: (1) remember that research is in flight, (2) check for results at natural conversation breaks, (3) integrate results smoothly without breaking conversational flow, and (4) handle cases where results never arrive (Exa MCP unavailable, timeout). The CONTEXT.md user decision is clear: the conversation NEVER pauses to wait for results. If results arrive late or not at all, the explorer continues without them and reports honestly.

**Primary recommendation:** Implement as 2 plans: (1) Create the brain-researcher agent spec with Exa MCP query patterns and structured output format, plus modify install.sh to symlink templates directory for researcher output. (2) Modify the brain-explorer agent spec AND the explore.md command to add research detection, permission flow, Task-based spawning, result polling, and re-integration behavior. Plan 2 is the higher-risk plan and should come second so plan 1's researcher spec is available as a dependency.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Research Triggers
- Explorer intercepts vague claims: "il mercato è grande", "credo ci siano competitor", "dovrebbe essere fattibile"
- Researcher runs in background/parallel — conversation NEVER pauses to wait for results
- Explorer gives a brief inline notice ("Intanto verifico quel dato...") then continues with the next question immediately
- Maximum 2-3 parallel research requests per session to prevent result flooding

#### Confirmation Flow
- No upfront permission — confirmation happens at the first trigger
- First time the explorer spots a vague claim, it asks permission: "Posso cercare dati su X in background?" From that point forward, the explorer is autonomous
- If user refuses, explorer retries once later only if the moment is highly relevant
- User can refine research scope (e.g., "cerca solo il mercato italiano, non globale") — explorer passes refinement to the researcher's query

#### Researcher Output Format
- 3-5 synthetic bullet points, each with key data point + source (name + year + URL)
- 2-3 queries per research request to triangulate data from different angles
- Results are integrated into the dimension file at session closure — no separate research files
- Sources with name + URL for verifiability

#### Re-integration into Conversation
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

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| RES-01 | Explorer identifies when real data would help and suggests spawning brain-researcher | Explorer detects vague claims (market size, competitor assertions, tech feasibility) during conversation. Detection rules embedded in explore.md and brain-explorer.md behavioral sections. First trigger asks user permission; subsequent triggers are autonomous. |
| RES-02 | User confirms before researcher is spawned (explorer suggests, user approves) | One-time confirmation at first trigger: "Posso cercare dati su X in background?" After approval, explorer is autonomous for the rest of the session. User can refine scope. If refused, explorer retries once later only if highly relevant. |
| RES-03 | brain-researcher fetches factual data via Exa MCP (market data, competitor info, tech feasibility) | Researcher agent spec uses `mcp__exa__web_search_exa` and `mcp__exa__get_code_context_exa` tools. 2-3 queries per research request with different angles. Output: 3-5 bullet points with source name + year + URL. Results written to temp file in `.brainstorm/`. |
| RES-04 | Researcher results are integrated into dimension exploration context | Explorer polls for results at natural conversation breaks. Inserts with casual bridge phrase. Results included in dimension file under a "Research Data" subsection at closure. No separate research artifact files. |
| AGT-02 | brain-researcher agent fetches factual data via web search (Exa MCP) when spawned by explorer | Full agent spec in `agents/brain-researcher.md` with tool declarations, query formulation patterns, output format, and error handling. Spawned via Task tool from explore.md. |

</phase_requirements>

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Claude Code command `.md` | Current | Modifications to `explore.md` and `brain-explorer.md` for research integration behavior | Same pattern as Phases 2-4. The explore command is the orchestrator that spawns the researcher. |
| Task tool (TaskCreate) | Built-in | Spawn brain-researcher as a background subagent during exploration | Native Claude Code mechanism for background task execution. Subagent runs independently, parent continues conversation. |
| `mcp__exa__web_search_exa` | Current | General web search for market data, competitor info, industry trends | Exa MCP provides clean, LLM-optimized content. Supports natural language queries and category filters (company, research paper). |
| `mcp__exa__get_code_context_exa` | Current | Code/documentation search for tech feasibility questions | Specialized for GitHub, Stack Overflow, official docs. Better than web_search for technical queries. |
| Read tool | Built-in | Explorer reads researcher results from temp file | Same pattern as all phases. Explorer polls for result file existence. |
| Write tool | Built-in | Researcher writes structured results to temp file | Researcher output goes to `.brainstorm/.research-pending/` as temp storage. |
| Bash tool | Built-in | Directory creation, file cleanup after integration | Create `.brainstorm/.research-pending/`, clean up temp files after explorer reads results. |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Glob tool | Built-in | Explorer checks for pending research results | Poll `.brainstorm/.research-pending/*.md` for new result files |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Task tool (background subagent) | Inline Exa calls from explorer | REJECTED: Inline calls would pause the conversation for 5-15 seconds per search. CONTEXT.md explicitly forbids pausing. Background Task is the only pattern that keeps conversation flowing. |
| Temp file exchange (`.brainstorm/.research-pending/`) | SendMessage between agents | REJECTED: SendMessage requires Agent Teams (experimental, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Explorer is not a teammate -- it's a command-driven interactive session. File-based exchange is simpler and works without experimental features. |
| Exa MCP | Built-in WebSearch tool | Exa produces cleaner, more LLM-friendly content. User's global CLAUDE.md explicitly prefers Exa MCP. WebSearch is fallback only if Exa is unavailable. |
| Writing results to temp file | TaskOutput to read subagent results | TaskOutput returns raw JSONL conversation log in some versions (known bug: GitHub issues #16789, #17591). File-based exchange is more reliable and gives the researcher control over output format. |

**Installation:** No additional installation for the task mechanism. Exa MCP must already be configured (it is -- verified in user's global CLAUDE.md as default search tool). The brain-researcher agent file already exists as a stub in `agents/brain-researcher.md` and is already symlinked to `~/.claude/agents/`.

## Architecture Patterns

### Recommended Project Structure

```
agents/
├── brain-explorer.md       # MODIFIED: add research detection, spawning, and re-integration behavior
├── brain-researcher.md     # MODIFIED: replace stub with full agent spec (Exa MCP queries, output format)
└── brain-synthesizer.md    # Existing stub (unchanged)

commands/brain/
├── explore.md              # MODIFIED: add research spawning flow, result polling, dimension file integration
├── new.md                  # Existing (unchanged)
├── resume.md               # Existing (unchanged)
├── status.md               # Existing (unchanged)
├── add-dimension.md        # Existing (unchanged)
├── product.md              # Existing shortcut (unchanged -- inherits explore.md changes via delegation)
├── tech.md                 # Existing shortcut (unchanged)
├── market.md               # Existing shortcut (unchanged)
├── business.md             # Existing shortcut (unchanged)
├── competitors.md          # Existing shortcut (unchanged)
└── users.md                # Existing shortcut (unchanged)

.brainstorm/                     # Runtime session workspace
├── .research-pending/           # NEW: temp directory for researcher results (explorer reads, then cleans)
│   └── research-<timestamp>.md  # Temp result file from researcher subagent
├── IDEA.md
├── SESSION.md
├── dimensions/
│   └── <dimension>.md           # MODIFIED: new "Dati e Ricerche" subsection added at closure
└── sessions/
    └── <dimension>-<date>.md
```

### Pattern 1: Background Subagent Spawning from Interactive Command

**What:** The explore.md command (which drives an interactive conversation) uses the Task tool to spawn a brain-researcher subagent in the background. The conversation continues uninterrupted. The researcher works independently and writes results to a temp file.

**Why this works:** The Task tool creates a separate Claude instance with its own context window. The parent (explorer conversation) is NOT blocked -- it continues processing user messages. The subagent has access to tools declared in its agent spec (Exa MCP, Read, Write). When it completes, its results are available via the temp file it wrote.

**Critical distinction from the existing anti-pattern rule:** The explore.md currently says "NEVER delegate to a separate agent via Task -- this is a direct conversation with the user, do not break it." This rule prevents delegating the CONVERSATION to a Task. Phase 5 does NOT delegate the conversation -- it spawns a background WORKER that has no interaction with the user. The explorer remains the sole conversation partner.

**Implementation approach:**

```
RESEARCH SPAWNING FLOW (inside explore.md conversation):

1. Explorer detects vague claim during conversation
2. First time: ask permission ("Posso cercare dati su X in background?")
   - If user refuses: note internally, retry once later if highly relevant
   - If user approves: set RESEARCH_ENABLED = true for this session
3. Subsequent times (RESEARCH_ENABLED = true): spawn directly
4. Spawn researcher via Task tool:
   - Agent: brain-researcher
   - Prompt: the research question formulated from conversational context
   - Background: true
   - The researcher writes results to .brainstorm/.research-pending/research-<timestamp>.md
5. Explorer gives brief notice ("Intanto verifico quel dato...") and continues conversation
6. Track: increment RESEARCH_COUNT (max 2-3 per session)
```

**Key constraints:**
- Maximum 2-3 research requests per session (CONTEXT.md decision)
- Explorer continues asking the next question immediately after spawning
- No waiting, no polling loops, no conversation pauses

### Pattern 2: Result Polling and Re-integration

**What:** The explorer checks for pending research results at natural conversation breaks (after processing a user response, before asking the next question). If results are found, they are woven into the conversation naturally.

**When to check:** At every response cycle, after processing the user's answer and before formulating the next question. This is a lightweight check (Glob for `.brainstorm/.research-pending/*.md`). If no files found, proceed normally. If file found, read it and integrate.

**Implementation approach:**

```
RESULT RE-INTEGRATION FLOW (inside explore.md conversation loop):

Before each explorer response:
1. Use Glob to check: .brainstorm/.research-pending/*.md
2. If no files: proceed with normal conversation flow
3. If file(s) found:
   a. Read the result file(s)
   b. Integrate naturally into the response:
      - If topic is still current: "A proposito, i dati dicono che..."
      - If topic moved on: "A proposito di prima, quando parlavamo di X..."
      - If no data found: "Ho cercato dati su X ma non ho trovato nulla di rilevante"
      - If data contradicts user: signal transparently
   c. Delete the temp file(s) after reading (cleanup)
   d. Store results internally for dimension file integration at closure
4. Results influence subsequent questions only when naturally relevant
```

**Multiple results:** If 2 results arrive simultaneously (from separate research requests), group them if correlated (e.g., both about market size), separate them if not (e.g., one about market, one about tech feasibility).

### Pattern 3: Researcher Agent Spec (brain-researcher.md)

**What:** The brain-researcher agent is a non-conversational worker. It receives a research question, formulates 2-3 Exa MCP queries, executes them, synthesizes results into 3-5 bullet points, and writes a structured result file.

**Agent lifecycle:**
1. Receive research question from parent Task
2. Formulate 2-3 search queries from different angles
3. Execute queries via Exa MCP tools
4. Synthesize results: 3-5 bullet points, each with data point + source (name + year + URL)
5. Write results to `.brainstorm/.research-pending/research-<timestamp>.md`
6. Complete (subagent terminates)

**Query formulation patterns:**

| Claim Type | Query Strategy | Exa Tool |
|------------|---------------|----------|
| Market size ("il mercato è grande") | "market size [domain] 2025 2026 revenue" + "[domain] market growth forecast" | `web_search_exa` with category: "company" or "research paper" |
| Competitor claims ("ci sono pochi competitor") | "[domain] competitors landscape" + "alternatives to [product type]" | `web_search_exa` |
| Tech feasibility ("dovrebbe essere fattibile") | "[technology] implementation guide" + "[technology] limitations gotchas" | `get_code_context_exa` |
| User behavior ("gli utenti vogliono X") | "[domain] user research survey 2025" + "[user type] pain points needs" | `web_search_exa` |
| Pricing ("il prezzo giusto è X") | "[domain] pricing benchmarks" + "[product type] pricing models 2025" | `web_search_exa` with category: "company" |

**Result file format:**

```markdown
# Research Results

**Query:** [original research question from explorer]
**Searched:** [timestamp]
**Status:** [found_data | no_relevant_data | partial_data | error]

## Findings

- **[Key data point]** — Source: [Name] ([Year]) [URL]
- **[Key data point]** — Source: [Name] ([Year]) [URL]
- **[Key data point]** — Source: [Name] ([Year]) [URL]

## Raw Queries Used

1. [query 1] → [N results]
2. [query 2] → [N results]
3. [query 3] → [N results]

---
*Research by brain-researcher for /brain:explore on [date]*
```

### Pattern 4: Dimension File Integration at Closure

**What:** At session closure, research results that were integrated during conversation are written into the dimension file under a dedicated subsection. No separate research artifact files are created (CONTEXT.md decision).

**Implementation:** Add a "Dati e Ricerche" subsection to the dimension document, placed after the Cross-Dimensional Notes section. This subsection contains all research data that was surfaced during the exploration, with sources preserved.

```markdown
## Dati e Ricerche

Research data surfaced during exploration:

- **[Topic]:** [Data point integrated during conversation] — Source: [Name] ([Year]) [URL]
- **[Topic]:** [Data point] — Source: [Name] ([Year]) [URL]

*[N] research requests executed via brain-researcher during this exploration.*

## Cross-Dimensional Notes

[existing section, unchanged]
```

If no research was performed or all searches returned no data, this section reads: "No research data was surfaced during this exploration."

### Pattern 5: Permission and State Tracking

**What:** The explorer tracks research permission and count as internal state during the conversation. This state is NOT persisted to files -- it lives only for the duration of the exploration session.

**State variables (internal to explorer):**
- `RESEARCH_ENABLED`: false → true after user grants permission (stays true for session)
- `RESEARCH_COUNT`: 0 → incremented on each spawn (max 2-3)
- `RESEARCH_REFUSED`: false → true if user declines (allows one retry later)
- `PENDING_RESULTS`: list of research topics in flight (for tracking what to check)
- `INTEGRATED_RESULTS`: list of results already shown to user (for dimension file at closure)

### Anti-Patterns to Avoid

- **Blocking the conversation for search results.** NEVER pause the conversation to wait for researcher results. The researcher runs asynchronously; results arrive when they arrive. If they never arrive, the conversation loses nothing.
- **Spawning the researcher without permission.** The FIRST research trigger MUST ask the user. Only subsequent triggers are autonomous.
- **Flooding the conversation with research data.** Maximum 2-3 research requests per session. Results are brief (3-5 bullets). Integration is casual, not a formal report.
- **Creating separate research files.** CONTEXT.md decision: results are integrated into the dimension file at closure. No `.brainstorm/research/` directory. The temp files in `.research-pending/` are cleaned up after the explorer reads them.
- **Researcher talking to the user.** The researcher is a silent background worker. It has no conversational interface. It writes a file and terminates. Only the explorer talks to the user.
- **Revealing research mechanics.** The explorer should NOT say "I'm spawning a subagent" or "The Task tool is creating a researcher." It should say "Intanto verifico quel dato..." -- casual, natural, no implementation details.
- **Modifying the existing explore.md anti-pattern rule incorrectly.** The rule "NEVER delegate to a separate agent via Task" should be REFINED, not removed. The refinement: "NEVER delegate the CONVERSATION to a Task. Background research via Task is permitted when RESEARCH_ENABLED is true."
- **Using SendMessage/Agent Teams.** The explorer is a command-driven interactive session, not an Agent Teams teammate. File-based exchange via `.brainstorm/.research-pending/` is the correct mechanism. Agent Teams would require experimental feature flags and architectural changes incompatible with the current Brain Suite design.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Web search for factual data | Custom scraping or API calls | Exa MCP (`web_search_exa`, `get_code_context_exa`) | Exa returns clean, LLM-optimized content. No need to parse HTML, handle rate limits, or manage API keys (already configured). |
| Background task execution | Custom async mechanism or shell background processes | Task tool (Claude Code built-in) | Native support for subagent spawning with background execution. Handles lifecycle, context isolation, and tool access automatically. |
| Result exchange between explorer and researcher | In-memory state, message queues, or file watchers | Simple file write/read pattern via `.brainstorm/.research-pending/` | File-based exchange is the simplest reliable mechanism. No shared memory, no experimental features, no complexity. Glob checks for file existence are instant. |
| Query formulation from conversation | NLP/entity extraction pipeline | Claude's natural language understanding | The explorer IS an LLM. It can formulate search queries from conversational context directly. No separate extraction step needed. |
| Source citation formatting | Citation management library | Simple markdown format: `Source: [Name] ([Year]) [URL]` | Only 3-5 bullets per research request. Simple inline formatting is sufficient. |

**Key insight:** The core complexity of Phase 5 is NOT in the search mechanism (Exa MCP is straightforward) or the subagent spawning (Task tool is well-documented). The complexity is in the **behavioral prompt engineering** -- teaching the explorer WHEN to trigger research, HOW to continue the conversation seamlessly, and HOW to re-integrate results naturally. This is a prompt engineering challenge, not a systems engineering challenge.

## Common Pitfalls

### Pitfall 1: Explorer Pauses Conversation While Waiting for Research

**What goes wrong:** After spawning the researcher, the explorer says "Aspetta un momento, sto cercando..." and stops asking questions until results arrive.

**Why it happens:** The explorer instruction to "check for results" is interpreted as "wait for results." Or the explorer doesn't know what to ask next because it's mentally "waiting" for the research data.

**How to avoid:**
- The spawning instruction must be EXPLICIT: "After spawning, immediately continue with the next question. Do NOT wait. Do NOT mention waiting."
- The result check happens BEFORE each response, not as a blocking wait.
- The explorer must always have a next question ready, independent of research results.
- Behavioral reinforcement at end of explore.md: "Research is fire-and-forget. Spawn, notice briefly, move on."

**Warning signs:** Long silence after "Intanto verifico..." Explorer asks "Stai aspettando i risultati?" Conversation has an unnatural pause.

### Pitfall 2: Researcher Spawns But Cannot Access Exa MCP

**What goes wrong:** The brain-researcher subagent is spawned via Task but has no access to Exa MCP tools, so it fails silently or produces empty results.

**Why it happens:** The agent spec declares Exa MCP tools, but the subagent's runtime environment may not have them available. Exa MCP is configured via the user's global settings, but subagent tool access depends on how the Task tool inherits the parent's MCP configuration.

**How to avoid:**
- Verify during implementation that Task-spawned subagents inherit MCP server configuration from the parent session.
- The researcher agent spec must list exact tool names: `mcp__exa__web_search_exa`, `mcp__exa__get_code_context_exa`.
- Include a fallback in the researcher: if Exa MCP tools are unavailable, write a result file with status "error" and a message explaining the failure. The explorer then tells the user honestly: "Non sono riuscito a cercare dati -- lo strumento di ricerca non è disponibile."
- Test this during verification: spawn a researcher and confirm Exa MCP access.

**Warning signs:** Researcher completes instantly with empty results. Explorer never receives result files. Error logs in Task output.

### Pitfall 3: Research Results Arrive After Session Closure

**What goes wrong:** The user wraps up the conversation and the dimension file is written, but researcher results arrive after closure. Results are lost.

**Why it happens:** The researcher subagent may take 10-30 seconds. If the conversation is short or the user wraps up quickly, closure can happen before results are ready.

**How to avoid:**
- At closure time, explicitly check `.brainstorm/.research-pending/` one final time before writing the dimension file.
- If results are pending (researcher still running), the explorer should mention it: "C'è ancora una ricerca in corso -- se vuoi possiamo aspettare un momento, oppure chiudiamo e la aggiungo dopo."
- If the user chooses to wait: poll briefly (5-10 seconds max), then proceed regardless.
- If results arrive after full closure: they remain in `.research-pending/` and can be integrated next time the dimension is explored (deepen mode from Phase 4).
- Dimension file "Dati e Ricerche" section notes: "1 research request still pending at closure."

**Warning signs:** User sees "Intanto verifico quel dato..." but the dimension file has no research data section. Temp files linger in `.research-pending/` indefinitely.

### Pitfall 4: Explorer Over-Triggers Research

**What goes wrong:** The explorer spawns 3 research requests in the first 5 exchanges, hitting the maximum immediately. OR every slightly uncertain statement triggers a research request.

**Why it happens:** The threshold for "vague claim" is too low, or the explorer is too eager to demonstrate the research capability.

**How to avoid:**
- Define clear threshold criteria in the explorer behavioral spec: research is for FACTUAL claims that can be verified with data, not for opinions, preferences, or speculative ideas.
- Good triggers: "il mercato vale X miliardi", "non ci sono competitor", "questa tecnologia può scalare a Y"
- Bad triggers: "penso che sarebbe bello", "forse potremmo", "il design dovrebbe essere semplice"
- The 2-3 request cap is a hard limit. Explorer should save requests for the most impactful moments.
- Behavioral guidance: "Spawn research only when factual data would MEANINGFULLY change the direction of exploration. If the vague claim is about taste/preference/vision, do NOT research it."

**Warning signs:** All 3 research slots used up in the first third of the conversation. Research triggered for opinion-based statements. User feels bombarded with "Intanto verifico..."

### Pitfall 5: Research Results Disrupt Conversational Flow

**What goes wrong:** The explorer interrupts a deep discussion about product vision to insert market data from a researcher that completed. The result feels forced and breaks the user's train of thought.

**Why it happens:** Results are inserted at the first possible moment regardless of conversational context.

**How to avoid:**
- CONTEXT.md is clear: "Explorer inserts results at the first NATURAL opportunity." Natural = between topics, during a transition, or when the data directly relates to the current discussion.
- If the current discussion is intense and focused, defer result integration for 1-2 more exchanges.
- Use bridge phrases to smooth the transition: "A proposito di prima, quando parlavamo di [topic]..."
- The result integration should feel like a natural aside, not a formal data presentation.
- Keep integration brief: 1-2 sentences summarizing the key finding, not reading all 5 bullets.

**Warning signs:** User says "aspetta, stavo dicendo..." after result insertion. The conversation loses momentum at insertion points. Results feel like commercial interruptions.

### Pitfall 6: Task Tool Anti-Pattern Rule Confusion

**What goes wrong:** The existing explore.md rule "NEVER delegate to a separate agent via Task" prevents the explorer from spawning the researcher, because the LLM interprets the rule as a blanket prohibition on all Task tool usage.

**Why it happens:** The rule was written in Phase 3 to prevent delegating the CONVERSATION to a Task (which would break multi-turn interaction). But the LLM may not distinguish between "delegating conversation" and "spawning a background worker."

**How to avoid:**
- The rule must be REFINED, not removed. New wording: "NEVER delegate the conversation to a Task. The explorer maintains the direct conversation with the user at all times. Background research tasks via brain-researcher ARE permitted when research is enabled."
- Place the research-specific permission BEFORE the general anti-pattern rule in the file (earlier placement = stronger signal).
- Add the research spawning instructions in a dedicated section that explicitly grants Task tool usage for brain-researcher only.

**Warning signs:** Explorer never spawns research despite detecting vague claims. Explorer outputs "I cannot use the Task tool per my instructions." Explorer tries to call Exa MCP directly (inline, blocking the conversation).

## Code Examples

### Example 1: Research Trigger and Permission Flow

```markdown
## During conversation (explorer perspective):

User says: "Il mercato del project management vale tantissimo"

Explorer thinks:
- This is a factual claim about market size → research trigger
- RESEARCH_ENABLED is false (first time) → ask permission
- RESEARCH_COUNT is 0 → under limit

Explorer response:
"OK, il project management è un mercato enorme, ma quanto enorme?
Posso cercare dati reali sulla dimensione del mercato in background
mentre continuiamo a parlare -- ci metto un attimo e non fermiamo
la conversazione. Vuoi?"

User: "Sì, cerca pure"

Explorer sets RESEARCH_ENABLED = true, spawns researcher via Task:
- Research question: "What is the current market size for project management software?"
- Queries to formulate: market size + growth forecast + key players

Explorer continues immediately:
"Perfetto, intanto verifico. Tornando a noi -- quando dici project
management, a quale tipo di team stai pensando? Startup o enterprise?"
```

### Example 2: Researcher Agent Execution

```markdown
## brain-researcher receives task prompt:

"Research the following claim: 'The project management market is very large.'
Formulate 2-3 search queries to find factual data about project management
software market size, growth, and key players. Write results to
.brainstorm/.research-pending/research-<timestamp>.md"

## Researcher execution:

1. Query 1: web_search_exa("project management software market size 2025 2026 revenue")
2. Query 2: web_search_exa("project management market growth forecast", category: "research paper")
3. Query 3: web_search_exa("project management software market leaders share")

4. Synthesize results → 3-5 bullets with sources
5. Write to .brainstorm/.research-pending/research-20260308-1430.md
6. Complete (subagent terminates)
```

### Example 3: Result Re-integration

```markdown
## Explorer checks before next response:

Glob: .brainstorm/.research-pending/*.md → found research-20260308-1430.md
Read the file. Status: found_data.

Explorer integrates (topic is still market):
"A proposito, i dati dicono che il mercato del project management
software vale circa $7.2 miliardi nel 2025, con una crescita del 12%
annuo. I big player sono Asana, Monday.com e Jira. Questo significa
che è un mercato grande ma anche affollato -- come pensi di
posizionarti rispetto a questi?"

## Explorer integrates (topic has moved on to tech):
"A proposito di prima, quando parlavamo del mercato del project
management -- i dati dicono che vale $7.2 miliardi. Mercato grande
ma affollato. Teniamolo a mente per dopo."
```

### Example 4: Researcher Result File

```markdown
# Research Results

**Query:** The project management market is very large
**Searched:** 2026-03-08 14:30
**Status:** found_data

## Findings

- **Il mercato globale del project management software ha raggiunto $7.2B nel 2025** — Source: Grand View Research (2025) https://www.grandviewresearch.com/industry-analysis/project-management-software-market
- **Crescita prevista del 12.1% CAGR fino al 2030** — Source: Fortune Business Insights (2025) https://www.fortunebusinessinsights.com/project-management-software-market
- **I leader di mercato sono Asana (12%), Monday.com (10%), Atlassian/Jira (15%)** — Source: G2 Market Report (2025) https://www.g2.com/categories/project-management
- **Il segmento SMB è il più in crescita (+18% YoY)** — Source: Statista (2025) https://www.statista.com/outlook/project-management

## Raw Queries Used

1. "project management software market size 2025 2026 revenue" → 8 results
2. "project management market growth forecast" (research paper) → 5 results
3. "project management software market leaders share" → 6 results

---
*Research by brain-researcher for /brain:explore on 2026-03-08*
```

### Example 5: Modified Explore.md Research Section

```markdown
## Research Integration (Phase 5)

### Research State (internal, invisible to user)

Track these variables throughout the conversation:
- RESEARCH_ENABLED: false (becomes true after user grants permission)
- RESEARCH_COUNT: 0 (increment on each spawn, max 3)
- RESEARCH_REFUSED: false (true if user declined, allows one retry)
- PENDING_RESULTS: [] (list of research topics in flight)
- INTEGRATED_RESULTS: [] (results shown to user, for dimension file)

### Detecting Research Triggers

During conversation, watch for FACTUAL claims that can be verified with data:
- Market size or growth claims
- Competitor existence or absence claims
- Technology capability or limitation claims
- User behavior or preference claims based on assumption
- Pricing benchmarks or willingness-to-pay claims

Do NOT trigger research for:
- Opinions, preferences, or vision statements
- Design or UX ideas
- Personal experiences or anecdotes
- Speculative "what if" scenarios

### Spawning the Researcher

When a research trigger is detected:

1. If RESEARCH_COUNT >= 3: do NOT spawn (limit reached)
2. If RESEARCH_ENABLED is false AND RESEARCH_REFUSED is false:
   - Ask permission: "Posso cercare dati su [topic] in background?"
   - Wait for user response
   - If approved: set RESEARCH_ENABLED = true, proceed to step 3
   - If refused: set RESEARCH_REFUSED = true, do NOT spawn
3. If RESEARCH_ENABLED is true:
   - Formulate the research question from conversational context
   - Include user refinements if provided ("solo mercato italiano")
   - Spawn brain-researcher via Task tool (background)
   - Give brief notice: "Intanto verifico quel dato..."
   - Increment RESEARCH_COUNT
   - Add topic to PENDING_RESULTS
   - Continue with the next question IMMEDIATELY

### Checking for Results

Before EVERY explorer response:
1. If PENDING_RESULTS is empty: skip check
2. Use Glob: .brainstorm/.research-pending/*.md
3. If no files: continue normally
4. If file(s) found:
   - Read the file
   - If status is "found_data": integrate naturally (see re-integration rules)
   - If status is "no_relevant_data": mention honestly
   - If status is "error": note Exa unavailable, move on
   - Delete the temp file
   - Move from PENDING_RESULTS to INTEGRATED_RESULTS
```

### Example 6: Brain-Researcher Agent Spec Structure

```markdown
---
name: brain-researcher
description: Fetches factual data via Exa MCP to support dimension exploration
tools: Read, Write, Bash, mcp__exa__web_search_exa, mcp__exa__get_code_context_exa
---

# Brain Researcher

Non-conversational background agent. Spawned by the explorer during
dimension exploration to fetch factual data that supports or challenges
claims made during the conversation.

## Role

You are a research assistant. You receive a research question, formulate
search queries, execute them, and produce structured results. You do NOT
interact with the user. You write results to a file and terminate.

## Execution Flow

1. Parse the research question from your task prompt
2. Determine claim type (market, competitor, tech, user, pricing)
3. Formulate 2-3 search queries from different angles
4. Execute queries via Exa MCP tools
5. Synthesize top findings into 3-5 bullet points
6. Write results to .brainstorm/.research-pending/research-<timestamp>.md
7. Complete

## Query Formulation

[claim type → query strategy table]

## Output Format

[structured result file format]

## Error Handling

- Exa MCP unavailable: write status "error" with explanation
- No relevant results: write status "no_relevant_data"
- Partial results: write status "partial_data" with what was found
- Always write a result file, even on failure (explorer expects it)

## Constraints

- Maximum 3 queries per research request
- Maximum 10 results requested per query (numResults: 10)
- Prefer recent sources (2024-2026)
- Always include source URL for verifiability
- Keep bullet points concise (1-2 sentences each)
- Do NOT interpret or editorialize -- report data, let the explorer analyze
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| No factual data during exploration | Background researcher spawned on vague claims | Phase 5 | Explorer can ground conversations in real data without pausing |
| Task tool prohibited in explore.md | Task tool permitted for background research only | Phase 5 | Refined rule distinguishes conversation delegation (banned) from background workers (allowed) |
| Researcher agent as stub | Full researcher agent spec with Exa MCP | Phase 5 | brain-researcher is now a functional agent, not a placeholder |
| Dimension files without research data | Dimension files include "Dati e Ricerche" section | Phase 5 | Research findings are preserved as part of the dimension exploration artifact |

**Validated patterns carrying forward from Phases 2-4:**
- markdown-as-prompt for all command files
- Runtime reference loading via Bash `echo $HOME` then Read tool
- Recap-confirm-save closure flow (research data included in recap)
- Behavioral reinforcement at end of prompt file
- Invisible tracking (research state tracked internally, not revealed)
- Shortcut delegation via Read tool (shortcuts inherit explore.md changes automatically)
- File-based exchange for inter-component communication (SESSION.md pattern)

**New patterns introduced in Phase 5:**
- Background Task spawning from interactive command
- File-based result exchange between subagent and parent (`.research-pending/`)
- One-time permission gate with autonomous continuation
- Inline result re-integration with conversational bridging

## Open Questions

1. **Task tool subagent MCP inheritance**
   - What we know: Task-spawned subagents are separate Claude instances with their own context. They load agent specs from `~/.claude/agents/`. The agent spec declares which tools are available.
   - What's unclear: Whether a subagent spawned via Task inherits the parent session's MCP server configuration (Exa MCP). If MCP servers are configured globally or per-project, the subagent should have access. But this needs empirical validation.
   - Recommendation: Test during implementation. If subagent cannot access Exa MCP, the researcher must include fallback instructions for WebSearch tool instead. The agent spec already declares `mcp__exa__web_search_exa` -- if the tool is available in the environment, the subagent should be able to use it.
   - Confidence: MEDIUM -- architectural reasoning is sound but no empirical test performed.

2. **Task tool behavior during interactive conversation**
   - What we know: The Task tool can spawn background subagents. External sources confirm this works for non-blocking research tasks. The parent agent continues processing.
   - What's unclear: Whether spawning a Task from within a markdown-as-prompt interactive command (explore.md) works identically to spawning from a normal conversation. The explore.md command is loaded as system-level instructions -- the explorer IS the main Claude session, so Task tool should be available.
   - Recommendation: Test during implementation with a minimal example: during an exploration conversation, spawn a Task that writes a file, verify the file appears, and verify the conversation was not interrupted.
   - Confidence: MEDIUM -- the mechanism is well-documented for general Claude Code usage, but the markdown-as-prompt context is untested.

3. **Timing of result file availability**
   - What we know: The researcher subagent writes to `.brainstorm/.research-pending/`. The explorer checks via Glob before each response.
   - What's unclear: How long the researcher takes (depends on Exa MCP response time and number of queries). If it takes 30+ seconds, the explorer may have processed 3-4 exchanges before results are ready.
   - Recommendation: This is actually fine -- the CONTEXT.md design expects delayed results. The explorer continues naturally, and results are integrated when they appear. If they arrive 5 exchanges later, the bridge phrase handles it: "A proposito di prima..."
   - Confidence: HIGH -- the design explicitly accounts for async timing.

4. **Researcher temp file cleanup**
   - What we know: Explorer reads and deletes temp files from `.research-pending/`. But if the explorer session ends abnormally (user disconnects, context window exhausted), temp files may linger.
   - What's unclear: Whether lingering temp files cause problems in subsequent sessions.
   - Recommendation: On next `/brain:explore` setup, check for and clean any old files in `.research-pending/`. Alternatively, include timestamp in filename and ignore files older than 1 hour. Pragmatic: lingering files are harmless -- they'll be read and integrated on next exploration if found, or ignored if stale.
   - Confidence: HIGH -- pragmatic solution, low impact edge case.

5. **Exa MCP rate limits and API key**
   - What we know: Exa MCP requires an API key (configured in user's MCP settings). Rate limits exist but are not documented in the MCP tool description.
   - What's unclear: Whether 2-3 research requests (each with 2-3 queries = 4-9 total Exa API calls per session) will hit rate limits. Also whether the API key cost is acceptable.
   - Recommendation: 4-9 Exa API calls per session is very low volume. Unlikely to hit rate limits. The researcher should handle HTTP errors gracefully and report "error" status. Cost is the user's concern -- they've already configured Exa MCP and presumably have an API key.
   - Confidence: HIGH -- low volume, well within reasonable API usage.

## Sources

### Primary (HIGH confidence)

- `commands/brain/explore.md` -- directly inspected (351 lines, Phase 4 output). Contains the full exploration flow, conversation patterns, artifact generation, and anti-pattern rules that Phase 5 must modify. The Task tool anti-pattern rule at line 351 is the critical constraint to refine.
- `agents/brain-explorer.md` -- directly inspected (206 lines, Phase 2 output). Behavioral spec that Phase 5 must extend with research detection, permission flow, and re-integration patterns.
- `agents/brain-researcher.md` -- directly inspected (11 lines, Phase 1 stub). Placeholder to be replaced with full agent spec.
- `05-CONTEXT.md` -- Phase 5 user decisions, directly sourced. All locked decisions constrain implementation.
- `.planning/REQUIREMENTS.md` -- directly inspected. RES-01, RES-02, RES-03, RES-04, AGT-02 requirement definitions.
- `install.sh` -- directly inspected. Agent files are symlinked individually from `agents/brain-*.md`. brain-researcher.md is already symlinked. No install changes needed.
- Exa MCP tools -- directly loaded and inspected via ToolSearch. `web_search_exa` accepts query, numResults, category, contextMaxCharacters. `get_code_context_exa` accepts query, tokensNum.
- Exa Search Best Practices (exa.ai/docs/reference/search-best-practices) -- query formulation, token efficiency, category filters, content freshness.

### Secondary (MEDIUM confidence)

- Claude Code Task tool documentation -- `TaskCreate` tool description directly inspected via ToolSearch. Confirms Task tool supports background execution and structured task definition.
- Claude Code async workflows (claudefa.st) -- describes background subagent spawning pattern: spawn, background with Ctrl+B, results surface when done. Confirms the pattern works.
- Claude Code Agent Teams guide (claudefa.st, blog.laozhang.ai) -- confirms Agent Teams vs subagents distinction. Agent Teams require experimental flag; subagents via Task tool are standard. Brain Suite should use Task tool (subagents), NOT Agent Teams.
- GitHub issues #16789, #17591 (anthropics/claude-code) -- TaskOutput returns raw JSONL in some versions. Validates decision to use file-based exchange instead of TaskOutput.

### Tertiary (LOW confidence)

- Task tool behavior within markdown-as-prompt commands -- not empirically validated. Architectural reasoning suggests it should work (the command is processed by the main Claude session which has Task tool access), but no test case found.
- MCP inheritance by Task-spawned subagents -- not empirically validated. Agent spec declares tools, but runtime availability depends on environment configuration.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- Exa MCP and Task tool are well-documented Claude Code built-ins
- Architecture patterns (researcher agent spec): HIGH -- straightforward non-conversational agent with clear input/output contract
- Architecture patterns (background spawning from explore.md): MEDIUM -- mechanism is well-documented for general use but untested in markdown-as-prompt context
- Architecture patterns (result re-integration): MEDIUM -- behavioral prompt engineering challenge; timing and flow disruption are the main risks
- Pitfalls: HIGH -- based on direct analysis of CONTEXT.md constraints and Phase 2-4 experience with prompt engineering
- Exa MCP query formulation: MEDIUM -- best practices documented, but effectiveness of queries for specific market/competitor data depends on Exa's index coverage

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (faster-moving domain -- Task tool and Exa MCP may evolve)
