# 🏗️ Architecture

> **FILE:** `docs/ARCHITECTURE.md`
> **PURPOSE:** System design, structural decisions, and component relationships
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`, `.agent/memory/DECISIONS.md`
> **DEPENDED ON BY:** All agents, onboarding
> **LAST MODIFIED:** See git log

---

## 🗺️ System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   UNIVERSAL AGENT FRAMEWORK                  │
├──────────────────┬──────────────────┬───────────────────────┤
│   🤖 Agent Layer │  📚 Docs Layer   │  🔧 Scripts Layer      │
│                  │                  │                        │
│ MASTER_INSTR.    │ CHANGELOG        │ health-check.sh        │
│ config/          │ DEPENDENCIES     │ lock-manager.sh        │
│ roles/           │ TESTS            │ dump-processor.sh      │
│ locks/           │ ARCHITECTURE     │ consolidate.sh         │
│ memory/          │ SOURCES          │                        │
│ templates/       │                  │                        │
├──────────────────┴──────────────────┴───────────────────────┤
│                    📦 Project Source (src/)                  │
│              [Your actual project code goes here]            │
├─────────────────────────────────────────────────────────────┤
│                    📥 Dump Zone                              │
│          inbox/ → processed/ → sorted into src/             │
├─────────────────────────────────────────────────────────────┤
│                    🔄 CI/CD Layer                            │
│     .github/workflows/ OR .gitlab-ci.yml                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Agent Interaction Flow

```
New Agent Session
      │
      ▼
Read MASTER_INSTRUCTIONS.md ──────────────────────────────┐
      │                                                    │
      ▼                                                    │
Read CONTEXT.md                                           │
      │                                                    │
      ▼                                                    │
Check .locked ──► Conflict? ──► HANDOVER protocol        │
      │ (clear)                                           │
      ▼                                                    │
Register Lock                                             │
      │                                                    │
      ▼                                                    │
Do Work ──► Update headers, CHANGELOG, CONTEXT, DEPS     │
      │                                                    │
      ▼                                                    │
Semantic Commit                                           │
      │                                                    │
      ▼                                                    │
Release Lock ──► Update LOCK_REGISTRY ────────────────────┘
```

---

## 🗂️ Layer Responsibilities

### 🤖 Agent Layer (`.agent/`)
**Owns:** Framework rules, lock state, agent memory, role definitions, prompt library
**Does NOT own:** Project source code, business logic
**Interfaces with:** All other layers (reads/writes)

### 📚 Docs Layer (`docs/`)
**Owns:** Project documentation, changelog, dependency audit, test strategy, architecture
**Does NOT own:** Code, agent configs
**Interfaces with:** Source layer (reflects its state), CI layer (gate inputs)

### 🔧 Scripts Layer (`scripts/`)
**Owns:** Operational utilities (health, locking, dump processing, consolidation)
**Does NOT own:** Business logic, agent configs
**Interfaces with:** Agent layer (lock files), Docs layer (updates)

### 📦 Source Layer (`src/`)
**Owns:** Actual project code
**Does NOT own:** Framework rules, CI config
**Interfaces with:** Agent layer (via locks), Docs layer (via CHANGELOG)

### 📥 Dump Layer (`dump/`)
**Owns:** Incoming external files and processed staging
**Does NOT own:** Anything in the main structure
**Interfaces with:** Source layer (destination after sorting), Docs layer (CHANGELOG)

### 🔄 CI/CD Layer (`.github/` or `.gitlab-ci.yml`)
**Owns:** Automated validation gates
**Does NOT own:** Source, docs
**Interfaces with:** All layers (reads, validates, reports)

---

## 🧩 Module Specialisation Pattern

```
src/
└── payments/
    ├── .agent/              ← Module-level agent config (extends root)
    │   ├── agent.config.md  ← payments-specific behaviour overrides
    │   └── roles.md         ← payments-specific role extensions
    ├── src/
    └── tests/
```

**Inheritance rule:** Module configs EXTEND root, never replace. Hard locks always win.

---

## 🌿 Git Architecture

```
release ←──────────── PR + CI gate ──────────── dev
                                                  │
                                    ┌─────────────┼──────────────┐
                                    ▼             ▼              ▼
                                feat/*          fix/*        agent/*
```

See `branches.config.md` for full details.

---

## ⚙️ Key Design Principles

| Principle | Implementation |
|---|---|
| **Universal / vendor-agnostic** | Plain markdown, JSON, YAML — no tool lock-in |
| **Human-readable + machine-parseable** | All files valid MD + structured data |
| **Auditability** | Append-only registries, semantic commits, ADR log |
| **Safe concurrency** | Lock types, handover protocol, stale detection |
| **Rollback always available** | Git tags on release, revert procedures documented |
| **Context never lost** | MASTER_INSTRUCTIONS + CONTEXT.md ensure restart-ability |
| **Modular specialisation** | Sub-folder `.agent/` override pattern |
| **Dump-safe intake** | Confirmation gate before any external file processing |

---

*Update this file when major structural changes occur. Reference in ADR when doing so.*
