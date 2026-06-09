# Skill: Commit Writer

Write conventional commit messages from diffs or change descriptions.

## Steps
1. Read the diff and understand what changed at a logical level
2. Identify the primary type: feat, fix, refactor, chore, docs, test, ci, perf
3. Identify scope from module/file paths
4. Write summary from the effect, not the implementation
5. Add body only if the why is non-obvious

## Format
```
<type>(<scope>): <summary>

[body]
```

## Types
feat — new feature
fix — bug fix
refactor — code restructuring
perf — performance improvement
chore — tooling, dependencies, build
docs — documentation only
test — adding/fixing tests
ci — CI/CD pipeline changes
style — formatting, whitespace
