"""CLI tests; run with python3 -m unittest discover -s scripts -p 'test_rename_names.py'."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("rename_names.py")


class RenameNamesTests(unittest.TestCase):
    def run_script(self, root, old="old", new="new", *options):
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(root), old, new, *options],
            capture_output=True, text=True,
        )

    def test_recursively_renames_all_occurrences_without_changing_contents(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "old-root"
            child = root / "old-dir" / "nested-old"
            child.mkdir(parents=True)
            (child / "old-old.txt").write_text("old contents")
            (root / ".old-hidden").touch()
            (root / "unchanged.txt").touch()
            result = self.run_script(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (root / "new-dir" / "nested-new" / "new-new.txt").read_text(),
                "old contents",
            )
            self.assertTrue((root / ".new-hidden").exists())
            self.assertTrue((root / "unchanged.txt").exists())
            self.assertFalse((root / "old-dir").exists())


    def test_collision_is_rejected_before_any_rename(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "old-first.txt").touch()
            (root / "old.txt").write_text("source")
            (root / "new.txt").write_text("destination")
            result = self.run_script(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("already exists", result.stderr)
            self.assertTrue((root / "old-first.txt").exists())
            self.assertEqual((root / "new.txt").read_text(), "destination")


    def test_dry_run_leaves_names_unchanged(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "old.txt").touch()
            result = self.run_script(root, "old", "new", "--dry-run")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("new.txt", result.stdout)
            self.assertTrue((root / "old.txt").exists())
            self.assertFalse((root / "new.txt").exists())


    def test_empty_search_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "old.txt").touch()
            result = self.run_script(root, "", "new")
            self.assertNotEqual(result.returncode, 0)
            self.assertTrue((root / "old.txt").exists())


    def test_symlinks_are_renamed_without_traversing_targets(self):
        with tempfile.TemporaryDirectory() as temp:
            outside = Path(temp) / "outside"
            outside.mkdir()
            (outside / "old.txt").touch()
            root = Path(temp) / "root"
            root.mkdir()
            (root / "old-link").symlink_to(outside, target_is_directory=True)
            (root / "old-broken").symlink_to(Path(temp) / "missing")
            result = self.run_script(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((root / "new-link").is_symlink())
            self.assertTrue((root / "new-broken").is_symlink())
            self.assertTrue((outside / "old.txt").exists())

    def test_invalid_destination_is_rejected_before_renaming(self):
        for replacement in ("", "..", "nested/name"):
            with self.subTest(replacement=replacement), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                (root / "old").touch()
                result = self.run_script(root, "old", replacement)
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue((root / "old").exists())


if __name__ == "__main__":
    unittest.main()
