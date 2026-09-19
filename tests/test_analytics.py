import sqlite3
import tempfile
import unittest
from pathlib import Path
from analyze import build_database, query, run, validate


class AnalyticsTests(unittest.TestCase):
    def setUp(self):
        self.db = build_database()

    def tearDown(self):
        self.db.close()

    def test_fixture_passes_quality_checks(self):
        validate(self.db)

    def test_revenue_excludes_failed_payments_and_dates_refunds(self):
        rows = query(self.db, 'monthly_revenue')
        self.assertEqual([r['net_cents'] for r in rows], [24000, 29000, 24000, 19000])
        self.assertEqual(sum(r['net_cents'] for r in rows), 96000)
        self.assertEqual(rows[1]['refund_cents'], 2000)
        self.assertIsNone(rows[0]['mom_growth_pct'])
        self.assertEqual(rows[1]['mom_growth_pct'], 20.83)

    def test_zero_revenue_month_is_preserved_and_growth_is_null_after_zero(self):
        self.db.execute("UPDATE payments SET status='failed' WHERE occurred_at LIKE '2026-01-%'")
        rows = query(self.db, 'monthly_revenue')
        self.assertEqual(rows[0]['net_cents'], 0)
        self.assertIsNone(rows[1]['mom_growth_pct'])

    def test_missing_attendance_counts_in_denominator_with_separate_coverage(self):
        row = query(self.db, 'attendance')[0]
        self.assertEqual((row['eligible_visits'], row['recorded_visits'], row['attended_visits']), (6,5,3))
        self.assertEqual(row['attendance_pct'], 50)
        self.assertEqual(row['recording_coverage_pct'], 83.33)

    def test_canceled_sessions_are_excluded(self):
        rows = query(self.db, 'attendance')
        self.assertFalse(any(r['month']=='2026-02-01' and r['program_name']=='After-School Multi-Sport' for r in rows))

    def test_retention_deduplicates_programs_shows_true_zero_and_censors_future(self):
        rows = query(self.db, 'retention')
        january = [r for r in rows if r['cohort']=='2026-01-01']
        self.assertEqual([r['retained_participants'] for r in january], [5,3,2,0])
        self.assertEqual([r['retention_pct'] for r in january], [100,60,40,0])
        self.assertEqual(len(rows), 10)
        self.assertFalse(any(r['month']=='2026-05-01' for r in rows))

    def test_capacity_does_not_multiply_by_payments(self):
        rows = query(self.db, 'capacity')
        self.assertEqual(len(rows), 8)
        self.assertEqual(rows[0]['enrolled'], 3)
        self.assertEqual(rows[0]['available_seats'], 1)
        self.assertEqual(rows[0]['utilization_pct'], 75)
        self.assertEqual(sum(r['enrolled'] for r in rows), 17)

    def test_schema_rejects_orphans_and_duplicates(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO enrollments VALUES (99,999,1,'2026-01-01')")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO enrollments VALUES (99,1,1,'2026-01-01')")

    def test_quality_checks_detect_over_refund(self):
        self.db.execute('UPDATE payments SET amount_cents=8000 WHERE payment_id=6')
        with self.assertRaisesRegex(ValueError, 'refunds_exceed_charge'):
            validate(self.db)

    def test_quality_checks_detect_wrong_program_attendance(self):
        self.db.execute('INSERT INTO attendance VALUES (1,4,1)')
        with self.assertRaisesRegex(ValueError, 'attendance_program_or_month_mismatch'):
            validate(self.db)

    def test_exports_are_repeatable_and_database_is_queryable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            run(root)
            first = (root / 'monthly_revenue.csv').read_bytes()
            run(root)
            self.assertEqual(first, (root / 'monthly_revenue.csv').read_bytes())
            with sqlite3.connect(root / 'sports.sqlite') as db:
                self.assertEqual(db.execute('SELECT COUNT(*) FROM participants').fetchone()[0], 8)


if __name__ == '__main__':
    unittest.main()
