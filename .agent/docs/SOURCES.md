# 🔗 Sources & References

> **FILE:** `docs/SOURCES.md`
> **PURPOSE:** Complete catalogue of all external references, links, and source material
> **DEPENDS ON:** All files that cite external sources
> **DEPENDED ON BY:** All agents (must reference here, not inline)
> **LAST MODIFIED:** See git log
> **FORMAT:** Append new sources. Never remove. Mark as deprecated if needed.

---

## 📋 How to Reference Sources

In any project file, reference as:
```
> 📖 Source: [SOURCES.md#S-NNNN] — Short description
```

In this file, maintain the full entry.

---

## 🗂️ Source Registry

### Agent Systems

| ID | Source | URL | Referenced In | Status |
|---|---|---|---|---|
| S-0001 | Antigravity Agent Framework | `https://antigravity.md/` | MASTER_INSTRUCTIONS.md | 🟢 Active |
| S-0002 | Antigravity Google Agent Docs | `https://antigravity.google/docs/agent` | MASTER_INSTRUCTIONS.md | 🟢 Active |

### Version Control & Git

| ID | Source | URL | Referenced In | Status |
|---|---|---|---|---|
| S-0003 | Semantic Versioning (SemVer) | `https://semver.org/` | branches.config.md, CHANGELOG.md | 🟢 Active |
| S-0004 | Conventional Commits | `https://www.conventionalcommits.org/` | branches.config.md | 🟢 Active |
| S-0005 | GitFlow Branching Model | `https://nvie.com/posts/a-successful-git-branching-model/` | branches.config.md | 🟢 Active |
| S-0006 | Keep a Changelog | `https://keepachangelog.com/en/1.1.0/` | CHANGELOG.md | 🟢 Active |

### Standards & Configuration

| ID | Source | URL | Referenced In | Status |
|---|---|---|---|---|
| S-0007 | EditorConfig | `https://editorconfig.org/` | .editorconfig, MASTER_INSTRUCTIONS.md | 🟢 Active |
| S-0008 | GitHub Actions Docs | `https://docs.github.com/en/actions` | .github/workflows/ | 🟢 Active |
| S-0009 | GitLab CI/CD Docs | `https://docs.gitlab.com/ee/ci/` | .gitlab-ci.yml | 🟢 Active |

### Architecture & Design

| ID | Source | URL | Referenced In | Status |
|---|---|---|---|---|
| S-0010 | Architecture Decision Records (ADR) | `https://adr.github.io/` | memory/DECISIONS.md | 🟢 Active |
| S-0011 | 12-Factor App | `https://12factor.net/` | ARCHITECTURE.md | 🟢 Active |

### Prompt Library

| ID | Source | Description | Referenced In | Status |
|---|---|---|---|---|
| S-0012 | Internal Prompt Collection | Original prompt set provided for this framework | prompts.config.md | 🟢 Active |

---

## 📝 Source Addition Protocol

When adding a new external reference anywhere in the project:

1. Add an entry to this file with the next S-NNNN ID
2. Update the `Referenced In` column for any existing sources you use
3. In the referring file, add: `> 📖 Source: [SOURCES.md#S-NNNN]`
4. Commit with: `docs: add source reference S-NNNN to SOURCES.md`

---

## ⚠️ Deprecated Sources

| ID | Source | Deprecated | Reason | Replaced By |
|---|---|---|---|---|
| — | — | — | — | — |

---

*Maintain this file for full auditability and traceability of all external content.*
