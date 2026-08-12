# 📚 Prompt Library Configuration

> **FILE:** `.agent/config/prompts.config.md`
> **PURPOSE:** Centralised, reusable prompt catalogue for all agent code review, debug, and analysis tasks
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`
> **DEPENDED ON BY:** All agents performing code analysis
> **SOURCES:** See `docs/SOURCES.md` — Prompt Library v1.0
> **LAST MODIFIED:** See git log

---

## 🗂️ Categories

| # | Category | Prompts |
|---|---|---|
| 1 | 🔍 [Code Review](#1--code-review) | Style Audit, Security Pass, Red Flag Sniff, Dead Code Sweep, Complexity Scan, Comment Layer, Best Practice Lens |
| 2 | 🐛 [Debugging](#2--debugging) | Trace Fails, Chain Analysis, State Snapshot, Debug Scenarios, Log Strategy, Fix Suggestion, Refactor Before Debug, Unit Isolate |
| 3 | ♻️ [Refactoring](#3--refactoring) | One Function Wonder, Layer Separation, Refactor Review, DRY Pass, Modular Extract, Naming Clinic, Error Handling Lift |
| 4 | 🏛️ [Architecture](#4--architecture) | Service Map, Decouple Plan, Boundary Define, Folder Logic, Rewrite as Microservice, Dependency Audit, Pattern Overlay |
| 5 | 🧪 [Testing](#5--testing) | Test Coverage Gap, Stress Scenario, Flaky Test Hunt, Input Fuzzing, Test Skeleton, Mock Strategy, Test Suite Review |
| 6 | ⚡ [Performance](#6--performance) | Loop Tune, Parallelize It, Lazy Eval Swap, DB Call Shrink, Memory Map, Batch Pipeline, Resource Cleanup, Big O Guess, Hot Path Focus, Profile Compare |
| 7 | 🛠️ [Tooling & DevOps](#7--tooling--devops) | CLI Wrapper, CI Pipeline Fix, Perf Profiler, Precommit Setup, Code Metrics Dump, Editor Settings, Dev Tool Stack |

---

## 1 🔍 Code Review

### `style-audit`
**Trigger:** Style inconsistencies, naming issues, unclear comments
```
Audit this code for style consistency, naming conventions, and comment clarity.
Return suggestions organised by file and priority.
```

### `security-pass`
**Trigger:** Before any PR to release, new external integrations
```
Review this code for security vulnerabilities, edge cases, and common exploits.
Output: risks (table), affected lines, and suggested fixes.
```

### `red-flag-sniff`
**Trigger:** After large features, new contributors, inherited code
```
Scan this repo for anti-patterns, overengineering, or unnecessary complexity.
Rank red flags by severity (Critical / High / Medium / Low).
```

### `dead-code-sweep`
**Trigger:** Before release, after major refactors
```
Identify and list any dead code, unused imports, or redundant logic in this project.
Suggest removals with justification for each.
```

### `complexity-scan`
**Trigger:** Functions suspected of high complexity
```
Analyse this function for cyclomatic complexity.
Recommend simplifications if complexity score is over 10.
Include: current score, contributing factors, refactored version.
```

### `comment-layer`
**Trigger:** Code with poor or missing documentation
```
Rewrite comments in this codebase to better explain intent, not just logic.
Focus on WHY, not WHAT. Return updated file.
```

### `best-practice-lens`
**Trigger:** Module reviews, onboarding new code
```
Run a best practice audit on this module.
Highlight deviations and suggest better idioms for this language/framework.
Return: deviation table, severity, suggested replacement.
```

---

## 2 🐛 Debugging

### `trace-fails`
**Trigger:** Unclear bug location, runtime errors
```
Step through this code and narrate what it's doing line-by-line until the bug appears.
Include: line number, state at that point, what went wrong and why.
```

### `chain-analysis`
**Trigger:** Crash of unknown origin, complex call stacks
```
Map the full call chain leading to this crash.
Visualise in text/ASCII and highlight critical dependencies.
```

### `state-snapshot`
**Trigger:** Hard-to-reproduce bugs, state corruption
```
At this failure point, what are all state variables and their values?
Simulate the exact stack trace and memory state at time of crash.
```

### `debug-scenarios`
**Trigger:** Understanding bug reproduction surface
```
Generate 5 debugging scenarios that could trigger this same bug.
Vary user inputs and edge cases. Include expected vs actual output for each.
```

### `log-strategy`
**Trigger:** Need observability without full debug session
```
Insert strategic log statements to pinpoint where the bug is emerging.
Return updated code with logs, and explain why each log point was chosen.
```

### `fix-suggestion`
**Trigger:** Have an error log, need triage
```
Diagnose and suggest a fix for this error log.
Return three potential causes with ranked likelihoods (%) and a fix for each.
```

### `refactor-before-debug`
**Trigger:** Code too messy to debug effectively
```
Refactor this messy block before debugging.
Clean up logic, separate concerns, and reindent for clarity.
Return cleaned version, then identify the likely bug location.
```

### `unit-isolate`
**Trigger:** Bug needs minimal reproducible test case
```
Write a unit test to isolate this bug.
Keep inputs minimal and make failure clearly visible.
Include: test code, expected output, why it isolates the issue.
```

---

## 3 ♻️ Refactoring

### `one-function-wonder`
**Trigger:** Repeated inline logic, long procedural sequences
```
Collapse this sequence into a single reusable, named function.
Improve readability and reduce repetition.
Return: function signature, implementation, and all call sites updated.
```

### `layer-separation`
**Trigger:** Mixed concerns (data + business + UI in one file)
```
Restructure this file to clearly separate concerns:
data access layer, business logic layer, and UI/presentation layer.
Return refactored structure with file split recommendations.
```

### `refactor-review`
**Trigger:** Evaluating recent refactor quality
```
Evaluate this recent refactor. Was it an improvement?
Return: what improved, what regressed, where it could still be improved.
```

### `dry-pass`
**Trigger:** Duplicated code across files
```
Find all repeated logic and abstract into shared utilities or constants.
Return proposed diffs and the new shared utility location.
```

### `modular-extract`
**Trigger:** Class or module too large or tightly coupled
```
Extract this class into its own module.
Show before/after import/export changes and any interface adjustments.
```

### `naming-clinic`
**Trigger:** Cryptic variable/function names
```
Rename variables and functions here for better intent and consistency.
Avoid cryptic abbreviations. Return: old name → new name table + updated code.
```

### `error-handling-lift`
**Trigger:** Scattered try/catch, inconsistent error handling
```
Lift all error handling into a centralised strategy.
Use custom exceptions where needed. Return: error hierarchy + updated code.
```

---

## 4 🏛️ Architecture

### `service-map`
**Trigger:** Onboarding, architecture review, documentation
```
Map all services, their responsibilities, and interactions.
Return as a hierarchy and/or ASCII flowchart with dependency arrows.
```

### `decouple-plan`
**Trigger:** Tightly coupled modules causing change cascades
```
How would you decouple this tightly-bound logic into swappable modules or services?
Return: current coupling analysis, proposed interfaces, migration steps.
```

### `boundary-define`
**Trigger:** Unclear service/component/data responsibilities
```
Define clear boundaries for services, components, and data layers in this system.
Return as tables: component, owns, does NOT own, external interfaces.
```

### `folder-logic`
**Trigger:** Messy project structure, domain logic unclear
```
Restructure this project's folder layout to better reflect domain logic and responsibilities.
Return: before/after tree, migration steps, rationale.
```

### `rewrite-as-microservice`
**Trigger:** Monolith extraction, scalability needs
```
Rewrite this monolithic logic as a microservice.
Include: endpoint list, data model, key concerns, and inter-service communication strategy.
```

### `dependency-audit`
**Trigger:** Before releases, periodic maintenance
```
List all external dependencies.
Flag: unnecessary, outdated (CVE or version lag), or risky ones.
Return as table: package, version, status (🟢/🟡/🔴), action.
```

### `pattern-overlay`
**Trigger:** Structural design decisions
```
Suggest a design pattern (e.g., Factory, Strategy, Observer) for this structure.
Justify the fit, show implementation sketch, and note tradeoffs.
```

---

## 5 🧪 Testing

### `test-coverage-gap`
**Trigger:** Pre-release coverage audit
```
Identify logic in this file not covered by any existing tests.
List uncovered blocks by function with: lines, risk level, suggested test.
```

### `stress-scenario`
**Trigger:** Performance and concurrency validation
```
Write a stress test to simulate high load or concurrency conditions for this function.
Include: load profile, expected behaviour, failure modes to watch.
```

### `flaky-test-hunt`
**Trigger:** CI with intermittent failures
```
Analyse recent test runs to identify and explain likely sources of flaky tests.
Return: test name, flakiness reason, fix recommendation.
```

### `input-fuzzing`
**Trigger:** Security and robustness validation
```
Generate a fuzz test for this function to catch unusual edge cases and input types.
Include: input space coverage, boundary cases, malformed inputs.
```

### `test-skeleton`
**Trigger:** New module with no tests
```
Generate a test skeleton for this module with stubbed unit and integration test cases.
Include: describe blocks, it/test cases, mock placeholders.
```

### `mock-strategy`
**Trigger:** Tests with external dependencies
```
Write a mocking strategy for external dependencies in these tests.
Include sample mocks and explain when to use mock vs real dependency.
```

### `test-suite-review`
**Trigger:** Existing test suite quality check
```
Review this test suite for: redundancy, missing edge cases, over-specification.
Return: findings table and recommended additions/removals.
```

---

## 6 ⚡ Performance

### `loop-tune`
**Trigger:** Slow loops, O(n²) suspicions
```
Analyse this loop for unnecessary operations or performance issues.
Suggest rewrites to reduce time complexity. Show before/after Big O.
```

### `parallelize-it`
**Trigger:** Sequential code that could benefit from concurrency
```
Which parts of this function can be safely parallelised or async'd?
Add a threading/async strategy with code example.
```

### `lazy-eval-swap`
**Trigger:** Eager loading large datasets unnecessarily
```
Rewrite this code to use lazy evaluation or generators.
Return revised version with explanations of memory savings.
```

### `db-call-shrink`
**Trigger:** N+1 queries, high DB call volume
```
Reduce the number of database calls made by this function.
Suggest caching or batching strategies with implementation example.
```

### `memory-map`
**Trigger:** High memory usage, suspected leaks
```
Profile this code's memory usage.
Identify: leaks, large allocations, repeated object creation.
Return: memory timeline, hotspots, fixes.
```

### `batch-pipeline`
**Trigger:** Row-by-row processing bottlenecks
```
Convert this row-by-row logic into a batch-processing pipeline.
Use streaming or vectorised ops where applicable.
```

### `resource-cleanup`
**Trigger:** File/socket/DB connection management
```
Ensure all resources (files, sockets, DB connections) are properly closed.
Add guards or context managers where missing. Return updated code.
```

### `big-o-guess`
**Trigger:** Algorithm complexity analysis
```
Estimate the time and space complexity of this algorithm.
Justify each part with reasoning. Return: Time O(), Space O(), breakdown.
```

### `hot-path-focus`
**Trigger:** Profiling identified bottleneck
```
Find and optimise the hot path in this logic.
Show before/after performance benchmarks (simulated or measured).
```

### `profile-compare`
**Trigger:** After performance change, need validation
```
Compare performance before and after this change.
Return benchmark diff and tradeoffs (speed vs readability vs memory).
```

---

## 7 🛠️ Tooling & DevOps

### `cli-wrapper`
**Trigger:** Script needs a proper interface
```
Wrap this script into a CLI tool using the language's standard library.
Include: argument parsing, help text, error handling, exit codes.
```

### `ci-pipeline-fix`
**Trigger:** Broken CI/CD
```
Fix this broken CI pipeline.
Show updated YAML and explain each fix with root cause analysis.
```

### `perf-profiler`
**Trigger:** Code block suspected of being slow
```
Run a simulated performance profiling on this code block.
Suggest optimisations if simulated time exceeds 100ms.
```

### `precommit-setup`
**Trigger:** New project setup, enforce code quality
```
Generate a Git pre-commit hook config to lint, format, and run tests before pushing.
Support: .pre-commit-config.yaml, husky, or manual hook scripts.
```

### `code-metrics-dump`
**Trigger:** Project health overview
```
Produce a table of code metrics:
lines per function, file size, comment ratio, test coverage %, complexity scores.
```

### `editor-settings`
**Trigger:** New team member onboarding, consistency
```
Generate .editorconfig and VSCode settings.json to enforce consistent dev standards.
Include: indentation, line endings, charset, rulers, format-on-save.
```

### `dev-tool-stack`
**Trigger:** New project, language ecosystem setup
```
Recommend a modern tool stack (linters, formatters, debuggers, profilers) for this language ecosystem.
Return: tool, purpose, config snippet, integration method.
```

---

## 🔧 Using Prompts

### Direct Use (any LLM/agent)
```
1. Copy the prompt text from the relevant section above
2. Append your code/context after the prompt
3. Include: language, framework version, error messages if applicable
```

### Structured Agent Use
```yaml
prompt_id: "security-pass"
context:
  language: "python"
  framework: "fastapi"
  code: "<paste code>"
  error_log: "<optional>"
output_format: "markdown table + code blocks"
```

### Chaining Prompts
```
Recommended chains for common tasks:

🔴 Pre-release review:
  dead-code-sweep → security-pass → test-coverage-gap → dependency-audit

🐛 Bug investigation:
  trace-fails → chain-analysis → state-snapshot → unit-isolate → fix-suggestion

♻️ Refactor project:
  complexity-scan → refactor-before-debug → dry-pass → layer-separation → test-skeleton

🏛️ New architecture:
  service-map → boundary-define → pattern-overlay → decouple-plan → folder-logic
```

---

*This prompt library is sourced from the project's prompt collection.*
*Add new prompts by appending to the relevant category and updating docs/SOURCES.md.*
