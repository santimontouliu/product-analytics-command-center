-- 07_executive_summary_daily.sql
--
-- Dashboard-ready daily executive metrics.
--
-- reliable_cart_tracking = TRUE from 2020-11-25 onward,
-- when add-to-cart event coverage becomes continuous.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.executive_summary_daily`
AS

WITH session_daily AS (

  SELECT
    session_date AS date,

    COUNT(*) AS sessions,
    COUNT(DISTINCT user_pseudo_id) AS users,

    COUNTIF(product_views > 0) AS product_view_sessions,
    COUNTIF(add_to_carts > 0) AS cart_sessions,
    COUNTIF(checkouts > 0) AS checkout_sessions,
    COUNTIF(purchases > 0) AS purchase_sessions

  FROM
    `abiding-hull-510703-g2.analytics.sessions`

  GROUP BY date
),

revenue_daily AS (

  SELECT
    purchase_date AS date,

    SUM(revenue_usd) AS revenue_usd,

    COUNT(*) AS purchase_records,

    AVG(revenue_usd) AS avg_purchase_value_usd

  FROM
    `abiding-hull-510703-g2.analytics.purchases_clean`

  GROUP BY date
)

SELECT
  s.date,

  s.sessions,
  s.users,

  s.product_view_sessions,
  s.cart_sessions,
  s.checkout_sessions,
  s.purchase_sessions,

  COALESCE(r.revenue_usd, 0) AS revenue_usd,

  COALESCE(r.purchase_records, 0) AS purchase_records,

  COALESCE(
    r.avg_purchase_value_usd,
    0
  ) AS avg_purchase_value_usd,

  SAFE_DIVIDE(
    s.purchase_sessions,
    s.sessions
  ) * 100 AS session_conversion_pct,

  CASE
    WHEN s.date >= DATE '2020-11-25'
    THEN TRUE
    ELSE FALSE
  END AS reliable_cart_tracking

FROM session_daily s

LEFT JOIN revenue_daily r
  USING (date);