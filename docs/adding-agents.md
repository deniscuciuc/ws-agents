# Adding New Agents

## Workflow

New agents always start in `shared/personas/` and are then adapted for each tool.

### Step 1 — Write the shared persona

Create `shared/personas/<name>.md`:

```md
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

Keep it technology-scoped — no project-specific context.

### Step 2 — Create Copilot instruction file

Create `copilot/instructions/<name>.md` — condensed version of the persona:

- Remove extended explanations
- Keep rules as short imperative statements
- Keep code examples only if they're the clearest way to express the rule
- Aim for < 50 lines

### Step 3 — Update Codex AGENTS.md

Add a new section to `codex/AGENTS.md`:

```md
## <Domain> Analysis

### Stack Context
...

### Audit Checklist
- [ ] rule one
- [ ] rule two
```

Focus on what Codex will use for analysis and audit — checklist format works best.

### Step 4 — Create Claude agent (optional)

If the persona benefits from a focused Claude subagent, create `.claude/agents/<name>.md`:

```md
---
name: <agent-name>
description: <one-line description>
tools:
  - grep
  - view
  - edit
  - bash
---

You are a <role>. <Detailed instructions>.
```

### Step 5 — Create Copilot custom agent (optional)

If the persona works well as a named Copilot agent, create `.github/agents/<name>.agent.md`:

```md
---
name: <agent-name>
description: <one-line description>
---

You are a <role>. <Detailed instructions>.
```

### Step 6 — Create workflow file (optional)

For process-oriented personas, create `shared/workflows/<name>.md` describing the step-by-step workflow.

### Step 7 — Run verification

```bash
./scripts/build.sh          # regenerate combined files
./scripts/verify.sh --static # check for issues
```

---

## Naming Conventions

| Pattern | Example |
|---|---|
| `<tech>-<role>` | `dotnet-api-architect` |
| `<tech>-expert` | `postgresql-expert` |
| `<tech>-<action>er` | `dotnet-refactorer` |
| `<action>-writer` | `commit-writer` |

Use kebab-case, all lowercase.
