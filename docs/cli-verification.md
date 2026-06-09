# CLI Verification

## Quick Health Check

```bash
./scripts/doctor.sh
```

Reports: installed CLI versions, active symlinks, MCP readiness, and persona count.

## Static Validation

```bash
./scripts/verify.sh --static
```

Checks: broken symlinks, Markdown file structure, POSIX shell syntax, and agent frontmatter.

## CLI Smoke Tests

```bash
./scripts/verify.sh --smoke
```

Reports available CLIs and their versions. Non-fatal for missing CLIs.

## Per-CLI Verification

### Codex

```bash
codex --version
codex exec --ask-for-approval never "Summarize active instructions"
```

### Copilot (VS Code)

- Open Copilot Chat
- Ask: "What instructions are you following?"
- Check VS Code settings for `github.copilot.chat.codeGeneration.instructions`

### Claude Code

```bash
claude --version
claude doctor          # diagnostic report
claude mcp list        # active MCP servers
claude -p "Summarize your active memory and instructions"
```

### GitHub CLI

```bash
gh auth status         # checks authentication
gh --version
```

### GitLab CLI

```bash
glab auth status       # checks authentication
glab --version
```

## Full Validation

```bash
./scripts/build.sh
./scripts/verify.sh --all
```
