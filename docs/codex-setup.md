# Codex: Setup & Usage

## How Codex Reads AGENTS.md

OpenAI Codex CLI automatically reads `AGENTS.md` from the current working directory (or any parent directory up to the git root) and uses it as the agent's system instructions for that session.

No configuration needed — just having the file present activates it.

---

## Global Setup (applies everywhere)

### Using the Installer (recommended)

```bash
./scripts/apply-global.sh
```

This symlinks `codex/AGENTS.md` to `~/AGENTS.md`.

### Manual Setup

```bash
# Clone this repo to a fixed location
git clone git@github.com:deniscuciuc/ws-agents.git ~/repos/ws-agents

# Symlink AGENTS.md to your home directory
ln -s ~/repos/ws-agents/codex/AGENTS.md ~/AGENTS.md
```

Codex will find `~/AGENTS.md` when running from any subdirectory of `~`.

### Shell alias (alternative)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
alias codex='codex --agent-file ~/repos/ws-agents/codex/AGENTS.md'
```

---

## Per-Repo Setup

Symlink `AGENTS.md` into your repo:

```bash
ln -s ~/repos/ws-agents/codex/AGENTS.md /path/to/your-repo/AGENTS.md
```

Or copy it if you want to commit it for the team.

---

## MCP Configuration

Copy the example config:

```bash
cp .codex/config.toml.example ~/.codex/config.toml
```

Edit `~/.codex/config.toml` and uncomment/add the MCP servers you need (GitHub, filesystem, Playwright, etc.).

---

## Recommended Usage Patterns

### Architecture audit
```bash
cd /path/to/your-repo
codex "Audit the API layer for violations of the rules in AGENTS.md. Output structured findings with severity levels."
```

### Query review
```bash
codex "Review the SQL queries in src/Infrastructure/Queries/ against the PostgreSQL analysis rules."
```

### Pipeline audit
```bash
codex "Audit .gitlab-ci.yml against the GitLab CI/CD checklist in AGENTS.md."
```

### Security review
```bash
codex "Audit this codebase against the .NET Security Audit checklist in AGENTS.md."
```

### Full codebase audit
```bash
codex "Perform a full audit of this codebase. Use the audit output format defined in AGENTS.md."
```

---

## Customising AGENTS.md per Project

If a project uses a specific subset, create a trimmed `AGENTS.md` that only includes relevant sections.

---

## Keeping in Sync

Use `./scripts/build.sh` to regenerate `dist/codex/AGENTS.md` from all shared personas. The `codex/AGENTS.md` file in this repo is manually maintained — keep it in sync with shared personas.
