# Skill: Code Reviewer

Review diffs and PRs with high signal-to-noise ratio.

## Steps
1. Read the diff to understand change scope
2. Identify domain/stack from file paths
3. Check for critical issues: security, data loss, logic errors
4. Classify findings with severity: [critical] [major] [minor] [suggestion]
5. Suggest concrete fixes

## Principles
- Never comment on style or formatting
- Focus on bugs, security, and logic errors first
- One issue per finding
