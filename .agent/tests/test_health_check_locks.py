#!/usr/bin/env python3
"""test_health_check_locks.py - Tests for the no stale SOFT locks check in health-check.sh"""

import pytest
import subprocess
import json
import os
import shutil
import tempfile
from pathlib import Path
from datetime import datetime, timedelta, timezone

def create_mock_repo(tmp_path):
    os.makedirs(tmp_path / ".agent" / "locks")
    os.makedirs(tmp_path / ".agent" / "scripts")
    os.makedirs(tmp_path / ".agent" / "config")
    os.makedirs(tmp_path / ".agent" / "roles")
    os.makedirs(tmp_path / ".agent" / "memory")
    os.makedirs(tmp_path / "docs")
    os.makedirs(tmp_path / "dump" / "inbox")

    files_to_create = [
        "README.md",
        ".agent/MASTER_INSTRUCTIONS.md",
        ".agent/config/agent.config.md",
        ".agent/config/locking.config.md",
        ".agent/config/branches.config.md",
        ".agent/config/prompts.config.md",
        ".agent/roles/roles.md",
        ".agent/locks/.locked",
        ".agent/locks/HANDOVER.md",
        ".agent/locks/LOCK_REGISTRY.md",
        ".agent/memory/CONTEXT.md",
        ".agent/memory/DECISIONS.md",
        "docs/CHANGELOG.md",
        "docs/DEPENDENCIES.md",
        "docs/TESTS.md",
        "docs/ARCHITECTURE.md",
        "docs/SOURCES.md",
        "dump/README.md"
    ]
    for f in files_to_create:
        Path(tmp_path / f).write_text("mock content")

def test_health_check_no_stale_soft_locks():
    script_path = Path(__file__).parent.parent / "scripts" / "health-check.sh"
    colors_path = Path(__file__).parent.parent / "scripts" / "colors.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        create_mock_repo(tmp_path)

        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "health-check.sh")
        shutil.copy(colors_path, tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"

        future_time = (datetime.now(timezone.utc) + timedelta(hours=1)).isoformat().replace('+00:00', 'Z')
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft1",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent1",
                "expires_at": future_time
            }]
        }))

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "health-check.sh")],
            capture_output=True, text=True, cwd=tmpdir
        )

        assert "No stale locks detected" in result.stdout
        assert "Stale locks found:" not in result.stdout

def test_health_check_with_stale_soft_locks():
    script_path = Path(__file__).parent.parent / "scripts" / "health-check.sh"
    colors_path = Path(__file__).parent.parent / "scripts" / "colors.sh"

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        create_mock_repo(tmp_path)

        shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "health-check.sh")
        shutil.copy(colors_path, tmp_path / ".agent" / "scripts" / "colors.sh")

        lock_file = tmp_path / ".agent" / "locks" / ".locked"

        past_time = (datetime.now(timezone.utc) - timedelta(hours=1)).isoformat().replace('+00:00', 'Z')
        lock_file.write_text(json.dumps({
            "locks": [{
                "id": "lock-soft-stale",
                "file_or_folder": "test/path",
                "type": "SOFT",
                "locked_by": "agent1",
                "expires_at": past_time
            }]
        }))

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "health-check.sh")],
            capture_output=True, text=True, cwd=tmpdir
        )

        assert "Stale locks found: lock-soft-stale" in result.stdout
        assert "No stale locks detected" not in result.stdout
