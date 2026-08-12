#!/usr/bin/env python3
"""test_consolidate.py - Tests for the consolidate.sh script"""

import pytest
import subprocess
import os
import shutil
import tempfile
from pathlib import Path

def setup_mock_repo(tmp_path: Path):
    os.makedirs(tmp_path / ".agent" / "scripts")
    script_path = Path(__file__).parent.parent / "scripts" / "consolidate.sh"
    colors_path = Path(__file__).parent.parent / "scripts" / "colors.sh"
    shutil.copy(script_path, tmp_path / ".agent" / "scripts" / "consolidate.sh")
    shutil.copy(colors_path, tmp_path / ".agent" / "scripts" / "colors.sh")

    # Required docs
    os.makedirs(tmp_path / "docs")
    for doc in ["CHANGELOG.md", "DEPENDENCIES.md", "TESTS.md", "ARCHITECTURE.md", "SOURCES.md"]:
        (tmp_path / "docs" / doc).write_text(f"dummy content for {doc}")

    # CONTEXT.md
    os.makedirs(tmp_path / ".agent" / "memory")
    (tmp_path / ".agent" / "memory" / "CONTEXT.md").write_text(
        "Some preceding text\nSessions Since Last Consolidation Review | 5\nSome following text\n"
    )

def test_clean_state():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0 or result.returncode == 1
        assert "No duplicate files detected" in result.stdout
        assert "No unexpectedly large files" in result.stdout
        assert "No empty directories" in result.stdout
        assert "MISSING:" not in result.stdout
        assert "Project structure is well-optimised!" in result.stdout

def test_duplicate_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        # Create a duplicate file
        (tmp_path / "docs" / "DUPLICATE.md").write_text("dummy content for CHANGELOG.md")

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0 or result.returncode == 1
        assert "Potential duplicate files:" in result.stdout
        assert "Issues Found: 1" in result.stdout

def test_large_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        # Create a large file (>50KB)
        (tmp_path / "large_file.txt").write_text("x" * 60000)

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0 or result.returncode == 1
        assert "Large files detected" in result.stdout
        assert "Issues Found: 1" in result.stdout

def test_empty_directories():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        # Create an empty directory
        os.makedirs(tmp_path / "empty_folder")

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0 or result.returncode == 1
        assert "Empty directories (add .gitkeep or remove):" in result.stdout
        assert "empty_folder" in result.stdout
        assert "Issues Found: 1" in result.stdout

def test_missing_docs():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        # Remove a required doc
        os.remove(tmp_path / "docs" / "CHANGELOG.md")

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )
        assert result.returncode == 0 or result.returncode == 1
        assert "MISSING: docs/CHANGELOG.md" in result.stdout
        assert "Issues Found: 1" in result.stdout

def test_report_only():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
            capture_output=True, text=True, cwd=tmpdir
        )

        content = (tmp_path / ".agent" / "memory" / "CONTEXT.md").read_text()
        assert "Sessions Since Last Consolidation Review | 5" in content
        assert "Report-only mode" in result.stdout

def test_reset_counter():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        result = subprocess.run(
            ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh")],
            capture_output=True, text=True, cwd=tmpdir
        )

        content = (tmp_path / ".agent" / "memory" / "CONTEXT.md").read_text()
        assert "Sessions Since Last Consolidation Review | 0" in content
        assert "Reset consolidation counter to 0 in CONTEXT.md" in result.stdout

def test_empty_directories_error_path():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        setup_mock_repo(tmp_path)

        # Create an empty directory
        os.makedirs(tmp_path / "empty_folder")

        # Create a restricted directory to cause find to exit with an error
        restricted_dir = tmp_path / "restricted_folder"
        os.makedirs(restricted_dir)
        os.chmod(restricted_dir, 0o000)

        try:
            result = subprocess.run(
                ["bash", str(tmp_path / ".agent" / "scripts" / "consolidate.sh"), "--report-only"],
                capture_output=True, text=True, cwd=tmpdir
            )
            assert result.returncode == 0 or result.returncode == 1
            assert "Empty directories (add .gitkeep or remove):" in result.stdout
            assert "empty_folder" in result.stdout
            assert "Issues Found: 1" in result.stdout
        finally:
            os.chmod(restricted_dir, 0o755)
