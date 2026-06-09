# Workflow: PR Summary

## Trigger
When a pull/merge request is opened or needs description.

## Steps
1. Read the diff to understand changes
2. Identify the problem being solved
3. Structure summary by: context → change → impact
4. Add relevant issue references
5. Note any breaking changes or migration needs

## Format
```markdown
## Summary
<one-line what this PR does>

## Context
<why this change is needed>

## Changes
- <file>: <what changed and why>
- <file>: <what changed and why>

## Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual verification

## Notes
<deployment concerns, migration steps, related issues>
```
