#!/usr/bin/env bash
# ============================================================
# FILE: scripts/dump-processor.sh
# PURPOSE: Detect and guide processing of dump/inbox/ files
# DEPENDS ON: dump/inbox/, .agent/config/prompts.config.md
# DEPENDED ON BY: Maintainer agents (R-05), health-check.sh
# USAGE: bash scripts/dump-processor.sh [--auto-list]
# ============================================================

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INBOX="$REPO_ROOT/dump/inbox"
PROCESSED="$REPO_ROOT/dump/processed"

echo -e "${BOLD}${CYAN}📥 Dump Zone Processor${NC}"
echo "$(printf '─%.0s' {1..55})"

# ── Check inbox ───────────────────────────────────────────────
FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$INBOX" -type f -print0 2>/dev/null)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo -e "${GREEN}✅ Dump inbox is empty — nothing to process${NC}"
  exit 0
fi

echo -e "${YELLOW}🟡 Found ${#FILES[@]} file(s) in dump/inbox/${NC}"
echo ""

for i in "${!FILES[@]}"; do
  echo -e "  ${BLUE}[$((i+1))] ${FILES[$i]##*/}${NC}"
  echo -e "      Size: $(du -sh "${FILES[$i]}" | cut -f1) | Modified: $(date -r "${FILES[$i]}" '+%Y-%m-%d %H:%M')"
done

echo ""
echo -e "${BOLD}⚠️  HUMAN CONFIRMATION REQUIRED${NC}"
echo -e "${YELLOW}The following action requires your approval:${NC}"
echo ""
echo "  Analyse and integrate the above file(s) into the project structure."
echo "  This will:"
echo "    1. Apply code review prompts (security, red-flags, best-practice)"
echo "    2. Propose an integration target location"
echo "    3. Move files to dump/processed/ with analysis notes"
echo "    4. Update CHANGELOG.md, CONTEXT.md, SOURCES.md"
echo ""
echo -e "${BOLD}Prompts that will be applied (from prompts.config.md):${NC}"
echo "  → red-flag-sniff → security-pass → dead-code-sweep"
echo "  → best-practice-lens → dependency-audit → comment-layer"
echo ""

if [[ "${1:-}" == "--auto-list" ]]; then
  echo -e "${BLUE}ℹ️  Running in --auto-list mode (listing only, no processing)${NC}"
  exit 0
fi

echo -e "${YELLOW}Reply YES to this prompt in your agent/chat interface to proceed.${NC}"
echo -e "${YELLOW}Or run: bash scripts/dump-processor.sh --process after approval.${NC}"

if [[ "${1:-}" == "--process" ]]; then
  # Automated processing stub — agents fill in the actual analysis
  echo ""
  echo -e "${GREEN}🔵 Processing mode active...${NC}"
  for f in "${FILES[@]}"; do
    fname=$(basename "$f")
    timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    processed_file="$PROCESSED/${fname%.${fname##*.}}-processed-$(date +%Y%m%d%H%M%S).md"
    
    echo -e "${BLUE}[→] Processing: $fname${NC}"
    
    # Write analysis header
    cat > "$processed_file" <<HEADER
---
# DUMP ANALYSIS — $fname
- **Received:** $timestamp
- **Processed By:** dump-processor.sh (agent should complete this)
- **Original Source:** dump/inbox/$fname
- **Analysis Summary:** [AGENT: Complete this]
- **Prompts Applied:** red-flag-sniff, security-pass, dead-code-sweep, best-practice-lens, dependency-audit, comment-layer
- **Issues Found:** [AGENT: List or "none"]
- **Optimisations Applied:** [AGENT: List or "none"]
- **Integration Target:** [AGENT: Propose path]
- **Human Approved By:** [AGENT: Record approval]
- **Integration Date:** $timestamp
---

HEADER
    # Append original content
    cat "$f" >> "$processed_file"
    
    echo -e "  ${GREEN}✅ Staged to: $processed_file${NC}"
    echo -e "  ${YELLOW}⚠️  Agent must complete the analysis header and propose integration target${NC}"
  done
  
  echo ""
  echo -e "${CYAN}Next steps for agent:${NC}"
  echo "  1. Open each file in dump/processed/"
  echo "  2. Complete analysis header fields"
  echo "  3. Apply prompts from prompts.config.md"
  echo "  4. Propose integration target to human"
  echo "  5. On approval: copy to target, update docs"
fi
