# Roadmap: Brain Suite

## Overview

Brain Suite delivers a structured brainstorming framework for Claude Code in 6 phases. Phase 1 establishes infrastructure (install scripts, repo structure, reference files). Phase 2 delivers the first vertical slice: `/brain:new` with interactive Socratic questioning. Phase 3 builds the core exploration loop across 6 dimensions. Phase 4 adds session management (resume, status, re-exploration, custom dimensions). Phase 5 integrates the research agent for factual data fetching. Phase 6 delivers cross-dimensional synthesis and GSD handoff. Each phase produces an end-to-end testable capability.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Infrastructure & Foundations** - Install scripts, repo structure, reference files, base templates
- [x] **Phase 2: New Session Flow** - `/brain:new` end-to-end with interactive Socratic questioning
- [ ] **Phase 3: Dimension Exploration** - `/brain:explore` across 6 dimensions with structured artifact output
- [ ] **Phase 4: Session Management** - Resume, status, re-exploration, custom dimensions
- [ ] **Phase 5: Research Integration** - brain-researcher agent with Exa MCP for factual data
- [ ] **Phase 6: Synthesis & Handoff** - Cross-dimensional synthesis and GSD-ready handoff document

## Phase Details

### Phase 1: Infrastructure & Foundations
**Goal**: Project can be installed from git clone with a single command, and all foundation files (references, base templates) are in place for subsequent phases
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04, INFRA-05
**Success Criteria** (what must be TRUE):
  1. User can run `git clone` + `./install.sh` and all symlinks are created in `~/.claude/` (commands, agents, framework files)
  2. User can run `./uninstall.sh` and all Brain Suite symlinks are removed without affecting GSD or other `~/.claude/` files
  3. Running `./install.sh` twice produces the same result (idempotent)
  4. Reference files exist: `voice-interaction.md`, `questioning.md`, `frameworks.md`, `dimensions-guide.md`
  5. README.md documents installation, usage, and command reference
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md -- Repo structure, reference files, dimension templates, agent stubs
- [x] 01-02-PLAN.md -- Install/uninstall scripts and README documentation

### Phase 2: New Session Flow
**Goal**: User can start a brainstorming session from scratch and produce structured artifacts through interactive dialogue
**Depends on**: Phase 1
**Requirements**: CORE-01, CORE-07, AGT-01, SESS-01
**Success Criteria** (what must be TRUE):
  1. User runs `/brain:new` and is guided through Socratic questioning to define their idea, producing `.brainstorm/IDEA.md` and `.brainstorm/SESSION.md`
  2. brain-explorer agent follows voice-first patterns: responses are short and scannable, exactly one question per response, summary before question
  3. SESSION.md tracks session state (explored dimensions list, dates, notes) and persists across Claude Code sessions
  4. Interaction tolerates informal spoken input without confusion or correction
**Plans**: 2 plans

Plans:
- [x] 02-01-PLAN.md -- Complete /brain:new command with interactive Socratic brainstorming
- [x] 02-02-PLAN.md -- Brain-explorer agent behavioral specification

### Phase 3: Dimension Exploration
**Goal**: User can interactively explore any of 6 dimensions, producing structured artifacts, with control over exploration depth, mode, and order
**Depends on**: Phase 2
**Requirements**: CORE-02, CORE-03, CORE-04, CORE-05, CORE-06, DIM-01, DIM-02, DIM-03, ART-01, ART-02
**Success Criteria** (what must be TRUE):
  1. User runs `/brain:explore product` (or any of 6 dimensions) and engages in guided Socratic dialogue that produces `.brainstorm/dimensions/<dimension>.md`
  2. User can use shortcut commands (`/brain:product`, `/brain:tech`, etc.) that behave identically to `/brain:explore <dimension>`
  3. Each dimension exploration also produces a cleaned session log in `.brainstorm/sessions/<dimension>-<date>.md` with conversational noise removed
  4. User can choose exploration mode per dimension (Socratic, devil's advocate, creative/divergent)
  5. Explorer challenges assumptions constructively and suggests when key points are covered, but user decides to continue or stop
**Plans**: 2 plans

Plans:
- [x] 03-01-PLAN.md -- Complete /brain:explore command with interactive dimension exploration
- [ ] 03-02-PLAN.md -- 6 shortcut commands delegating to explore behavior

### Phase 4: Session Management
**Goal**: User can resume previous sessions, track progress, revisit dimensions, add custom dimensions, and receive guidance on what to explore next
**Depends on**: Phase 3
**Requirements**: ART-03, SESS-02, SESS-03, DIM-04, DIM-05
**Success Criteria** (what must be TRUE):
  1. User runs `/brain:status` and sees which dimensions have been explored, which remain, exploration dates, and overall progress
  2. User runs `/brain:resume` and the full session context is loaded (IDEA.md + SESSION.md + all explored dimensions) enabling continuation where they left off
  3. When re-exploring an already-explored dimension, user is asked whether to deepen existing content or start fresh
  4. User can add a custom dimension via `/brain:add-dimension` with automatic template creation and SESSION.md registration
  5. Explorer proactively suggests which dimension to explore next based on gaps and what was already discussed
**Plans**: TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD

### Phase 5: Research Integration
**Goal**: User can get factual data (market data, competitor info, tech feasibility) injected into exploration when the explorer identifies a need
**Depends on**: Phase 3
**Requirements**: RES-01, RES-02, RES-03, RES-04, AGT-02
**Success Criteria** (what must be TRUE):
  1. During dimension exploration, explorer identifies when real data would strengthen the analysis and suggests spawning brain-researcher
  2. User explicitly confirms before the researcher is spawned (no automatic spawning)
  3. brain-researcher fetches factual data via Exa MCP and returns structured results
  4. Researcher results are integrated back into the ongoing dimension exploration context
**Plans**: TBD

Plans:
- [ ] 05-01: TBD

### Phase 6: Synthesis & Handoff
**Goal**: User can generate cross-dimensional insights and a structured document ready for implementation planning
**Depends on**: Phase 3 (requires 2+ explored dimensions)
**Requirements**: SYNTH-01, SYNTH-02, SYNTH-03, SYNTH-04, SYNTH-05, AGT-03
**Success Criteria** (what must be TRUE):
  1. User runs `/brain:synthesize` (with 2+ dimensions explored) and receives cross-dimensional analysis identifying tensions, synergies, contradictions, and opportunities
  2. Synthesis output is saved as `.brainstorm/SYNTHESIS.md`
  3. User runs `/brain:handoff` and receives a GSD-ready document with structured sections: Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model
  4. HANDOFF.md is saved in `.brainstorm/` and is directly consumable by `/gsd:new-project`
**Plans**: TBD

Plans:
- [ ] 06-01: TBD
- [ ] 06-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6
Note: Phases 5 and 6 both depend on Phase 3 (not on each other).

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Infrastructure & Foundations | 2/2 | Complete | 2026-03-04 |
| 2. New Session Flow | 2/2 | Complete | 2026-03-05 |
| 3. Dimension Exploration | 1/2 | In progress | - |
| 4. Session Management | 0/2 | Not started | - |
| 5. Research Integration | 0/1 | Not started | - |
| 6. Synthesis & Handoff | 0/2 | Not started | - |
