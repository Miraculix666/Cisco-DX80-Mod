# 🌿 Branch Strategy Configuration

> **FILE:** `.agent/config/branches.config.md`
> **PURPOSE:** Define Git branching rules, protection, merge policies, and rollback procedures
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`
> **DEPENDED ON BY:** CI workflows, all agents
> **LAST MODIFIED:** See git log
> **BRANCH:** All branches

---

## 🗺️ Branch Overview

```
release ─────────────────────────────────────────────────► (stable, production)
    ▲                                                         tagged: v1.0.0
    │  PR + review only
    │
dev ──────┬──────────────────────────────────────────────► (integration)
          │
    ┌─────┼──────────────────┐
    ▼     ▼                  ▼
feat/* fix/* refactor/*   agent/*
(feature) (bugfix) (refactor) (agent-specific work)
```

---

## 📋 Branch Definitions

| Branch | Pattern | Purpose | Direct Push | Delete After Merge |
|---|---|---|---|---|
| `release` | exact | Production-stable | ❌ Never | ❌ No |
| `dev` | exact | Integration / WIP | ✅ Agents | ❌ No |
| `feat/*` | prefix | New features | ✅ Owner agent | ✅ Yes |
| `fix/*` | prefix | Bug fixes | ✅ Owner agent | ✅ Yes |
| `refactor/*` | prefix | Code restructure | ✅ Owner agent | ✅ Yes |
| `agent/*` | prefix | Agent experiments | ✅ Agent | ✅ Yes |
| `hotfix/*` | prefix | Critical prod fix | Human only | ✅ After merge |

---

## 🔐 Branch Protection Rules

### `release` Branch
```yaml
protection:
  require_pull_request: true
  required_approvals: 1              # Human or designated architect agent
  dismiss_stale_reviews: true
  require_status_checks:
    - ci/tests-pass
    - ci/lint-pass
    - ci/security-scan
  restrict_push_to: []               # Nobody (PRs only)
  require_linear_history: false
  allow_force_push: false
  allow_deletion: false
```

### `dev` Branch
```yaml
protection:
  require_pull_request: false        # Agents may push directly
  require_status_checks:
    - ci/tests-pass
  allow_force_push: false
  allow_deletion: false
```

---

## 🔄 Merge Flow

### Feature → Dev
```bash
git checkout dev
git merge --no-ff feat/my-feature -m "feat: merge my-feature into dev"
git push origin dev
# Delete: git branch -d feat/my-feature
```

### Dev → Release (via Pull Request)
```
1. Create PR: dev → release
2. PR title format: "release: v1.x.x — <summary>"
3. PR description must include:
   - Summary of changes (bullet list)
   - Tests passed (reference docs/TESTS.md)
   - Dependencies changed (reference docs/DEPENDENCIES.md)
   - Rollback plan
4. Require 1 approval (human or architect agent)
5. Squash option: NO — preserve commit history
6. Merge commit message: "release: v1.x.x"
7. Tag immediately after merge:
   git tag -a v1.x.x -m "Release v1.x.x"
   git push origin v1.x.x
```

---

## 🏷️ Versioning (Semantic Versioning)

Format: `MAJOR.MINOR.PATCH`

| Increment | When | Example |
|---|---|---|
| `MAJOR` | Breaking changes, API incompatibility | `1.0.0 → 2.0.0` |
| `MINOR` | New features, backward-compatible | `1.0.0 → 1.1.0` |
| `PATCH` | Bug fixes, minor corrections | `1.0.0 → 1.0.1` |

Reference: https://semver.org/

---

## ⏪ Rollback Procedures

### Rollback a Single Commit (safe, preserves history)
```bash
git revert <commit-hash>
git push origin <branch>
# Document in CHANGELOG.md and DECISIONS.md
```

### Rollback to a Previous Release Tag
```bash
git checkout release
git revert <hash1> <hash2> ...   # Revert range OR:
git checkout v1.x.x -- .        # Check out old state as new commit
git commit -m "fix: rollback to v1.x.x due to <reason>"
git push origin release
git tag -a v1.x.x-rollback -m "Rollback to v1.x.x"
```

### Emergency Hotfix (only human-authorised)
```bash
git checkout -b hotfix/critical-issue release
# Make fix
git commit -m "hotfix: <description>"
# PR → release AND cherry-pick to dev:
git checkout dev && git cherry-pick <hotfix-commit>
```

---

## 📝 Commit Message Conventions

Reference: https://www.conventionalcommits.org/

```
<type>[optional scope]: <description>

[optional body]

[optional footer: BREAKING CHANGE, issue refs]
```

### Types

| Type | Usage |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change (no feature/fix) |
| `test` | Tests |
| `chore` | Maintenance (deps, config, tooling) |
| `lock` | Lock/unlock operations |
| `agent` | Agent framework changes |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |
| `revert` | Reverting a commit |

### Examples
```
feat(payments): add retry logic for failed transactions
fix(auth): prevent token refresh race condition
docs(api): update endpoint documentation for v2
agent(lock): register lock for auth module refactor
```

---

## 🔁 Recommended Agent Git Workflow

```bash
# Start work
git fetch origin
git checkout dev && git pull origin dev
git checkout -b feat/my-feature

# Work...
git add -A
git commit -m "feat: <description>"

# Finish
git push origin feat/my-feature
# Create PR to dev in GitHub/GitLab
```

---

## 🏢 GitLab vs GitHub

This framework supports both. See:
- `.github/workflows/` — GitHub Actions
- `.gitlab-ci.yml` — GitLab CI/CD

Configuration is equivalent; choose based on your hosting platform.

---

*Changes to this file cascade to: CI workflow files, MASTER_INSTRUCTIONS.md*
