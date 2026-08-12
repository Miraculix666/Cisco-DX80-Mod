# 🤝 Agent Handover Protocol

> **FILE:** `.agent/locks/HANDOVER.md`
> **PURPOSE:** Define and document handover procedures between agents for locked files
> **DEPENDS ON:** `locking.config.md`, `.locked`
> **DEPENDED ON BY:** All agents performing lock transfers
> **LAST MODIFIED:** See git log

---

## 📋 Overview

A **handover** occurs when one agent needs to transfer control of a locked resource to another agent.
This ensures continuity, context preservation, and no lost work.

---

## 🔄 Handover Trigger Conditions

| Condition | Action |
|---|---|
| Session timeout (>4h for SOFT lock) | Mandatory handover OR lock release |
| Agent switching tasks | Handover or release |
| New agent needs locked file | Request handover from current holder |
| Human-initiated switch | Override handover (human authority) |
| Emergency (agent unresponsive) | Stale lock protocol via Maintainer (R-05) |

---

## 📝 Handover Request Template

When requesting a handover, append to this file:

```markdown
---
## 🔵 HANDOVER REQUEST — <ISO8601 timestamp>

### Requesting Agent
- **Agent ID:** <agent-id>
- **Role:** <role-id>
- **Target Files:** <list of files needed>
- **Reason for Request:** <why this agent needs access>
- **Priority:** Low / Medium / High / Critical

### Current Lock Holder
- **Agent ID:** <current-holder-id> (from .locked)
- **Lock ID:** <lock-id from .locked>
- **Lock Acquired:** <timestamp>

### Request Status
- [ ] Sent
- [ ] Acknowledged by holder
- [ ] Approved
- [ ] Transfer complete
```

---

## 📤 Handover Sender Template

When sending a handover, append to this file:

```markdown
---
## 🟡 HANDOVER TRANSFER — <ISO8601 timestamp>

### Transferring Agent
- **Agent ID:** <sender-agent-id>
- **Role:** <role-id>
- **Lock ID:** <lock-id>
- **Transferring To:** <receiver-agent-id>

### Work Summary
- **Files Modified:** <list with brief change description>
- **Commits Made:** <commit hashes>
- **Current Branch:** <branch name>
- **Branch State:** <clean / uncommitted changes / WIP>

### Decisions Made
- <Decision 1 and rationale>
- <Decision 2 and rationale>

### Open Issues / TODOs
- <Issue 1>
- <Issue 2>

### Warnings / Gotchas
- <Anything the receiver must know>

### Next Recommended Steps
1. <Step 1>
2. <Step 2>

### Lock Transfer Instructions
1. Update `.locked`: change `locked_by` to receiver-agent-id, update `locked_at`
2. Update `.locked`: set `handover_to: null` (transfer complete)
3. Append to `LOCK_REGISTRY.md` (sender's session end entry)
4. Receiver: append acknowledgement below

### Sender Sign-off
- [ ] All changes committed
- [ ] CHANGELOG.md updated
- [ ] CONTEXT.md updated
- [ ] Handover summary complete
```

---

## 📥 Handover Receiver Template

When receiving a handover, append to this file:

```markdown
---
## 🟢 HANDOVER ACKNOWLEDGEMENT — <ISO8601 timestamp>

### Receiving Agent
- **Agent ID:** <receiver-agent-id>
- **Role:** <role-id>
- **Received From:** <sender-agent-id>
- **Lock ID:** <lock-id>

### Handover Review
- [ ] Read full sender handover summary
- [ ] Read all modified files
- [ ] Read CONTEXT.md
- [ ] Read DECISIONS.md (recent entries)
- [ ] Reviewed all open issues

### Understanding Confirmed
- I understand the current state of: <files>
- I acknowledge the open issues: <list>
- I will continue from: <next step from sender>

### Lock Registered
- Updated .locked: locked_by = this agent-id, locked_at = now
- Lock ID: <lock-id>
```

---

## 🚨 Emergency / Stale Lock Protocol

If a lock holder is unresponsive and the lock is stale (past `expires_at`):

```
1. Verify the lock is genuinely stale (check LOCK_REGISTRY.md for recent pings)
2. Maintainer agent (R-05) may claim stale lock
3. Log in LOCK_REGISTRY.md:
   - Original holder, lock-id, stale time, reason for emergency claim
4. Notify human of emergency claim via CONTEXT.md
5. Proceed with work
6. Release lock normally when done
```

---

## 📜 Active Handover Log

> Append all handover transactions below. Newest at top.

---

<!-- Handover entries will be appended here by agents -->

*No handovers recorded yet — initial project state.*

---

*This file is append-only. Never delete historical entries.*
*Update LOCK_REGISTRY.md in parallel with every entry here.*
