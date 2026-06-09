# Workflow: Commit Writing

## Trigger
When asked to write a commit message from a diff or change description, or to commit/push changes.

## Steps
1. Read `git status` or the diff to understand what changed
2. Identify the primary type: feat, fix, refactor, chore, docs, test, ci, perf
3. Identify scope from module/file paths
4. Write summary from the **effect**, not the implementation
5. Add body only if the "why" is non-obvious

## Git Operations
- **Stage**: `git add <file>` — stage related files together per commit
- **Preview**: `git diff --cached` — always review before committing
- **Commit**: `git commit -m "<type>(<scope>): <summary>"`
- **Push**: `git push` — only when explicitly asked
- **Never** commit or push without user confirmation

## Format
See `commit-writer` persona for detailed rules.
