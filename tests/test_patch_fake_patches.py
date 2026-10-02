import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "PatchFakePatches.kts"
KOTLIN_SETTING = os.environ.get("KOTLIN", "kotlin")
KOTLIN_EXECUTABLE = shutil.which(KOTLIN_SETTING)
if KOTLIN_EXECUTABLE is None and Path(KOTLIN_SETTING).is_file():
    KOTLIN_EXECUTABLE = str(Path(KOTLIN_SETTING).resolve())

NAMESPACE_INCLUDE = "#include <trace/hooks/blk.h>"
SUPER_INCLUDE = "#include <trace/hooks/fs.h>"
JOURNAL_NAME = ".fakepatch-includes.properties"


@unittest.skipUnless(KOTLIN_EXECUTABLE, "Kotlin executable not installed (set KOTLIN to its path to run these regressions)")
class FakePatchIncludeJournalTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.work_dir = Path(self.temp_dir.name)
        (self.work_dir / "fs").mkdir()
        self.namespace = self.work_dir / "fs" / "namespace.c"
        self.super_c = self.work_dir / "fs" / "super.c"
        self.journal = self.work_dir / JOURNAL_NAME

    def write_sources(self, namespace_lines, super_lines):
        self.namespace.write_text("\n".join(namespace_lines) + "\n", encoding="utf-8")
        self.super_c.write_text("\n".join(super_lines) + "\n", encoding="utf-8")

    def create_header(self, relative_path):
        header = self.work_dir / relative_path
        header.parent.mkdir(parents=True, exist_ok=True)
        header.write_text("/* header available to this test */\n", encoding="utf-8")

    def run_script(self, mode):
        env = os.environ.copy()
        env["KMI"] = "android14-6.1"
        env["SUBLEVEL"] = "157"
        return subprocess.run(
            [KOTLIN_EXECUTABLE, str(SCRIPT), mode, str(self.work_dir)],
            env=env,
            capture_output=True,
            text=True,
            timeout=180,
            check=False,
        )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)

    def test_mtk_baseline_without_headers_stays_without_them(self):
        self.write_sources(
            ['#include "internal.h"', "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )

        self.assert_success(self.run_script("apply"))
        self.assertTrue(self.journal.is_file())
        self.assertNotIn(NAMESPACE_INCLUDE, self.namespace.read_text(encoding="utf-8"))
        self.assertNotIn(SUPER_INCLUDE, self.super_c.read_text(encoding="utf-8"))
        self.assert_success(self.run_script("revert"))

        self.assertNotIn(NAMESPACE_INCLUDE, self.namespace.read_text(encoding="utf-8"))
        self.assertNotIn(SUPER_INCLUDE, self.super_c.read_text(encoding="utf-8"))
        self.assertFalse(self.journal.exists())

    def test_existing_header_files_do_not_add_originally_absent_includes(self):
        self.create_header("include/trace/hooks/blk.h")
        self.create_header("include/trace/hooks/fs.h")
        self.write_sources(
            ['#include "internal.h"', "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )

        self.assert_success(self.run_script("apply"))
        self.assert_success(self.run_script("revert"))

        self.assertNotIn(NAMESPACE_INCLUDE, self.namespace.read_text(encoding="utf-8"))
        self.assertNotIn(SUPER_INCLUDE, self.super_c.read_text(encoding="utf-8"))

    def test_restores_original_headers_once_and_preserves_susfs_edits(self):
        self.create_header("include/trace/hooks/blk.h")
        self.create_header("include/trace/hooks/fs.h")
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "#include <linux/vendor_namespace.h>", "int namespace_marker;"],
            ['#include "internal.h"', SUPER_INCLUDE, "#include <linux/vendor_super.h>", "int super_marker;"],
        )

        self.assert_success(self.run_script("apply"))
        self.namespace.write_text(
            '#include <linux/susfs_def.h>\n' + self.namespace.read_text(encoding="utf-8") + "/* SUSFS namespace hook */\n",
            encoding="utf-8",
        )
        self.super_c.write_text(
            '#include <linux/susfs_def.h>\n' + self.super_c.read_text(encoding="utf-8") + "/* SUSFS super hook */\n",
            encoding="utf-8",
        )

        # apply and revert are separate Kotlin processes; state must come from the properties journal.
        self.assert_success(self.run_script("revert"))
        namespace_text = self.namespace.read_text(encoding="utf-8")
        super_text = self.super_c.read_text(encoding="utf-8")
        self.assertEqual(namespace_text.count(NAMESPACE_INCLUDE), 1)
        self.assertEqual(super_text.count(SUPER_INCLUDE), 1)
        self.assertIn("#include <linux/susfs_def.h>", namespace_text)
        self.assertIn("#include <linux/susfs_def.h>", super_text)
        self.assertIn("/* SUSFS namespace hook */", namespace_text)
        self.assertIn("/* SUSFS super hook */", super_text)
        self.assertFalse(self.journal.exists())

    def test_following_nonblank_source_lines_survive_apply_and_revert(self):
        self.create_header("include/trace/hooks/blk.h")
        self.create_header("include/trace/hooks/fs.h")
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "#include <linux/vendor_namespace.h>", "int namespace_marker;"],
            ['#include "internal.h"', SUPER_INCLUDE, "#include <linux/vendor_super.h>", "int super_marker;"],
        )

        self.assert_success(self.run_script("apply"))
        self.assertIn("#include <linux/vendor_namespace.h>", self.namespace.read_text(encoding="utf-8"))
        self.assertIn("#include <linux/vendor_super.h>", self.super_c.read_text(encoding="utf-8"))
        self.assert_success(self.run_script("revert"))
        self.assertIn("#include <linux/vendor_namespace.h>", self.namespace.read_text(encoding="utf-8"))
        self.assertIn("#include <linux/vendor_super.h>", self.super_c.read_text(encoding="utf-8"))

    def test_revert_does_not_duplicate_include_already_reintroduced(self):
        self.create_header("include/trace/hooks/blk.h")
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )
        self.assert_success(self.run_script("apply"))
        self.namespace.write_text(
            self.namespace.read_text(encoding="utf-8").replace(
                '#include "internal.h"\n',
                '#include "internal.h"\n' + NAMESPACE_INCLUDE + "\n",
                1,
            ),
            encoding="utf-8",
        )

        self.assert_success(self.run_script("revert"))

        self.assertEqual(self.namespace.read_text(encoding="utf-8").count(NAMESPACE_INCLUDE), 1)

    def test_second_apply_cannot_overwrite_pending_state(self):
        self.create_header("include/trace/hooks/blk.h")
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )

        self.assert_success(self.run_script("apply"))
        original_journal = self.journal.read_bytes()
        second_apply = self.run_script("apply")

        self.assertNotEqual(second_apply.returncode, 0)
        self.assertEqual(self.journal.read_bytes(), original_journal)
        self.assert_success(self.run_script("revert"))
        self.assertEqual(self.namespace.read_text(encoding="utf-8").count(NAMESPACE_INCLUDE), 1)

    def test_missing_original_header_file_fails_without_discarding_journal(self):
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )
        self.assert_success(self.run_script("apply"))

        result = self.run_script("revert")

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.journal.is_file())
        self.assertNotIn(NAMESPACE_INCLUDE, self.namespace.read_text(encoding="utf-8"))

    def test_missing_internal_header_anchor_fails_without_discarding_journal(self):
        self.create_header("include/trace/hooks/blk.h")
        self.write_sources(
            ['#include "internal.h"', NAMESPACE_INCLUDE, "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )
        self.assert_success(self.run_script("apply"))
        self.namespace.write_text("int namespace_marker;\n", encoding="utf-8")

        result = self.run_script("revert")

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.journal.is_file())
        self.assertNotIn(NAMESPACE_INCLUDE, self.namespace.read_text(encoding="utf-8"))

    def test_missing_journal_fails_explicitly_on_revert(self):
        self.write_sources(
            ['#include "internal.h"', "int namespace_marker;"],
            ['#include "internal.h"', "int super_marker;"],
        )

        original_namespace = self.namespace.read_text(encoding="utf-8")
        original_super = self.super_c.read_text(encoding="utf-8")
        result = self.run_script("revert")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.namespace.read_text(encoding="utf-8"), original_namespace)
        self.assertEqual(self.super_c.read_text(encoding="utf-8"), original_super)


if __name__ == "__main__":
    unittest.main()
