#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# Brain Suite installer
# Creates symlinks in ~/.claude/ for commands, agents, and references
# ─────────────────────────────────────────────────────────

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Color output ──────────────────────────────────────────

if command -v tput &>/dev/null && [ -t 1 ] && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  RED=''
  NC=''
fi

# ── Counters ──────────────────────────────────────────────

linked=0
warned=0
failed=0

# ── Helper functions ──────────────────────────────────────

info()  { printf "${GREEN}%s${NC}\n" "$1"; }
warn()  { printf "${YELLOW}%s${NC}\n" "$1"; }
error() { printf "${RED}%s${NC}\n" "$1"; }

link_file() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$REPO_DIR"* ]]; then
      ln -sf "$src" "$dest"
      info "  updated: $label"
      linked=$((linked + 1))
      return 0
    else
      warn "  WARN: $label already exists (not Brain Suite) -- skipping"
      warned=$((warned + 1))
      return 1
    fi
  elif [ -e "$dest" ]; then
    warn "  WARN: $label already exists (not Brain Suite) -- skipping"
    warned=$((warned + 1))
    return 1
  else
    ln -sf "$src" "$dest"
    info "  linked: $label"
    linked=$((linked + 1))
    return 0
  fi
}

link_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
    info "  updated: $label"
  else
    ln -sfn "$src" "$dest"
    info "  linked: $label"
  fi
  linked=$((linked + 1))
}

# ── Pre-checks ────────────────────────────────────────────

mkdir -p "$HOME/.claude"

missing=0
for check in "commands/brain/" "agents/brain-explorer.md" "references/voice-interaction.md"; do
  if [ ! -e "$REPO_DIR/$check" ]; then
    error "Missing: $check"
    missing=1
  fi
done

if [ "$missing" -eq 1 ]; then
  error "Missing source files. Is this the brain-suite repo?"
  exit 1
fi

echo "Installing Brain Suite..."
echo ""

# ── Manifest initialization ───────────────────────────────

MANIFEST="$HOME/.claude/.brain-suite-manifest"
> "$MANIFEST"

# ── Symlink: commands/brain/ directory ────────────────────

mkdir -p "$HOME/.claude/commands"
link_dir "$REPO_DIR/commands/brain" "$HOME/.claude/commands/brain" "commands/brain/"
echo "$HOME/.claude/commands/brain" >> "$MANIFEST"

# ── Symlink: individual agent files ───────────────────────

mkdir -p "$HOME/.claude/agents"
for f in "$REPO_DIR"/agents/brain-*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  dest="$HOME/.claude/agents/$name"
  if link_file "$f" "$dest" "agents/$name"; then
    echo "$dest" >> "$MANIFEST"
  fi
done

# ── Symlink: references/ directory ────────────────────────

mkdir -p "$HOME/.claude/brain-suite"
link_dir "$REPO_DIR/references" "$HOME/.claude/brain-suite/references" "brain-suite/references/"
echo "$HOME/.claude/brain-suite/references" >> "$MANIFEST"

# ── Symlink: templates/ directory ─────────────────────────
link_dir "$REPO_DIR/templates" "$HOME/.claude/brain-suite/templates" "brain-suite/templates/"
echo "$HOME/.claude/brain-suite/templates" >> "$MANIFEST"

echo "$HOME/.claude/brain-suite" >> "$MANIFEST"

# ── Summary ───────────────────────────────────────────────

echo ""
echo "Brain Suite installation complete."
printf "  %d files linked  %d skipped  %d errors\n" "$linked" "$warned" "$failed"
echo ""
echo "Restart Claude Code for commands to appear."
