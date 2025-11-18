"""
DRC History Tracking System
Manages DRC check history and tracks progress over time
"""
import json
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class DRCHistoryManager:
    """Manage DRC check history and track progress over time"""

    def __init__(self, db_path: Optional[str] = None):
        if db_path is None:
            db_path = Path.home() / ".altium-mcp" / "drc_history.db"

        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

        self._init_database()

    def _init_database(self):
        """Initialize the DRC history database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS drc_runs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_path TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                total_violations INTEGER,
                critical_count INTEGER,
                warning_count INTEGER,
                info_count INTEGER,
                violation_data TEXT
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS violation_types (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                drc_run_id INTEGER,
                violation_type TEXT,
                count INTEGER,
                FOREIGN KEY (drc_run_id) REFERENCES drc_runs(id)
            )
        """)

        conn.commit()
        conn.close()

    def record_drc_run(self, project_path: str, violations: Dict) -> int:
        """Record a DRC run and return the run ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        # Count violations by severity
        critical_count = sum(1 for v in violations.get("violations", [])
                           if v.get("severity") == "critical")
        warning_count = sum(1 for v in violations.get("violations", [])
                          if v.get("severity") == "warning")
        info_count = sum(1 for v in violations.get("violations", [])
                       if v.get("severity") == "info")

        cursor.execute("""
            INSERT INTO drc_runs
            (project_path, total_violations, critical_count, warning_count, info_count, violation_data)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            project_path,
            len(violations.get("violations", [])),
            critical_count,
            warning_count,
            info_count,
            json.dumps(violations)
        ))

        run_id = cursor.lastrowid

        # Record violation types
        violation_counts = {}
        for v in violations.get("violations", []):
            vtype = v.get("type", "unknown")
            violation_counts[vtype] = violation_counts.get(vtype, 0) + 1

        for vtype, count in violation_counts.items():
            cursor.execute("""
                INSERT INTO violation_types (drc_run_id, violation_type, count)
                VALUES (?, ?, ?)
            """, (run_id, vtype, count))

        conn.commit()
        conn.close()

        return run_id

    def get_history(self, project_path: str, limit: int = 10) -> List[Dict]:
        """Get DRC history for a project"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT id, timestamp, total_violations, critical_count,
                   warning_count, info_count
            FROM drc_runs
            WHERE project_path = ?
            ORDER BY id DESC
            LIMIT ?
        """, (project_path, limit))

        runs = []
        for row in cursor.fetchall():
            runs.append({
                "id": row[0],
                "timestamp": row[1],
                "total_violations": row[2],
                "critical": row[3],
                "warnings": row[4],
                "info": row[5]
            })

        conn.close()
        return runs

    def get_progress_report(self, project_path: str) -> Dict:
        """Generate a progress report comparing recent DRC runs"""
        history = self.get_history(project_path, limit=5)

        if len(history) < 2:
            return {
                "success": True,
                "message": "Need at least 2 DRC runs to show progress",
                "history": history
            }

        latest = history[0]
        previous = history[1]

        # Calculate changes
        total_change = latest["total_violations"] - previous["total_violations"]
        critical_change = latest["critical"] - previous["critical"]
        warning_change = latest["warnings"] - previous["warnings"]

        # Determine trend
        if total_change < 0:
            trend = "improving"
        elif total_change > 0:
            trend = "declining"
        else:
            trend = "stable"

        return {
            "success": True,
            "trend": trend,
            "latest_run": latest,
            "previous_run": previous,
            "changes": {
                "total": total_change,
                "critical": critical_change,
                "warnings": warning_change
            },
            "history": history
        }

    def get_violation_types(self, run_id: int) -> List[Dict]:
        """Get violation types for a specific DRC run"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT violation_type, count
            FROM violation_types
            WHERE drc_run_id = ?
            ORDER BY count DESC
        """, (run_id,))

        types = []
        for row in cursor.fetchall():
            types.append({
                "type": row[0],
                "count": row[1]
            })

        conn.close()
        return types

    def get_detailed_run(self, run_id: int) -> Optional[Dict]:
        """Get detailed information for a specific DRC run"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT project_path, timestamp, total_violations, critical_count,
                   warning_count, info_count, violation_data
            FROM drc_runs
            WHERE id = ?
        """, (run_id,))

        row = cursor.fetchone()
        conn.close()

        if not row:
            return None

        return {
            "id": run_id,
            "project_path": row[0],
            "timestamp": row[1],
            "total_violations": row[2],
            "critical": row[3],
            "warnings": row[4],
            "info": row[5],
            "violation_data": json.loads(row[6]) if row[6] else None
        }
