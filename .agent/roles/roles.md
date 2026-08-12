# 🎭 Agent Roles

> **FILE:** `.agent/roles/roles.md`
> **PURPOSE:** Define all agent roles, responsibilities, permissions, and constraints
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`, `locking.config.md`
> **DEPENDED ON BY:** All agents (role assignment required on session start)
> **GOVERNANCE:** HARD — human approval required for changes
> **LAST MODIFIED:** See git log

---

## 🗂️ Role Registry

| Role ID | Name | Symbol | Primary Responsibility |
|---|---|---|---|
| `R-01` | Reviewer | 🔍 | Code review, audits, no writes to source |
| `R-02` | Author | ✍️ | Feature development, bug fixes, source writes |
| `R-03` | Architect | 🏗️ | System design, framework changes, governance |
| `R-04` | Tester | 🧪 | Test writing, coverage analysis, QA |
| `R-05` | Maintainer | 🔧 | Health checks, deps, dump processing, optimisation |
| `R-06` | Releaser | 🚀 | Branch merges, version tagging, release notes |
| `R-07` | Observer | 👁️ | Read-only monitoring, no write access |

---

## 📋 Role Detail Cards

### 🔍 R-01 — Reviewer

**Can access:** All files (read)
**Can write to:** `docs/CHANGELOG.md` (review notes only), review output files
**Cannot write to:** Source code, `.agent/` configs, lock files
**Lock types available:** `SHARED` (read), no write locks
**Prompt categories:** Code Review, Architecture (analysis only)

**Responsibilities:**
- Run code review prompts (see `prompts.config.md` → Section 1)
- Produce structured review reports
- Flag issues for Author agents
- Never implement fixes directly

---

### ✍️ R-02 — Author

**Can access:** All files per lock permissions
**Can write to:** `src/`, `docs/`, test files, `dump/processed/`
**Cannot write to:** Hard-locked files, files locked by other agents
**Lock types available:** `SOFT`, `REQ`
**Prompt categories:** All except Architecture (governance level)

**Responsibilities:**
- Implement features and bug fixes
- Update dependent docs on every change
- Write semantic commits
- Run test suite after changes

---

### 🏗️ R-03 — Architect

**Can access:** All files
**Can write to:** `.agent/` configs (non-hard-locked), architecture docs
**Cannot write to:** Hard-locked files without human approval
**Lock types available:** All except HARD (human only)
**Prompt categories:** Architecture, Refactoring, Code Review

**Responsibilities:**
- Define and maintain system boundaries
- Approve major structural changes
- Update `MASTER_INSTRUCTIONS.md` (with human review)
- Manage `.agent/` sub-folder specialisations

---

### 🧪 R-04 — Tester

**Can access:** All files (read), test files (write)
**Can write to:** `docs/TESTS.md`, test directories
**Cannot write to:** Source code directly, production configs
**Lock types available:** `REQ` (test files only)
**Prompt categories:** Testing (all), Code Review (coverage only)

**Responsibilities:**
- Identify and fill test coverage gaps
- Write unit, integration, stress, fuzz tests
- Maintain `docs/TESTS.md`
- Report flaky tests

---

### 🔧 R-05 — Maintainer

**Can access:** All files
**Can write to:** All non-hard-locked files
**Cannot write to:** Hard-locked files without approval
**Lock types available:** `SOFT`, `REQ`
**Prompt categories:** Performance, Tooling, Architecture (audit)

**Responsibilities:**
- Run periodic health checks (`scripts/health-check.sh`)
- Process `dump/inbox/` files (with human approval)
- Audit and update `docs/DEPENDENCIES.md`
- Trigger consolidation reviews every 5 sessions
- Manage stale locks

---

### 🚀 R-06 — Releaser

**Can access:** All branches (read), `dev` and `release` (write via PR)
**Can write to:** Release tags, `docs/CHANGELOG.md`, version files
**Cannot write to:** Source code directly, feature branches owned by others
**Lock types available:** `SOFT` (release process)
**Prompt categories:** Tooling (CI, metrics)

**Responsibilities:**
- Manage `dev → release` PRs
- Write release notes
- Create semantic version tags
- Validate CI gates before release
- Document rollback procedures

---

### 👁️ R-07 — Observer

**Can access:** All files (read-only)
**Can write to:** Nothing
**Lock types available:** None
**Prompt categories:** All (output only, no writes)

**Responsibilities:**
- Monitor project state
- Generate reports without side effects
- Useful for audit, compliance, or logging agents

---

## 🔄 Role Assignment Protocol

On session start, every agent declares:

```yaml
# Paste into .agent/memory/CONTEXT.md on session start
session:
  agent_id: "unique-id"
  role: "R-02"          # Role ID from above
  start_time: "ISO8601"
  planned_work: "brief description"
  target_files: ["src/module.py", "docs/CHANGELOG.md"]
```

---

## 🏢 Role Escalation

If an agent needs a higher permission level:
```
1. Log escalation request in .agent/memory/DECISIONS.md
2. Describe why the current role is insufficient
3. Wait for human or R-03 Architect approval
4. On approval: update role in session declaration
5. On completion: revert to original role, log outcome
```

---

## 🧩 Module-Level Role Specialisation

Sub-folders may define specialised roles:

```
src/payments/.agent/roles/roles.md
  → Extends R-02 Author with payments-specific write permissions
  → Restricts R-01 Reviewer to payments compliance checklists only
```

Sub-folder roles INHERIT from root roles. They may restrict or extend, but never contradict hard-locked root rules.

---

*HARD governance file — changes require human approval.*
*Changes cascade to: agent.config.md, MASTER_INSTRUCTIONS.md, capabilities.md*
