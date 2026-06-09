#!/bin/sh
# apply-global.sh — Install ws-agents configuration globally.
# Detects repo root, OS, shell, and installed CLIs, then symlinks configs.
#
# Usage: ./scripts/apply-global.sh [options]
#   --dry-run    Show what would be done without doing it
#   --force      Overwrite existing files (backups in ~/.agents-backup-<timestamp>)
#   --copy       Copy instead of symlink
#   --only       Comma-separated list: codex,copilot,claude
#   --verify     Verify after applying
#   --no-mcp     Skip MCP configuration

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
FORCE=false
COPY_MODE=false
ONLY=""
VERIFY=false
NO_MCP=false
BACKUP_DIR="${HOME}/.agents-backup-$(date +%Y%m%dT%H%M%S)"

usage() {
  cat << 'EOF'
Usage: ./scripts/apply-global.sh [options]

Options:
  --dry-run          Show what would be done without doing it
  --force            Overwrite existing files (backups created)
  --copy             Copy files instead of symlinking
  --only codex,copilot,claude  Apply only to specified tools
  --verify           Run verification after applying
  --no-mcp           Skip MCP configuration
  --help             Show this help
EOF
  exit 0
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --force)   FORCE=true; shift ;;
    --copy)    COPY_MODE=true; shift ;;
    --only)    ONLY="$2"; shift 2 ;;
    --verify)  VERIFY=true; shift ;;
    --no-mcp)  NO_MCP=true; shift ;;
    --help)    usage ;;
    *)         echo "Unknown option: $1"; usage ;;
  esac
done

info()  { echo "  [INFO]  $*"; }
warn()  { echo "  [WARN]  $*"; }
action(){ echo "  [ACTION] $*"; }

backup_existing() {
  [ "$DRY_RUN" = true ] && return
  local src="$1"
  if [ -f "$src" ] || [ -d "$src" ] || [ -L "$src" ]; then
    mkdir -p "${BACKUP_DIR}"
    cp -r "$src" "${BACKUP_DIR}/" 2>/dev/null || true
    info "Backed up ${src} to ${BACKUP_DIR}/"
  fi
}

link_or_copy() {
  local src="$1" dst="$2"
  if [ "$COPY_MODE" = true ]; then
    action "cp ${src} -> ${dst}"
    [ "$DRY_RUN" = false ] && cp "$src" "$dst"
  else
    action "ln -s ${src} -> ${dst}"
    [ "$DRY_RUN" = false ] && ln -sf "$src" "$dst"
  fi
}

safe_install() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" = true ]; then
      backup_existing "$dst"
      rm -rf "$dst"
      link_or_copy "$src" "$dst"
    else
      warn "Exists: ${dst} (use --force to overwrite)"
    fi
  else
    link_or_copy "$src" "$dst"
  fi
}

# --- Installation ---

echo "=== ws-agents Global Installer ==="
echo "  Mode: $([ "$COPY_MODE" = true ] && echo copy || echo symlink)"
echo "  Force: ${FORCE}"
[ -n "$ONLY" ] && echo "  Only: ${ONLY}"
[ "$DRY_RUN" = true ] && echo "  [DRY RUN — no changes will be made]"
echo ""

# Determine selected tools
ENABLE_CODEX=false; ENABLE_COPILOT=false; ENABLE_CLAUDE=false
if [ -n "$ONLY" ]; then
  echo "$ONLY" | tr ',' '\n' | while IFS= read -r t; do
    case "$t" in
      codex)   ENABLE_CODEX=true ;;
      copilot) ENABLE_COPILOT=true ;;
      claude)  ENABLE_CLAUDE=true ;;
    esac
  done
else
  # Auto-detect by installed CLI
  command -v codex    >/dev/null 2>&1 && ENABLE_CODEX=true
  command -v copilot  >/dev/null 2>&1 && ENABLE_COPILOT=true
  command -v claude   >/dev/null 2>&1 && ENABLE_CLAUDE=true
  # Enable all if none detected
  $ENABLE_CODEX || $ENABLE_COPILOT || $ENABLE_CLAUDE || {
    ENABLE_CODEX=true; ENABLE_COPILOT=true; ENABLE_CLAUDE=true
    info "No CLIs detected, enabling all targets"
  }
fi

echo ""

# --- Codex ---
if [ "$ENABLE_CODEX" = true ]; then
  echo "## Codex"
  # AGENTS.md in home directory
  safe_install "${REPO_ROOT}/codex/AGENTS.md" "${HOME}/AGENTS.md"
  # .codex directory
  if [ ! -d "${HOME}/.codex" ]; then
    [ "$DRY_RUN" = false ] && mkdir -p "${HOME}/.codex"
  fi
  echo ""
fi

# --- Copilot ---
if [ "$ENABLE_COPILOT" = true ]; then
  echo "## Copilot"
  mkdir -p "${HOME}/.config/copilot" 2>/dev/null || true
  # Global instructions
  global_inst="${REPO_ROOT}/copilot/copilot-instructions.md"
  if [ -f "$global_inst" ]; then
    safe_install "$global_inst" "${HOME}/.config/copilot/instructions.md"
  else
    # Build from shared personas
    tmpf="/tmp/copilot-instructions-$$.md"
    for pf in "${REPO_ROOT}/shared/personas"/*.md; do
      name="$(basename "$pf" .md)"
      echo "# ${name}" >> "$tmpf"
      echo "" >> "$tmpf"
      cat "$pf" >> "$tmpf"
      echo -e "\n---\n" >> "$tmpf"
    done
    safe_install "$tmpf" "${HOME}/.config/copilot/instructions.md"
    [ "$DRY_RUN" = false ] && rm -f "$tmpf"
  fi
  echo ""
fi

# --- Claude ---
if [ "$ENABLE_CLAUDE" = true ]; then
  echo "## Claude Code"
  # Global CLAUDE.md
  safe_install "${REPO_ROOT}/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
  # .claude agents
  if [ -d "${REPO_ROOT}/.claude/agents" ]; then
    for f in "${REPO_ROOT}/.claude/agents"/*.md; do
      [ -f "$f" ] || continue
      safe_install "$f" "${HOME}/.claude/agents/$(basename "$f")"
    done
  fi
  # .claude skills
  if [ -d "${REPO_ROOT}/.claude/skills" ]; then
    for skilldir in "${REPO_ROOT}/.claude/skills"/*/; do
      [ -d "$skilldir" ] || continue
      skill_name="$(basename "$skilldir")"
      mkdir -p "${HOME}/.claude/skills/${skill_name}"
      for f in "${skilldir}"*; do
        [ -f "$f" ] || continue
        safe_install "$f" "${HOME}/.claude/skills/${skill_name}/$(basename "$f")"
      done
    done
  fi
  echo ""
fi

# --- MCP (if not skipped) ---
if [ "$NO_MCP" = false ]; then
  echo "## MCP Configuration"
  # Claude MCP
  if [ -f "${REPO_ROOT}/claude/.mcp.json" ] && [ "$ENABLE_CLAUDE" = true ]; then
    safe_install "${REPO_ROOT}/claude/.mcp.json" "${HOME}/.claude/.mcp.json"
  fi
  echo ""
fi

echo "=== Installation $([ "$DRY_RUN" = true ] && echo 'Simulation' || echo 'Complete') ==="

if [ "$DRY_RUN" = false ] && [ "$VERIFY" = true ]; then
  echo ""
  "${REPO_ROOT}/scripts/doctor.sh"
fi
