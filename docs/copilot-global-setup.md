# Copilot: Global & Per-Repo Setup

## How Copilot Instructions Work

GitHub Copilot Chat reads instruction files automatically and injects them into every chat context. There are two levels:

- **Global (personal)** — applies to all repos on your machine
- **Per-repo** — applies only when working inside that repository

---

## Global Setup (applies everywhere)

### Using the Installer (recommended)

```bash
./scripts/apply-global.sh
```

This symlinks `copilot/copilot-instructions.md` to `~/.config/copilot/instructions.md`.

### Step 1 — Point VS Code to the file

Open VS Code settings (`Ctrl+,`) → search for `github.copilot.chat.codeGeneration.instructions`

Or add to `settings.json`:

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    {
      "file": "$HOME/.config/copilot/instructions.md"
    }
  ]
}
```

> **Note:** Use the absolute path, replacing `$HOME` with your home directory.

### Step 2 — Verify

Open Copilot Chat in VS Code and ask: `What instructions are you following?`

---

## Per-Repo Setup

### Option A — Single file (simplest)

Create `.github/copilot-instructions.md` in the repo root.

Symlink the combined file:

```bash
ln -s ~/repos/ws-agents/copilot/copilot-instructions.md .github/copilot-instructions.md
```

Or combine specific personas:

```bash
cat copilot/instructions/dotnet-api-architect.md \
    copilot/instructions/postgresql-expert.md \
    copilot/instructions/react-developer.md \
    > /path/to/your-repo/.github/copilot-instructions.md
```

### Option B — Reference this repo as a symlink

```bash
ln -s ~/repos/ws-agents/copilot/instructions/dotnet-api-architect.md \
      /path/to/your-repo/.github/copilot-instructions.md
```

> Symlinks work locally but won't resolve on CI or for other contributors.

---

## Custom Agents (.github/agents/*.agent.md)

This repo includes pre-built Copilot custom agents in `.github/agents/`:

| Agent | Description |
|---|---|
| `dotnet-integration-testing.agent.md` | Integration test architect |
| `security-auditor.agent.md` | Security auditor for OWASP compliance |
| `performance-auditor.agent.md` | Backend performance auditor |
| `distributed-debugger.agent.md` | Distributed systems debugger |
| `clean-architecture-modernizer.agent.md` | Legacy .NET modernizer |
| `frontend-reviewer.agent.md` | React/TypeScript code reviewer |
| `release-notes-writer.agent.md` | Structured release notes generator |

These are recognised by VS Code when placed in `.github/agents/` within a repo.

---

## Tips

- You can have both global + per-repo instructions active simultaneously — they are merged
- Keep global instructions short and tech-agnostic (your personal style)
- Keep per-repo instructions specific to that project's stack
- Copilot re-reads the file on each chat session — edits take effect immediately
