# 📋 Changelog

> **FILE:** `docs/CHANGELOG.md`
> **PURPOSE:** Versioned record of all project changes
> **DEPENDS ON:** All source files (any change triggers entry here)
> **FORMAT:** [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) — newest first
> **VERSIONING:** [Semantic Versioning](https://semver.org/)

---

## [Unreleased]

> Changes staged for next release

### Added
### Added
- Added optional counter entity input to Tibber automations (`tibber_smart_device.yaml`, `tibber_pool_pump.yaml`, `tibber_pool_pump_emergency.yaml`).
- (nothing yet)

---

## [2.0.0] — 2026-02-23

### 🏗️ Major Restructuring — Proper Directory Layout

#### Changed
- Reorganized flat file structure into proper subdirectories: `config/`, `roles/`, `locks/`, `memory/`, `templates/`, `scripts/`, `docs/`
- De-duplicated `Agent.md` vs `MASTER_INSTRUCTIONS.md` — `Agent.md` is now the single authoritative agent file, `MASTER_INSTRUCTIONS.md` is the lean multi-agent startup protocol
- Renamed `editorconfig` → `.editorconfig`, `gitignore` → `.gitignore`
- Generalized CI workflows as reusable templates (`.template.yml`)
- Updated all internal cross-references to match new directory structure
- Expanded multi-agent locking section in `Agent.md` with full lock type reference
- Updated `docs/README.md` with correct paths and navigation
- Version bumped to 2.0.0

#### Removed
- `.agent_antother config/` — orphaned duplicate directory (36 files)
- `README_2.md` — misnamed dump zone README (content preserved in dump workflow docs)
- `strukture.md` — duplicate of README structure tree
- `gitkeep` — unnecessary placeholder
- `locked` — duplicate of `.locked` (now at `locks/.locked`)
- `history.md`, `AI.md`, `LLMprompt.md` references — replaced with `memory/CONTEXT.md` + `memory/DECISIONS.md`

---

## [1.0.0] — 2026-02-23

### 🎉 Initial Release — Universal Agent Framework

#### Added
- `README.md` — Project entry point and navigation
- `.agent/MASTER_INSTRUCTIONS.md` — Complete agent restart guide (HARD locked)
- `.agent/config/agent.config.md` — Agent behaviour, modes, output standards
- `.agent/config/locking.config.md` — Lock types, protocols, expiry (HARD locked)
- `.agent/config/branches.config.md` — Git branch strategy and commit conventions
- `.agent/config/prompts.config.md` — Full reusable prompt library (7 categories, 50+ prompts)
- `.agent/roles/roles.md` — 7 agent roles with permissions (HARD locked)
- `.agent/locks/.locked` — Machine-readable lock state (3 initial HARD locks)
- `.agent/locks/HANDOVER.md` — Multi-agent handover protocol
- `.agent/locks/LOCK_REGISTRY.md` — Append-only lock history
- `.agent/memory/CONTEXT.md` — Live project state
- `.agent/memory/DECISIONS.md` — Architecture decision records (ADR-0001 through ADR-0005)
- `.agent/templates/task.template.md` — Task specification template
- `.agent/templates/pr.template.md` — Pull request template
- `.agent/templates/review.template.md` — Code review template
- `docs/CHANGELOG.md` — This file
- `docs/DEPENDENCIES.md` — Dependency audit
- `docs/TESTS.md` — Test documentation
- `docs/ARCHITECTURE.md` — System architecture overview
- `docs/SOURCES.md` — All references and links
- `dump/README.md` — Dump zone processing instructions
- `scripts/health-check.sh` — Framework health validation
- `scripts/consolidate.sh` — Structure optimisation check
- `scripts/dump-processor.sh` — Dump inbox processor
- `scripts/lock-manager.sh` — Lock management utility
- `.github/workflows/ci.yml` — GitHub Actions CI
- `.github/workflows/release.yml` — Release pipeline
- `.github/workflows/wip.yml` — WIP/dev pipeline
- `.gitlab-ci.yml` — GitLab CI/CD alternative
- `.editorconfig` — Editor consistency settings
- `.gitignore` — Standard ignores

#### Decisions
- ADR-0001: Universal JSON Lock File
- ADR-0002: Dual-Branch Strategy
- ADR-0003: Hard Lock Governance
- ADR-0004: Dump Zone with Confirmation
- ADR-0005: Modular Sub-Agent Folders

---

<!-- Append new versions above the [1.0.0] entry, below [Unreleased] -->

[Unreleased]: https://github.com/your-org/your-repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/your-repo/releases/tag/v1.0.0
## [Unreleased] - 2026-07-04
### Changed
- `blueprints/automation/tibber_smart_device.yaml`: Replaced deprecated `service:` syntax with modern `action:` syntax.
- `blueprints/scripts/universal_notification.yaml`: Replaced deprecated `notify.notify` and `notify.alexa_media` services with `notify.send_message` targeting corresponding entity_ids.
## [Unreleased]

### Added
- Added `blueprints/automation/tibber_pool_pump.yaml` for smart pool pump automation based on Tibber prices.
- Added `blueprints/automation/tibber_pool_pump_emergency.yaml` for fallback pool pump scheduling.
