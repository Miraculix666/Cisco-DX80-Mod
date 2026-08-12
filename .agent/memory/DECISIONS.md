# 🧠 Architecture Decision Log

> **FILE:** `.agent/memory/DECISIONS.md`
> **PURPOSE:** Immutable log of architecture decisions, rationale, and alternatives considered
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`
> **DEPENDED ON BY:** All agents when making structural choices
> **LAST MODIFIED:** See git log
> **FORMAT:** Append-only. Use ADR (Architecture Decision Record) format. Newest last.

---

## 📋 ADR Format

```markdown
## ADR-NNNN: <Title>
- **Date:** ISO8601
- **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNNN
- **Decided By:** <agent-id or human>
- **Context:** Why was this decision needed?
- **Decision:** What was decided?
- **Alternatives Considered:** What else was evaluated?
- **Rationale:** Why this option over others?
- **Consequences:** What does this change? What are the tradeoffs?
- **References:** Links, related ADRs
```

---

## ADR-0001: Universal JSON Lock File

- **Date:** 2026-02-23
- **Status:** Accepted
- **Decided By:** system-init
- **Context:** Multi-agent coordination requires a shared, machine-readable lock state that any agent (LLM or script) can parse.
- **Decision:** Use a JSON file at `.agent/locks/.locked` as the single source of lock truth.
- **Alternatives Considered:**
  - Git-based lock branches — complex, requires network
  - Database — adds external dependency
  - YAML — less standard for machine parsing
- **Rationale:** JSON is universally parseable, human-readable, diff-friendly in git, and requires no external tooling.
- **Consequences:** All agents must parse/write valid JSON. File contention possible if agents write simultaneously — mitigated by soft lock expiry windows.
- **References:** `locking.config.md`

---

## ADR-0002: Dual-Branch Strategy (release + dev)

- **Date:** 2026-02-23
- **Status:** Accepted
- **Decided By:** system-init
- **Context:** Need stable production state and active development without conflicts.
- **Decision:** Maintain `release` (protected, PR-only) and `dev` (active, agent-writable). Feature branches from `dev`.
- **Alternatives Considered:**
  - GitFlow (main/develop/feature/hotfix) — more complex, overkill for agent workflows
  - Trunk-based — risky with multi-agent concurrent writes
- **Rationale:** Simple enough for agents to follow reliably; provides clear rollback point via `release` tags.
- **Consequences:** Agents must never push directly to `release`. PR + CI gate required.
- **References:** `branches.config.md`, https://semver.org/

---

## ADR-0003: Hard Lock Governance for Framework Files

- **Date:** 2026-02-23
- **Status:** Accepted
- **Decided By:** system-init
- **Context:** Framework files (MASTER_INSTRUCTIONS, locking config, roles) must not be auto-modified by agents without human oversight.
- **Decision:** HARD lock type introduced — only human can modify these files. Any agent attempting modification must be blocked by the locking protocol.
- **Alternatives Considered:**
  - Architect agent can modify — risk of recursive self-modification
  - No locks — agents could corrupt framework
- **Rationale:** Safety and auditability. Framework integrity is more important than agent autonomy for these specific files.
- **Consequences:** Human must be available to approve framework changes. Slows framework evolution but ensures correctness.
- **References:** `locking.config.md`, `roles.md`

---

## ADR-0004: Dump Zone with Mandatory Confirmation

- **Date:** 2026-02-23
- **Status:** Accepted
- **Decided By:** system-init
- **Context:** External files need a safe intake process that doesn't auto-corrupt project structure.
- **Decision:** `dump/inbox/` receives external files. Agents MUST ask human for confirmation before processing. Processed files move to `dump/processed/` with analysis notes, then integrated.
- **Alternatives Considered:**
  - Auto-process — too risky for unknown file quality
  - Manual-only — defeats agent automation benefit
- **Rationale:** Semi-automated with human gate provides safety + efficiency.
- **Consequences:** Adds one human interaction per dump batch. Acceptable tradeoff.
- **References:** `dump/README.md`, `MASTER_INSTRUCTIONS.md`

---

## ADR-0005: Modular `.agent` Sub-Folders for Specialisation

- **Date:** 2026-02-23
- **Status:** Accepted
- **Decided By:** system-init
- **Context:** Different modules (payments, auth, etc.) may need specialised agent behaviour, roles, or prompts.
- **Decision:** Allow `src/<module>/.agent/` sub-folders that extend (not replace) root `.agent/` config via inheritance.
- **Alternatives Considered:**
  - Monolithic config — doesn't scale to complex projects
  - Separate repos per module — too fragmented
- **Rationale:** Inheritance model gives flexibility without losing central governance.
- **Consequences:** Sub-folder configs must explicitly declare what they extend. Root hard-locks always take precedence.
- **References:** `agent.config.md`, `roles.md`

---

<!-- Append new ADRs below this line -->
