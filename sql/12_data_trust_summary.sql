-- 12_data_trust_summary.sql
--
-- Dashboard-ready summary of validated data-quality issues.
--
-- Findings were established during exploratory QA of the
-- underlying GA4 sample.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.data_trust_summary`
AS

SELECT
  'Opaque acquisition attribution' AS issue,
  97290 AS affected_rows,
  360129 AS total_rows,
  27.02 AS affected_pct

UNION ALL

SELECT
  'Missing transaction ID',
  456,
  4922,
  9.26

UNION ALL

SELECT
  'Potential store self-referral',
  28849,
  360129,
  8.01

UNION ALL

SELECT
  'Deleted acquisition attribution',
  22632,
  360129,
  6.28

UNION ALL

SELECT
  'Duplicate purchase-event rows removed',
  320,
  5242,
  6.10

UNION ALL

SELECT
  'Missing / unclassified product category',
  799,
  14624,
  5.46;