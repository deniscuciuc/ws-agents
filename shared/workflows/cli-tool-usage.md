# Workflow: CLI Tool Usage

## Trigger
When performing operations via GitHub CLI (gh) or GitLab CLI (glab).

## Steps
1. Identify the operation needed (PR, issue, release, CI, API)
2. Use built-in commands first — fall back to `gh api`/`glab api` only when missing
3. Use `--json` or `--output json` for structured output
4. Pipe through jq for data extraction
5. Verify the operation succeeded before proceeding

## Gh Commands Reference
```
gh pr create|view|review|merge|list
gh issue create|view|list|close
gh run list|view|watch|download|cancel
gh release create|view|list|upload
gh api <endpoint> [--method] [--field]
```

## Glab Commands Reference
```
glab mr create|view|approve|merge|list
glab issue create|view|list|close
glab ci status|run list|trace|cancel
glab release create|view|list
glab api <endpoint> [--method] [--field]
```
