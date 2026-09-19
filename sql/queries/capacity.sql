-- Count enrollment rows at program-month grain; do not join payment or attendance facts.
SELECT m.month, p.program_name, p.monthly_capacity,
       COUNT(e.enrollment_id) AS enrolled,
       p.monthly_capacity - COUNT(e.enrollment_id) AS available_seats,
       ROUND(100.0 * COUNT(e.enrollment_id) / p.monthly_capacity,2) AS utilization_pct
FROM months m CROSS JOIN programs p
LEFT JOIN enrollments e ON e.month = m.month AND e.program_id = p.program_id
WHERE m.month <= date((SELECT as_of_date FROM reporting_context), 'start of month')
GROUP BY m.month, p.program_id ORDER BY m.month, p.program_id;
