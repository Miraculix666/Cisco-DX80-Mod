#!/usr/bin/env python3
"""test_lock_manager.py - Tests for the lock-manager.sh script"""

import datetime
import pytest
import subprocess
import json
import os
import shutil
import tempfile
from pathlib import Path

def test_lock_manager_lock_validation():
    # To test the bash function `cmd_lock()`, we can just call it via bash.
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    # We create a temporary environment
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        # Create expected directory structure
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")

        # Copy script to the temporary directory so its REPO_ROOT points to tmpdir
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        lock_file.write_text('{"locks": []}')

        # In the script, it relies on being run from the current working directory because
        # of how python opens `.agent/locks/.locked`.
        # So we MUST change the cwd to the temp directory when running subprocess.

        # Test invalid lock type
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "lock", "test/path", "INVALID", "agent1", "reason"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Invalid lock type: INVALID" in result.stdout

        # Test valid lock type
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "lock", "test/path", "SOFT", "agent1", "reason"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0
        assert "Lock acquired" in result.stdout

        # Verify the lock file
        data = json.loads(lock_file.read_text())
        assert len(data["locks"]) == 1
        assert data["locks"][0]["file_or_folder"] == "test/path"
        assert data["locks"][0]["type"] == "SOFT"
        assert data["locks"][0]["locked_by"] == "agent1"
        assert data["locks"][0]["reason"] == "reason"


def test_lock_manager_lock_conflicts():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"

        # Test conflict with HARD lock
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-hard1",
                "file_or_folder": "test/path",
                "type": "HARD",
                "locked_by": "human"
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "lock", "test/path", "SOFT", "agent1", "reason"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "HARD lock on test/path \u2014 cannot acquire" in result.stdout

        # Test conflict with SOFT lock from another agent
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft1",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent2"
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "lock", "test/path", "SOFT", "agent1", "reason"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "File locked by agent2" in result.stdout

def test_lock_manager_invalid_arguments():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        lock_file.write_text('{"locks": []}')

        # Missing reason
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "lock", "test/path", "SOFT", "agent1"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Lock Manager \u2014 Usage" in result.stdout

def test_lock_manager_history_injection():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        lock_file.write_text('{"locks": []}')

        registry_file = tmp_path / ".agent" / "locks" / "LOCK_REGISTRY.md"
        registry_file.write_text('')

        # Test valid history count
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "history", "5"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0
        assert "Lock Registry (last 5 entries)" in result.stdout

        # Test invalid history count (command injection attempt)
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "history", "a[$(id>&2)]"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Invalid history count: must be a positive integer" in result.stderr

def test_lock_manager_release_not_found():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        lock_file.write_text('{"locks": []}')

        registry_file = tmp_path / ".agent" / "locks" / "LOCK_REGISTRY.md"
        registry_file.write_text('')

        # Test releasing a non-existent lock
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "release", "invalid-lock", "agent1"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Lock invalid-lock not found" in result.stdout

def test_lock_manager_clear_stale():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        os.makedirs(tmp_path / ".agent" / ".agent" / "locks", exist_ok=True)
        registry_file = tmp_path / ".agent" / ".agent" / "locks" / "LOCK_REGISTRY.md"
        registry_file.write_text('')

        # 1. Non-existent lock
        lock_file.write_text('{"locks": []}')
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "clear-stale", "missing-lock"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "not found" in result.stdout

        # 2. HARD lock
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-hard1",
                "file_or_folder": "test/path",
                "type": "HARD",
                "locked_by": "human"
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "clear-stale", "lock-hard1"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Cannot clear HARD lock" in result.stdout

        # 3. SOFT lock not yet expired
        future_time = (datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=1)).isoformat()
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft1",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent",
                "expires_at": future_time
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "clear-stale", "lock-soft1"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 1
        assert "Lock not stale yet" in result.stdout

        # 4. SOFT lock already expired
        past_time = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=1)).isoformat()
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft2",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent",
                "expires_at": past_time
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "clear-stale", "lock-soft2"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0
        assert "cleared and logged" in result.stdout
        data = json.loads(lock_file.read_text())
        assert len(data["locks"]) == 0

        # 5. SOFT lock with no expires_at
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft3",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent"
            }]
        }))
        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "clear-stale", "lock-soft3"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0
        assert "cleared and logged" in result.stdout
        data = json.loads(lock_file.read_text())
        assert len(data["locks"]) == 0

def test_lock_manager_no_python3():
    script_path = Path(__file__).parent.parent / "scripts" / "lock-manager.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        os.makedirs(tmp_path / ".agent" / "locks")
        os.makedirs(tmp_path / ".agent" / "scripts")
        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "lock-manager.sh")
        shutil.copy(script_path.parent / "colors.sh", tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"
        lock_file.write_text('{"locks": []}')

        mock_path = tmp_path / "mock_bin"
        os.makedirs(mock_path)

        # Mock PATH by creating a minimal PATH environment
        # We need bash to run the script and potentially other builtins, but they are builtins.
        # Actually, if we just set PATH to an empty dir, it will fail to find bash.
        # So we just symlink bash and dirname which are explicitly used before the python3 check.
        bash_path = shutil.which("bash")
        dirname_path = shutil.which("dirname")
        if bash_path:
            os.symlink(bash_path, mock_path / "bash")
        if dirname_path:
            os.symlink(dirname_path, mock_path / "dirname")


        env = os.environ.copy()
        env["PATH"] = str(mock_path)

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "lock-manager.sh"), "status"],
            capture_output=True, text=True, cwd=tmpdir, env=env
        )
        assert result.returncode == 1
        assert "python3 required for lock-manager" in result.stdout or "python3 is required to parse locks" in result.stdout or "python3 required for lock-manager" in result.stderr
