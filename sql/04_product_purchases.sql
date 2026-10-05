-- 04_product_purchases.sql
--
-- Item-level purchase model.
--
-- Purchase events are deduplicated before UNNEST(items)
-- to prevent duplicate events from inflating product revenue.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.product_purchases`
AS

WITH purchase_events AS (

  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS purchase_date,

    event_timestamp,
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
    items,

    ROW_NUMBER() OVER (

      PARTITION BY
        ecommerce.transaction_id,

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
        )

      ORDER BY event_timestamp

    ) AS duplicate_rank

  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  WHERE
    event_name = 'purchase'
    AND ecommerce.purchase_revenue_in_usd > 0
),

clean_purchase_events AS (

  SELECT *

  FROM purchase_events

  WHERE
    transaction_id IS NULL
    OR transaction_id = '(not set)'
    OR duplicate_rank = 1

)

SELECT
  purchase_date,
  user_pseudo_id,
  ga_session_id,
  session_id,
  transaction_id,

  item.item_id,
  item.item_name,
  item.item_brand,
  item.item_category,
  item.item_variant,

  item.price_in_usd AS price_usd,
  item.quantity,
  item.item_revenue_in_usd AS item_revenue_usd

FROM
  clean_purchase_events,
  UNNEST(items) AS item

WHERE
  item.item_name IS NOT NULL
  AND item.item_name != '(not set)'
  AND item.item_revenue_in_usd IS NOT NULL;