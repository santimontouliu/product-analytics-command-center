-- 13_funnel_sequence_quality.sql
--
-- Tests whether key commerce events occurred in plausible
-- chronological order within sessions.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.funnel_sequence_quality`
AS

WITH events AS (

  SELECT

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

    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    event_name,
    event_timestamp

  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  WHERE
    event_name IN (
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
),

session_funnel AS (

  SELECT
    session_id,

    MIN(
      IF(
        event_name = 'view_item',
        event_timestamp,
        NULL
      )
    ) AS first_view_ts,

    MIN(
      IF(
        event_name = 'add_to_cart',
        event_timestamp,
        NULL
      )
    ) AS first_cart_ts,

    MIN(
      IF(
        event_name = 'begin_checkout',
        event_timestamp,
        NULL
      )
    ) AS first_checkout_ts,

    MIN(
      IF(
        event_name = 'purchase',
        event_timestamp,
        NULL
      )
    ) AS first_purchase_ts

  FROM events

  WHERE ga_session_id IS NOT NULL

  GROUP BY session_id
),

summary AS (

  SELECT
    COUNT(*) AS funnel_sessions,

    COUNTIF(
      first_cart_ts IS NOT NULL
      AND first_view_ts IS NOT NULL
      AND first_cart_ts < first_view_ts
    ) AS cart_before_view,

    COUNTIF(
      first_checkout_ts IS NOT NULL
      AND first_cart_ts IS NOT NULL
      AND first_checkout_ts < first_cart_ts
    ) AS checkout_before_cart,

    COUNTIF(
      first_purchase_ts IS NOT NULL
      AND first_checkout_ts IS NOT NULL
      AND first_purchase_ts < first_checkout_ts
    ) AS purchase_before_checkout,

    COUNTIF(
      first_purchase_ts IS NOT NULL
      AND first_cart_ts IS NOT NULL
      AND first_purchase_ts < first_cart_ts
    ) AS purchase_before_cart,

    COUNTIF(
      first_purchase_ts IS NOT NULL
      AND first_view_ts IS NOT NULL
      AND first_purchase_ts < first_view_ts
    ) AS purchase_before_view

  FROM session_funnel
)

SELECT
  'Cart before product view' AS check_name,
  cart_before_view AS affected_sessions,
  funnel_sessions,
  SAFE_DIVIDE(
    cart_before_view,
    funnel_sessions
  ) AS affected_rate

FROM summary

UNION ALL

SELECT
  'Checkout before cart',
  checkout_before_cart,
  funnel_sessions,
  SAFE_DIVIDE(
    checkout_before_cart,
    funnel_sessions
  )

FROM summary

UNION ALL

SELECT
  'Purchase before checkout',
  purchase_before_checkout,
  funnel_sessions,
  SAFE_DIVIDE(
    purchase_before_checkout,
    funnel_sessions
  )

FROM summary

UNION ALL

SELECT
  'Purchase before cart',
  purchase_before_cart,
  funnel_sessions,
  SAFE_DIVIDE(
    purchase_before_cart,
    funnel_sessions
  )

FROM summary

UNION ALL

SELECT
  'Purchase before product view',
  purchase_before_view,
  funnel_sessions,
  SAFE_DIVIDE(
    purchase_before_view,
    funnel_sessions
  )

FROM summary;