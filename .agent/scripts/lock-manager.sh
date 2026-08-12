#!/usr/bin/env bash
# ============================================================
# FILE: scripts/lock-manager.sh
# PURPOSE: CLI utility for managing agent file locks
# DEPENDS ON: .agent/locks/.locked, .agent/locks/LOCK_REGISTRY.md
# DEPENDED ON BY: All agents, CI/CD
# USAGE: bash scripts/lock-manager.sh <command> [args]
# ============================================================

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_FILE="$REPO_ROOT/.agent/locks/.locked"
REGISTRY_FILE="$REPO_ROOT/.agent/locks/LOCK_REGISTRY.md"

# ── Require python3 ──────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo -e "${RED}❌ python3 required for lock-manager${NC}"
  exit 1
fi

# ── Commands ──────────────────────────────────────────────────
usage() {
  echo -e "${BOLD}${CYAN}🔒 Lock Manager — Usage${NC}"
  echo ""
  echo "  bash scripts/lock-manager.sh status"
  echo "  bash scripts/lock-manager.sh lock <path> <SOFT|REQ|SHARED> <agent-id> <reason>"
  echo "  bash scripts/lock-manager.sh release <lock-id> <agent-id>"
  echo "  bash scripts/lock-manager.sh clear-stale <lock-id>"
  echo "  bash scripts/lock-manager.sh history [--last N]"
  echo "  bash scripts/lock-manager.sh check <path>"
  echo ""
}

cmd_status() {
  echo -e "${BOLD}${CYAN}🔒 Current Lock State${NC}"
  echo "$(printf '─%.0s' {1..55})"
  python3 - <<'EOF'
import json, sys, datetime

with open(".agent/locks/.locked") as f:
    data = json.load(f)

locks = data.get("locks", [])
if not locks:
    print("✅ No active locks")
    last_updated = data.get('last_updated', '?')
    print(f'\n\033[0;34mLast updated: {last_updated}\033[0m')
    sys.exit(0)

now = datetime.datetime.now(datetime.timezone.utc)

print(f"{'ID':<12} {'Type':<6} {'File':<35} {'Agent':<20} {'Expires'}")
print("─" * 95)
for l in locks:
    lock_id = l.get("id", "?")[:11]
    ltype = l.get("type", "?")
    fpath = l.get("file_or_folder", "?")[:34]
    agent = l.get("locked_by", "?")[:19]
    expires = l.get("expires_at") or "never"
    
    if ltype == "HARD":
        colour = "\033[0;31m"
    elif expires != "never":
        try:
            exp = datetime.datetime.fromisoformat(expires.replace("Z", "+00:00"))
            colour = "\033[1;33m" if exp < now else "\033[0;32m"
        except:
            colour = "\033[0;34m"
    else:
        colour = "\033[0;34m"
    
    print(f"{colour}{lock_id:<12} {ltype:<6} {fpath:<35} {agent:<20} {expires}\033[0m")
last_updated = data.get('last_updated', '?')
print(f'\n\033[0;34mLast updated: {last_updated}\033[0m')
EOF
}

cmd_lock() {
  local path="$1" ltype="$2" agent="$3" reason="$4"
  
  # Validate type
  if [[ ! "$ltype" =~ ^(SOFT|REQ|SHARED)$ ]]; then
    echo -e "${RED}❌ Invalid lock type: $ltype (use SOFT, REQ, or SHARED)${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}🔵 Acquiring $ltype lock on: $path${NC}"
  
  python3 - "$path" "$ltype" "$agent" "$reason" <<'EOF'
import json, sys, uuid, datetime

path, ltype, agent, reason = sys.argv[1:]

with open(".agent/locks/.locked") as f:
    data = json.load(f)

# Check for conflicts
for l in data.get("locks", []):
    if l.get("file_or_folder") == path:
        if l.get("type") == "HARD":
            print(f"\033[0;31m❌ HARD lock on {path} — cannot acquire (human only)\033[0m")
            sys.exit(1)
        if l.get("type") in ("SOFT", "REQ") and l.get("locked_by") != agent:
            print(f"\033[1;33m🟡 File locked by {l['locked_by']} — initiate HANDOVER protocol\033[0m")
            sys.exit(1)

now = datetime.datetime.now(datetime.timezone.utc)
expires_hours = {"SOFT": 4, "REQ": 0.5, "SHARED": 1}
expires = now + datetime.timedelta(hours=expires_hours[ltype])

lock_id = "lock-" + str(uuid.uuid4())[:8]
new_lock = {
    "id": lock_id,
    "file_or_folder": path,
    "scope": "file",
    "type": ltype,
    "locked_by": agent,
    "locked_at": now.isoformat(),
    "expires_at": expires.isoformat(),
    "reason": reason,
    "handover_required": ltype in ("SOFT", "REQ"),
    "handover_to": None,
    "metadata": {}
}

data["locks"].append(new_lock)
data["last_updated"] = now.isoformat()
data["updated_by"] = agent

with open(".agent/locks/.locked", "w") as f:
    json.dump(data, f, indent=2)

print(f"\033[0;32m✅ Lock acquired: {lock_id}\033[0m")
print(f"   Type: {ltype} | Expires: {expires.isoformat()}")
EOF
}

cmd_release() {
  local lock_id="$1" agent="$2"
  echo -e "${BLUE}🔓 Releasing lock: $lock_id${NC}"
  
  python3 - "$lock_id" "$agent" "$REGISTRY_FILE" <<'EOF'
import json, sys, datetime

lock_id, agent, registry = sys.argv[1:]

with open(".agent/locks/.locked") as f:
    data = json.load(f)

found = None
found_idx = -1
for i, l in enumerate(data["locks"]):
    if l["id"] == lock_id:
        found = l
        found_idx = i
        break

if not found:
    print(f"\033[0;31m❌ Lock {lock_id} not found\033[0m")
    sys.exit(1)

if found["type"] == "HARD":
    print(f"\033[0;31m❌ Cannot release HARD lock — requires human\033[0m")
    sys.exit(1)

if found["locked_by"] != agent:
    print(f"\033[1;33m🟡 Lock owned by {found['locked_by']} — use handover protocol\033[0m")
    sys.exit(1)

del data["locks"][found_idx]
now = datetime.datetime.now(datetime.timezone.utc).isoformat()
data["last_updated"] = now
data["updated_by"] = agent

with open(".agent/locks/.locked", "w") as f:
    json.dump(data, f, indent=2)

# Append to registry
with open(registry, "a") as f:
    f.write(f"\n---\n\n### Released — {now}\n\n")
    f.write(f"| Field | Value |\n|---|---|\n")
    f.write(f"| Lock ID | {lock_id} |\n")
    f.write(f"| File | `{found['file_or_folder']}` |\n")
    f.write(f"| Type | {found['type']} |\n")
    f.write(f"| Agent | {agent} |\n")
    f.write(f"| Start | {found['locked_at']} |\n")
    f.write(f"| End | {now} |\n")
    f.write(f"| Outcome | completed |\n")
    f.write(f"| Notes | Released by {agent} |\n")

print(f"\033[0;32m✅ Lock {lock_id} released and logged to registry\033[0m")
EOF
}

cmd_clear_stale() {
  local lock_id="$1"
  echo -e "${YELLOW}🟡 Clearing stale lock: $lock_id${NC}"
  
  python3 - "$lock_id" "$REGISTRY_FILE" <<'EOF'
import json, sys, datetime

lock_id, registry = sys.argv[1:]

with open(".agent/locks/.locked") as f:
    data = json.load(f)

found = None
found_idx = -1
for i, l in enumerate(data["locks"]):
    if l["id"] == lock_id:
        found = l
        found_idx = i
        break

if not found:
    print(f"\033[0;31m❌ Lock {lock_id} not found\033[0m")
    sys.exit(1)

if found["type"] == "HARD":
    print(f"\033[0;31m❌ Cannot clear HARD lock\033[0m")
    sys.exit(1)

now = datetime.datetime.now(datetime.timezone.utc)
if found.get("expires_at"):
    exp = datetime.datetime.fromisoformat(found["expires_at"].replace("Z", "+00:00"))
    if exp > now:
        print(f"\033[1;33m🟡 Lock not stale yet (expires {exp.isoformat()}) — use release instead\033[0m")
        sys.exit(1)

del data["locks"][found_idx]
data["last_updated"] = now.isoformat()
data["updated_by"] = "maintainer-stale-clear"

with open(".agent/locks/.locked", "w") as f:
    json.dump(data, f, indent=2)

with open(registry, "a") as f:
    f.write(f"\n---\n\n### Stale Clear — {now.isoformat()}\n\n")
    f.write(f"| Field | Value |\n|---|---|\n")
    f.write(f"| Lock ID | {lock_id} |\n")
    f.write(f"| File | `{found['file_or_folder']}` |\n")
    f.write(f"| Original Agent | {found['locked_by']} |\n")
    f.write(f"| Expired At | {found.get('expires_at','?')} |\n")
    f.write(f"| Cleared At | {now.isoformat()} |\n")
    f.write(f"| Outcome | expired — stale clear |\n")

print(f"\033[0;32m✅ Stale lock {lock_id} cleared and logged\033[0m")
EOF
}

cmd_check() {
  local path="$1"
  echo -e "${BLUE}🔍 Checking lock status for: $path${NC}"
  python3 - "$path" <<'EOF'
import json, sys

path = sys.argv[1]
with open(".agent/locks/.locked") as f:
    data = json.load(f)

found = [l for l in data.get("locks", []) if l.get("file_or_folder") == path]
if not found:
    print(f"\033[0;32m🟢 No lock on {path} — safe to acquire\033[0m")
else:
    for l in found:
        print(f"\033[0;31m🔒 Locked: {l['id']} | Type: {l['type']} | By: {l['locked_by']} | Expires: {l.get('expires_at','never')}\033[0m")
EOF
}

cmd_history() {
  local last="${2:-10}"
  if ! [[ "$last" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Invalid history count: must be a positive integer${NC}" >&2
    exit 1
  fi
  echo -e "${BOLD}${CYAN}📜 Lock Registry (last $last entries)${NC}"
  grep -A 10 "^### " "$REGISTRY_FILE" | tail -$(( last * 12 )) || echo "No history yet"
}

# ── Dispatch ─────────────────────────────────────────────────
CMD="${1:-help}"
case "$CMD" in
  status)       cmd_status ;;
  lock)         [[ $# -ge 5 ]] || { usage; exit 1; }; cmd_lock "$2" "$3" "$4" "$5" ;;
  release)      [[ $# -ge 3 ]] || { usage; exit 1; }; cmd_release "$2" "$3" ;;
  clear-stale)  [[ $# -ge 2 ]] || { usage; exit 1; }; cmd_clear_stale "$2" ;;
  check)        [[ $# -ge 2 ]] || { usage; exit 1; }; cmd_check "$2" ;;
  history)      cmd_history "${@}" ;;
  help|--help)  usage ;;
  *)            echo -e "${RED}❌ Unknown command: $CMD${NC}"; usage; exit 1 ;;
esac
