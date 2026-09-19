-- Every enrollment is eligible for every held session of its program/month.
-- Missing records count as not-present, with coverage reported separately.
SELECT date(s.session_date, 'start of month') AS month, p.program_name,
       COUNT(*) AS eligible_visits,
       COUNT(a.present) AS recorded_visits,
       SUM(COALESCE(a.present,0)) AS attended_visits,
       ROUND(100.0 * SUM(COALESCE(a.present,0)) / COUNT(*),2) AS attendance_pct,
       ROUND(100.0 * COUNT(a.present) / COUNT(*),2) AS recording_coverage_pct
FROM sessions s JOIN programs p USING (program_id)
JOIN enrollments e ON e.program_id = s.program_id AND e.month = date(s.session_date,'start of month')
LEFT JOIN attendance a ON a.session_id = s.session_id AND a.enrollment_id = e.enrollment_id
WHERE s.status = 'held' AND s.session_date <= (SELECT as_of_date FROM reporting_context)
GROUP BY 1, p.program_id ORDER BY 1, p.program_id;
