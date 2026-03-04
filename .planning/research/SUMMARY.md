# Project Research Summary

**Project:** Brain Suite
**Domain:** Claude Code extension framework -- structured brainstorming and product ideation
**Researched:** 2026-03-04
**Confidence:** HIGH

## Executive Summary

Brain Suite is a **prompt-engineering project**, not a software-engineering project. The entire v1 deliverable is structured markdown files (commands, agents, workflows, templates, reference files) distributed via POSIX symlinks into `~/.claude/`. There is no compiled code, no runtime dependencies, no framework. Claude Code IS the runtime. This is the same architecture pattern used by the GSD framework, which serves as a proven reference implementation. The "stack" question resolves to: what are the exact file formats, naming conventions, directory structures, and interaction patterns that Claude Code supports? All four research streams confirm high confidence in these patterns.

The recommended approach is to build bottom-up by dependency layer (references, then templates, then agents, then workflows, then commands, then install scripts) but to execute in vertical slices so each phase delivers an end-to-end testable flow. Phase 1 should deliver `/brain:new` working end-to-end, Phase 2 should deliver dimension exploration via `/brain:explore`, and so on. The architecture cleanly separates WHAT to do (workflows), HOW to behave (agents), WHAT to produce (templates), and shared knowledge (references). This separation must be enforced from day one because the markdown-only nature of the project offers no runtime guardrails.

The primary risks are: (1) prompt bloat causing context window starvation, especially during session resume after 4-5 explored dimensions; (2) workflow-agent coupling where behavioral rules leak into orchestration files and vice versa; and (3) voice-first interaction patterns that look good in text but fail in actual voice-to-text usage. All three are preventable through disciplined prompt budgets, strict separation of concerns, and real voice-input testing before shipping.

## Key Findings

### Recommended Stack

Brain Suite uses Claude Code's native extensibility system exclusively. There is no traditional technology stack -- the "technologies" are Claude Code's five extension points: custom slash commands, agent definitions, workflows (commands with orchestration logic), templates (markdown read at runtime), and reference files (shared knowledge). Distribution is via POSIX symlinks from `~/.claude/` to the git-tracked repo. Installation is `git clone` + `./install.sh`.

**Core technologies:**
- **Claude Code (latest):** Runtime platform -- Brain Suite is a Claude Code extension, there is no alternative
- **Markdown (.md):** All config files -- commands, agents, workflows, templates, references are all markdown
- **POSIX symlinks:** Distribution -- edits reflected immediately, single source of truth in git repo
- **Bash (install.sh):** Install/uninstall scripts -- creates/removes symlinks, no dependencies
- **Git:** Version control and distribution -- `git clone` + `./install.sh` is the entire install flow

**Critical convention:** Commands live in `commands/brain/` (namespace `/brain:*`). Agents use `brain-` prefix in shared `~/.claude/agents/` directory. Framework files (workflows, templates, references) live in `~/.claude/brainstorm/`.

### Expected Features

**Must have (table stakes):**
- **T1: Interactive Socratic questioning** -- core mechanic, the reason Brain Suite exists
- **T2: Session persistence** -- `.brainstorm/` directory with structured artifacts on disk
- **T3: Multi-dimensional analysis** -- 6 built-in dimensions (product, tech, market, business, competitors, users)
- **T4: Structured output artifacts** -- markdown dimension files, not raw conversation logs
- **T5: Session status tracking** -- `/brain:status` shows progress across dimensions
- **T6: Resume capability** -- reload context from disk, continue where left off (hardest table-stakes feature)
- **T7: Handoff to implementation** -- HANDOFF.md consumable by GSD
- **T8: Non-linear exploration** -- explore dimensions in any order, skip, revisit
- **T9: Voice-first interaction patterns** -- short responses, one question at a time, summary-before-question

**Should have (differentiators):**
- **D1: Cross-dimensional synthesis** -- tensions, synergies, contradictions across dimensions (the killer feature)
- **D2: Assumption challenging** -- adversarial exploration mode that pushes back on user assumptions
- **D5: Re-exploration with depth choices** -- "deepen" vs "start fresh" when revisiting
- **D6: Custom dimensions** -- user-defined analysis dimensions beyond the 6 defaults
- **D8: Explorer depth gating** -- suggests when key points are covered, user decides to continue or stop
- **D9: Proactive next-step suggestions** -- recommend which dimension to explore next

**Defer (v2+):**
- **D3: Spawnable research agent** -- depends on Exa MCP availability, adds significant complexity
- **D4: GSD integration flag** -- `--from-brainstorm` is a GSD modification, out of scope for v1
- **D7: Session log cleaning** -- raw logs with structured artifacts work for v1
- **D10: Multiple exploration modes** -- single well-tuned explorer first, add variants after validation

**Critical path:** T1 -> T3 -> T4 -> T2 -> T6 -> D1 -> T7 -> D4

### Architecture Approach

Brain Suite follows a **Prompt-as-Software** architecture with five component types organized in a strict dependency DAG: References (layer 0, no dependencies) -> Templates (layer 1) -> Agents (layer 2) -> Workflows (layer 3) -> Commands (layer 4) -> Install scripts (layer 5). Each component has a single responsibility enforced by convention. Communication between components is via file reads (prompts reference other files by path) and filesystem state (`.brainstorm/` artifacts).

**Major components:**
1. **Commands** (`commands/brain/`) -- Thin entry points; validate preconditions and delegate to workflows
2. **Workflows** (`brainstorm/workflows/`) -- Orchestration logic; define WHAT to do step-by-step with conditionals
3. **Agents** (`agents/brain-*.md`) -- Execution personas; define HOW to behave (tone, strategy, constraints)
4. **Templates** (`brainstorm/templates/`) -- Output contracts; define the SHAPE of generated artifacts
5. **References** (`brainstorm/references/`) -- Shared knowledge; single source of truth for cross-cutting rules
6. **Artifacts** (`.brainstorm/`) -- Per-project generated data; SESSION.md is the state machine

**Key patterns:** Command-as-thin-entry-point, workflow-as-orchestration-script, agent-as-execution-persona, reference-as-single-source-of-truth, template-as-output-contract, state-via-filesystem, symlink-distribution.

### Critical Pitfalls

1. **Prompt bloat / context window starvation** -- Agent prompts grow unbounded as rules are added to fix edge cases. Combined with resume loading all dimension files, context window exhausts. **Avoid by:** 800-1200 line budget per agent, use reference files for shared rules, dimension files have TL;DR headers (max 10 lines), resume loads summaries first.

2. **Workflow-agent coupling** -- Behavioral rules leak into workflows, sequencing leaks into agents. The markdown-only nature offers no runtime enforcement. **Avoid by:** Hard separation from day one. Workflows define SEQUENCE. Agents define PERSONALITY. References define RULES. Test: can you change questioning style by editing only `questioning.md`?

3. **Voice-first patterns that only work in text** -- Developers test by typing. Agent outputs 3-paragraph responses when users need a single sentence plus one question. **Avoid by:** Prescriptive voice-interaction.md (max 3 sentences before a question, exactly ONE question per response), test with actual voice-to-text input.

4. **Symlink collision in shared `~/.claude/`** -- No namespace registry for Claude Code extensions. Brain Suite must coexist with GSD. **Avoid by:** Manifest-based install script, strict `brain-` prefix for agents, `brain/` directory for commands, never overwrite existing non-symlink files.

5. **Template rigidity turning exploration into form-filling** -- Overly structured dimension templates with 15+ required sections make the explorer ask forced questions. **Avoid by:** Templates with 3-5 required sections plus optional sections marked `<!-- if discussed -->`. Exploration is conversation-driven, not template-driven.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundations and New Session

**Rationale:** Everything depends on the reference files, base templates, and the install script. The `/brain:new` command is the entry point for all workflows. Without a working new-session flow, nothing else can be tested.
**Delivers:** Working `/brain:new` command that creates `.brainstorm/` with IDEA.md and SESSION.md through interactive Socratic questioning
**Addresses:** T1 (interactive questioning), T4 (structured artifacts), T9 (voice-first patterns), T2 (session persistence, initial structure)
**Avoids:** Pitfall 3 (symlink collision -- manifest-based install), Pitfall 11 (install idempotency), Pitfall 16 (circular reference deps), Pitfall 4 (workflow-agent coupling -- establish separation contract)
**Files:** 3 references, 2 base templates (idea.md, session.md), new-session workflow, new.md command, install.sh, uninstall.sh

### Phase 2: Core Agents

**Rationale:** Agents define the behavioral personas that all subsequent phases use. The brain-explorer is the workhorse of the entire suite; its quality determines the quality of all dimension explorations. Getting agent design right before building exploration workflows prevents costly rework.
**Delivers:** brain-explorer.md, brain-researcher.md, brain-synthesizer.md with proper prompt budgets and reference file integration
**Addresses:** T1 (interactive questioning quality), T9 (voice-first enforcement), D2 (assumption challenging mode)
**Avoids:** Pitfall 1 (prompt bloat -- establish 1000-line budget), Pitfall 5 (voice-first in text -- prescriptive rules), Pitfall 10 (researcher spawn criteria -- explicit gating)

### Phase 3: Dimension Exploration

**Rationale:** With agents and references in place, dimension exploration is the core value loop. This phase delivers the primary user experience: interactive exploration across 6 dimensions producing structured artifacts.
**Delivers:** 6 dimension templates, explore-dimension workflow, `/brain:explore` command, 6 dimension shortcut commands, `/brain:status`
**Addresses:** T3 (multi-dimensional analysis), T4 (structured artifacts), T5 (status tracking), T8 (non-linear exploration)
**Avoids:** Pitfall 6 (template rigidity -- required vs optional sections), Pitfall 7 (session log pollution -- define keep/drop categories), Pitfall 12 (thin wrapper drift -- 10-line max for shortcuts), Pitfall 2 (context starvation -- TL;DR headers in dimension templates)

### Phase 4: Synthesis and Handoff

**Rationale:** Synthesis requires 2+ explored dimensions. Handoff requires synthesis quality. This phase delivers the differentiated value (cross-dimensional insight) and the bridge to implementation.
**Delivers:** SYNTHESIS.md generation, HANDOFF.md generation, `/brain:synthesize`, `/brain:handoff`
**Addresses:** D1 (cross-dimensional synthesis), T7 (handoff to implementation)
**Avoids:** Pitfall 8 (handoff mismatch -- validate against GSD input expectations), Pitfall 13 (shallow synthesis -- force tensions/tradeoffs section)

### Phase 5: Session Management and Utilities

**Rationale:** Resume, re-exploration, and custom dimensions are utility features that round out the experience. They depend on all previous phases being stable. Resume is the hardest feature (context reload) and benefits from having the dimension template patterns fully established.
**Delivers:** `/brain:resume`, `/brain:add-dimension`, re-exploration with deepen/restart choice, proactive next-step suggestions
**Addresses:** T6 (resume capability), D5 (re-exploration with depth), D6 (custom dimensions), D8 (depth gating), D9 (next-step suggestions)
**Avoids:** Pitfall 2 (context starvation on resume -- progressive loading, summary-first), Pitfall 9 (re-exploration confusion -- explicit user choice with archive), Pitfall 14 (custom dimension sprawl -- semantic overlap check)

### Phase Ordering Rationale

- **Bottom-up by dependency:** References (layer 0) must exist before templates (layer 1) before agents (layer 2) before workflows (layer 3) before commands (layer 4). But each phase builds a vertical slice, not a horizontal layer.
- **Feature dependency chain:** Interactive questioning (T1) enables multi-dimensional exploration (T3) enables synthesis (D1) enables handoff (T7). This dictates the phase order.
- **Risk front-loading:** Prompt bloat and workflow-agent coupling are the highest risks. Phases 1-2 establish the separation contract and prompt budgets before the bulk of content is written. Voice-first testing must happen in Phase 2, before Phase 3 adds 6 dimension explorations that would all need rework.
- **User value progression:** Phase 1 delivers "start brainstorming." Phase 3 delivers "explore your idea deeply." Phase 4 delivers "get insights across dimensions." Phase 5 delivers "come back tomorrow and continue." Each phase is independently valuable.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Agents):** Prompt engineering for the explorer agent is the highest-risk, highest-value work. The questioning calibration (depth, challenge level, coverage detection) has no established patterns -- it needs iterative testing. Recommend `/gsd:research-phase` focused on Socratic dialogue prompt patterns.
- **Phase 4 (Synthesis):** Cross-dimensional synthesis is the killer differentiator but also the most novel prompt engineering challenge. How to structure a synthesizer prompt that finds genuine tensions (not just summarizes) needs experimentation. Recommend `/gsd:research-phase`.
- **Phase 5 (Resume):** Progressive context loading strategy (summaries first, full content on-demand) needs validation against actual context window limits with realistic artifact sizes. Recommend `/gsd:research-phase`.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundations):** Install scripts, reference files, templates, and basic command structure are well-documented patterns from GSD. Standard implementation.
- **Phase 3 (Dimension Exploration):** Once the agent and workflow patterns are established in Phases 1-2, dimension exploration is repetition of those patterns across 6 dimensions. The templates vary by content but not by structure.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Claude Code extensibility is core Anthropic product; GSD validates all patterns in production |
| Features | MEDIUM | Feature landscape based on training data; competitive analysis not verified via web search |
| Architecture | HIGH | Direct analysis of Claude Code runtime model + GSD reference architecture |
| Pitfalls | HIGH | Derived from hands-on experience with exact architecture pattern (Claude Code extensions via markdown) |

**Overall confidence:** HIGH

The project's unusual nature (prompt engineering, not software engineering) means the stack and architecture are extremely well-understood -- there is essentially one way to build Claude Code extensions. The uncertainty concentrates in two areas: (1) feature competitive landscape (no web search available to verify recent AI ideation tools), and (2) prompt engineering quality for the explorer and synthesizer agents (unknowable until iterative testing).

### Gaps to Address

- **Voice-first validation:** All research assumes voice-first patterns will work as designed. Must be validated with actual voice-to-text input during Phase 2 agent development. No workaround -- needs real testing.
- **Context window budget:** Architecture research estimates ~2000 lines of prompt content per operation. This number is inferred, not measured. Must be validated empirically during Phase 3 when real dimension artifacts exist.
- **GSD handoff format:** HANDOFF.md structure must match what `/gsd:new-project` expects. Research identifies this as a coupling risk but does not specify the exact expected format. Must study GSD's `new-project` command during Phase 4 planning.
- **Competitive landscape freshness:** Feature research is based on May 2025 training data. Recent AI-assisted ideation tools may exist. Low risk for v1 but worth a web search before v2 planning.
- **$ARGUMENTS behavior:** Exact behavior with multi-word input and special characters in command arguments is not fully documented. Needs quick validation during Phase 1.
- **Hot reload behavior:** Whether Claude Code picks up symlinked file changes mid-session or requires restart is undocumented. Needs quick validation during Phase 1.

## Sources

### Primary (HIGH confidence)
- Claude Code official documentation (custom commands, agents, CLAUDE.md, `~/.claude/` conventions)
- GSD framework (Get Shit Done) -- production reference implementation of the exact same architecture pattern
- Brain Suite BRAIN_SUITE_PLAN.md -- detailed project architecture and requirements
- Direct Claude Code runtime model analysis (command resolution, agent spawning, tool dispatch)

### Secondary (MEDIUM confidence)
- Training data knowledge of brainstorming/ideation tools (Miro, FigJam, Lean Canvas, Business Model Canvas)
- Training data knowledge of AI-assisted workflows (ChatGPT, Claude, developer tooling patterns)
- Template and reference file patterns inferred from GSD conventions

### Tertiary (LOW confidence)
- Competitive landscape for AI-native developer ideation tools (category may have evolved since training cutoff)
- Context window budget estimates (inferred from prompt loading patterns, not empirically measured)

---
*Research completed: 2026-03-04*
*Ready for roadmap: yes*
