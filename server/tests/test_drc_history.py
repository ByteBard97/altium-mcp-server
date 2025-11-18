"""
Unit tests for DRC History Manager
"""
import unittest
import tempfile
import os
from pathlib import Path
import sys

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from drc_history import DRCHistoryManager


class TestDRCHistoryManager(unittest.TestCase):
    """Test cases for DRCHistoryManager"""

    def setUp(self):
        """Set up test fixtures"""
        # Create temporary database for testing
        self.temp_db = tempfile.NamedTemporaryFile(delete=False, suffix='.db')
        self.temp_db.close()
        self.db_path = self.temp_db.name
        self.manager = DRCHistoryManager(db_path=self.db_path)

    def tearDown(self):
        """Clean up test fixtures"""
        # Remove temporary database
        if os.path.exists(self.db_path):
            os.unlink(self.db_path)

    def test_init_database(self):
        """Test database initialization"""
        # Database should be created
        self.assertTrue(os.path.exists(self.db_path))

    def test_record_drc_run(self):
        """Test recording a DRC run"""
        violations = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Clearance violation"},
                {"type": "width", "severity": "warning", "description": "Track width issue"},
                {"type": "annular_ring", "severity": "info", "description": "Small annular ring"}
            ]
        }

        run_id = self.manager.record_drc_run("test_project.PrjPcb", violations)

        # Should return a valid ID
        self.assertIsInstance(run_id, int)
        self.assertGreater(run_id, 0)

    def test_get_history(self):
        """Test retrieving DRC history"""
        import time
        project_path = "test_project.PrjPcb"

        # Record multiple runs
        violations1 = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"}
            ]
        }
        violations2 = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"},
                {"type": "width", "severity": "warning", "description": "Issue 2"}
            ]
        }

        self.manager.record_drc_run(project_path, violations1)
        time.sleep(0.1)  # Small delay to ensure different timestamps
        self.manager.record_drc_run(project_path, violations2)

        # Get history
        history = self.manager.get_history(project_path, limit=10)

        # Should have 2 runs
        self.assertEqual(len(history), 2)

        # Most recent should be first (2 violations)
        self.assertEqual(history[0]["total_violations"], 2)
        self.assertEqual(history[1]["total_violations"], 1)

    def test_get_progress_report(self):
        """Test generating progress report"""
        import time
        project_path = "test_project.PrjPcb"

        # First run with 3 violations
        violations1 = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"},
                {"type": "clearance", "severity": "critical", "description": "Issue 2"},
                {"type": "width", "severity": "warning", "description": "Issue 3"}
            ]
        }

        # Second run with 1 violation (improvement!)
        violations2 = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"}
            ]
        }

        self.manager.record_drc_run(project_path, violations1)
        time.sleep(0.1)  # Small delay to ensure different timestamps
        self.manager.record_drc_run(project_path, violations2)

        # Get progress report
        report = self.manager.get_progress_report(project_path)

        # Should indicate improvement
        self.assertTrue(report["success"])
        self.assertEqual(report["trend"], "improving")
        self.assertEqual(report["changes"]["total"], -2)
        self.assertEqual(report["changes"]["critical"], -1)
        self.assertEqual(report["changes"]["warnings"], -1)

    def test_progress_report_insufficient_data(self):
        """Test progress report with only one run"""
        project_path = "test_project.PrjPcb"

        violations = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"}
            ]
        }

        self.manager.record_drc_run(project_path, violations)

        # Get progress report
        report = self.manager.get_progress_report(project_path)

        # Should indicate insufficient data
        self.assertTrue(report["success"])
        self.assertIn("Need at least 2", report["message"])

    def test_get_violation_types(self):
        """Test retrieving violation types for a run"""
        violations = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"},
                {"type": "clearance", "severity": "critical", "description": "Issue 2"},
                {"type": "width", "severity": "warning", "description": "Issue 3"}
            ]
        }

        run_id = self.manager.record_drc_run("test_project.PrjPcb", violations)

        # Get violation types
        types = self.manager.get_violation_types(run_id)

        # Should have 2 types
        self.assertEqual(len(types), 2)

        # Clearance should be first (2 occurrences)
        self.assertEqual(types[0]["type"], "clearance")
        self.assertEqual(types[0]["count"], 2)

    def test_get_detailed_run(self):
        """Test retrieving detailed run information"""
        violations = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"}
            ]
        }

        run_id = self.manager.record_drc_run("test_project.PrjPcb", violations)

        # Get detailed run
        details = self.manager.get_detailed_run(run_id)

        # Should have all the details
        self.assertIsNotNone(details)
        self.assertEqual(details["id"], run_id)
        self.assertEqual(details["project_path"], "test_project.PrjPcb")
        self.assertEqual(details["total_violations"], 1)
        self.assertEqual(details["critical"], 1)
        self.assertIsNotNone(details["violation_data"])

    def test_multiple_projects(self):
        """Test tracking multiple projects separately"""
        project1 = "project1.PrjPcb"
        project2 = "project2.PrjPcb"

        violations = {
            "violations": [
                {"type": "clearance", "severity": "critical", "description": "Issue 1"}
            ]
        }

        # Record runs for both projects
        self.manager.record_drc_run(project1, violations)
        self.manager.record_drc_run(project2, violations)

        # Each project should have 1 run
        history1 = self.manager.get_history(project1)
        history2 = self.manager.get_history(project2)

        self.assertEqual(len(history1), 1)
        self.assertEqual(len(history2), 1)


if __name__ == '__main__':
    unittest.main()
