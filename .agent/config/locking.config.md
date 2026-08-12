# 🔒 Locking Configuration

> **FILE:** `.agent/config/locking.config.md`
> **PURPOSE:** Define multi-agent file locking rules, protocols, and enforcement
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`
> **DEPENDED ON BY:** All agents, `HANDOVER.md`, `lock-manager.sh`
> **LAST MODIFIED:** See git log
> **BRANCH:** All branches

---

## 🗂️ Lock Types Reference

| Type | Symbol | Writeable By | Released By | Override |
|---|---|---|---|---|
| `HARD` | 🔴 | No one (human review required) | Human only | Never automated |
| `SOFT` | 🟡 | Lock holder only | Session end or handover | Via handover protocol |
| `REQ` | 🔵 | Any agent (after request) | After write complete | Request-and-release |
| `SHARED` | 🟢 | Multiple agents (read intent) | Any holder | Automatic on release |

---

## 🔴 Permanently Hard-Locked Files

These files require **human approval** before any agent may modify them:

```
.agent/MASTER_INSTRUCTIONS.md
.agent/config/locking.config.md
.agent/roles/roles.md
release branch (any file)         ← enforced by Git branch protection
```

---

## 📄 `.locked` File Format

Location: `.agent/locks/.locked`
Format: JSON (machine-readable + human-readable)

```json
{
  "format_version": "1.0",
  "last_updated": "ISO8601",
  "updated_by": "agent-id",
  "locks": [
    {
      "id": "lock-uuid-v4",
      "file_or_folder": "relative/path/from/repo/root",
      "scope": "file | folder | glob",
      "type": "HARD | SOFT | REQ | SHARED",
      "locked_by": "agent-id or 'human'",
      "locked_at": "ISO8601",
      "expires_at": "ISO8601 or null",
      "reason": "Human-readable reason for lock",
      "handover_required": true,
      "handover_to": "agent-id or null",
      "metadata": {}
    }
  ]
}
```

---

## 🔄 Lock Acquisition Protocol

```
STEP 1: Read .locked file
STEP 2: Check target file/folder for existing locks
    IF HARD lock found  → STOP. Do not proceed. Notify human.
    IF SOFT lock found  → Check expires_at
        IF expired      → Proceed to stale lock cleanup (Step 3)
        IF active       → Initiate HANDOVER protocol (see HANDOVER.md)
    IF REQ lock found   → Send handover request, wait for approval
    IF no lock found    → Proceed to Step 4
STEP 3: Stale Lock Cleanup
    - Log stale lock in LOCK_REGISTRY.md with reason
    - Remove from .locked
    - Proceed to Step 4
STEP 4: Register Lock
    - Add entry to .locked with your agent-id
    - Set expires_at (recommended: session_start + 4 hours for SOFT)
    - Update last_updated timestamp
STEP 5: Perform work
STEP 6: Release Lock
    - Remove your entry from .locked
    - Append completed session to LOCK_REGISTRY.md
    - Update last_updated in .locked
```

---

## 🤝 Handover Protocol Summary

Full protocol in: `.agent/locks/HANDOVER.md`

Quick reference:
```
Initiating agent (sender):
  1. Set handover_to in .locked entry
  2. Write handover summary to HANDOVER.md
  3. Include: files modified, decisions made, next steps, open issues

Receiving agent:
  1. Read HANDOVER.md completely
  2. Confirm understanding in HANDOVER.md (append acknowledgement)
  3. Take over lock (update locked_by, locked_at)
  4. Proceed with work
```

---

## ⏱️ Lock Expiry Policy

| Lock Type | Default Expiry | Max Expiry | Auto-Renew |
|---|---|---|---|
| `HARD` | Never | Never | No |
| `SOFT` | 4 hours | 24 hours | Yes (agent must ping) |
| `REQ` | 30 minutes | 2 hours | No |
| `SHARED` | 1 hour | 4 hours | No |

**Stale lock** = lock past `expires_at` with no renewal ping.
Stale `SOFT`/`REQ` locks may be claimed by any agent after logging in LOCK_REGISTRY.md.

---

## 📜 LOCK_REGISTRY.md Format

Append-only log. Every completed lock session is recorded:

```markdown
## Lock Session: <ISO8601>

| Field | Value |
|---|---|
| Lock ID | uuid |
| File | path |
| Type | SOFT/REQ/etc |
| Agent | agent-id |
| Start | ISO8601 |
| End | ISO8601 |
| Outcome | completed / handover / expired / aborted |
| Notes | What was done |
```

---

## 🛡️ Module-Level Lock Inheritance

When a folder lock is acquired:
```
.agent/locks/.locked entry: { "file_or_folder": "src/payments/", "scope": "folder" }

Effect:
  ✅ All files under src/payments/ are locked
  ✅ Sub-agents in src/payments/.agent/ inherit parent lock context
  ❌ Other agents cannot acquire locks on any file inside src/payments/
```

---

## 🔧 Lock Manager Utility

```bash
# Check current locks
bash scripts/lock-manager.sh status

# Acquire a lock
bash scripts/lock-manager.sh lock <path> <type> <agent-id> <reason>

# Release a lock
bash scripts/lock-manager.sh release <lock-id> <agent-id>

# Force-clear stale lock (logs automatically)
bash scripts/lock-manager.sh clear-stale <lock-id>

# List lock history
bash scripts/lock-manager.sh history [--last 10]
```

---

*Modifying this file requires human approval (HARD governance).*
*Changes cascade to: MASTER_INSTRUCTIONS.md, HANDOVER.md, lock-manager.sh*
