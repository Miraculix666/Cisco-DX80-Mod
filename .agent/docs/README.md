# 🤖 Universal Agent Framework

> **Version:** 2.0.0 | **Status:** 🟢 Active | **Branch Strategy:** `release` + `dev/wip`

---

## 🗺️ Quick Navigation

| 📄 Document | 🎯 Purpose |
|---|---|
| [`Agent.md`](../Agent.md) | ⚡ **MASTER AGENT** — Identity, rules, code standards |
| [`MASTER_INSTRUCTIONS.md`](../MASTER_INSTRUCTIONS.md) | Multi-agent startup protocol & dependency map |
| [`config/prompts.config.md`](../config/prompts.config.md) | Reusable prompt library (50+ prompts) |
| [`config/branches.config.md`](../config/branches.config.md) | Git branch strategy & commit conventions |
| [`roles/roles.md`](../roles/roles.md) | Agent role definitions & permissions |
| [`locks/HANDOVER.md`](../locks/HANDOVER.md) | Multi-agent handover protocol |
| [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) | System design & structure overview |
| [`docs/CHANGELOG.md`](CHANGELOG.md) | All changes, versioned |
| [`docs/SOURCES.md`](SOURCES.md) | All references & links |

---

## 🏗️ Framework Structure

```
.agent/
├── Agent.md                          # MASTER Agent — identity, rules, code standards
├── MASTER_INSTRUCTIONS.md            # Multi-agent startup protocol
├── config/
│   ├── agent.config.md               # Modes, personas, output standards
│   ├── locking.config.md             # Lock system (HARD/SOFT/REQ/SHARED)
│   ├── branches.config.md            # Git branch strategy, semver, rollback
│   └── prompts.config.md             # Reusable prompt library (7 categories)
├── roles/
│   ├── roles.md                      # 7 agent roles with permissions
│   └── capabilities.md               # Role → capability matrix
├── locks/
│   ├── .locked                       # Machine-readable lock state (JSON)
│   ├── HANDOVER.md                   # Multi-agent handover protocol
│   └── LOCK_REGISTRY.md              # Append-only lock history
├── memory/
│   ├── CONTEXT.md                    # Live project state
│   └── DECISIONS.md                  # Architecture decision log (ADR)
├── templates/
│   ├── task.template.md              # Task specification template
│   ├── pr.template.md                # Pull request template
│   ├── review.template.md            # Code review template
│   ├── ci.template.yml               # GitHub Actions CI template
│   ├── release.template.yml          # Release pipeline template
│   ├── wip.template.yml              # WIP/dev branch pipeline template
│   └── gitlab-ci.template.yml        # GitLab CI alternative template
├── scripts/
│   ├── health-check.sh               # Framework health validation
│   ├── consolidate.sh                # Structure optimisation check
│   ├── dump-processor.sh             # Dump inbox processor
│   └── lock-manager.sh               # Lock management utility
├── docs/
│   ├── README.md                     # ← You are here
│   ├── ARCHITECTURE.md               # System architecture
│   ├── CHANGELOG.md                  # Versioned change history
│   ├── DEPENDENCIES.md               # Dependency audit
│   ├── TESTS.md                      # Test documentation
│   └── SOURCES.md                    # References & links
├── .editorconfig                     # Editor consistency settings
└── .gitignore                        # Standard ignores
```

---

## 🚀 Getting Started

### For Agents / LLMs

```
1. READ  Agent.md                      (identity, rules, code standards)
2. READ  MASTER_INSTRUCTIONS.md        (startup protocol, dependencies)
3. CHECK locks/.locked                 (verify no conflicts)
4. READ  memory/CONTEXT.md             (current project state)
5. READ  roles/roles.md                (identify your role)
6. START working in the correct branch (see config/branches.config.md)
```

### For Humans

```bash
# Check health
bash scripts/health-check.sh

# Process dump files
bash scripts/dump-processor.sh

# Check lock state
cat locks/.locked

# Manage locks
bash scripts/lock-manager.sh status
```

---

## 🌿 Branch Strategy

| Branch | Purpose | Protected |
|---|---|---|
| `release` | 🟢 Stable, production-ready | ✅ Yes |
| `dev` / `wip` | 🔵 Active development | ⚠️ Partial |

> 📖 Full strategy: [`config/branches.config.md`](../config/branches.config.md)

---

## 🤝 Multi-Agent Rules (Summary)

- ✅ **Always** check `locks/.locked` before writing
- ✅ **Always** update `memory/CONTEXT.md` after changes
- ❌ **Never** write to locked files without completing handover
- ❌ **Never** commit directly to `release`

> 📖 Full locking rules: [`config/locking.config.md`](../config/locking.config.md)
> 📖 Handover protocol: [`locks/HANDOVER.md`](../locks/HANDOVER.md)

---

## 📊 Framework Health

Run anytime:

```bash
bash scripts/health-check.sh
```

Expected output indicators:
- 🟢 All docs in sync
- 🟢 No stale locks
- 🟢 Branch strategy valid
- 🟢 Dump inbox empty

---

*Universal Agent Framework v2.0.0 · References: [`docs/SOURCES.md`](SOURCES.md)*
