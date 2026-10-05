-- 09_funnel_rates.sql
--
-- Stage-to-stage funnel conversion rates.
-- Uses the reliable cart-tracking period only.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.funnel_rates`
AS

WITH valid_sessions AS (

  SELECT *

  FROM
    `abiding-hull-510703-g2.analytics.sessions`

  WHERE
    session_date >= DATE '2020-11-25'

),

totals AS (

  SELECT
    COUNTIF(product_views > 0) AS product_view_sessions,
    COUNTIF(add_to_carts > 0) AS cart_sessions,
    COUNTIF(checkouts > 0) AS checkout_sessions,
    COUNTIF(purchases > 0) AS purchase_sessions

  FROM valid_sessions
)

SELECT

  SAFE_DIVIDE(
    cart_sessions,
    product_view_sessions
  ) AS view_to_cart_rate,

  SAFE_DIVIDE(
    checkout_sessions,
    cart_sessions
  ) AS cart_to_checkout_rate,

  SAFE_DIVIDE(
    purchase_sessions,
    checkout_sessions
  ) AS checkout_to_purchase_rate

FROM totals;