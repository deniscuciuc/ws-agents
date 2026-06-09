# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project structure with shared personas, workflows, and templates
- `shared/personas/` — 42 agent persona definitions (source of truth)
- `shared/workflows/` — 6 reusable process prompts (code review, PR summary, commit writing, OSS modernization, CLI usage, MCP triage)
- `templates/` — 3 target adapter conversion rules (Codex, Copilot, Claude)
- `scripts/apply-global.sh` — POSIX shell installer (symlink/copy, dry-run, force, backups)
- `scripts/build.sh` — Assembles target files from shared sources into `dist/`
- `scripts/verify.sh` — Static validation and CLI smoke tests
- `scripts/doctor.sh` — Diagnostic health check for installed CLIs and symlinks
- `codex/AGENTS.md` — Analysis checklists for all domains
- `copilot/instructions/*.md` — One instruction file per persona (35 files)
- `copilot/copilot-instructions.md` — Combined global instructions
- `.github/agents/*.agent.md` — 15 Copilot custom agents
- `.github/copilot-instructions.md` — Repo-level Copilot instructions
- `claude/CLAUDE.md` — Global memory file
- `.claude/agents/*.md` — 12 Claude subagents
- `.claude/skills/*/SKILL.md` — Repeatable skill workflows
- `.agents/skills/*/SKILL.md` — Codex skill workflows
- `claude/.mcp.json` — MCP server configuration example
- `.codex/config.toml.example` — Codex MCP configuration example
- `docs/` — 6 documentation files (adding agents, codex setup, copilot setup, CLI verification, sync, troubleshooting)
- `CHANGELOG.md` with Keep a Changelog format
- GitHub Actions CI workflow (shell check, markdown validation, build/verify)
- Dependabot configuration for GitHub Actions
- Proper MIT LICENSE file

### Changed

- Refactored `dotnet-refactorer` into lightweight refactorer + `dotnet-clean-architecture-modernizer` with architecture violation reports and safe refactor plans
- Enhanced `dotnet-api-integration-test-architect` with coverage gap analysis workflow and branch-to-test mapping

## [0.1.0]

### Added

- 9 existing persona files (initial commit)
- Basic Codex AGENTS.md with .NET, PostgreSQL, Python, GitLab CI/CD, Docker Compose, Git, and React sections
- Basic Copilot instruction files for existing personas
- Initial docs: adding-agents.md, codex-setup.md, copilot-global-setup.md
- Basic README.md
