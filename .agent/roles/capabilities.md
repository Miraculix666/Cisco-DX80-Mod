# 🗂️ Agent Capabilities Matrix

> **FILE:** `.agent/roles/capabilities.md`
> **PURPOSE:** Detailed matrix of what each role can/cannot do across all framework areas
> **DEPENDS ON:** `roles.md`, `locking.config.md`
> **GOVERNANCE:** HARD — follows roles.md governance
> **LAST MODIFIED:** See git log

---

## 📊 Full Capability Matrix

| Capability | R-01 🔍 | R-02 ✍️ | R-03 🏗️ | R-04 🧪 | R-05 🔧 | R-06 🚀 | R-07 👁️ |
|---|---|---|---|---|---|---|---|
| **Read all files** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Write src/** | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Write docs/** | ⚠️* | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Write tests/** | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Write .agent/config/** | ❌ | ❌ | ⚠️** | ❌ | ❌ | ❌ | ❌ |
| **Write .agent/memory/** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Write .agent/locks/** | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ❌ |
| **Acquire SOFT lock** | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠️ | ❌ |
| **Acquire REQ lock** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Clear stale locks** | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Push to dev** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Push to release** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Create release tags** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Process dump/inbox/** | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Run health-check.sh** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Run consolidate.sh** | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Modify HARD-locked files** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Request role escalation** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- ✅ Full permission
- ❌ Not permitted
- ⚠️ Limited (see notes)

**Notes:**
- `⚠️*` R-01 may only append review notes to `docs/CHANGELOG.md`
- `⚠️**` R-03 may modify non-hard-locked `.agent/config/` files with DECISIONS.md log entry; HARD-locked files require human
- `⚠️` R-06 may only acquire SOFT lock on release process itself

---

## 🧩 Prompt Access by Role

| Prompt Category | R-01 | R-02 | R-03 | R-04 | R-05 | R-06 | R-07 |
|---|---|---|---|---|---|---|---|
| Code Review | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Debugging | ⚠️ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| Refactoring | ⚠️ | ✅ | ✅ | ⚠️ | ✅ | ❌ | ⚠️ |
| Architecture | ⚠️ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ⚠️ |
| Testing | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| Performance | ⚠️ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| Tooling | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |

*`⚠️` = analysis/output only, no implementation writes*

---

*Changing this file requires changing roles.md simultaneously (same governance).*
