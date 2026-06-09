# Template: Copilot Adapter

## Purpose
Adapter for converting shared personas into Copilot instruction files (.github/copilot-instructions.md or copilot/instructions/*.md).

## Conversion Rules
- Start with a one-line role statement: `You are a <role>.`
- Remove extended explanations — keep only rules and patterns
- Rules as short imperative statements
- Code examples only when they express a pattern better than text
- Target < 50 lines per instruction file
- Combine multiple persona snippets by stacking with `---` separators

## Output Structure
```markdown
# <Role Name>

You are a <one-line description>.

## Rules
- Rule one
- Rule two

## Patterns
<code examples if needed>

## Avoid
- Anti-pattern one
- Anti-pattern two
```

## Example
Source (`shared/personas/dotnet-api-architect.md`):
```
# Persona: .NET API Architect
## Role
Senior .NET architect specialising in ASP.NET Core Minimal APIs.
...
```

Result (`copilot/instructions/dotnet-api-architect.md`):
```markdown
# .NET API Architect

You are a senior .NET architect specialising in ASP.NET Core Minimal APIs.

## Rules
- Use Minimal API only — no Controllers
- All business logic goes into MediatR handlers
- Use TypedResults for all responses
...
```
