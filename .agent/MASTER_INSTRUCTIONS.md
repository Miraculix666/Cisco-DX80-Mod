# ⚡ MASTER INSTRUCTIONS — Universal Agent Framework

> **⚠️ MANDATORY READ:** Any agent, LLM, or automated system MUST read this file completely
> before performing ANY action in this repository. This file is the multi-agent startup protocol.
> For full agent identity, rules, and code standards, see [`Agent.md`](Agent.md).

---

## 📋 Meta

| Field | Value |
|---|---|
| **Version** | 2.1.0 |
| **Last Updated** | 2026-03-02 |
| **Maintained By** | All agents (auto-update required on each session) |
| **Branch** | Applies to ALL branches |
| **Compatibility** | Any LLM / agent system (language-agnostic instructions) |

---

## 🎯 Framework Mission

This framework provides a **universal, language-agnostic, multi-agent-ready project scaffold** that:

- Works with any agent system or LLM (no vendor lock-in)
- Enforces consistent documentation, locking, and version control
- Provides reusable prompt patterns (see [`config/prompts.config.md`](config/prompts.config.md))
- Supports safe concurrent multi-agent collaboration
- Maintains full auditability and rollback capability via Git

---

## 🔗 Workspace Integration & Deployment

- **No Repository Crossing Links:** Repositories must remain completely independent. Do not use directory junctions or symbolic links to share code, scripts, or configurations between repositories.
- **Auto-Clone neuer Repos:** Sobald ein neues Repository remote erstellt wurde, soll es umgehend lokal geklont werden, damit die lokale Workspace-Struktur lückenlos bleibt.
- **Workspace-Dateien:** Jedes Repository MUSS in den globalen Workspace `all.code-workspace` inkludiert sein und zudem über einen eigenen dedizierten Workspace (z.B. `<RepoName>.code-workspace` im zentralen Verzeichnis) verfügen.

---

## 🏗️ Mandatory File Dependency Map

> Every agent MUST understand and respect these dependencies.
> When modifying any file, ALL dependent files must be updated in the SAME commit.

```
MASTER_INSTRUCTIONS.md
    └── Depends on / Must stay in sync with:
        ├── memory/CONTEXT.md              (current state)
        ├── memory/DECISIONS.md            (architecture choices)
        ├── locks/.locked                  (lock state)
        ├── docs/CHANGELOG.md             (every change logged)
        ├── docs/DEPENDENCIES.md          (when deps change)
        ├── docs/TESTS.md                 (when tests change)
        └── docs/SOURCES.md              (when references added)

Source Code Files
    └── Must trigger updates to:
        ├── docs/CHANGELOG.md             (ALWAYS)
        ├── docs/DEPENDENCIES.md          (if deps changed)
        ├── docs/TESTS.md                 (if tests changed)
        ├── File headers/comments         (ALWAYS - keep in sync)
        └── memory/CONTEXT.md             (ALWAYS)
```

---

## 🔄 Agent Session Protocol

### Step 1 — Orientation (ALWAYS FIRST)
```
1. Read Agent.md                          → Identity, rules, code standards
2. Read this file (MASTER_INSTRUCTIONS.md) → Startup protocol & dependencies
3. Read memory/CONTEXT.md                 → Current project state
4. Read locks/.locked                     → Check for active locks
5. Read memory/DECISIONS.md              → Understand past choices
6. Identify your role from roles/roles.md
```

### Step 2 — Lock Check
```
IF .locked contains entries:
    IF your target files are listed → STOP, execute HANDOVER protocol
    IF your target files are NOT listed → proceed, register your lock
ELSE:
    Proceed and register your lock before writing
```

> 📖 Full locking rules: [`config/locking.config.md`](config/locking.config.md)
> 📖 Handover protocol: [`locks/HANDOVER.md`](locks/HANDOVER.md)

### Step 3 — Work
```
- Work in correct branch (NEVER write directly to `release`)
- Update file headers/comments in every file you touch
- Log decisions in memory/DECISIONS.md
- Keep changes atomic (one logical unit per commit)
```

> 📖 Branch strategy: [`config/branches.config.md`](config/branches.config.md)
> 📖 Code standards: [`Agent.md`](Agent.md) §6

### Step 4 — Close Session
```
1. Update docs/CHANGELOG.md
2. Update docs/DEPENDENCIES.md (if changed)
3. Update docs/TESTS.md (if changed)
4. Update memory/CONTEXT.md
5. Release your locks in locks/.locked
6. Append to locks/LOCK_REGISTRY.md
7. Commit with semantic message (see config/branches.config.md)
```

---

## 📝 File Header Standard

Every source file MUST contain a header with this information:

```
# FILE: <filename>
# PURPOSE: <one-line description>
# DEPENDS ON: <list of files this depends on>
# DEPENDED ON BY: <list of files that depend on this>
# LAST MODIFIED: <ISO8601 date>
# MODIFIED BY: <agent-id or human>
# CHANGE SUMMARY: <what changed and why>
# BRANCH: <which branch this applies to>
```

For code files, use appropriate comment syntax:
```python
# FILE: module.py | PURPOSE: ... | DEPENDS ON: config.py | ...
```
```javascript
// FILE: service.js | PURPOSE: ... | DEPENDS ON: db.js | ...
```

---

## 🔄 Periodic Optimisation Protocol

Every **5 agent sessions** OR on explicit request, run:
```
1. Review entire project structure for consolidation opportunities
2. Check for duplicate logic, redundant files
3. Audit dependencies (docs/DEPENDENCIES.md)
4. Propose consolidations to human before executing
5. Document changes in docs/CHANGELOG.md
```

---

## ⚙️ Environment Data & Secrets Management

- **Centralized Environment Configs (MANDATORY):** Alle umgebungsspezifischen Konfigurationen (wie URLs, Pfade, Hostnamen, Credentials) MÜSSEN zwingend in einer zentralen Datei gesammelt werden.
- **Unified Naming & Format:** Die Benennung dieser Datei muss über alle Repositories hinweg einheitlich sein. Als Standard wird `environment.json` (mit Pseudo-Kommentaren) oder `environment.yaml` / `.env` festgelegt.
- **Self-Documenting Comments:** In der Konfigurationsdatei (oder einer zugehörigen `.example`-Datei) MUSS im Zeilenkommentar immer genug Information stehen, um die Datei direkt ausfüllen zu können. Dies umfasst:
  - Beispielwerte & Defaults
  - Dummy-Daten
  - Klare Anforderungen (z.B. "Das Passwort muss mindestens 8 Zeichen lang sein und Sonderzeichen enthalten")
- **Separation of Code & Config:** Skripte müssen immer so geschrieben werden, dass das eigentliche Skript veröffentlicht werden kann ("publishable") und **keine privaten Daten** enthält.
- **Secure Storage (Settings):** Wenn spezifische Einstellungen getroffen werden (Client, Dienstname, Configs), müssen diese sicher, sortiert und getrennt gespeichert werden, sodass Skripte und Einstellungen wiederverwendet werden können.
- **Environment Inheritance:** Daten zum Environment müssen immer sicher passend abgespeichert werden und vererben sich automatisch auf die Unterordner.

---

## 🗑️ Dump- & WIP-Folder und Data Consolidation

- **🗑️ Dump-Folder (`dump/`):** Jedes Repository besitzt einen dedizierten Dump-Ordner, in dem Daten temporär abgelegt werden können.
  - **Tägliche Kontrolle:** Der Ordner wird 1x am Tag kontrolliert.
  - **Einsortierung:** Daten werden, wenn nötig nach Rückfrage, passend einsortiert.

- **🚧 WIP-Folder (`WIP/`):** Jedes Repository besitzt immer einen WIP-Ordner (vergleichbar mit einem Playground), um unfertige Sachen schnell zwischenzuspeichern.
  - **Monatliche Überprüfung:** Dieser Ordner wird 1x im Monat (wie das gesamte Repo) überprüft und aufgeräumt/konsolidiert.

- **Konsolidierungs-Prüfung:** Der Agent prüft bei den Bereinigungen, ob explizit eine Konsolidierung sinnvoll ist (z. B. bei verschiedenen Test-Versionen, anderen Ansätzen oder Überschneidungen mit Scripts/Configs anderer Projekten).
  - **Historien-Wiederherstellung:** Werden beim Aufräumen verschiedene Versionen einer Datei gefunden, MUSS der Agent versuchen, den zeitlichen Verlauf bzw. die Historie wiederherzustellen und diese konform und konsistent im Git zu speichern (z. B. durch sequenzielle Commits der Versionen).
- **Scope:** Der Prozess kann für das einzelne Repo oder für alle Repos im Workspace ausgelöst werden.

---

## 🧪 Automated Testing Standard (High-Fidelity Mock & Integration Testing)

Every repository and component MUST implement a rigorous, automated, non-elevated, and high-fidelity testing process that adheres to the following principles:

### 1. Separate Script-Driven Test Runner
- Create a dedicated test runner script (e.g., `tests/Run-FullTestSuite.ps1` or `tests/test_runner.py`) in the `tests/` directory.
- The test runner must execute fully unattended (non-interactive) without requiring human input or blocking the console.

### 2. High-Fidelity Test Environment Mocking
- **No-Privilege Mode Support:** Provide a clean mock-bypass toggle (e.g., `$global:BypassAdminCheck` or `$env:BYPASS_ADMIN_CHECK`) to safely bypass any required Administrator or system elevation checks.
- **Unattended Console Detection:** Ensure all interactive prompts, confirmation checks (e.g., "J/N" menus), and GUI prompts are bypassed under test/automation mode (e.g., overriding raw interactive console checks).
- **Mocking System/Network Actions:** Instead of failing on remote system calls, Active Directory pings, or SMTP transports, intercept them under test bypass mode to output realistic success logs and simulated return states.

### 3. Step-by-Step Function & Scenario Coverage
- **Step-by-Step Function Testing:** Separately verify each independent module, function, and parameter set of the codebase.
- **Dynamic Log Verification (`GenerateFromLog`):** Test the full roundtrip of state changes by ensuring outputs of a provisioning step are dynamically parsed and fed into downstream query/replay steps (e.g., re-running from logs).
- **Component and Standalone Testing:** Add tests for all supplementary templates, dashboards, and CLI session launchers (both dry-run summaries and connectivity-only modes).

### 4. Dummy/Local Data Requirements
- **Always Online Test Targets:** Use dummy/local test targets (e.g., `127.0.0.1` and `localhost` in `Clients_Test.csv`) for connection validation to ensure they are always online and reachable.
- **Controlled Test Dataset:** Maintain a representative dummy CSV/data set (e.g., `Users_Test_5.csv` representing participants, teachers, and admins) to exercise all branches.

### 5. Strict Error Catching and Validation
- **Exit Code Verification:** Ensure that non-zero exit codes or script exit statuses (`$LASTEXITCODE`) are intercepted inside the test block and thrown as terminating errors so that failures are caught.

---

## 🔖 Version Management & Auto-Commit Protocol

### Pflege von `version.json` und `package.json`

Der Agent ist verantwortlich für die Aktualität der Versionsdateien in jedem Workspace:

```
- version.json  → enthält { "version": "<semver>", "updated": "<ISO8601>" }
- package.json  → "version"-Feld muss mit version.json übereinstimmen
```

Bei jeder inhaltlichen Änderung am Code:
1. Semver erhöhen (patch / minor / major je nach Änderungstiefe)
2. Beide Dateien atomar aktualisieren
3. `Last Updated`-Felder in Datei-Headern und `MASTER_INSTRUCTIONS.md` § Meta anpassen

### Trigger — Wann wird automatisch committed?

Der Agent überwacht den aktiven Workspace kontinuierlich. Ein **Auto-Commit** wird ausgelöst, wenn **eines** der folgenden Ereignisse eintritt:

| Ereignis | Beschreibung |
|---|---|
| **Task erledigt** | Ein Checklist-Item wird in einer `task.md` oder `CONTEXT.md` auf `[x]` gesetzt |
| **version.json geändert** | Der `version`-Wert wurde erhöht |
| **package.json geändert** | Das `version`-Feld wurde geändert |
| **Explizite Anforderung** | Nutzer fordert einen Commit an |

### Auto-Commit-Ablauf

```
1. Diff analysieren   → git diff --staged oder alle ungestagten Änderungen prüfen
2. Commit-Message     → semantic, prägnant, auf Englisch:
                        <type>(<scope>): <summary>
                        Beispiele:
                          feat(auth): add JWT refresh token logic
                          fix(ui): correct button alignment on mobile
                          chore(deps): bump version to 1.4.2
3. Ausführen:
   git add .
   git commit -m "<generierte Message>"
   git push origin main
4. Meldung in der Inbox:
   ✅ Committed & pushed: "<commit-message>" → main
```

> ⚠️ **Regel:** Niemals direkt auf `release`-Branch pushen.
> Der Auto-Commit gilt immer für den Branch `main`, sofern kein anderer Branch aktiv ist.

> 📖 Branch-Strategie: [`config/branches.config.md`](config/branches.config.md)

---

## 📊 Prompt Library Reference

All reusable prompts are catalogued in:
> [`config/prompts.config.md`](config/prompts.config.md)

Categories: Code Review · Debugging · Refactoring · Architecture · Testing · Performance · Tooling & DevOps

---

## 🌐 Sources & References

All external references: [`docs/SOURCES.md`](docs/SOURCES.md)

Key references:
- Semantic versioning: `https://semver.org/`
- Conventional commits: `https://www.conventionalcommits.org/`
- EditorConfig: `https://editorconfig.org/`
- Git flow: `https://nvie.com/posts/a-successful-git-branching-model/`

---

## ⚡ Emergency Restart Checklist

If project context is lost, execute in order:

```
☐ 1. git clone / git pull latest from release branch
☐ 2. Read Agent.md                          → Identity & rules
☐ 3. Read this file (MASTER_INSTRUCTIONS.md) → Startup protocol
☐ 4. Read memory/CONTEXT.md                 → Current state
☐ 5. Read memory/DECISIONS.md              → Past decisions
☐ 6. Read docs/CHANGELOG.md (last 10 entries)
☐ 7. Check locks/.locked for active sessions
☐ 8. Read locks/LOCK_REGISTRY.md for history
☐ 9. Proceed with Step 1 of Agent Session Protocol above
```

---

*This file must be updated whenever the framework changes significantly.*
*All agents are responsible for keeping this file accurate.*
