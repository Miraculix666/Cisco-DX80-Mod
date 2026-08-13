agent-framework/
├── 🤖 .agent/                    ← Framework brain
│   ├── MASTER_INSTRUCTIONS.md    ← THE restart file — every agent reads this first
│   ├── config/
│   │   ├── agent.config.md       ← Modes, personas, output standards
│   │   ├── locking.config.md     ← HARD/SOFT/REQ/SHARED lock system 🔴 Hard-locked
│   │   ├── branches.config.md    ← release + dev strategy, semver, rollback
│   │   └── prompts.config.md     ← All 50+ prompts catalogued (7 categories)
│   ├── roles/                    ← 7 agent roles + full capabilities matrix 🔴 Hard-locked
│   ├── locks/                    ← .locked (JSON), HANDOVER.md, LOCK_REGISTRY.md
│   ├── memory/                   ← CONTEXT.md (live state), DECISIONS.md (ADR log)
│   └── templates/                ← task / PR / review templates
├── 📚 docs/                      ← CHANGELOG, DEPENDENCIES, TESTS, ARCHITECTURE, SOURCES
├── 📥 dump/inbox/                ← Drop-zone (confirmation-gated, never auto-processed)
├── ⚙️ scripts/                   ← health-check, lock-manager, dump-processor, consolidate
├── 🔄 .github/workflows/         ← CI + Release + WIP pipelines (GitLab .gitlab-ci.yml too)
├── .editorconfig + .gitignore
└── README.md

Key Design Decisions
Topic	Solution
Restart safety	MASTER_INSTRUCTIONS.md — single file with complete context, session protocol, and emergency checklist
Multi-agent locking	JSON .locked with HARD/SOFT/REQ/SHARED types; lock-manager.sh CLI; HANDOVER.md protocol
Instruction permanence	All instructions consolidated in MASTER_INSTRUCTIONS.md; cascaded to all dependent files
Branch strategy	release (PR-only, protected) + dev (agent-writable); semantic commits; git revert rollback
Dump zone	dump/inbox/ with mandatory human confirmation before any processing
Consolidation	Counter in CONTEXT.md; consolidate.sh runs every 5 sessions
Sources	All external links catalogued in docs/SOURCES.md with S-NNNN IDs
Specialisation	src/module/.agent/ sub-folders inherit + extend root config

