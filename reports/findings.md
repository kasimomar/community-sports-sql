# Reading the demonstration results

Source: the versioned synthetic fixture in `sql/seed.sql`, reported through 2026-04-30. Regenerate with `python3 analyze.py`; exact rows are in `reports/csv/`.

## Collection

Net cash rises from $240 in January to $290 in February, then falls to $190 by April. February includes a $20 refund of a January payment; counting by enrollment month would misstate the timing. April's failed charge is followed by a successful retry, and only the successful payment counts. These numbers alone cannot establish profitability or customer lifetime value: costs and a complete billing schedule are absent.

## Participation

January soccer fills 3 of 4 seats (75% utilization). Only 3 of its 6 eligible visits are marked present. One visit has no recorded mark, so the 50% attendance rate is conservative; 83.33% recording coverage exposes that uncertainty. The sensible next step in a real dataset would be to resolve missing marks before interpreting low attendance as disengagement.

## Retention

The January cohort contains five distinct participants. Three are active in February, even though one joins two programs; the query counts that participant once. None are active in April. This tiny constructed example cannot establish a trend, an intervention effect, or why participants left. Newer cohorts have fewer observable follow-up months; future periods are omitted to avoid presenting unobserved behavior as churn.

## What this project establishes

The SQL produces consistent, testable answers to precisely defined questions. A real operating decision would additionally require complete enrollment history, validated attendance capture, billing reconciliation, and enough observations to assess uncertainty.
