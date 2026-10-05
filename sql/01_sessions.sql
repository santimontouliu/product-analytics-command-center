-- 01_sessions.sql
--
-- Creates the canonical session-level analytics view.
-- Grain: one row per unique GA4 session.
--
-- Session key:
-- user_pseudo_id + ga_session_id
--
-- Note:
-- first_user_source / first_user_medium represent first-user acquisition,
-- not session-level attribution.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.sessions`
AS

WITH events AS (

  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_timestamp,
    event_name,
    user_pseudo_id,

    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    device.category AS device_category,
    geo.country AS country,

    traffic_source.source AS first_user_source,
    traffic_source.medium AS first_user_medium

  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

)

SELECT

  CONCAT(
    user_pseudo_id,
    '-',
    CAST(ga_session_id AS STRING)
  ) AS session_id,

  user_pseudo_id,

  MIN(event_date) AS session_date,

  ANY_VALUE(device_category) AS device_category,

  ANY_VALUE(country) AS country,

  ANY_VALUE(first_user_source) AS first_user_source,

  ANY_VALUE(first_user_medium) AS first_user_medium,

  COUNT(*) AS event_count,

  COUNTIF(event_name = 'view_item') AS product_views,

  COUNTIF(event_name = 'add_to_cart') AS add_to_carts,

  COUNTIF(event_name = 'begin_checkout') AS checkouts,

  COUNTIF(event_name = 'purchase') AS purchases

FROM events

WHERE ga_session_id IS NOT NULL

GROUP BY
  session_id,
  user_pseudo_id;