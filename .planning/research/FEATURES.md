# Feature Landscape

**Domain:** AI-assisted structured brainstorming / product ideation framework for CLI
**Researched:** 2026-03-04
**Overall confidence:** MEDIUM (based on training data; web search unavailable for verification)

## Context

Brain Suite is a **Claude Code-native brainstorming framework** that operates as markdown prompts (commands, agents, workflows, templates, references) symlinked into `~/.claude/`. It is NOT a standalone application -- it is a prompt engineering system that gives Claude Code structured ideation capabilities. This unique positioning means the competitive landscape includes both traditional brainstorming tools (Miro, FigJam, Whimsical) and AI-native ideation tools (ChatGPT canvas, Claude artifacts, various AI copilots), but Brain Suite's actual competitors are **developer workflow tools that augment CLI-based AI assistants**.

The feature analysis below considers what users expect from structured ideation, adapted to the CLI/voice-first/developer context.

---

## Table Stakes

Features users expect. Missing = product feels incomplete or users abandon.

| # | Feature | Why Expected | Complexity | Notes |
|---|---------|--------------|------------|-------|
| T1 | **Interactive questioning / Socratic exploration** | Core mechanic of brainstorming. Users expect guided questioning, not just "tell me your idea and I'll generate a doc." Every ideation tool (Miro AI, FigJam AI, ChatGPT) offers conversational exploration. | Medium | Requires well-crafted agent prompt (brain-explorer). Quality depends entirely on prompt engineering for question sequencing, depth calibration, and knowing when to push vs. accept. |
| T2 | **Session persistence across conversations** | Claude Code sessions are ephemeral by default. Users cannot brainstorm a product idea in one sitting. Without persistence, every session starts from zero -- unusable for real ideation. | Medium | `.brainstorm/` directory with structured artifacts. SESSION.md tracks state, dimension files store findings. The resume workflow must reload all context reliably. |
| T3 | **Multi-dimensional analysis** | Product ideas have multiple facets (product, tech, market, business, users, competitors). Every serious ideation framework (Lean Canvas, Business Model Canvas, Design Thinking) structures thinking across dimensions. A tool that only covers "product features" is incomplete. | Medium | 6 built-in dimensions + custom. Templates per dimension ensure consistent output structure. The challenge is making dimensions feel distinct rather than repetitive. |
| T4 | **Structured output artifacts** | Users expect tangible deliverables, not just conversation. Every brainstorming session should produce documents that can be referenced later. Raw conversation logs are not artifacts. | Low | Markdown templates per dimension. Brain Suite already plans this well with `dimensions/*.md` files. |
| T5 | **Session status / progress tracking** | Users need to know where they are: which dimensions explored, which remain, overall completion. Without this, multi-session brainstorming feels disorienting. | Low | `/brain:status` reading SESSION.md. Straightforward implementation. |
| T6 | **Resume capability** | Users must be able to close terminal, come back tomorrow, and continue where they left off with full context. This is the #1 pain point of using vanilla ChatGPT/Claude for ideation -- context window resets. | High | This is the hardest table-stakes feature. Requires: loading IDEA.md + SESSION.md + all explored dimension files into context. The challenge is fitting everything in context window without truncation, and making the resumed session feel natural rather than mechanical. |
| T7 | **Handoff to implementation** | Brainstorming without implementation path = wasted effort. Users expect the tool to produce something actionable. In Brain Suite's case, this means a document consumable by GSD's `/gsd:new-project`. | Medium | HANDOFF.md with structured sections mapping to GSD's expected inputs. The quality depends on synthesis quality, not handoff format. |
| T8 | **Non-linear exploration** | Users must be able to explore dimensions in any order, skip dimensions, re-explore already-explored dimensions. Forcing a linear path kills creative exploration. | Low | Already planned. The explore command takes dimension as argument. Re-explore needs a decision: append/deepen vs. restart. |
| T9 | **Voice-first interaction patterns** | Given Brain Suite's design philosophy (voice-to-text input via tools like Wispr Flow), responses must be short, scannable, one-question-at-a-time. This isn't a "nice to have" -- it's a core interaction constraint. | Low | Reference file `voice-interaction.md` consumed by all workflows/agents. Low implementation complexity but high design importance -- bad voice-first patterns make the tool frustrating. |

---

## Differentiators

Features that set Brain Suite apart from alternatives. Not expected, but significantly increase value.

| # | Feature | Value Proposition | Complexity | Notes |
|---|---------|-------------------|------------|-------|
| D1 | **Cross-dimensional synthesis** | Most brainstorming tools let you explore topics independently. Few automatically identify tensions, synergies, and contradictions ACROSS dimensions. "Your tech stack choice conflicts with your business model assumption" is extremely valuable insight. | High | Requires brain-synthesizer agent to read all explored dimensions and find patterns. This is the feature that makes Brain Suite more than "ChatGPT with persistence." Needs 2+ dimensions explored. Quality is heavily prompt-dependent. |
| D2 | **Assumption challenging / adversarial exploration** | Most AI assistants are agreeable by default. An explorer that actively challenges assumptions ("You said X, but what if Y?") forces deeper thinking. This is what makes human brainstorming partners valuable. | Medium | Prompt engineering in brain-explorer. The challenge is calibrating aggression -- too soft = useless, too aggressive = annoying. The "sfidante" mode needs to feel constructive, not combative. |
| D3 | **Spawnable research agent** | During exploration, the explorer identifies when real data would help (market size, competitor analysis, tech feasibility). Instead of breaking flow, it suggests spawning a researcher to fetch data in background. | High | Requires brain-researcher agent with web search capabilities (Exa MCP). The handoff between explorer and researcher is the tricky part -- researcher must understand context without re-asking. |
| D4 | **GSD pipeline integration** | No other brainstorming tool produces output directly consumable by an implementation pipeline. The brain-to-GSD bridge is a unique differentiator for developers who use both tools. | Medium | HANDOFF.md format must match GSD's expectations precisely. This creates a coupling -- changes in GSD's expected format require HANDOFF template updates. |
| D5 | **Dimension re-exploration with depth choices** | When revisiting an explored dimension, offering the choice between "deepen what we found" vs. "start fresh with new angle" respects the iterative nature of ideation. Most tools just overwrite. | Low | UX design choice in explore-dimension workflow. Append existing content or start new version while preserving old. |
| D6 | **Custom dimensions** | Built-in dimensions cover most cases, but some ideas need domain-specific analysis (regulatory, ethical, accessibility, sustainability). Adding custom dimensions makes the framework extensible. | Low | `/brain:add-dimension` creates template + registers in SESSION.md. Pattern already exists for built-in dimensions. |
| D7 | **Session log cleaning** | Raw conversation transcripts include filler, corrections, tangents. Cleaned session logs preserve substance while removing noise, making them useful for later reference and for context loading on resume. | Medium | This is harder than it sounds. "Noise" vs. "substance" is subjective. Over-cleaning loses nuance; under-cleaning wastes context window. May need heuristics or a dedicated cleaning pass. |
| D8 | **Explorer depth gating (hybrid)** | Explorer suggests when key points are covered but lets user decide to continue or move on. This prevents both premature termination and endless loops. | Medium | Requires the explorer to track what has been covered in a dimension and judge completeness. Prompt engineering challenge -- the explorer needs a mental model of "what constitutes adequate coverage" per dimension. |
| D9 | **Proactive next-step suggestions** | After completing an exploration, suggesting which dimension to explore next (based on what was discussed, dependencies, gaps). Reduces cognitive load. | Low | Workflow logic: after dimension completion, analyze what was found and suggest related unexplored dimensions. "You mentioned competitor X -- want to explore the competitive landscape next?" |
| D10 | **Multiple exploration modes** | Offering different styles of exploration (Socratic, creative/divergent, analytical/convergent, devil's advocate) for the same dimension. Different modes surface different insights. | Medium | Multiple personality modes for brain-explorer. Could be implemented as mode parameter or as separate reference files for questioning styles. Adds variety but increases prompt complexity. |

---

## Anti-Features

Features to explicitly NOT build. These seem obvious but would hurt Brain Suite.

| # | Anti-Feature | Why Avoid | What to Do Instead |
|---|--------------|-----------|-------------------|
| A1 | **Auto-generated documents without interaction** | Defeats the entire purpose. "Generate a business plan for X" is what ChatGPT already does. Brain Suite's value is the interactive exploration process, not the output generation. | Always explore interactively, produce artifacts as byproduct of conversation. |
| A2 | **Real-time collaboration / multiplayer** | Brain Suite runs in a single developer's Claude Code session. Multi-user adds massive complexity (conflict resolution, shared context, permissions) for near-zero v1 value. | Single-user. Share artifacts via git. Collaboration happens asynchronously via shared repo. |
| A3 | **Visual canvas / mind map / GUI** | Brain Suite is CLI-native. Adding a GUI layer (Electron app, web UI) would split the codebase and distract from core value. Miro/FigJam already do visual brainstorming well. | Produce clean markdown that can be visualized by external tools if needed. |
| A4 | **Automatic dimension ordering / forced workflow** | Suggesting "you should do product before tech" is fine. Enforcing it kills creative flow. Users know their ideas better than the tool. | Suggest but never enforce. Non-linear exploration is a table-stakes feature. |
| A5 | **Scoring / ranking / quantitative evaluation** | "Your idea scores 7.2/10" is misleading precision. Brainstorming is qualitative. Scores create false confidence and discourage exploration of ideas that score low but have hidden potential. | Identify strengths, weaknesses, tensions, gaps -- qualitatively. Let the user judge. |
| A6 | **Template marketplace / plugin system** | Over-engineering for v1. The framework should ship with good defaults. A plugin system adds maintenance burden and abstraction layers before the core patterns are proven. | Ship opinionated defaults. Accept contributions via PR to the repo. |
| A7 | **Chat history export / conversation replay** | Session logs serve as cleaned transcripts. Full chat replay (with all the "um, wait, go back" moments) adds no value. The dimension artifacts ARE the useful output. | Clean session logs + structured dimension artifacts. |
| A8 | **Integration with external project management tools** | Jira/Linear/Notion integrations add coupling and maintenance burden. Brain Suite's output is markdown -- it's universally portable. | HANDOFF.md is the integration point. Users can manually copy to any tool. GSD integration is the one exception (same ecosystem). |
| A9 | **AI-generated images / diagrams / wireframes** | Scope creep. Brain Suite is about structured thinking, not asset generation. Image generation belongs in design tools. | If users need diagrams, they can describe them in dimension artifacts and generate separately. |

---

## Feature Dependencies

```
T1 (Interactive questioning) ← Foundation for everything
  └── T3 (Multi-dimensional analysis) ← Requires exploration mechanic
       └── D1 (Cross-dimensional synthesis) ← Requires 2+ dimensions explored
            └── T7 (Handoff) ← Requires synthesis quality
                 └── D4 (GSD integration) ← Requires handoff format

T2 (Session persistence) ← Foundation for multi-session
  └── T6 (Resume capability) ← Requires persistence + context loading
       └── T5 (Status tracking) ← Requires session state
  └── D7 (Session log cleaning) ← Requires raw logs to clean

T1 (Interactive questioning)
  └── D2 (Assumption challenging) ← Mode of exploration
  └── D10 (Multiple exploration modes) ← Variants of exploration
  └── D8 (Explorer depth gating) ← Requires tracking coverage
       └── D3 (Spawnable researcher) ← Triggered by explorer identifying data needs
            └── D9 (Next-step suggestions) ← Benefits from researcher findings

T8 (Non-linear exploration)
  └── D5 (Re-exploration with depth choices) ← Extension of non-linear
  └── D6 (Custom dimensions) ← Extension of dimension system

T9 (Voice-first patterns) ← Cross-cutting concern, affects ALL features
```

### Critical Path

```
T1 → T3 → T4 → T2 → T6 → D1 → T7 → D4
```

This maps to: Can explore interactively → across dimensions → producing artifacts → that persist → and resume → then synthesize → then hand off → to GSD.

---

## Competitive Landscape Context

### What exists (from training data, MEDIUM confidence)

**Traditional brainstorming tools (Miro, FigJam, Whimsical):**
- Visual canvas, sticky notes, templates
- Real-time collaboration
- AI features (generate ideas, summarize, categorize) added as layer
- Strength: visual thinking, team collaboration
- Weakness: no structured multi-dimensional analysis, no persistence of reasoning

**AI chat assistants (ChatGPT, Claude, Gemini):**
- Conversational exploration
- Can use frameworks if prompted
- Strength: flexible, natural language
- Weakness: no session persistence, no structured output, no dimension tracking, context window resets

**Lean Canvas / Business Model Canvas tools (Leanstack, Strategyzer):**
- Structured multi-dimensional frameworks
- Template-driven
- Strength: proven frameworks, clear structure
- Weakness: not interactive/exploratory, fill-in-the-blank rather than guided discovery

**Developer ideation tools in CLI:**
- Nearly non-existent as a category. Developers use text editors, markdown files, and ad-hoc ChatGPT sessions.
- Brain Suite fills an unoccupied niche: structured brainstorming native to the developer's primary AI-assisted workflow (Claude Code).

### Where Brain Suite fits

Brain Suite combines:
- Interactive exploration depth of AI chat (from ChatGPT/Claude)
- Structured multi-dimensional frameworks of canvas tools (from Lean Canvas)
- Session persistence and artifact tracking (from project management tools)
- CLI-native, developer-workflow integration (unique)
- Handoff to implementation pipeline (unique via GSD bridge)

No existing tool combines all five. The closest would be "a developer who manually uses Claude/ChatGPT with custom prompts and saves outputs to files" -- which is exactly what Brain Suite automates and structures.

---

## MVP Recommendation

### Must ship (Phase 1-2):
1. **T1: Interactive questioning** -- the core mechanic, via brain-explorer agent
2. **T3: Multi-dimensional analysis** -- 6 built-in dimensions with templates
3. **T4: Structured output artifacts** -- dimension markdown files
4. **T9: Voice-first patterns** -- reference file consumed by agents
5. **T2: Session persistence** -- `.brainstorm/` directory structure
6. **T5: Status tracking** -- `/brain:status`
7. **T8: Non-linear exploration** -- dimension selection by user

### Must ship (Phase 3-4):
8. **T6: Resume capability** -- context reload from artifacts
9. **D1: Cross-dimensional synthesis** -- brain-synthesizer agent
10. **T7: Handoff** -- HANDOFF.md generation
11. **D2: Assumption challenging** -- explorer mode

### Should ship (Phase 5):
12. **D8: Explorer depth gating** -- hybrid suggestion + user control
13. **D5: Re-exploration with depth choices** -- deepen vs. restart
14. **D9: Proactive next-step suggestions**
15. **D6: Custom dimensions**

### Defer:
- **D3: Spawnable researcher** -- depends on Exa MCP availability and adds significant complexity. Ship after core loop is proven.
- **D4: GSD integration** -- already marked out of scope for v1 (flag `--from-brainstorm` is a separate GSD modification). HANDOFF.md format is the v1 bridge.
- **D7: Session log cleaning** -- nice to have but raw logs with structured artifacts work for v1.
- **D10: Multiple exploration modes** -- single well-tuned explorer mode first. Add variants after validating the core pattern.

---

## Complexity Assessment

| Feature | Prompt Engineering | Workflow Logic | File I/O | Agent Coordination | Overall |
|---------|-------------------|----------------|----------|-------------------|---------|
| T1 Interactive questioning | HIGH | Low | Low | Low | **Medium** |
| T2 Session persistence | Low | Medium | HIGH | Low | **Medium** |
| T3 Multi-dimensional | Medium | Medium | Medium | Low | **Medium** |
| T4 Structured artifacts | Low | Low | Medium | Low | **Low** |
| T5 Status tracking | Low | Low | Medium | Low | **Low** |
| T6 Resume | Medium | HIGH | HIGH | Low | **High** |
| T7 Handoff | Medium | Medium | Medium | Low | **Medium** |
| T8 Non-linear | Low | Low | Low | Low | **Low** |
| T9 Voice-first | HIGH | Low | Low | Low | **Low** (design, not code) |
| D1 Synthesis | HIGH | Medium | HIGH | Medium | **High** |
| D2 Assumption challenging | HIGH | Low | Low | Low | **Medium** |
| D3 Spawnable researcher | Medium | HIGH | Medium | HIGH | **High** |
| D4 GSD integration | Low | Medium | Medium | Low | **Medium** |
| D5 Re-exploration | Low | Medium | Medium | Low | **Low** |
| D6 Custom dimensions | Low | Medium | Medium | Low | **Low** |
| D7 Session log cleaning | HIGH | Medium | Medium | Low | **Medium** |
| D8 Depth gating | HIGH | Medium | Low | Low | **Medium** |
| D9 Next-step suggestions | Medium | Low | Low | Low | **Low** |
| D10 Multiple modes | HIGH | Low | Low | Low | **Medium** |

---

## Sources

- Brain Suite PROJECT.md and BRAIN_SUITE_PLAN.md (primary source for project requirements and architecture)
- Training data knowledge of brainstorming/ideation tools (Miro, FigJam, Whimsical, Lean Canvas, Business Model Canvas) -- MEDIUM confidence
- Training data knowledge of AI-assisted workflows (ChatGPT, Claude, developer tooling patterns) -- MEDIUM confidence
- Training data knowledge of Claude Code agent/command/workflow patterns -- HIGH confidence (author has direct project context)

**Note:** Web search was unavailable during this research session. Competitive landscape analysis is based on training data (cutoff ~May 2025). Recent entrants in the AI-assisted ideation space may not be captured. This is flagged as a gap for future validation.
