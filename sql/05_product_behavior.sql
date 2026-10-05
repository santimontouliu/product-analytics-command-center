-- 05_product_behavior.sql
--
-- Item-level product behavior model for product views
-- and add-to-cart activity.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.product_behavior`
AS

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_date,

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

  event_name,

  item.item_id,
  item.item_name,
  item.item_brand,
  item.item_category

FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item

WHERE
  event_name IN ('view_item', 'add_to_cart')
  AND item.item_name IS NOT NULL
  AND item.item_name != '(not set)';