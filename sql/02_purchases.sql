-- 02_purchases.sql
--
-- Raw positive-revenue purchase-event model.
-- Duplicate purchase events are intentionally retained here
-- so they can be detected and handled downstream.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.purchases`
AS

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS purchase_date,

  user_pseudo_id,

  (
    SELECT value.int_value
    FROM UNNEST(event_params)
    WHERE key = 'ga_session_id'
  ) AS ga_session_id,

  CONCAT(
    user_pseudo_id,
    '-',
    CAST(
      (
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING
    )
  ) AS session_id,

  ecommerce.transaction_id,
  ecommerce.purchase_revenue_in_usd AS revenue_usd,
  ecommerce.unique_items,

  device.category AS device_category,
  geo.country AS country,

  traffic_source.source AS first_user_source,
  traffic_source.medium AS first_user_medium

FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
  event_name = 'purchase'
  AND ecommerce.purchase_revenue_in_usd > 0;