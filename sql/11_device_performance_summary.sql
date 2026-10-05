-- 11_device_performance_summary.sql
--
-- Device performance comparison.
--
-- Overall session conversion uses the full analysis period.
-- Cart-stage metrics use 2020-11-25 onward because earlier
-- add-to-cart tracking is incomplete.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.device_performance_summary`
AS

WITH all_period AS (

  SELECT
    device_category,

    COUNT(*) AS sessions,

    COUNTIF(purchases > 0) AS purchase_sessions,

    SAFE_DIVIDE(
      COUNTIF(purchases > 0),
      COUNT(*)
    ) AS session_conversion_rate

  FROM
    `abiding-hull-510703-g2.analytics.sessions`

  GROUP BY
    device_category
),

reliable_cart_period AS (

  SELECT
    device_category,

    COUNTIF(product_views > 0) AS product_view_sessions,

    COUNTIF(add_to_carts > 0) AS cart_sessions,

    COUNTIF(checkouts > 0) AS checkout_sessions,

    SAFE_DIVIDE(
      COUNTIF(add_to_carts > 0),
      COUNTIF(product_views > 0)
    ) AS view_to_cart_rate,

    SAFE_DIVIDE(
      COUNTIF(checkouts > 0),
      COUNTIF(add_to_carts > 0)
    ) AS cart_to_checkout_rate,

    SAFE_DIVIDE(
      COUNTIF(purchases > 0),
      COUNTIF(checkouts > 0)
    ) AS checkout_to_purchase_rate

  FROM
    `abiding-hull-510703-g2.analytics.sessions`

  WHERE
    session_date >= DATE '2020-11-25'

  GROUP BY
    device_category
)

SELECT
  INITCAP(a.device_category) AS device_category,

  a.sessions,
  a.purchase_sessions,
  a.session_conversion_rate,

  r.product_view_sessions,
  r.cart_sessions,
  r.checkout_sessions,

  r.view_to_cart_rate,
  r.cart_to_checkout_rate,
  r.checkout_to_purchase_rate

FROM all_period a

LEFT JOIN reliable_cart_period r
  USING (device_category);