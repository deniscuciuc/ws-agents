# Troubleshooting

## CLI Not Found

Run `./scripts/doctor.sh` to see which CLIs are installed and where.

| CLI | Install Command |
|---|---|
| codex | `npm install -g @openai/codex` or `brew install codex` |
| copilot | Included with GitHub Copilot in VS Code |
| claude | `npm install -g @anthropic-ai/claude-code` or `brew install claude-code` |
| gh | `brew install gh` or `apt install gh` |
| glab | `brew install glab` or `curl -sL https://gitlab.com/gitlab-org/cli/-/releases | ...` |

## Symlinks Not Working

Some tools (notably some Copilot configurations) don't follow symlinks.

**Fix:** Run the installer with `--copy` mode:
```bash
./scripts/apply-global.sh --force --copy
```

## Permission Denied on Scripts

```bash
chmod +x scripts/*.sh
```

## Existing Config Not Being Replaced

By default, the installer preserves existing files. Use `--force` to overwrite with backup:

```bash
./scripts/apply-global.sh --force
```

Backups go to `~/.agents-backup-<timestamp>/`.

## Codex Not Reading AGENTS.md

- Ensure the file is in the current or parent directory
- Codex reads from cwd up to the git root
- Use `codex --agent-file ~/AGENTS.md` to specify explicitly

## Copilot Not Reading Instructions

- Check VS Code setting: `github.copilot.chat.codeGeneration.instructions`
- Ensure the path is absolute
- Restart VS Code after changes
- Ask in chat: "What instructions are you following?"

## Claude Not Reading CLAUDE.md

- Ensure `~/.claude/CLAUDE.md` exists
- Run `claude doctor` to verify
- Restart Claude Code session

## MCP Servers Not Connecting

See the `mcp-tools-operator` persona. Common fixes:
1. Check environment variables are set
2. Verify server binary is installed
3. Test with direct JSON-RPC call
