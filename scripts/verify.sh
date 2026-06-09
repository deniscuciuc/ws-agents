#!/bin/sh
# verify.sh — Static validation and CLI smoke tests for ws-agents configuration.
# Usage: ./scripts/verify.sh [--static] [--smoke] [--all]

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

PYTHON_AVAILABLE=false
command -v python3 >/dev/null 2>&1 && PYTHON_AVAILABLE=true

static_checks() {
  errors=0
  echo "=== Static Validation ==="

  # Check all symlink targets in generated files exist
  if [ -d "${REPO_ROOT}/dist" ]; then
    echo "[verify] Checking dist/ symlink targets..."
    find "${REPO_ROOT}/dist" -type l | while read -r link; do
      if [ ! -e "$(readlink "$link")" ]; then
        echo "  [FAIL] Broken symlink: ${link}"
        errors=$((errors + 1))
      fi
    done
  fi

  # Check shared/personas exist
  echo "[verify] Checking shared personas..."
  persona_count=0
  for f in "${REPO_ROOT}/shared/personas"/*.md; do
    [ -f "$f" ] || { echo "  [FAIL] Missing persona file: ${f}"; errors=$((errors + 1)); continue; }
    persona_count=$((persona_count + 1))
    # Check persona has YAML frontmatter
    head -1 "$f" | grep -q "^---" || { echo "  [FAIL] No YAML frontmatter in ${f}"; errors=$((errors + 1)); }
    # Check persona has required sections
    grep -q "^#" "$f" || { echo "  [FAIL] No title in ${f}"; errors=$((errors + 1)); }
    # Check no escaped YAML blocks (literal \n in body)
    if python3 -c "
import re,sys
raw = open('$f').read()
m = re.match(r'^---\s*\n.*?\n---\s*\n(.*)', raw, re.DOTALL)
if m and re.search(r'---\\\\nname:', m.group(1)):
    sys.exit(1)
" 2>/dev/null; then
      :  # ok
    else
      echo "  [FAIL] Escaped YAML block in ${f}"
      errors=$((errors + 1))
    fi
  done
  echo "  [OK]  ${persona_count} persona files found"
  [ "$persona_count" -eq 42 ] || { echo "  [FAIL] Expected 42 personas, found ${persona_count}"; errors=$((errors + 1)); }

  # Check shared/workflows exist
  if [ -d "${REPO_ROOT}/shared/workflows" ]; then
    echo "[verify] Checking shared workflows..."
    for f in "${REPO_ROOT}/shared/workflows"/*.md; do
      [ -f "$f" ] || continue
      grep -q "^#" "$f" || { echo "  [FAIL] No title in ${f}"; errors=$((errors + 1)); }
    done
  fi

  # Check templates exist
  if [ -d "${REPO_ROOT}/templates" ]; then
    echo "[verify] Checking templates..."
    for f in "${REPO_ROOT}/templates"/*.md; do
      [ -f "$f" ] || continue
      grep -q "^#" "$f" || { echo "  [FAIL] No title in ${f}"; errors=$((errors + 1)); }
    done
  fi

  # Check copilot agent files have valid frontmatter
  agent_dir="${REPO_ROOT}/.github/agents"
  if [ -d "$agent_dir" ]; then
    agent_count=0
    for f in "$agent_dir"/*.agent.md; do
      [ -f "$f" ] || continue
      agent_count=$((agent_count + 1))
      head -1 "$f" | grep -q "^---" || { echo "  [FAIL] Missing frontmatter in ${f}"; errors=$((errors + 1)); }
    done
    echo "  [OK]  ${agent_count} agent files in .github/agents"
    # Expect 42 canonical + 6 aliases = 48 total
    [ "$agent_count" -eq 48 ] || { echo "  [WARN] Expected 48 agent files (42 canonical + 6 aliases), found ${agent_count}"; }
  fi

  # Check copilot instructions exist
  instr_dir="${REPO_ROOT}/copilot/instructions"
  if [ -d "$instr_dir" ]; then
    instr_count=0
    for f in "$instr_dir"/*.md; do
      [ -f "$f" ] || continue
      instr_count=$((instr_count + 1))
    done
    echo "  [OK]  ${instr_count} instruction files in copilot/instructions"
    [ "$instr_count" -eq 48 ] || { echo "  [WARN] Expected 48 instruction files (42 canonical + 6 aliases), found ${instr_count}"; }
  fi

  # Check claude agent files exist
  claude_dir="${REPO_ROOT}/.claude/agents"
  if [ -d "$claude_dir" ]; then
    claude_count=0
    for f in "$claude_dir"/*.md; do
      [ -f "$f" ] || continue
      claude_count=$((claude_count + 1))
    done
    echo "  [OK]  ${claude_count} agent files in .claude/agents"
    # There may be extra hand-authored agents, so just warn
    [ "$claude_count" -ge 48 ] || { echo "  [WARN] Expected at least 48 agent files in .claude/agents, found ${claude_count}"; }
  fi

  # Check aggregate files exist and have content
  for agg_file in codex/AGENTS.md claude/CLAUDE.md .github/copilot-instructions.md copilot/copilot-instructions.md; do
    full="${REPO_ROOT}/${agg_file}"
    if [ -f "$full" ]; then
      size=$(wc -c < "$full")
      echo "  [OK]  ${agg_file} (${size} bytes)"
    else
      echo "  [FAIL] Missing ${agg_file}"
      errors=$((errors + 1))
    fi
  done

  # Check script files are valid POSIX shell
  for f in "${REPO_ROOT}/scripts"/*.sh; do
    [ -f "$f" ] || continue
    sh -n "$f" 2>/dev/null || { echo "  [FAIL] Shell syntax error in ${f}"; errors=$((errors + 1)); }
  done

  # Python-based validation via adapt.py
  if $PYTHON_AVAILABLE; then
    echo ""
    echo "[verify] Running Python persona validation..."
    if python3 "${REPO_ROOT}/scripts/adapt.py" --validate; then
      echo "  [OK]  Python validation passed"
    else
      echo "  [FAIL] Python validation failed"
      errors=$((errors + 1))
    fi
  fi

  [ "$errors" -eq 0 ] && echo "[verify] All static checks passed." || echo "[verify] ${errors} error(s) found."
  return "$errors"
}

smoke_checks() {
  errors=0
  echo "=== CLI Smoke Tests ==="

  # Check for installed CLIs (optional — report, don't fail)
  for cli in codex copilot claude gh glab; do
    if command -v "$cli" >/dev/null 2>&1; then
      version="$("$cli" --version 2>/dev/null || "$cli" version 2>/dev/null || echo "version check unsupported")"
      echo "  [OK] ${cli}: ${version}"
    else
      echo "  [INFO] ${cli} not installed (optional)"
    fi
  done

  # Verify repo structure
  echo "[verify] Checking repo structure..."
  for dir in shared/personas scripts docs; do
    [ -d "${REPO_ROOT}/${dir}" ] || { echo "  [FAIL] Missing directory: ${dir}"; errors=$((errors + 1)); }
  done
  [ -f "${REPO_ROOT}/README.md" ] || { echo "  [FAIL] Missing README.md"; errors=$((errors + 1)); }

  [ "$errors" -eq 0 ] && echo "[verify] All smoke checks passed." || echo "[verify] ${errors} error(s) found."
  return "$errors"
}

# Main
mode="${1:---all}"
case "$mode" in
  --static) static_checks ;;
  --smoke)  smoke_checks ;;
  --all|*)  static_checks && smoke_checks ;;
esac
