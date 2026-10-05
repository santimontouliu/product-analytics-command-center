-- 10_first_user_acquisition_summary.sql
--
-- First-user acquisition performance.
--
-- IMPORTANT:
-- GA4 traffic_source fields in this dataset represent
-- first-user acquisition, not session-scoped attribution.
--
-- Display fields clean raw GA4 labels for dashboard use.

CREATE OR REPLACE VIEW
  `abiding-hull-510703-g2.analytics.first_user_acquisition_summary`
AS

SELECT

  CASE
    WHEN first_user_source = 'google' THEN 'Google'
    WHEN first_user_source = '(direct)' THEN 'Direct'
    WHEN first_user_source = 'shop.googlemerchandisestore.com'
      THEN 'Google Merchandise Store'
    WHEN first_user_source = '(data deleted)' THEN 'Data deleted'
    WHEN first_user_source = '<Other>' THEN 'Other'
    ELSE first_user_source
  END AS source_display,

  CASE
    WHEN first_user_medium = 'organic' THEN 'Organic'
    WHEN first_user_medium = 'cpc' THEN 'Paid Search'
    WHEN first_user_medium = 'referral' THEN 'Referral'
    WHEN first_user_medium = '(none)' THEN 'None'
    WHEN first_user_medium = '(data deleted)' THEN 'Data deleted'
    WHEN first_user_medium = '<Other>' THEN 'Other'
    ELSE first_user_medium
  END AS medium_display,

  first_user_source,
  first_user_medium,

  COUNT(*) AS sessions,

  COUNTIF(product_views > 0) AS product_view_sessions,
  COUNTIF(add_to_carts > 0) AS cart_sessions,
  COUNTIF(checkouts > 0) AS checkout_sessions,
  COUNTIF(purchases > 0) AS purchase_sessions,

  SAFE_DIVIDE(
    COUNTIF(purchases > 0),
    COUNT(*)
  ) AS session_conversion_rate

FROM
  `abiding-hull-510703-g2.analytics.sessions`

GROUP BY
  first_user_source,
  first_user_medium;