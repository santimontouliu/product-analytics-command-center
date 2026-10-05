-- 08_funnel_summary.sql
--
-- Dashboard-ready funnel.
-- Uses 2020-11-25 onward because add-to-cart tracking
-- is incomplete/intermittent before that date.
--
-- Grain: one row per funnel stage.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.funnel_summary`
AS

WITH valid_sessions AS (

  SELECT *

  FROM
    `abiding-hull-510703-g2.analytics.sessions`

  WHERE
    session_date >= DATE '2020-11-25'

)

SELECT
  1 AS stage_order,
  'Product View' AS funnel_stage,
  COUNTIF(product_views > 0) AS sessions

FROM valid_sessions

UNION ALL

SELECT
  2,
  'Add to Cart',
  COUNTIF(add_to_carts > 0)

FROM valid_sessions

UNION ALL

SELECT
  3,
  'Checkout',
  COUNTIF(checkouts > 0)

FROM valid_sessions

UNION ALL

SELECT
  4,
  'Purchase',
  COUNTIF(purchases > 0)

FROM valid_sessions;