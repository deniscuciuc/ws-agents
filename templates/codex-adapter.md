# Template: Codex Adapter

## Purpose
Adapter for converting shared personas into Codex AGENTS.md format.

## Conversion Rules
- Persona title → Codex section heading `## <Persona Name>`
- "Core Stack" section → `### Stack Context` (as inline text)
- "Principles / Rules" section → audit checklists
- "What to Avoid" → appended after checklist
- "Focus Areas" (if present) → inline text under heading
- All bullet items become checklist items: `[ ]`
- Skip code examples unless they express a rule better than text
- Keep analysis patterns as-is for structured output formats

## Output Structure
```markdown
## <Domain> Analysis

### Stack Context
...

### Audit Checklist
- [ ] rule one
- [ ] rule two

### <Additional Section>
...
```

## Example
Source (`shared/personas/postgresql-expert.md`):
```
## Core Stack
PostgreSQL 15+
```

Result (`codex/AGENTS.md`):
```
## PostgreSQL Analysis

### Stack Context
PostgreSQL 15+

### Audit Checklist
- [ ] No SELECT * in production queries
...
```
