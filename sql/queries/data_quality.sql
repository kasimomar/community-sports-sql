-- All of these checks must return zero violations before exporting reports.
SELECT 'attendance_program_or_month_mismatch' AS check_name, COUNT(*) AS violations
FROM attendance a JOIN sessions s USING (session_id) JOIN enrollments e USING (enrollment_id)
WHERE s.program_id <> e.program_id OR date(s.session_date,'start of month') <> e.month
UNION ALL
SELECT 'attendance_on_canceled_session', COUNT(*)
FROM attendance JOIN sessions USING (session_id) WHERE status = 'canceled'
UNION ALL
SELECT 'invalid_refund_reference', COUNT(*)
FROM payments r LEFT JOIN payments c ON c.payment_id = r.refund_of
WHERE r.kind = 'refund' AND (c.kind <> 'charge' OR c.status <> 'succeeded'
 OR c.enrollment_id <> r.enrollment_id OR c.occurred_at > r.occurred_at)
UNION ALL
SELECT 'refunds_exceed_charge', COUNT(*) FROM (
    SELECT c.payment_id FROM payments c JOIN payments r ON r.refund_of = c.payment_id
    WHERE r.status = 'succeeded'
    GROUP BY c.payment_id HAVING SUM(r.amount_cents) > c.amount_cents
)
UNION ALL
SELECT 'program_capacity_exceeded', COUNT(*) FROM (
    SELECT e.program_id, e.month FROM enrollments e JOIN programs p USING (program_id)
    GROUP BY e.program_id, e.month HAVING COUNT(*) > p.monthly_capacity
);
