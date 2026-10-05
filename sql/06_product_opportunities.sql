CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.product_opportunities`
AS

WITH behavior AS (

  SELECT
    item_name,

    COUNT(DISTINCT CASE
      WHEN event_name = 'view_item'
      THEN session_id
    END) AS view_sessions,

    COUNT(DISTINCT CASE
      WHEN event_name = 'add_to_cart'
      THEN session_id
    END) AS cart_sessions

  FROM
    `abiding-hull-510703-g2.analytics.product_behavior`

  GROUP BY item_name
),

purchases AS (

  SELECT
    item_name,

    COUNT(DISTINCT session_id) AS purchase_sessions,

    SUM(quantity) AS units_sold,

    SUM(item_revenue_usd) AS revenue_usd

  FROM
    `abiding-hull-510703-g2.analytics.product_purchases`

  GROUP BY item_name
),

product_metrics AS (

  SELECT
    b.item_name,
    b.view_sessions,
    b.cart_sessions,

    COALESCE(p.purchase_sessions, 0) AS purchase_sessions,
    COALESCE(p.units_sold, 0) AS units_sold,
    COALESCE(p.revenue_usd, 0) AS revenue_usd,

    SAFE_DIVIDE(
      COALESCE(p.purchase_sessions, 0),
      b.view_sessions
    ) * 100 AS view_to_purchase_pct

  FROM behavior b

  LEFT JOIN purchases p
    USING (item_name)

  WHERE
    b.view_sessions >= 100
),

benchmarks AS (

  SELECT
    APPROX_QUANTILES(view_sessions, 100)[OFFSET(50)]
      AS median_view_sessions,

    APPROX_QUANTILES(view_to_purchase_pct, 100)[OFFSET(50)]
      AS median_conversion_pct

  FROM product_metrics
)

SELECT
  p.*,

  b.median_view_sessions AS traffic_benchmark,
  b.median_conversion_pct AS conversion_benchmark,

  CASE
    WHEN
      p.view_sessions >= b.median_view_sessions
      AND p.view_to_purchase_pct >= b.median_conversion_pct
    THEN 'High traffic / High conversion'

    WHEN
      p.view_sessions >= b.median_view_sessions
      AND p.view_to_purchase_pct < b.median_conversion_pct
    THEN 'High traffic / Low conversion'

    WHEN
      p.view_sessions < b.median_view_sessions
      AND p.view_to_purchase_pct >= b.median_conversion_pct
    THEN 'Low traffic / High conversion'

    ELSE
      'Low traffic / Low conversion'
  END AS opportunity_segment

FROM product_metrics p

CROSS JOIN benchmarks b;