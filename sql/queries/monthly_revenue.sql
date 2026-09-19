-- Cash movement by transaction month; refunds reduce the month they occurred.
WITH cash AS (
    SELECT date(occurred_at, 'start of month') AS month,
           SUM(CASE WHEN kind = 'charge' THEN amount_cents ELSE 0 END) AS gross_cents,
           SUM(CASE WHEN kind = 'refund' THEN amount_cents ELSE 0 END) AS refund_cents
    FROM payments
    WHERE status = 'succeeded' AND occurred_at <= (SELECT as_of_date FROM reporting_context)
    GROUP BY 1
), monthly AS (
    SELECT m.month, COALESCE(c.gross_cents,0) AS gross_cents,
           COALESCE(c.refund_cents,0) AS refund_cents,
           COALESCE(c.gross_cents,0) - COALESCE(c.refund_cents,0) AS net_cents
    FROM months m LEFT JOIN cash c USING (month)
    WHERE m.month <= date((SELECT as_of_date FROM reporting_context), 'start of month')
), previous AS (
    SELECT *, LAG(net_cents) OVER (ORDER BY month) AS previous_net_cents FROM monthly
)
SELECT *, ROUND(100.0 * (net_cents - previous_net_cents) / NULLIF(previous_net_cents,0),2) AS mom_growth_pct
FROM previous ORDER BY month;
