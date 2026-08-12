# 🔀 Pull Request Template

> Use for all PRs, especially dev → release

## PR: <Title>

| Field | Value |
|---|---|
| **Type** | feat / fix / refactor / docs / chore |
| **Source Branch** | `feat/name` or `dev` |
| **Target Branch** | `dev` or `release` |
| **Version Bump** | MAJOR.MINOR.PATCH → NEW |
| **Author** | <agent-id or human> |
| **Date** | ISO8601 |

---

## 📋 Summary of Changes
<Brief paragraph. What changed and why.>

## ✅ Changes Checklist

### Code
- [ ] Feature/fix implemented
- [ ] No debug code left in
- [ ] Code follows style conventions
- [ ] Comments updated (intent, not just logic)

### Documentation
- [ ] `docs/CHANGELOG.md` updated
- [ ] `docs/DEPENDENCIES.md` updated (if deps changed)
- [ ] `docs/TESTS.md` updated (if tests changed)
- [ ] File headers updated in all touched files
- [ ] `memory/CONTEXT.md` updated

### Testing
- [ ] Tests written for new code
- [ ] All existing tests pass
- [ ] Edge cases covered
- [ ] Coverage gap check run

### Security (for release PRs)
- [ ] `security-pass` prompt run on changed code
- [ ] No new dependencies with known CVEs
- [ ] No secrets/credentials in code

## 🧪 Test Results
```
# Paste test output summary here
```

## ⏪ Rollback Plan
<Describe how to revert this change if issues arise post-merge>
```bash
git revert <commit-hash>  # or describe steps
```

## 🔗 Related Issues / Tasks
- Closes TASK-NNNN
- Related to ADR-NNNN

## 📝 Reviewer Notes
<Anything specific reviewers should focus on>
