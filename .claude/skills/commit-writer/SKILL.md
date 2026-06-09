# Skill: Commit Writer

Write a conventional commit message from the given diff.

## Steps
1. Read the diff
2. Identify the primary change type (feat, fix, refactor, chore, docs, test, ci, perf)
3. Identify scope from file paths
4. Write an imperative summary in 72 chars or less
5. Add a body only if the "why" is non-obvious

## Format
```
<type>(<scope>): <short summary>

[body — explain why, not what]
```

## Examples
```
feat(api): add paginated product search endpoint
fix(auth): handle expired refresh token on concurrent requests
```
