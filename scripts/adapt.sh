#!/bin/sh
# adapt.sh — DEPRECATED: use python3 scripts/adapt.py instead.
#
# This wrapper delegates to the Python adapter. The shell-based extraction
# logic has been removed — all persona parsing now happens via YAML frontmatter
# in the Python adapter only.
#
# Usage (same as adapt.py):
#   ./scripts/adapt.sh [persona|--all] [--target copilot|agent|claude|codex|all]
#
# Examples:
#   ./scripts/adapt.sh                                # Generate all targets
#   ./scripts/adapt.sh --all                          # Same as above
#   ./scripts/adapt.sh dotnet-api-architect           # Single persona
#   ./scripts/adapt.sh --all --target copilot         # Copilot only
#   ./scripts/adapt.sh --dry-run --validate           # Validate only
#
# See ./scripts/adapt.py --help for full options.

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "  [INFO] adapt.sh is deprecated — delegating to python3 scripts/adapt.py" >&2

# Convert shell-style flags to adapt.py-compatible flags
PERSONA=""
TARGET=""
DRY_RUN=""
VALIDATE=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)       PERSONA="" ; shift ;;
    --target)    TARGET="--target $2"; shift 2 ;;
    --dry-run)   DRY_RUN="--dry-run"; shift ;;
    --validate)  VALIDATE="--validate"; shift ;;
    --help|-h)   python3 "${REPO_ROOT}/scripts/adapt.py" --help; exit 0 ;;
    -*)
       if [ -z "$PERSONA" ]; then
         PERSONA="--persona $1"; shift
       else
         echo "Unknown option: $1"; python3 "${REPO_ROOT}/scripts/adapt.py" --help; exit 1
       fi
       ;;
    *)
       [ -z "$PERSONA" ] && PERSONA="--persona $1" || { echo "Unexpected: $1"; exit 1; }
       shift
       ;;
  esac
done

exec python3 "${REPO_ROOT}/scripts/adapt.py" $PERSONA $TARGET $DRY_RUN $VALIDATE
