# Brain Suite

Structured brainstorming framework for Claude Code. Explore product ideas dimension by dimension with interactive Socratic dialogue.

## What it does

- **Interactive brainstorming** through Socratic questioning with a thinking-partner AI
- **6 structured dimensions**: product, tech, market, business, competitors, users
- **Persistent artifacts** -- IDEA.md, dimension files, session logs, and synthesis
- **Multiple exploration modes**: Socratic (default), challenger, creative
- **GSD-ready handoff** for implementation planning with `/gsd:new-project`

## Installation

```bash
git clone https://github.com/brusc/brain-suite.git
cd brain-suite
./install.sh
```

Restart Claude Code after installation for commands to appear.

Brain Suite coexists safely with GSD and other Claude Code extensions. It only creates symlinks in the `commands/brain/`, `agents/`, and `brain-suite/` directories within `~/.claude/`.

## Uninstall

```bash
./uninstall.sh
```

Removes only Brain Suite symlinks. GSD and other extensions are never touched.

## Quick Start

```
/brain:new              # Start a new brainstorming session
/brain:explore product  # Explore the product dimension
/brain:status           # Check exploration progress
```

## Command Reference

| Command | Description | Phase |
|---------|-------------|-------|
| `/brain:new` | Start a new brainstorming session | Available |
| `/brain:explore <dim>` | Explore a dimension interactively | Available |
| `/brain:product` | Shortcut for explore product | Available |
| `/brain:tech` | Shortcut for explore tech | Available |
| `/brain:market` | Shortcut for explore market | Available |
| `/brain:business` | Shortcut for explore business | Available |
| `/brain:competitors` | Shortcut for explore competitors | Available |
| `/brain:users` | Shortcut for explore users | Available |
| `/brain:status` | Show session progress and dimension coverage | Available |
| `/brain:resume` | Resume a previous brainstorming session | Available |
| `/brain:add-dimension` | Add a custom dimension to the session | Available |
| `/brain:synthesize` | Cross-dimensional synthesis (requires 2+ dimensions) | Available |
| `/brain:handoff` | Generate GSD-ready handoff document | Available |

## Exploration Modes

Each dimension can be explored in one of three modes:

| Mode | Style | Default for |
|------|-------|-------------|
| **Socratic** | Guided questions, co-discovery | product, tech, users |
| **Challenger** | Devil's advocate, stress-tests assumptions | market, competitors, business |
| **Creative** | Divergent thinking, "what if" scenarios | product (alternate) |

The explorer suggests the default mode for each dimension, but you can override it at any time.

## Session Artifacts

Brain Suite creates a `.brainstorm/` directory in your project root with:

```
.brainstorm/
  IDEA.md                           # Core idea definition
  SESSION.md                        # Session state and progress
  dimensions/
    product.md                      # Structured output per dimension
    tech.md
    ...
  sessions/
    product-2026-03-04.md           # Session logs (date-stamped)
    tech-2026-03-05.md
```

- **IDEA.md** -- Your core idea, captured during `/brain:new`
- **SESSION.md** -- Tracks which dimensions are explored, dates, and overall progress
- **dimensions/** -- Structured output for each explored dimension
- **sessions/** -- Cleaned session logs with conversational noise removed

## How it works

Brain Suite breaks product ideation into 6 dimensions (product, tech, market, business, competitors, users). Each dimension has a structured template with key sections to cover.

The brain-explorer agent guides you through each dimension using Socratic questioning -- one question at a time, building on your answers. It uses voice-first interaction patterns: short responses, informal input tolerance, and a summary-before-question flow.

Everything is persisted as markdown files, so your brainstorming survives across Claude Code sessions. When all dimensions are explored, `/brain:synthesize` finds cross-dimensional insights, and `/brain:handoff` produces a document ready for implementation planning.

## Requirements

- Claude Code CLI
- bash 3.2+ (macOS) or bash 5+ (Linux)
