#!/bin/sh
# doctor.sh — Print installed versions, active symlinks, missing CLIs, and MCP readiness.
# Usage: ./scripts/doctor.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== ws-agents Doctor ==="
echo ""

# --- Repo info ---
echo "## Repository"
echo "  Path: ${REPO_ROOT}"
[ -d "${REPO_ROOT}/.git" ] && echo "  Branch: $(cd "${REPO_ROOT}" && git symbolic-ref --short HEAD 2>/dev/null || echo 'detached')"
echo ""

# --- CLI versions ---
echo "## CLI Versions"
for cli in codex copilot claude gh glab; do
  if command -v "$cli" >/dev/null 2>&1; then
    version="$("$cli" --version 2>/dev/null || "$cli" version 2>/dev/null || echo "version check unsupported")"
    loc="$(command -v "$cli")"
    echo "  [OK]  ${cli}: ${version} (${loc})"
  else
    echo "  [MISS] ${cli}: not installed"
  fi
done
echo ""

# --- Active symlinks ---
echo "## Active Symlinks"
found=0
for dir in "${HOME}/.codex" "${HOME}/.copilot" "${HOME}/.claude" "${HOME}/.agents" "${HOME}/.config/copilot"; do
  [ -L "$dir" ] && echo "  [LINK] ${dir} -> $(readlink "$dir")" && found=$((found + 1))
  [ -f "$dir" ] && echo "  [FILE] ${dir}" && found=$((found + 1))
  [ -d "$dir" ] && ! [ -L "$dir" ] && echo "  [DIR]  ${dir}" && found=$((found + 1))
  [ ! -e "$dir" ] && echo "  [--]   ${dir}: not present" && found=$((found + 1))
done
echo ""

# --- MCP readiness ---
echo "## MCP Readiness"
mcp_files=""
for p in "${HOME}/.codex/config.toml" "${REPO_ROOT}/.mcp.json" "${REPO_ROOT}/claude/.mcp.json"; do
  [ -f "$p" ] && mcp_files="${mcp_files}  [OK]  ${p}" && mcp_files="${mcp_files}\n"
done
if [ -n "$mcp_files" ]; then
  echo "  MCP configuration files found:"
  printf "%b" "$mcp_files"
else
  echo "  No MCP config files found (expected if not yet configured)"
fi
echo ""

# --- Shared personas ---
echo "## Shared Personas"
count=0
for f in "${REPO_ROOT}/shared/personas"/*.md; do
  [ -f "$f" ] && count=$((count + 1))
done
echo "  ${count} persona(s) in shared/personas/"
echo ""

# --- Generated targets ---
echo "## Generated Targets"
[ -d "${REPO_ROOT}/dist" ] && echo "  dist/ exists with $(find "${REPO_ROOT}/dist" -type f 2>/dev/null | wc -l) file(s)" || echo "  dist/ not present (run scripts/build.sh)"
echo ""

echo "=== Doctor Complete ==="
