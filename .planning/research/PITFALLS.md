# Domain Pitfalls

**Domain:** Claude Code extension development (custom commands, agents, workflows, templates)
**Project:** Brain Suite -- structured brainstorming framework
**Researched:** 2026-03-04
**Confidence:** HIGH (based on direct experience with Claude Code extension architecture patterns)

---

## Critical Pitfalls

Mistakes that cause rewrites, broken user experiences, or fundamental architectural problems.

---

### Pitfall 1: Prompt Bloat -- Stuffing Too Much Into Agent System Prompts

**What goes wrong:** Agent markdown files (brain-explorer.md, brain-synthesizer.md) grow to thousands of lines as developers keep adding rules, edge cases, and behavioral instructions. The system prompt consumes most of the context window before the conversation even starts, leaving insufficient room for the actual brainstorming content (loaded IDEA.md, dimension files, session logs).

**Why it happens:** Every time the agent misbehaves, the instinct is to add another rule. "It forgot to ask one question at a time" becomes a 200-word paragraph about interaction pacing. Compound this across 15+ behavioral rules and the agent prompt becomes a novel.

**Consequences:**
- Context window exhaustion during resume-session (needs to load IDEA.md + SESSION.md + all dimension files + agent prompt)
- Contradictory rules that cancel each other out ("be concise" vs "always summarize before asking")
- Claude ignores rules buried deep in long prompts (attention decay)
- Slower response times due to prompt size

**Prevention:**
- Budget agent prompts at 800-1200 lines maximum. Measure and track.
- Use reference files (questioning.md, voice-interaction.md) loaded on-demand by workflows rather than baked into agent prompts
- One rule, one sentence. If a rule needs a paragraph, it belongs in a reference file.
- Test agent behavior with minimal prompts first, add rules only when failure is observed AND the fix is specific
- Use "role + constraints + format" structure, not "role + every possible scenario"

**Detection (warning signs):**
- Agent .md file exceeds 1500 lines
- Adding a rule to fix behavior that another rule was supposed to handle
- Agent "forgets" instructions that are clearly in its prompt
- Resume-session fails to load full context

**Phase relevance:** Phase 2 (Agents). Establish prompt budgets and the reference-file pattern before writing any agent content.

---

### Pitfall 2: Context Window Starvation During Session Resume

**What goes wrong:** `/brain:resume` must reload IDEA.md + SESSION.md + all explored dimension files + potentially session logs. After 4-5 explored dimensions, this payload can exceed what the model can effectively process alongside the agent prompt and ongoing conversation.

**Why it happens:** Each dimension file is a structured artifact with substantial content (findings, questions asked, conclusions drawn). Six fully explored dimensions at 300-500 lines each = 1800-3000 lines of context, plus the agent prompt, plus IDEA.md, plus SESSION.md.

**Consequences:**
- Claude "forgets" earlier dimensions when discussing later ones
- Synthesis quality degrades because the model cannot attend to all dimension content simultaneously
- Resume feels broken -- the user expects continuity but gets amnesia

**Prevention:**
- Each dimension file should have a structured summary section at the top (max 10 lines) that captures key findings
- Resume workflow loads ONLY summaries first, then loads full dimension content on-demand when the user wants to re-explore
- SESSION.md tracks which dimensions are explored and their summary one-liners
- Set explicit size targets for dimension artifacts: ~200-300 lines of content max, with a structured TL;DR header
- Synthesis workflow can use progressive loading: read 2-3 dimensions at a time, accumulate synthesis notes, then cross-reference

**Detection (warning signs):**
- Dimension files growing beyond 400 lines
- Resume-session gives generic responses that don't reference specific earlier findings
- User says "I already told you this" after resuming

**Phase relevance:** Phase 1 (Templates) -- bake the TL;DR header pattern into dimension templates from day one. Phase 5 (Resume) -- implement progressive loading in resume-session workflow.

---

### Pitfall 3: Symlink Collision and Namespace Pollution

**What goes wrong:** Brain Suite symlinks into `~/.claude/` which is shared global space. Other extensions (GSD, future tools) also symlink there. Collisions happen when:
- Two extensions use the same agent filename
- Directory symlinks overwrite each other
- Install/uninstall scripts remove files belonging to other extensions
- `.claude/settings.local.json` gets overwritten

**Why it happens:** No namespace registry exists for Claude Code extensions. Each extension treats `~/.claude/` as its own territory. The plan correctly identifies this ("symlink singoli file, non directory" for agents) but the risk persists for other resources.

**Consequences:**
- Installing Brain Suite breaks GSD (or vice versa)
- Uninstall script removes files it didn't create
- Subtle breakage where an agent file from extension A shadows one from extension B
- User has no way to diagnose which extension owns which symlink

**Prevention:**
- Strict naming convention: ALL Brain Suite files prefixed with `brain-` (agents) or in `brain/` subdirectory (commands, brainstorm/)
- Install script checks for existing targets before creating symlinks, warns on collision
- Install script writes a manifest file (e.g., `~/.claude/.brain-suite-manifest.json`) listing every symlink it created
- Uninstall script reads manifest, only removes what it installed
- Never symlink directories that might contain files from other extensions (agents/ is shared; commands/brain/ is namespaced and safe)
- Test install/uninstall idempotency: running install twice should be safe; running uninstall should not break GSD

**Detection (warning signs):**
- Install script uses `ln -sfn` without checking existing targets (force-overwrite is dangerous for shared directories)
- No manifest tracking which files belong to Brain Suite
- Uninstall script uses glob patterns that might match other extensions' files

**Phase relevance:** Phase 1 (Foundations). The install script is the first thing users interact with. Every phase adds files that get symlinked, so the manifest pattern must be established early.

---

### Pitfall 4: Workflow-Agent Coupling -- The Monolith Prompt Trap

**What goes wrong:** Workflows (explore-dimension.md, new-session.md) contain agent-level behavioral instructions instead of orchestration logic. Or agents contain workflow-level sequencing instead of behavioral rules. The separation of concerns collapses.

**Why it happens:** In Claude Code, commands, workflows, agents, and reference files are all markdown. There is no runtime enforcement of "this is orchestration" vs "this is behavior." When a workflow needs the agent to behave a certain way, it is tempting to inline the behavioral rules rather than reference the agent definition. Similarly, when an agent needs to follow a sequence, it is tempting to bake the workflow steps into the agent prompt.

**Consequences:**
- Same behavioral rules duplicated across workflows and agents (drift, contradictions)
- Changing agent personality requires editing 5+ workflow files
- Workflows become untestable because they mix "what to do" with "how to behave"
- Adding a new dimension requires editing both the workflow AND the agent AND the template (three-way coupling)

**Prevention:**
- Hard separation: workflows define SEQUENCE (load this, then do that, then write here). Agents define PERSONALITY and CONSTRAINTS. Reference files define SHARED RULES. Templates define OUTPUT STRUCTURE.
- Workflow references agent by name, never re-describes agent behavior
- Agent references shared rules via reference file paths, never re-states them
- Test: can you change the questioning style by editing only questioning.md? If not, the separation is broken.
- Document the separation contract in a CONTRIBUTING.md or architecture doc

**Detection (warning signs):**
- Workflow file contains phrases like "respond briefly" or "ask one question at a time" (those belong in agent or reference)
- Agent file contains phrases like "first load IDEA.md, then check SESSION.md" (those belong in workflow)
- Changing a behavior requires editing more than 2 files

**Phase relevance:** Phase 1 (Workflows + References) and Phase 2 (Agents). Must establish the contract before content is written.

---

### Pitfall 5: Voice-First Interaction Design That Only Works in Text

**What goes wrong:** The "voice-first" design principles are documented in a reference file but the actual agent prompts and templates produce text-heavy, visually structured output that is optimized for reading, not for the voice-to-text input / text-to-voice output loop.

**Why it happens:** Developers write and test in text mode. Even when they know the user dictates via voice-to-text, the testing happens by typing. The asymmetry is invisible: the developer sees clean terminal output, but the real user is speaking thoughts and glancing at text between spoken sentences.

**Consequences:**
- Agent outputs 3-paragraph responses with bullet lists when the user needs a single sentence plus one question
- Agent asks compound questions ("What's your target user, and what problem do they face, and how do they currently solve it?") that are impossible to answer via voice in one breath
- Templates generate wall-of-text artifacts that cannot be quickly scanned
- Explorer demands structured input ("rate from 1-5") instead of accepting natural language

**Prevention:**
- voice-interaction.md reference file must be prescriptive, not descriptive. Not "be concise" but "maximum 3 sentences before asking a question"
- Enforce single-question rule: every agent response ends with exactly ONE question, never more
- Test by actually using voice-to-text (dictation) for 3+ dimension explorations before shipping
- Summary-before-question pattern: "So you're saying X. [question]?" -- this lets the user correct misunderstandings
- Templates should use minimal structure: heading + 3-5 bullet max, not elaborate markdown tables
- AskUserQuestion options must be vocally distinguishable: "yes / no / tell me more" not "option A / option B / option C"

**Detection (warning signs):**
- Agent responses consistently exceed 5 sentences before asking a question
- Agent asks 2+ questions in a single response
- Templates contain tables with 4+ columns
- Testing is only done via keyboard typing

**Phase relevance:** Phase 2 (Agents) and Phase 3 (Dimension Exploration). Must be validated with real voice interaction before Phase 4 (Synthesis).

---

## Moderate Pitfalls

---

### Pitfall 6: Template Rigidity -- Overly Structured Dimension Artifacts

**What goes wrong:** Dimension templates (dimension-product.md, dimension-tech.md, etc.) define rigid structures with many required sections, specific heading hierarchies, and prescribed content. The explorer agent tries to fill every section, turning an organic exploration into a form-filling exercise.

**Why it happens:** Template designers want comprehensive output. They look at what a "complete" product analysis should contain and create 15+ sections. The agent then feels compelled to ask questions about each section even if the user has no insight on some topics.

**Prevention:**
- Templates should define MINIMUM viable sections (3-5) plus OPTIONAL sections that are only populated if the exploration surfaces relevant content
- Mark template sections as `<!-- required -->` vs `<!-- if discussed -->` so the agent knows what to skip
- Explorer should be driven by the conversation, not by template completeness. Template is a capture format, not an interview script.
- Gate completion on "key insights captured" not "all sections filled"

**Detection (warning signs):**
- Dimension templates have 10+ required sections
- Explorer asks questions that feel forced ("And what about [section the user never mentioned]?")
- Every dimension artifact looks the same regardless of what was discussed

**Phase relevance:** Phase 3 (Dimension Templates). Design templates as capture formats, not interview scripts.

---

### Pitfall 7: Session Log Pollution -- Saving Too Much or Too Little

**What goes wrong:** Session logs (sessions/product-2026-03-04.md) either capture the raw conversation verbatim (including Claude's system messages, tool outputs, error recovery, and conversational filler) or aggressively filter to the point where resuming the session loses critical context.

**Why it happens:** "Clean session logs" is an ambiguous requirement. What counts as "conversational noise" vs "important context"? Different parts of the conversation have different value densities.

**Prevention:**
- Define explicit categories: KEEP (user insights, decisions, conclusions, open questions) vs DROP (tool outputs, error messages, meta-conversation about the tool, greetings, acknowledgments)
- Session logs should be structured: not a raw transcript, but a sequence of `## Turn N` blocks with `**User said:**` and `**Key point:**` extractions
- Log writer is a defined step in the explore-dimension workflow, not an afterthought
- Size target: session log should be 30-50% the length of the raw conversation
- Include a `## Context for Resume` section at the top with the 3-5 most important things to know

**Detection (warning signs):**
- Session logs are nearly as long as the original conversation
- Session logs are so short that resuming feels like starting over
- No consistent structure across session logs

**Phase relevance:** Phase 3 (Explore-dimension workflow). The log writing step must be defined before dimension exploration is implemented.

---

### Pitfall 8: Handoff Document Impedance Mismatch

**What goes wrong:** HANDOFF.md is the bridge between brain: and gsd: worlds. If its structure does not match what `/gsd:new-project` expects (or what a human would need to start implementation), the handoff is useless and the user manually re-types information.

**Why it happens:** Brain Suite and GSD are developed independently. The handoff format is designed based on what Brain Suite produces, not what GSD consumes. The "consumer" requirements are assumed, not verified.

**Prevention:**
- Study `/gsd:new-project` input expectations BEFORE designing HANDOFF.md template
- Map each HANDOFF.md section to a specific GSD input field
- Include a validation checklist in the handoff workflow: "Does this document answer: What are we building? Why? For whom? Technical constraints? Success criteria?"
- Test the handoff by actually running `/gsd:new-project` with a generated HANDOFF.md (even manually, before `--from-brainstorm` flag exists)
- Keep HANDOFF.md format stable across versions -- it is a contract interface

**Detection (warning signs):**
- HANDOFF.md sections don't map 1:1 to GSD project initialization questions
- User has to re-explain things after handoff
- Handoff template changes frequently

**Phase relevance:** Phase 4 (Handoff). Must be validated against GSD's actual input expectations.

---

### Pitfall 9: Re-Exploration Confusion -- Append vs Replace vs Fork

**What goes wrong:** When the user re-explores an already-explored dimension, the system does not clearly handle whether to: (a) append new findings to the existing artifact, (b) replace the artifact entirely, or (c) create a versioned fork. The result is either lost data (replacement), confusing artifacts (incoherent append), or artifact sprawl (too many versions).

**Why it happens:** The initial design handles the happy path (explore once), and re-exploration is treated as an edge case. But in practice, users frequently revisit dimensions as their thinking evolves.

**Prevention:**
- Explicit user choice at re-exploration start: "You explored product on March 2. Do you want to build on those findings, or start fresh?"
- "Build on" = load existing artifact as context, append new section with timestamp
- "Start fresh" = archive old artifact (rename to product-v1.md), create new one
- SESSION.md tracks exploration versions: `product: [2026-03-02, 2026-03-04]`
- Never silently overwrite -- always confirm with user

**Detection (warning signs):**
- Dimension file contains contradictory information from different exploration sessions
- User is confused about which findings are current
- No archive/versioning mechanism for dimension artifacts

**Phase relevance:** Phase 3 (Explore-dimension workflow) and Phase 5 (Resume). The re-exploration path must be designed alongside the primary exploration path.

---

### Pitfall 10: Agent Spawn Overhead -- Researcher Spawned Too Eagerly

**What goes wrong:** The brain-researcher agent is spawned frequently during exploration for minor factual checks, each spawn consuming context window to load the researcher's prompt and losing the exploration conversation's continuity. The explorer becomes a dispatcher rather than an exploration partner.

**Why it happens:** The architecture supports explorer suggesting a researcher spawn. Without clear criteria for WHEN to spawn, the explorer defaults to "whenever a factual question comes up." Spawning is cheap in design but expensive in context and conversation flow.

**Prevention:**
- Define spawn criteria explicitly: researcher spawn ONLY when (a) the user confirms AND (b) the question requires web search / market data that the explorer cannot answer from general knowledge
- Batch researcher needs: explorer collects 3-5 research questions during exploration, proposes a single researcher spawn to answer all of them
- Researcher writes findings to a file, explorer reads the file -- no need for real-time back-and-forth
- Explorer can answer general knowledge questions itself (e.g., "what frameworks exist for X") without spawning researcher

**Detection (warning signs):**
- Researcher is spawned more than once per dimension exploration
- Explorer stops mid-conversation to spawn researcher for a question it could answer itself
- User feels the conversation is fragmented by agent switches

**Phase relevance:** Phase 2 (Agent design) and Phase 3 (Explore-dimension workflow). The spawn criteria must be in the explorer agent prompt.

---

### Pitfall 11: Install Script Non-Idempotency and Partial Failure

**What goes wrong:** `install.sh` fails midway (e.g., `~/.claude/commands/` does not exist yet, or a symlink target is a regular file instead of a symlink). The script leaves the installation in a half-done state with no rollback mechanism. Running install again does not fix the issue because some symlinks already exist.

**Why it happens:** Shell scripts are fragile. `ln -sfn` behaves differently when the target is a file vs directory vs existing symlink vs broken symlink. Each edge case needs handling.

**Prevention:**
- Install script creates parent directories before symlinking (`mkdir -p`)
- Check each symlink target before creating: if it exists and is NOT a symlink, warn and skip (do not overwrite user files)
- Use `set -euo pipefail` for fail-fast behavior
- Write manifest as you go: each successful symlink is recorded immediately
- Include a `--dry-run` flag that shows what would be done without doing it
- Test: `install.sh && uninstall.sh && install.sh` must leave a working state (idempotency)
- Test: `install.sh` on a machine that already has GSD installed must not break GSD

**Detection (warning signs):**
- Install script uses `ln -sfn` without checking what is at the target path
- No error handling or `set -e`
- No manifest file for tracking what was installed
- Uninstall script uses `rm -f` with glob patterns

**Phase relevance:** Phase 1 (Foundations). The install script is the first thing users interact with. It must be rock-solid.

---

## Minor Pitfalls

---

### Pitfall 12: Thin Wrapper Command Drift

**What goes wrong:** The 6 dimension shortcut commands (product.md, tech.md, etc.) are thin wrappers around explore.md. Over time, individual shortcuts accumulate custom logic (special questions for competitors, extra context for tech) and drift from the shared explore workflow.

**Prevention:**
- Thin wrappers should contain ONLY: command name, dimension argument, and a one-line reference to explore.md. No behavioral content.
- All dimension-specific behavior lives in the dimension template or a dimension-specific section of the explore-dimension workflow
- Code review rule: if a shortcut file exceeds 10 lines, something belongs in the template instead

**Phase relevance:** Phase 3 (Dimension Commands).

---

### Pitfall 13: Synthesis Without Sufficient Dimensions

**What goes wrong:** `/brain:synthesize` is available after 2+ dimensions, but meaningful synthesis requires dimensions that have meaningful cross-dimensional tension (e.g., product vs tech, users vs business). Two dimensions that are topically similar (product + users) produce a synthesis that is just concatenation, not insight.

**Prevention:**
- Synthesizer should identify and highlight cross-dimensional tensions specifically, not just summarize each dimension
- Consider recommending (not requiring) a minimum of 3 diverse dimensions before synthesis
- Synthesis template should have a `## Tensions and Tradeoffs` section that forces cross-referencing
- If only 2 dimensions explored, synthesizer should explicitly note what dimensions would add value

**Phase relevance:** Phase 4 (Synthesis).

---

### Pitfall 14: Custom Dimension Sprawl

**What goes wrong:** `/brain:add-dimension` lets users create custom dimensions with no guardrails. Users create overlapping dimensions ("marketing" when "market" already exists), overly narrow dimensions ("pricing-for-enterprise" instead of exploring pricing within "business"), or joke dimensions that pollute the session.

**Prevention:**
- When adding a custom dimension, check for semantic overlap with existing dimensions (both default and custom)
- Suggest existing dimensions that might cover the topic before creating a new one
- Custom dimensions must have a one-line description that is saved to SESSION.md
- Maximum 3-4 custom dimensions per session (soft limit, warn but allow)

**Phase relevance:** Phase 5 (add-dimension command).

---

### Pitfall 15: Cross-Platform Symlink Assumptions

**What goes wrong:** Install script assumes POSIX symlinks work. On Windows native (even with Developer Mode), symlink behavior differs: `ln -sfn` does not exist, paths use backslashes, and junction points behave differently from symlinks for directories.

**Prevention:**
- v1 targets Linux/WSL2 only -- document this explicitly in README
- Install script should detect the platform and abort with a clear message on unsupported platforms
- Design all path references in workflow/agent files as relative to `~/.claude/` -- never hardcode absolute paths that assume a specific OS
- When Windows support is added, use a separate install.ps1 or detect WSL vs native in install.sh

**Phase relevance:** Phase 1 (Install script). Add platform detection early even if only Linux is supported.

---

### Pitfall 16: Reference File Circular Dependencies

**What goes wrong:** Reference files reference each other, workflows reference references, agents reference workflows. A circular chain forms where understanding file A requires reading file B which requires reading file A. Claude loads all of them, consuming context without gaining clarity.

**Prevention:**
- Reference files are LEAF nodes: they reference nothing, they are only referenced by workflows and agents
- Workflows reference agents and reference files, never other workflows
- Agents reference reference files, never workflows or other agents
- Document the dependency DAG and enforce it during review
- Draw the dependency graph: `command -> workflow -> agent + reference`. If you see arrows going backwards, there is a problem.

**Phase relevance:** Phase 1 (References) and Phase 2 (Agents). Establish the DAG before building.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Phase 1: Foundations (references, templates, install) | Pitfall 3 (symlink collision), Pitfall 11 (install non-idempotency), Pitfall 16 (circular deps) | Write install.sh with manifest tracking. Define reference dependency DAG. Test install on machine with GSD. |
| Phase 2: Agents | Pitfall 1 (prompt bloat), Pitfall 4 (workflow-agent coupling), Pitfall 5 (voice-first in text), Pitfall 10 (researcher spawn criteria) | Set 1000-line budget per agent. Separate behavior from sequencing. Define explicit researcher spawn criteria. |
| Phase 3: Dimension Exploration | Pitfall 2 (context starvation), Pitfall 6 (template rigidity), Pitfall 7 (session log pollution), Pitfall 9 (re-explore confusion), Pitfall 12 (wrapper drift) | Templates with TL;DR headers and optional sections. Explicit re-explore user choice. Thin wrappers stay thin. |
| Phase 4: Synthesis and Handoff | Pitfall 8 (handoff mismatch), Pitfall 13 (shallow synthesis) | Validate HANDOFF.md against GSD expectations before implementation. Force cross-dimensional tensions in synthesis. |
| Phase 5: Utilities | Pitfall 2 (context starvation on resume), Pitfall 9 (re-explore), Pitfall 14 (custom dimension sprawl) | Progressive context loading for resume. Semantic overlap check for custom dimensions. |

---

## Meta-Pitfall: The Prompt Engineering Feedback Loop

There is a domain-wide meta-pitfall specific to Claude Code extension development that cuts across all phases:

**The problem:** When the extension does not work as expected, the default fix is "add more instructions to the prompt." This creates a ratchet effect where prompts only grow, never shrink. Eventually, prompts are so long and dense that Claude cannot follow all instructions, causing NEW failures, which cause MORE instructions to be added.

**The discipline:**
1. Before adding a prompt instruction, ask: "Is this a prompt problem or a workflow problem?" If the agent does the wrong thing at the wrong time, that is a workflow issue. If the agent does the right thing in the wrong style, that is a prompt issue.
2. Before adding a prompt instruction, remove one. If you cannot identify one to remove, the prompt is already too lean (rare) or you are not being critical enough (common).
3. Test with prompt REMOVAL: periodically try deleting 20% of agent instructions and see if behavior degrades. Often it does not, proving those instructions were noise.
4. Measure prompt sizes in each release. If total prompt tokens across all files grows by more than 20% between phases, audit for bloat.

---

## Sources

- Direct experience with Claude Code extension architecture (commands, agents, workflows, templates, reference files)
- GSD framework architectural patterns (the reference implementation that Brain Suite follows)
- BRAIN_SUITE_PLAN.md project architecture documentation
- PROJECT.md requirements and constraints
- Claude Code prompt engineering patterns from production usage

**Confidence:** HIGH -- these pitfalls are derived from hands-on experience with the exact architecture pattern (Claude Code extensions via markdown prompts, symlink distribution, agent orchestration) that Brain Suite will use. The GSD framework, which Brain Suite explicitly models itself after, has encountered and addressed many of these issues.
