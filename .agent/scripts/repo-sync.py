# FILE: repo-sync.py
# PURPOSE: Sync all git repositories under C:\GitHub with remote origins
# LAST MODIFIED: 2026-08-12
# MODIFIED BY: Agent

import os
import subprocess
import sys

def sync_repos():
    # Detect the correct GitHub base directory on Windows or Linux
    base_dir = 'C:/GitHub'
    if not os.path.exists(base_dir):
        base_dir = '/GitHub'
    if not os.path.exists(base_dir):
        base_dir = os.path.expanduser('~/GitHub')
        
    if not os.path.exists(base_dir):
        print(f"[ERR] Could not locate GitHub directory at C:/GitHub, /GitHub, or ~/GitHub.")
        sys.exit(1)

    print(f"Scanning repositories in {base_dir}...")
    repos = [d for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d, '.git'))]
    
    for r in repos:
        path = os.path.join(base_dir, r)
        print(f"\n=== Syncing {r} ===")
        
        # Add all files (respecting .gitignore)
        subprocess.run('git add .', shell=True, cwd=path)
        
        # Commit alignment changes if any
        subprocess.run('git commit -m "System-Wide Repo-Split Standard Alignment"', shell=True, cwd=path, capture_output=True)
        
        # Check active branch name
        branch_res = subprocess.run('git branch --show-current', shell=True, cwd=path, capture_output=True, text=True)
        branch = branch_res.stdout.strip() if branch_res.returncode == 0 else 'main'
        if not branch:
            branch = 'main'
            
        # Push to remote
        print(f"Pushing branch '{branch}' to origin...")
        res = subprocess.run(f'git push origin {branch}', shell=True, cwd=path, capture_output=True, text=True)
        
        if res.returncode == 0:
            print(f"[SUCCESS] {r} pushed to GitHub.")
        else:
            print(f"[PENDING/REMOTE REBUILD NEEDED] {r}: Check remote branch/name or create repo on GitHub.com.")

if __name__ == '__main__':
    sync_repos()
