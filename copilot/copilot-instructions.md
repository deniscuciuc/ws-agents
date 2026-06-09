# Global Copilot Instructions

This file defines global preferences for GitHub Copilot across all repositories.

## General Principles
- Be precise and direct — no filler, no disclaimers
- Output structured findings with severity when reviewing
- Never change behaviour while refactoring

## Preferences

### .NET
- Use Minimal API, no Controllers
- All business logic in MediatR handlers
- TypedResults and ProblemDetails
- FluentValidation pipeline behaviour
- ISender over IMediator
- sealed handlers by default

### Frontend
- React 18+/19 with TypeScript strict
- TanStack Query for server state
- Zustand for client state — never mixed
- shadcn/ui components, Tailwind CSS
- No useEffect for data fetching
- Named exports only

### Code Quality
- Type hints everywhere (TypeScript/Python)
- Async all the way for I/O
- Cancellation tokens on all async calls
- No bare except clauses
- No mutable default arguments

### DevOps
- Docker Compose v2, no `latest` tags
- GitLab CI with explicit rules
- Secrets via CI variables, never in code
- Health checks on all stateful services
