#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# Brain Suite uninstaller
# Reads manifest and removes only Brain Suite symlinks
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

removed=0
skipped=0

# ── Helper functions ──────────────────────────────────────

info()  { printf "${GREEN}%s${NC}\n" "$1"; }
warn()  { printf "${YELLOW}%s${NC}\n" "$1"; }

# ── Manifest check ────────────────────────────────────────

MANIFEST="$HOME/.claude/.brain-suite-manifest"

if [ ! -f "$MANIFEST" ]; then
  echo "No Brain Suite installation found (manifest missing)."
  exit 0
fi

echo "Uninstalling Brain Suite..."
echo ""

# ── Read manifest and remove ──────────────────────────────

while IFS= read -r path || [ -n "$path" ]; do
  # Skip empty lines
  [ -z "$path" ] && continue

  if [ -L "$path" ]; then
    rm "$path"
    info "  removed: $path"
    removed=$((removed + 1))
  elif [ -d "$path" ]; then
    if [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
      rmdir "$path"
      info "  removed directory: $path"
      removed=$((removed + 1))
    else
      warn "  kept (not empty): $path"
      skipped=$((skipped + 1))
    fi
  else
    warn "  skipped (not found): $path"
    skipped=$((skipped + 1))
  fi
done < "$MANIFEST"

# ── Remove manifest itself ────────────────────────────────

rm "$MANIFEST"
info "  removed manifest"

# ── Summary ───────────────────────────────────────────────

echo ""
echo "Brain Suite uninstalled."
printf "  %d removed  %d skipped\n" "$removed" "$skipped"
