-- 03_purchases_clean.sql
--
-- Deduplicates valid purchase events at:
-- transaction_id + session_id
--
-- Purchase events without a usable transaction ID are retained
-- because they cannot be safely deduplicated.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.purchases_clean`
AS

WITH ranked_purchases AS (

  SELECT
    *,

    ROW_NUMBER() OVER (
      PARTITION BY transaction_id, session_id
      ORDER BY purchase_date
    ) AS duplicate_rank

  FROM
    `abiding-hull-510703-g2.analytics.purchases`

)

SELECT
  purchase_date,
  user_pseudo_id,
  ga_session_id,
  session_id,
  transaction_id,
  revenue_usd,
  unique_items,
  device_category,
  country,
  first_user_source,
  first_user_medium,

  CASE
    WHEN transaction_id IS NULL
      OR transaction_id = '(not set)'
    THEN TRUE
    ELSE FALSE
  END AS missing_transaction_id

FROM ranked_purchases

WHERE
  transaction_id IS NULL
  OR transaction_id = '(not set)'
  OR duplicate_rank = 1;