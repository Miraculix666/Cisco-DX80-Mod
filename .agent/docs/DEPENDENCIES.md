# 📦 Dependencies

> **FILE:** `docs/DEPENDENCIES.md`
> **PURPOSE:** Complete audit of all external dependencies, their status, and risk assessment
> **DEPENDS ON:** Source files (update when deps change)
> **DEPENDED ON BY:** Release pipeline, security audits
> **LAST MODIFIED:** See git log
> **UPDATE TRIGGER:** Any change to package.json, requirements.txt, go.mod, Gemfile, etc.

---

## 🏗️ Framework Dependencies

> The agent framework itself has no runtime external dependencies by design.
> It is language-agnostic documentation and configuration only.

| Dependency | Type | Version | Status | Risk | Notes |
|---|---|---|---|---|---|
| Git | Tool | ≥ 2.30 | 🟢 Required | Low | Version control backbone |
| Any LLM / Agent | Runtime | Any | 🟢 Compatible | Low | By design — no vendor lock-in |
| GitHub Actions / GitLab CI | CI/CD | Latest | 🟡 Optional | Low | Can use any CI |
| Bash | Scripts | ≥ 4.0 | 🟡 Optional | Low | For utility scripts |

---

## 📋 Project Dependencies

> When your project adds dependencies, document them here.

### Runtime Dependencies

| Package | Version | Purpose | License | Status | CVE Risk | Action |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | Add deps here |

### Development Dependencies

| Package | Version | Purpose | License | Status | CVE Risk | Action |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | Add dev deps here |

---

## 🔴 Risk Legend

| Status | Meaning |
|---|---|
| 🟢 OK | Up to date, no known issues |
| 🟡 Review | Outdated or approaching EOL — review recommended |
| 🔴 Critical | CVE present, EOL, or licence conflict — action required |
| ⚪ Unused | Dependency found but not used — removal candidate |

---

## 🔄 Dependency Audit Protocol

Run the `dependency-audit` prompt (see `prompts.config.md`) before every release:

```bash
# Language-specific audit commands:
npm audit                    # Node.js
pip-audit                    # Python
bundle audit                 # Ruby
govulncheck ./...            # Go
cargo audit                  # Rust
```

Update this file with:
- New packages added
- Version bumps
- Removed packages (with reason)
- CVE findings and fixes

---

## 📝 Dependency Change Log

| Date | Package | Change | Reason | Author |
|---|---|---|---|---|
| 2026-02-23 | — | Initial file created | Framework v1.0.0 | system-init |

---

*Always update this file when dependencies change. Cascade check: CHANGELOG.md*
