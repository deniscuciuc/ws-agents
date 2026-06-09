# Workflow: Code Review

## Trigger
When reviewing a PR, diff, or code change request.

## Steps
1. Read the diff or PR description to understand the change scope
2. Identify the domain/stack from file paths
3. Check for critical issues first: security, data loss, logic errors
4. Review against the relevant persona checklist
5. Classify each finding with severity
6. Write review summary

## Role
See `code-reviewer` persona for detailed rules.

## Output
```
### Review of <PR/commit>

#### Critical
...

#### Major
...

#### Minor / Suggestions
...

#### Summary
<verdict>: Approve / Changes requested — <count> findings total
```
