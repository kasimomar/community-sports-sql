-- Participant retention across ANY program; remove cross-program duplicates first.
WITH active AS (
    SELECT DISTINCT participant_id, month FROM enrollments
    WHERE month <= date((SELECT as_of_date FROM reporting_context),'start of month')
), first_seen AS (
    SELECT participant_id, MIN(month) AS cohort FROM active GROUP BY participant_id
), cohort_sizes AS (
    SELECT cohort, COUNT(*) AS cohort_size FROM first_seen GROUP BY cohort
), grid AS (
    SELECT c.cohort, m.month, c.cohort_size,
           (CAST(strftime('%Y',m.month) AS INTEGER)-CAST(strftime('%Y',c.cohort) AS INTEGER))*12
           + CAST(strftime('%m',m.month) AS INTEGER)-CAST(strftime('%m',c.cohort) AS INTEGER) AS month_number
    FROM cohort_sizes c CROSS JOIN months m
    WHERE m.month >= c.cohort
      AND m.month <= date((SELECT as_of_date FROM reporting_context),'start of month')
)
SELECT g.cohort, g.month, g.month_number, g.cohort_size,
       COUNT(a.participant_id) AS retained_participants,
       ROUND(100.0 * COUNT(a.participant_id) / g.cohort_size,2) AS retention_pct
FROM grid g JOIN first_seen f ON f.cohort = g.cohort
LEFT JOIN active a ON a.participant_id = f.participant_id AND a.month = g.month
GROUP BY g.cohort, g.month ORDER BY g.cohort, g.month;
