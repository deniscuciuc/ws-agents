# Skill: Code Reviewer

Review a PR, diff, or code change request. Focus on correctness, security, and maintainability.

## Steps
1. Read the diff and understand the change scope
2. Check for critical issues first: security, data loss, logic errors
3. Classify each finding: [critical] [major] [minor] [suggestion]
4. Suggest concrete fixes for each finding
5. Write a summary verdict

## Output
```
### Review
[severity] <file:line> — <problem> — Fix: <fix>

### Summary
<verdict>: Approve / Changes requested
```
