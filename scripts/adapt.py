#!/usr/bin/env python3
"""
ws-agents adapter: converts shared/personas/*.md YAML frontmatter + body
into Copilot instructions, Copilot .agent.md, Claude agents, Codex sections,
and Claude CLAUDE.md sections.

The YAML frontmatter provides metadata; the full body is the prompt content.

Usage:
  ./scripts/adapt.py                              # Generate all targets
  ./scripts/adapt.py --persona commit-writer      # Single persona
  ./scripts/adapt.py --validate                   # Validate all outputs
  ./scripts/adapt.py --dry-run                    # Preview without writing
  ./scripts/adapt.py --target copilot             # Only Copilot instructions
"""

import argparse
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Error: PyYAML is required. Install with: pip install pyyaml")
    sys.exit(1)

REPO_ROOT = Path(__file__).resolve().parent.parent
PERSONAS_DIR = REPO_ROOT / "shared" / "personas"
COPILOT_INSTR_DIR = REPO_ROOT / "copilot" / "instructions"
GITHUB_AGENTS_DIR = REPO_ROOT / ".github" / "agents"
CLAUDE_AGENTS_DIR = REPO_ROOT / ".claude" / "agents"
CODEX_FILE = REPO_ROOT / "codex" / "AGENTS.md"
CLAUDE_FILE = REPO_ROOT / "claude" / "CLAUDE.md"

# Required YAML fields for every persona
REQUIRED_FIELDS = ["name", "role", "description", "stack", "rules", "avoid", "checklist", "tools"]

# Alias mapping: legacy agent_type names -> canonical persona names
ALIAS_MAP = {
    "clean-architecture-modernizer": "dotnet-clean-architecture-modernizer",
    "dotnet-integration-testing": "dotnet-api-integration-test-architect",
    "observability-engineer": "dotnet-observability-engineer",
    "performance-auditor": "dotnet-backend-performance-auditor",
    "security-auditor": "dotnet-api-security-auditor",
    "frontend-reviewer": "code-reviewer",
}

EXPECTED_CANONICAL = {
    "ai-platform-operator", "analytics-integrator", "bi-analytics-architect",
    "code-reviewer", "commit-writer", "cross-stack-incident-debugger",
    "distributed-debugger", "docker-compose-expert", "dotnet-api-architect",
    "dotnet-api-implementor", "dotnet-api-integration-test-architect",
    "dotnet-api-security-auditor", "dotnet-backend-performance-auditor",
    "dotnet-clean-architecture-modernizer", "dotnet-observability-engineer",
    "dotnet-refactorer", "etl-pipeline-engineer", "fastapi-service-architect",
    "figma-to-code-designer", "frontend-architect", "frontend-coverage-gap-analyst",
    "frontend-integration-test-architect", "frontend-performance-auditor",
    "frontend-security-reviewer", "github-cli-operator", "gitlab-cicd",
    "gitlab-cli-operator", "grafana-ops-architect", "infrastructure-operator",
    "mcp-tools-operator", "opensource-maintainer", "postgresql-expert",
    "python-api-integration-test-architect", "python-api-security-auditor",
    "python-backend-performance-auditor", "python-clean-architecture-modernizer",
    "python-data-engineer", "python-database-optimizer", "python-refactorer",
    "react-developer", "release-notes-writer", "web-scraper-architect",
}


class Persona:
    """Parsed persona from a markdown file with YAML frontmatter + body."""

    def __init__(self, path: Path):
        self.path = path
        self.name = path.stem
        self.yaml: dict = {}
        self.body_md: str = ""
        self._parse()

    def _parse(self):
        raw = self.path.read_text(encoding="utf-8")
        m = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)", raw, re.DOTALL)
        if m:
            try:
                self.yaml = yaml.safe_load(m.group(1)) or {}
            except yaml.YAMLError as e:
                print(f"  [WARN] YAML parse error in {self.path.name}: {e}")
                self.yaml = {}
            self.body_md = m.group(2).strip()
        else:
            print(f"  [WARN] {self.path.name}: No YAML frontmatter found")
            self.body_md = raw.strip()
            self.yaml = {}

    def get(self, key: str, default=None):
        return self.yaml.get(key, default)

    def get_list(self, key: str) -> list:
        val = self.yaml.get(key, [])
        return val if isinstance(val, list) else []

    @property
    def role(self) -> str:
        return str(self.get("role", ""))

    @property
    def description(self) -> str:
        return str(self.get("description", self.role))

    @property
    def stack(self) -> list:
        return self.get_list("stack")

    @property
    def rules(self) -> list:
        return self.get_list("rules")

    @property
    def avoid(self) -> list:
        return self.get_list("avoid")

    @property
    def checklist(self) -> list:
        return self.get_list("checklist")

    @property
    def tools(self) -> str:
        val = self.get("tools", "")
        if isinstance(val, str):
            return val
        if isinstance(val, list):
            return str(val)
        return "[read, search, edit]"

    def role_fixed(self) -> str:
        """Properly conjugated role string, trailing period stripped."""
        r = self.role.rstrip(".")
        verb_map = {
            "Writes": "write", "Designs": "design", "Develops": "develop",
            "Creates": "create", "Manages": "manage", "Focuses": "focus",
            "Specializes": "specialize", "Reviews": "review", "Refactors": "refactor",
            "Converts": "convert", "Owns": "own", "Monitors": "monitor",
            "Adds": "add", "Gathers": "gather",
        }
        for verb, fixed in verb_map.items():
            if r.startswith(verb):
                return f"You {fixed}{r[len(verb):]}"
        return f"You are a {r}" if r else ""


def generate_copilot_instruction(persona: Persona) -> str:
    """Copilot instruction file — complete role + stack + rules + checklist."""
    lines = [f"# {persona.name}", ""]
    role = persona.role_fixed()
    if persona.stack:
        lines.append(f"{role}. Stack: {'; '.join(persona.stack)}.")
    else:
        lines.append(f"{role}.")
    lines.append("")
    if persona.rules:
        lines.append("## Rules")
        lines.extend(f"- {r}" for r in persona.rules)
    if persona.checklist:
        lines.append("## Checklist")
        lines.extend(f"- [ ] {c}" for c in persona.checklist)
    if persona.avoid:
        lines.append("## What to Avoid")
        lines.extend(f"- {a}" for a in persona.avoid)
    return "\n".join(lines) + "\n"


def generate_agent_md(persona: Persona) -> str:
    """
    Copilot custom agent profile with YAML frontmatter + full body.
    The body IS the full prompt — YAML provides structured metadata.
    """
    tools_str = persona.tools
    lines = [
        "---",
        f"name: {persona.name}",
        f'description: "{persona.description}"',
        f"tools: {tools_str}",
        "---",
        "",
    ]
    lines.append(persona.body_md)
    return "\n".join(lines) + "\n"


def generate_claude_agent(persona: Persona) -> str:
    """
    Claude agent profile with YAML frontmatter + full body.
    The body IS the full prompt — YAML provides structured metadata.
    """
    lines = [
        "---",
        f"name: {persona.name}",
        f'description: "{persona.description}"',
        "tools:",
        "  - grep",
        "  - view",
        "  - edit",
        "  - bash",
        "---",
        "",
    ]
    lines.append(persona.body_md)
    return "\n".join(lines) + "\n"


def generate_codex_section(persona: Persona) -> str:
    """Codex AGENTS.md section from YAML fields (aggregated)."""
    lines = ["", f"## {persona.name} Analysis", ""]
    if persona.stack:
        lines.append("### Stack Context")
        lines.extend(f"- {s}" for s in persona.stack)
        lines.append("")
    if persona.checklist:
        lines.append("### Audit Checklist")
        lines.extend(f"- [ ] {c}" for c in persona.checklist)
    elif persona.rules:
        lines.append("### Rules")
        lines.extend(f"- {r}" for r in persona.rules)
    else:
        lines.append("### Audit Checklist")
        lines.append("- (no checklist defined)")
    return "\n".join(lines) + "\n"


def generate_claude_section(persona: Persona) -> str:
    """Claude CLAUDE.md section from YAML fields (aggregated)."""
    lines = ["", f"## {persona.name}", ""]
    if persona.stack:
        lines.append("### Stack Context")
        lines.extend(f"- {s}" for s in persona.stack)
        lines.append("")
    if persona.rules:
        lines.append("### Principles")
        lines.extend(f"- {r}" for r in persona.rules)
    elif persona.checklist:
        lines.append("### Checklist")
        lines.extend(f"- [ ] {c}" for c in persona.checklist)
    return "\n".join(lines) + "\n"


def write_file(path: Path, content: str, dry_run: bool):
    """Write content to file, creating parent directories if needed."""
    path.parent.mkdir(parents=True, exist_ok=True)
    if dry_run:
        print(f"  [DRY] Would write {path}")
    else:
        path.write_text(content, encoding="utf-8")
        print(f"  [OK]  {path}")


def remove_section(content: str, heading: str) -> str:
    """Remove a section starting with ## heading from content."""
    pattern = re.compile(
        rf"^## {re.escape(heading)}\n.*?(?=^## |\Z)",
        re.MULTILINE | re.DOTALL,
    )
    return pattern.sub("", content).strip()


def get_persona_paths(persona_arg: str | None) -> list[Path]:
    """Get list of persona file paths to process."""
    if persona_arg:
        canonical = ALIAS_MAP.get(persona_arg, persona_arg)
        path = PERSONAS_DIR / f"{canonical}.md"
        if not path.exists():
            print(f"Error: persona '{persona_arg}' (canonical: '{canonical}') not found")
            sys.exit(1)
        return [path]
    return sorted(PERSONAS_DIR.glob("*.md"))


def resolve_personas(persona_arg: str | None) -> list[Persona]:
    """Get personas for generation."""
    paths = get_persona_paths(persona_arg)
    return [Persona(p) for p in paths]


def has_escaped_block(path: Path) -> bool:
    """Check if file still contains escaped YAML blocks."""
    raw = path.read_text(encoding="utf-8")
    m = re.match(r"^---\s*\n.*?\n---\s*\n(.*)", raw, re.DOTALL)
    if m:
        body = m.group(1)
        if re.search(r"---\\nname:", body):
            return True
    return False


def run_validate(personas: list[Persona]):
    """Validate all personas and generated outputs."""
    print(f"{'Persona':<40} {'Role':<55} {'Stack':>5} {'Rules':>5} {'Avoid':>5} {'Chklist':>7}  Issues")
    print("-" * 130)

    persona_names = set(p.name for p in personas)
    all_valid = True

    for persona in personas:
        has_esc = has_escaped_block(persona.path)
        if has_esc:
            all_valid = False
            print(f"\u274c {persona.name:<37} {'<escaped block>':<55} {'':>5} {'':>5} {'':>5} {'':>7}  ESCAPED YAML BLOCK")
            continue

        issues = []
        for field in REQUIRED_FIELDS:
            if field not in persona.yaml or persona.yaml.get(field) is None:
                issues.append(f"MISSING {field}")

        role_preview = persona.role[:60] if persona.role else ""
        status = "\u2705" if not issues else "\u274c"
        if issues:
            all_valid = False
        issues_str = ", ".join(issues) if issues else "ok"
        print(f"{status} {persona.name:<37} {role_preview:<55} {len(persona.stack):>5} "
              f"{len(persona.rules):>5} {len(persona.avoid):>5} {len(persona.checklist):>7}  {issues_str}")

    missing_canonical = EXPECTED_CANONICAL - persona_names
    if missing_canonical:
        all_valid = False
        print(f"\n  MISSING canonical personas: {', '.join(sorted(missing_canonical))}")

    print(f"\n--- Alias Agent Files ({len(ALIAS_MAP)}) ---")
    for alias, canonical in sorted(ALIAS_MAP.items()):
        agent_file = GITHUB_AGENTS_DIR / f"{alias}.agent.md"
        claude_file = CLAUDE_AGENTS_DIR / f"{alias}.md"
        copilot_file = COPILOT_INSTR_DIR / f"{alias}.md"
        agent_ok = agent_file.exists()
        claude_ok = claude_file.exists()
        copilot_ok = copilot_file.exists()
        status = "\u2705" if (agent_ok and claude_ok and copilot_ok) else "\u274c"
        print(f"  {status} {alias} \u2192 {canonical}  "
              f"(.agent: {'OK' if agent_ok else 'MISSING'}, "
              f".claude: {'OK' if claude_ok else 'MISSING'}, "
              f"copilot: {'OK' if copilot_ok else 'MISSING'})")

    total = len(personas)
    valid_count = sum(1 for p in personas if not has_escaped_block(p.path))
    print(f"\n{valid_count}/{total} personas valid  ({total - valid_count} with issues)")
    print(f"All canonical personas present: {'\u2705' if not missing_canonical else '\u274c'}")
    print(f"Alias files all present: {'\u2705' if all(
        (GITHUB_AGENTS_DIR / f'{a}.agent.md').exists() and
        (CLAUDE_AGENTS_DIR / f'{a}.md').exists() and
        (COPILOT_INSTR_DIR / f'{a}.md').exists()
        for a in ALIAS_MAP
    ) else '\u274c'}")

    # Check body content completeness in samples
    print(f"\n--- Body Content Spot Check ---")
    samples = ["ai-platform-operator", "distributed-debugger", "infrastructure-operator", "code-reviewer"]
    for name in samples:
        path = PERSONAS_DIR / f"{name}.md"
        if not path.exists():
            continue
        persona = Persona(path)
        body_len = len(persona.body_md)
        agent_path = GITHUB_AGENTS_DIR / f"{name}.agent.md"
        if agent_path.exists():
            agent_content = agent_path.read_text(encoding="utf-8")
            # Check agent file contains key body sections
            body_sections = re.findall(r"^## .+$", persona.body_md, re.MULTILINE)
            present = sum(1 for s in body_sections if s in agent_content)
            print(f"  {'\u2705' if present == len(body_sections) else '\u274c'} {name}: "
                  f"{present}/{len(body_sections)} body sections in agent output"
                  f"  (body: {body_len} chars)")

    return all_valid


def generate_all(personas: list[Persona], target: str, dry_run: bool):
    """Generate all target outputs for the given personas."""
    for persona in personas:
        name = persona.name
        print(f"--- {name} ---")

        output_names = [name]
        for alias, canonical in ALIAS_MAP.items():
            if canonical == name:
                output_names.append(alias)

        for output_name in output_names:
            if target in ("copilot", "all"):
                write_file(
                    COPILOT_INSTR_DIR / f"{output_name}.md",
                    generate_copilot_instruction(persona),
                    dry_run,
                )

            if target in ("agent", "all"):
                write_file(
                    GITHUB_AGENTS_DIR / f"{output_name}.agent.md",
                    generate_agent_md(persona),
                    dry_run,
                )

            if target in ("claude", "all"):
                write_file(
                    CLAUDE_AGENTS_DIR / f"{output_name}.md",
                    generate_claude_agent(persona),
                    dry_run,
                )

        if target in ("codex", "all"):
            section = generate_codex_section(persona)
            section_mark = f"{persona.name} Analysis"
            _update_aggregate_file(CODEX_FILE, section_mark, section, dry_run)

        if target in ("claude", "all"):
            section = generate_claude_section(persona)
            section_mark = persona.name
            _update_aggregate_file(CLAUDE_FILE, section_mark, section, dry_run)


def _update_aggregate_file(path: Path, section_mark: str, section: str, dry_run: bool):
    """Append section to aggregated file, replacing existing content for that section."""
    if dry_run:
        print(f"  [DRY] Would update {path} [section: {section_mark}]")
        return

    if path.exists():
        content = path.read_text(encoding="utf-8")
        content = remove_section(content, section_mark)
        content += "\n" + section
    else:
        content = section

    path.write_text(content, encoding="utf-8")
    print(f"  [OK]  Updated {path} [section: {section_mark}]")


def main():
    parser = argparse.ArgumentParser(description="Adapt personas to tool targets")
    parser.add_argument("--persona", "-p", help="Process a single persona (name or alias)")
    parser.add_argument(
        "--target", "-t",
        choices=["copilot", "agent", "claude", "codex", "all"],
        default="all",
        help="Target format",
    )
    parser.add_argument("--dry-run", "-n", action="store_true", help="Preview only")
    parser.add_argument("--validate", "-v", action="store_true", help="Validate personas and outputs")
    args = parser.parse_args()

    if args.validate:
        paths = sorted(PERSONAS_DIR.glob("*.md"))
        personas = [Persona(p) for p in paths]
        valid = run_validate(personas)
        sys.exit(0 if valid else 1)

    personas = resolve_personas(args.persona)
    generate_all(personas, args.target, args.dry_run)
    print("\nDone.")


if __name__ == "__main__":
    main()
