# Template: Claude Adapter

## Purpose
Adapter for converting shared personas into Claude Code format (CLAUDE.md, .claude/agents/*.md, .claude/skills/*/SKILL.md).

## Conversion Rules

### For CLAUDE.md (global memory)
- Append persona content under `## <Persona Name>` headings
- Keep the persona's tone for Claude's conversational context
- Preserve code examples — Claude benefits from patterns
- Keep audit checklists as-is
- Combine all active personas in one file

### For .claude/agents/<name>.md
- Add YAML frontmatter with agent metadata
- Role and rules from persona → agent body
- Include tool lists for agent access permissions

### For .claude/skills/<name>/SKILL.md
- Simplified step-based workflow
- No frontmatter — pure process instructions
- One-shot workflows that complete without iteration

## Agent Frontmatter
```yaml
---
name: <agent-name>
description: <one-line description>
tools:
  - <tool-name>
---
```
