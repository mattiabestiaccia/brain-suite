# Requirements: Brain Suite

**Defined:** 2026-03-04
**Core Value:** L'utente può esplorare un'idea di prodotto in modo strutturato e interattivo, dimensione per dimensione, con artefatti persistenti e output azionabile per l'implementazione.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Exploration

- [ ] **CORE-01**: User can start a brainstorming session with `/brain:new` that creates `.brainstorm/` with IDEA.md and SESSION.md through interactive Socratic questioning
- [ ] **CORE-02**: User can explore any dimension interactively via `/brain:explore <dimension>` with guided Socratic dialogue
- [ ] **CORE-03**: User can explore dimensions in any order, skip dimensions, and revisit already-explored dimensions (non-linear)
- [ ] **CORE-04**: Explorer challenges user's assumptions constructively during exploration (assumption challenging mode)
- [ ] **CORE-05**: Explorer suggests when key points of a dimension are covered, but user decides to continue or stop (hybrid depth gating)
- [ ] **CORE-06**: User can choose exploration mode (Socratic, devil's advocate, creative/divergent) per dimension
- [ ] **CORE-07**: All interactions follow voice-first patterns: responses short and scannable, one question at a time, summary before question, tolerance for informal spoken input

### Dimensions

- [ ] **DIM-01**: 6 built-in dimensions available: product, tech, market, business, competitors, users
- [ ] **DIM-02**: Each dimension has a dedicated template that defines structured output sections
- [ ] **DIM-03**: User can launch dimension shortcuts (`/brain:product`, `/brain:tech`, `/brain:market`, `/brain:business`, `/brain:competitors`, `/brain:users`)
- [ ] **DIM-04**: User can add custom dimensions via `/brain:add-dimension` with template creation and SESSION.md registration
- [ ] **DIM-05**: Explorer suggests which dimension to explore next based on what was discussed and gaps identified (proactive next-step)

### Artifacts & Output

- [ ] **ART-01**: Each dimension exploration produces a structured markdown file in `.brainstorm/dimensions/<dimension>.md`
- [ ] **ART-02**: Each exploration session produces a cleaned session log in `.brainstorm/sessions/<dimension>-<date>.md` (conversational noise removed, content intact)
- [ ] **ART-03**: `/brain:status` shows overview of session: which dimensions explored, which remain, dates, overall progress

### Session Management

- [ ] **SESS-01**: Session state persists in `.brainstorm/SESSION.md` tracking explored dimensions, dates, and notes
- [ ] **SESS-02**: User can resume a previous session with `/brain:resume` that loads IDEA.md + SESSION.md + all explored dimensions into context
- [ ] **SESS-03**: When re-exploring an already-explored dimension, user is asked: deepen existing content or start fresh

### Research

- [ ] **RES-01**: Explorer identifies when real data would help and suggests spawning brain-researcher
- [ ] **RES-02**: User confirms before researcher is spawned (explorer suggests, user approves)
- [ ] **RES-03**: brain-researcher fetches factual data via Exa MCP (market data, competitor info, tech feasibility)
- [ ] **RES-04**: Researcher results are integrated into the dimension exploration context

### Synthesis & Handoff

- [ ] **SYNTH-01**: User can generate cross-dimensional synthesis via `/brain:synthesize` (requires 2+ dimensions explored)
- [ ] **SYNTH-02**: Synthesis identifies tensions, synergies, contradictions, and opportunities across dimensions
- [ ] **SYNTH-03**: Synthesis output saved as `.brainstorm/SYNTHESIS.md`
- [ ] **SYNTH-04**: User can generate GSD-ready handoff document via `/brain:handoff`
- [ ] **SYNTH-05**: HANDOFF.md contains structured sections: Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model

### Agents

- [ ] **AGT-01**: brain-explorer agent guides interactive Socratic exploration with voice-first patterns and assumption challenging
- [ ] **AGT-02**: brain-researcher agent fetches factual data via web search (Exa MCP) when spawned by explorer
- [ ] **AGT-03**: brain-synthesizer agent reads explored dimensions, identifies cross-dimensional patterns, generates SYNTHESIS.md and HANDOFF.md

### Infrastructure

- [ ] **INFRA-01**: `install.sh` creates symlinks from `~/.claude/` to repo files (commands, agents, brainstorm framework)
- [ ] **INFRA-02**: `uninstall.sh` removes symlinks without touching repo or other `~/.claude/` files
- [ ] **INFRA-03**: Install handles coexistence with GSD (symlink individual agent files, not agents directory)
- [ ] **INFRA-04**: Install is idempotent (running twice produces same result)
- [ ] **INFRA-05**: README.md with installation instructions, usage guide, and command reference

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Processing Pipeline (v1.5)

- **PROC-01**: CLI toolkit for audio transcription via faster-whisper
- **PROC-02**: Audio trimming/normalization via ffmpeg
- **PROC-03**: Speaker diarization via pyannote
- **PROC-04**: Transcript distillation via LLM API
- **PROC-05**: Bridge commands `/brain:transcribe` and `/brain:distill`
- **PROC-06**: TDD for all Python components

### MCP Server (v2)

- **MCP-01**: MCP server entrypoint for brain-tools
- **MCP-02**: Registration in `~/.claude.json`
- **MCP-03**: Audio recording import and processing

### GSD Integration

- **GSD-01**: `--from-brainstorm` flag for `/gsd:new-project` consuming HANDOFF.md

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| GUI / visual canvas | CLI-native, Miro/FigJam already do visual brainstorming |
| Real-time collaboration / multiplayer | Single-developer tool, share via git |
| Scoring / ranking ideas quantitatively | Misleading precision, brainstorming is qualitative |
| Template marketplace / plugin system | Over-engineering for v1, ship opinionated defaults |
| Chat history replay | Session logs + dimension artifacts are sufficient |
| External PM integrations (Jira, Linear) | Markdown output is universally portable |
| AI-generated images / wireframes | Scope creep, not core to structured thinking |
| Auto-generated documents without interaction | Defeats the purpose — value is in interactive exploration |
| App Android | v4, nessun impatto architetturale su v1 |
| Windows nativo | Post-v1, symlink richiedono privilegi admin |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| (populated during roadmap creation) | | |

**Coverage:**
- v1 requirements: 28 total
- Mapped to phases: 0
- Unmapped: 28 ⚠️

---
*Requirements defined: 2026-03-04*
*Last updated: 2026-03-04 after initial definition*
