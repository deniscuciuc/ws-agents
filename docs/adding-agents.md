# Adding New Agents

## Workflow

New agents always start in `shared/personas/` and are then adapted for each tool via `scripts/adapt.py`.

### Step 1 — Write the shared persona

Create `shared/personas/<name>.md` with YAML frontmatter:

```md
---
name: <name>
role: <present-tense role description>
description: <one-line description>
stack:
  - <tech1>
  - <tech2>
rules:
  - <rule one>
  - <rule two>
avoid:
  - <anti-pattern>
checklist:
  - <checklist item>
tools: '[read, search, edit, bash]'
---

# Persona: <Name>

## Role
One sentence describing what this agent does.

## Core Stack
Technologies and versions.

## Principles / Rules
Bulleted or sectioned rules the agent follows.

## Patterns (optional)
Code examples showing preferred implementation.

## What to Avoid
Anti-patterns specific to this domain.
```

Keep it technology-scoped — no project-specific context. The YAML frontmatter is **required** — `adapt.py` uses it to generate tool-specific files.

### Step 2 — Generate all tool targets

```bash
./scripts/adapt.py --persona <name> --target all
```

This generates:
- `copilot/instructions/<name>.md` — Copilot instruction file
- `.github/agents/<name>.agent.md` — Copilot custom agent
- `.claude/agents/<name>.md` — Claude subagent
- Updates `codex/AGENTS.md` — adds analysis checklist section
- Updates `claude/CLAUDE.md` — adds persona section

### Step 3 — Create workflow file (optional)

For process-oriented personas, create `shared/workflows/<name>.md` describing the step-by-step workflow.

### Step 4 — Handle aliases (optional)

If the persona should also be accessible under a legacy name, add an alias entry to the `ALIAS_MAP` dict in `scripts/adapt.py`.

### Step 5 — Run verification

```bash
./scripts/adapt.py --validate   # validate all personas and generated outputs
./scripts/build.sh              # regenerate combined files
./scripts/verify.sh --static    # check for issues
```

---

## Naming Conventions

| Pattern | Example |
|---------|---------|
| `<tech>-<role>` | `dotnet-api-architect` |
| `<tech>-expert` | `postgresql-expert` |
| `<tech>-<action>er` | `dotnet-refactorer` |
| `<action>-writer` | `commit-writer` |

Use kebab-case, all lowercase.

---

## Required YAML Fields

| Field | Description |
|-------|-------------|
| `name` | Kebab-case identifier matching the filename |
| `role` | Present-tense role description |
| `description` | One-line summary for agent metadata |
| `stack` | List of technologies and tools |
| `rules` | List of behavioral rules |
| `avoid` | List of anti-patterns to avoid |
| `checklist` | List of verification items |
| `tools` | Tool permission string, e.g. `'[read, search, edit, bash]'` |
