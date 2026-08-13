#!/usr/bin/env bash
# ============================================================
# FILE: scripts/health-check.sh
# PURPOSE: Validate framework integrity — all docs in sync,
#          no stale locks, branches configured, dump clear
# DEPENDS ON: .agent/locks/.locked, all .agent/docs/
# DEPENDED ON BY: CI/CD pipelines, Maintainer agents (R-05)
# LAST MODIFIED: See git log
# ============================================================

set -euo pipefail

# ── Colours & Symbols ────────────────────────────────────────
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

OK="✅"; WARN="🟡"; FAIL="❌"; INFO="🔵"; LOCK="🔒"

PASS=0; WARNINGS=0; FAILURES=0

# ── Helpers ──────────────────────────────────────────────────
pass()  { echo -e "${GREEN}${OK} $1${NC}"; ((PASS++)) || true; }
warn()  { echo -e "${YELLOW}${WARN} $1${NC}"; ((WARNINGS++)) || true; }
fail()  { echo -e "${RED}${FAIL} $1${NC}"; ((FAILURES++)) || true; }
info()  { echo -e "${BLUE}${INFO} $1${NC}"; }
header(){ echo -e "\n${BOLD}${CYAN}$1${NC}"; echo "$(printf '─%.0s' {1..55})"; }

# ── Header ───────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║      🤖 AGENT FRAMEWORK HEALTH CHECK         ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  $(date '+%Y-%m-%d %H:%M:%S')                          ║"
echo "╚══════════════════════════════════════════════╝${NC}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

# ── [1/6] Required Files ─────────────────────────────────────
header "[1/6] 📋 Required Files Check"
REQUIRED_FILES=(
  "README.md"
  ".agent/MASTER_INSTRUCTIONS.md"
  ".agent/config/agent.config.md"
  ".agent/config/locking.config.md"
  ".agent/config/branches.config.md"
  ".agent/config/prompts.config.md"
  ".agent/roles/roles.md"
  ".agent/locks/.locked"
  ".agent/locks/HANDOVER.md"
  ".agent/locks/LOCK_REGISTRY.md"
  ".agent/memory/CONTEXT.md"
  ".agent/memory/DECISIONS.md"
  ".agent/docs/CHANGELOG.md"
  ".agent/docs/DEPENDENCIES.md"
  ".agent/docs/TESTS.md"
  ".agent/docs/ARCHITECTURE.md"
  ".agent/docs/SOURCES.md"
  ".agent/dump/README.md"
)
for f in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    pass "$f"
  else
    fail "MISSING: $f"
  fi
done

# ── [2/6] Lock File Validity ──────────────────────────────────
header "[2/6] 🔒 Lock File Validation"
LOCK_FILE=".agent/locks/.locked"
if command -v python3 &>/dev/null; then
  if python3 -c "import json; json.load(open('$LOCK_FILE'))" 2>/dev/null; then
    pass ".locked is valid JSON"
    NOW=$(date +%s)
    mapfile -t stats <<< "$(python3 -c "
import json, datetime
try:
    with open('$LOCK_FILE') as f:
        data = json.load(f)
    locks = data.get('locks', [])
    hard = sum(1 for l in locks if l.get('type') == 'HARD')
    soft = sum(1 for l in locks if l.get('type') == 'SOFT')
    stale = []
    for l in locks:
        if l.get('type') in ('SOFT', 'REQ') and l.get('expires_at'):
            exp = datetime.datetime.fromisoformat(l['expires_at'].replace('Z','+00:00'))
            if exp.timestamp() < $NOW:
                stale.append(l['id'])
    print(len(locks))
    print(hard)
    print(soft)
    print(','.join(stale))
except Exception:
    pass
")"
    LOCK_COUNT="${stats[0]:-0}"
    HARD_COUNT="${stats[1]:-0}"
    SOFT_COUNT="${stats[2]:-0}"
    STALE="${stats[3]:-}"
    info "Total locks: $LOCK_COUNT (${RED}HARD: $HARD_COUNT${NC}${BLUE}, SOFT: $SOFT_COUNT${NC})"
    if [[ -z "$STALE" ]]; then
      pass "No stale locks detected"
    else
      warn "Stale locks found: $STALE — run: bash scripts/lock-manager.sh clear-stale <id>"
    fi
  else
    fail ".locked is NOT valid JSON — lock system broken"
  fi
else
  warn "python3 not available — skipping JSON lock validation"
fi

# ── [3/6] Dump Inbox ─────────────────────────────────────────
header "[3/6] 📥 Dump Inbox Check"
INBOX_FILES=$(find .agent/dump/inbox/ -type f 2>/dev/null | wc -l)
if [[ "$INBOX_FILES" -eq 0 ]]; then
  pass "Dump inbox is empty 🟢"
else
  warn "Dump inbox has $INBOX_FILES file(s) awaiting processing"
  find .agent/dump/inbox/ -type f | while read -r f; do
    echo -e "     ${YELLOW}→ $f${NC}"
  done
  echo -e "  ${YELLOW}Run: bash scripts/dump-processor.sh${NC}"
fi

# ── [4/6] Git Status ─────────────────────────────────────────
header "[4/6] 🌿 Git Branch & Status"
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  info "Current branch: ${BOLD}$BRANCH${NC}"
  if [[ "$BRANCH" == "release" ]]; then
    warn "Currently on RELEASE branch — be careful, no direct commits"
  elif [[ "$BRANCH" == "dev" || "$BRANCH" == "wip" ]]; then
    pass "On development branch ($BRANCH)"
  else
    info "On feature/fix branch: $BRANCH"
  fi
  # Uncommitted changes
  if git diff --quiet && git diff --staged --quiet; then
    pass "No uncommitted changes"
  else
    warn "Uncommitted changes detected"
    git status --short | head -10
  fi
else
  warn "Not a git repository or git not available"
fi

# ── [5/6] Consolidation Check ────────────────────────────────
header "[5/6] ♻️ Consolidation Review Status"
CONTEXT_FILE=".agent/memory/CONTEXT.md"
if [[ -f "$CONTEXT_FILE" ]]; then
  SESSIONS=$(grep -o "Sessions Since Last Consolidation Review.*" "$CONTEXT_FILE" | grep -o '[0-9]*' | head -1 || echo "0")
  if [[ -n "$SESSIONS" && "$SESSIONS" -ge 5 ]]; then
    warn "Consolidation review overdue ($SESSIONS sessions since last review)"
    echo -e "  ${YELLOW}Run: bash scripts/consolidate.sh${NC}"
  else
    pass "Consolidation review not yet due ($SESSIONS/5 sessions)"
  fi
else
  warn "CONTEXT.md not found — cannot check consolidation status"
fi

# ── [6/6] Doc Headers Spot Check ─────────────────────────────
header "[6/6] 📝 Documentation Spot Check"
for f in .agent/docs/CHANGELOG.md .agent/docs/DEPENDENCIES.md .agent/docs/TESTS.md; do
  if grep -q "LAST MODIFIED" "$f" 2>/dev/null; then
    pass "$f has required header fields"
  else
    warn "$f missing header metadata"
  fi
done

# ── Summary ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║               HEALTH SUMMARY                 ║${NC}"
echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${GREEN}${OK} Passed:   $PASS${NC}$(printf '%*s' $((35 - ${#PASS})) '')${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${YELLOW}${WARN} Warnings: $WARNINGS${NC}$(printf '%*s' $((35 - ${#WARNINGS})) '')${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${RED}${FAIL} Failures: $FAILURES${NC}$(printf '%*s' $((35 - ${#FAILURES})) '')${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"

if [[ $FAILURES -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}🔴 Health check FAILED — address failures before proceeding${NC}"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "\n${YELLOW}${BOLD}🟡 Health check PASSED with warnings${NC}"
  exit 0
else
  echo -e "\n${GREEN}${BOLD}🟢 All systems nominal!${NC}"
  exit 0
fi
