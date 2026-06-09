# ws-agents

[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![CI](https://github.com/deniscuciuc/ws-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/deniscuciuc/ws-agents/actions/workflows/ci.yml)

Portable, open personal agents configuration — one repo to configure **Codex**, **GitHub Copilot**, and **Claude Code** globally on any machine.

```bash
# One-shot install on a new machine
git clone git@github.com:deniscuciuc/ws-agents.git ~/repos/ws-agents
cd ~/repos/ws-agents
./scripts/apply-global.sh
```

---

## What's Inside

- **42+ agent personas** in `shared/personas/` — source-of-truth agent definitions covering .NET, Python, frontend, DevOps, security, data, AI, and more
- **6 reusable workflows** in `shared/workflows/` — process prompts for common tasks (code review, PR summary, commit writing, OSS modernization, CLI usage, MCP triage)
- **Per-tool adapters** in `templates/` — conversion rules for Codex, Copilot, and Claude formats
- **Codex config** — `codex/AGENTS.md` with analysis checklists, `.agents/skills/` for repeatable skills, `.codex/config.toml.example` for MCP
- **Copilot config** — `copilot/instructions/*.md` (42 per-persona files), `copilot/copilot-instructions.md` (combined global), `.github/agents/*.agent.md` (48 custom agents)
- **Claude Code config** — `claude/CLAUDE.md` (global memory), `.claude/agents/*.md` (48 subagents), `.claude/skills/*/SKILL.md` (skills), `claude/.mcp.json` (MCP servers)
- **POSIX shell scripts** — install, build, verify, doctor, adapt
- **CI/CD** — GitHub Actions CI (shell lint, markdown validation, build/verify), Dependabot for Actions

---

## Quick Start

```bash
# 1. Clone to a fixed location
git clone git@github.com:deniscuciuc/ws-agents.git ~/repos/ws-agents
cd ~/repos/ws-agents

# 2. Dry run to preview what would happen
./scripts/apply-global.sh --dry-run

# 3. Install globally (symlinks, with backups of existing files)
./scripts/apply-global.sh --force

# 4. Verify installation
./scripts/doctor.sh
```

The installer detects which CLIs you have installed (`codex`, `copilot`, `claude`) and sets up only those tools. Use `--only codex,copilot,claude` to limit.

### Install Options

| Flag | Purpose |
|------|---------|
| `--dry-run` | Show what would be done |
| `--force` | Overwrite existing files (backups created) |
| `--copy` | Copy instead of symlink |
| `--only codex,copilot,claude` | Limit to specific tools |
| `--verify` | Run doctor after install |
| `--no-mcp` | Skip MCP configuration |

---

## Personas

### Existing (pre-bootstrap)

| Persona | File |
|---------|------|
| Commit Writer | `shared/personas/commit-writer.md` |
| Docker Compose Expert | `shared/personas/docker-compose-expert.md` |
| .NET API Architect | `shared/personas/dotnet-api-architect.md` |
| .NET API Implementor | `shared/personas/dotnet-api-implementor.md` |
| .NET Refactorer | `shared/personas/dotnet-refactorer.md` |
| GitLab CI/CD Engineer | `shared/personas/gitlab-cicd.md` |
| PostgreSQL Expert | `shared/personas/postgresql-expert.md` |
| Python Data Engineer | `shared/personas/python-data-engineer.md` |
| React Developer | `shared/personas/react-developer.md` |

### Added — Phase 1 (Review, OSS, MCP, CLI, Debug)

| Persona | File |
|---------|------|
| Code Reviewer | `shared/personas/code-reviewer.md` |
| Open-Source Maintainer | `shared/personas/opensource-maintainer.md` |
| MCP Tools Operator | `shared/personas/mcp-tools-operator.md` |
| GitHub CLI Operator | `shared/personas/github-cli-operator.md` |
| GitLab CLI Operator | `shared/personas/gitlab-cli-operator.md` |
| Frontend Architect | `shared/personas/frontend-architect.md` |
| .NET API Security Auditor | `shared/personas/dotnet-api-security-auditor.md` |
| .NET Integration Test Architect | `shared/personas/dotnet-api-integration-test-architect.md` |
| .NET Backend Performance Auditor | `shared/personas/dotnet-backend-performance-auditor.md` |
| Distributed Debugger | `shared/personas/distributed-debugger.md` |
| Release Notes Writer | `shared/personas/release-notes-writer.md` |

### Added — Phase 2 (Observability, Modernizer, Scraper, Analytics)

| Persona | File |
|---------|------|
| .NET Observability Engineer | `shared/personas/dotnet-observability-engineer.md` |
| .NET Clean Architecture Modernizer | `shared/personas/dotnet-clean-architecture-modernizer.md` |
| Web Scraper Architect | `shared/personas/web-scraper-architect.md` |
| Analytics Integrator | `shared/personas/analytics-integrator.md` |
| Figma to Code Designer | `shared/personas/figma-to-code-designer.md` |

### Added — Phase 3 (DevOps, Platform, Database, ETL)

| Persona | File |
|---------|------|
| Python Database Optimizer | `shared/personas/python-database-optimizer.md` |
| ETL Pipeline Engineer | `shared/personas/etl-pipeline-engineer.md` |
| FastAPI Service Architect | `shared/personas/fastapi-service-architect.md` |
| Grafana Ops Architect | `shared/personas/grafana-ops-architect.md` |
| Cross-Stack Incident Debugger | `shared/personas/cross-stack-incident-debugger.md` |
| Infrastructure Operator | `shared/personas/infrastructure-operator.md` |
| AI Platform Operator | `shared/personas/ai-platform-operator.md` |
| Python Refactorer | `shared/personas/python-refactorer.md` |
| BI Analytics Architect | `shared/personas/bi-analytics-architect.md` |

### Added — Phase 4 (Mirrored .NET → Python & Frontend)

| Persona | File |
|---------|------|
| Python API Security Auditor | `shared/personas/python-api-security-auditor.md` |
| Python Backend Performance Auditor | `shared/personas/python-backend-performance-auditor.md` |
| Python API Integration Test Architect | `shared/personas/python-api-integration-test-architect.md` |
| Python Clean Architecture Modernizer | `shared/personas/python-clean-architecture-modernizer.md` |
| Frontend Security Reviewer | `shared/personas/frontend-security-reviewer.md` |
| Frontend Performance Auditor | `shared/personas/frontend-performance-auditor.md` |
| Frontend Integration Test Architect | `shared/personas/frontend-integration-test-architect.md` |
| Frontend Coverage Gap Analyst | `shared/personas/frontend-coverage-gap-analyst.md` |

---

## Workflows

| Workflow | File |
|----------|------|
| Code Review | `shared/workflows/code-review.md` |
| PR Summary | `shared/workflows/pr-summary.md` |
| Commit Writing | `shared/workflows/commit-writing.md` |
| Open-Source Modernization | `shared/workflows/open-source-modernization.md` |
| CLI Tool Usage | `shared/workflows/cli-tool-usage.md` |
| MCP Tool Triage | `shared/workflows/mcp-tool-triage.md` |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/apply-global.sh` | Install configs globally with symlinks or copies |
| `scripts/build.sh` | Assemble target files from shared sources into `dist/` |
| `scripts/adapt.sh` | Convert shared personas into tool-specific formats (delegates to `adapt.py`) |
| `scripts/adapt.py` | Python adapter for persona → tool format conversion |
| `scripts/verify.sh` | Static validation and CLI smoke tests |
| `scripts/doctor.sh` | Print installed versions, active symlinks, and MCP readiness |

---

## Repository Structure

```
ws-agents/
  shared/
    personas/           # Source-of-truth agent definitions (42+)
    workflows/          # Reusable process prompts (6)
  templates/            # Target adapter conversion rules (3)
  codex/                # Codex configuration
    AGENTS.md           # Analysis checklists for all domains
  .agents/
    skills/             # Codex repeatable skill workflows
  .codex/
    config.toml.example # MCP server configuration template
  copilot/              # Copilot configuration
    instructions/       # Per-persona instruction files (42)
    copilot-instructions.md  # Combined global instructions
  .github/
    agents/             # Copilot custom agents (48)
    copilot-instructions.md  # Repo-level Copilot instructions
    workflows/ci.yml    # GitHub Actions CI
    dependabot.yml      # Dependabot config
  claude/               # Claude Code configuration
    CLAUDE.md           # Global memory file
    .mcp.json           # MCP server configuration
  .claude/
    agents/             # Claude subagents (48)
    skills/             # Claude skill workflows (2)
  docs/                 # Documentation (6 files)
    adding-agents.md
    codex-setup.md
    copilot-global-setup.md
    cli-verification.md
    sync.md
    troubleshooting.md
  scripts/              # POSIX shell scripts (6)
  .gitignore
  LICENSE
  README.md
  CHANGELOG.md
```

---

## Tools Supported

### Codex

- `codex/AGENTS.md` — analysis checklists, auto-discovered by Codex CLI
- `.agents/skills/*/SKILL.md` — repeatable skill workflows
- `.codex/config.toml.example` — MCP server configuration template

### GitHub Copilot

- `copilot/instructions/*.md` — one instruction file per persona (42)
- `copilot/copilot-instructions.md` — combined global instructions
- `.github/agents/*.agent.md` — custom Copilot agents (48)
- `.github/copilot-instructions.md` — repo-level instructions

### Claude Code

- `claude/CLAUDE.md` — global memory file for Claude Code
- `.claude/agents/*.md` — Claude subagents (48)
- `.claude/skills/*/SKILL.md` — skill workflows
- `claude/.mcp.json` — MCP server configuration

---

## Keeping in Sync

Since `apply-global.sh` uses symlinks by default, `git pull` keeps all machines synchronised:

```bash
cd ~/repos/ws-agents
git pull
./scripts/build.sh       # regenerate combined files
./scripts/verify.sh --all # validate
```

---

## Adding a New Agent

1. Write the persona in `shared/personas/<name>.md`
2. Run `./scripts/adapt.py --persona <name>` to generate tool-specific files
3. Optionally create `shared/workflows/<name>.md`
4. Run `./scripts/build.sh && ./scripts/verify.sh --static`

See `docs/adding-agents.md` for detailed instructions.

---

## License

MIT — see [LICENSE](LICENSE).
