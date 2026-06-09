#!/bin/sh
# build.sh — Assemble target files from shared personas, workflows, and templates.
# Usage: ./scripts/build.sh [--target codex|copilot|claude|all]

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${REPO_ROOT}/dist"

usage() { echo "Usage: $0 [--target codex|copilot|claude|all]" && exit 1; }
TARGET="${1:-all}"; [ "$TARGET" = "--target" ] && TARGET="${2:-all}" && shift 2

# Ensure dist directory exists
mkdir -p "${DIST}"

build_codex() {
  echo "[build] Assembling Codex AGENTS.md..."
  mkdir -p "${DIST}/codex"
  cat > "${DIST}/codex/AGENTS.md" << 'HEADER'
# AGENTS.md

This file defines agent personas and analysis protocols for OpenAI Codex.
Primary use cases: **code analysis, architecture audit, and quality review**.

HEADER

  # Append each persona as a checklist section
  for f in "${REPO_ROOT}/shared/personas"/*.md; do
    name="$(basename "$f" .md)"
    echo "" >> "${DIST}/codex/AGENTS.md"
    echo "## ${name}" >> "${DIST}/codex/AGENTS.md"
    echo "" >> "${DIST}/codex/AGENTS.md"
    # Extract rules/checklists as bullet points
    sed -n '/^## Rules/,/^$/p' "$f" | grep '^- ' >> "${DIST}/codex/AGENTS.md" 2>/dev/null || true
    sed -n '/^## Principles/,/^$/p' "$f" | grep '^- ' >> "${DIST}/codex/AGENTS.md" 2>/dev/null || true
  done
  echo "[build] Codex AGENTS.md written to ${DIST}/codex/AGENTS.md"
}

build_copilot() {
  echo "[build] Assembling Copilot instructions..."
  mkdir -p "${DIST}/copilot"
  output="${DIST}/copilot/copilot-instructions.md"
  > "$output"
  for f in "${REPO_ROOT}/shared/personas"/*.md; do
    name="$(basename "$f" .md)"
    echo "# ${name}" >> "$output"
    echo "" >> "$output"
    cat "$f" >> "$output"
    echo -e "\n---\n" >> "$output"
  done
  echo "[build] Copilot instructions written to ${output}"
}

build_claude() {
  echo "[build] Assembling Claude CLAUDE.md..."
  mkdir -p "${DIST}/claude"
  output="${DIST}/claude/CLAUDE.md"
  > "$output"
  for f in "${REPO_ROOT}/shared/personas"/*.md; do
    name="$(basename "$f" .md | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')"
    echo "## ${name}" >> "$output"
    echo "" >> "$output"
    cat "$f" >> "$output"
    echo -e "\n---\n" >> "$output"
  done
  echo "[build] Claude CLAUDE.md written to ${output}"
}

case "${TARGET}" in
  all)      build_codex; build_copilot; build_claude ;;
  codex)    build_codex ;;
  copilot)  build_copilot ;;
  claude)   build_claude ;;
  *)        usage ;;
esac

echo "[build] Done."
