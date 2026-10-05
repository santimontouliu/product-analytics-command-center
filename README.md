# Product Analytics Command Center

A product analytics portfolio project built on Google’s public GA4 ecommerce dataset using BigQuery and Looker Studio.

The project focuses on three goals:

1. Build a reliable session- and purchase-level analytics model from raw GA4 event data.
2. Identify actionable product, funnel, acquisition, and segmentation insights.
3. Validate whether the underlying tracking is trustworthy enough to support business decisions.

## Stack

- BigQuery
- SQL
- Google Analytics 4 event data
- Looker Studio
- Git / GitHub

## Business Questions

This analysis was designed to answer questions such as:

- Where does the ecommerce funnel lose the most users?
- Which products generate the most revenue?
- Which high-traffic products underperform on conversion?
- Which products convert well but may be underexposed?
- Do mobile users experience more conversion friction than desktop users?
- Which acquisition sources are associated with stronger conversion?
- Are purchase, funnel, attribution, and product metrics trustworthy?

## Data

The project uses Google’s public GA4 ecommerce sample dataset:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

The source is event-level GA4 data containing nested event parameters, ecommerce fields, item arrays, user identifiers, device information, geography, and acquisition metadata.

## Analytics Model

Raw GA4 events were transformed into reusable analytics views.

### Session model

A canonical session key was created from:

`user_pseudo_id + ga_session_id`

The session model provides one row per session and includes:

- session date
- device
- country
- first-user acquisition source / medium
- product view activity
- add-to-cart activity
- checkout activity
- purchase activity

### Purchase model

Purchase events were modeled separately because duplicate purchase events were present in the source data.

Valid transactions were deduplicated using:

`transaction_id + session_id`

Purchase events without a usable transaction ID were retained and flagged rather than removed, because they could not be safely deduplicated.

### Product model

Purchase events were deduplicated before item arrays were unnested to prevent duplicate purchase events from inflating product-level revenue and unit metrics.

Product behavior was modeled using `view_item` and `add_to_cart` events, while purchase behavior was modeled separately and joined at product level.

## Key Findings

### Funnel

Over the reliable cart-tracking period:

- View → Cart: ~25.9%
- Cart → Checkout: ~52.2%
- Checkout → Purchase: ~48.5%

The largest early-stage loss occurs between product viewing and add-to-cart.

### Device performance

The hypothesis that mobile users experience materially greater conversion friction was not supported.

Overall session conversion was approximately:

- Desktop: 1.32%
- Mobile: 1.39%
- Tablet: 1.30%

Mobile slightly outperformed desktop on overall conversion.

### Product opportunities

Products were segmented using median traffic and median view-to-purchase conversion.

Four opportunity groups were created:

- High traffic / High conversion
- High traffic / Low conversion
- Low traffic / High conversion
- Low traffic / Low conversion

Examples of high-traffic / low-conversion opportunities included:

- Google Zip Hoodie F/C
- Super G Unisex Joggers
- Google Navy Speckled Tee
- Google Land & Sea French Terry Sweatshirt

Examples of lower-traffic / high-conversion products included:

- Google NYC Campus Zip Hoodie
- Google Chrome Dinosaur Collectible
- Google Black Cloud Zip Hoodie

These products represent potential merchandising or exposure opportunities.

## Data Trust Findings

A major part of the project was validating the reliability of the analytics layer before using it for decision-making.

### Duplicate purchase events

320 duplicate positive-revenue purchase-event rows were removed.

These duplicates would otherwise have inflated revenue and purchase KPIs.

### Missing transaction IDs

9.26% of cleaned positive-revenue purchase records lacked a usable transaction ID.

These purchases were retained but explicitly flagged.

### Acquisition attribution limitations

The GA4 sample exposes `traffic_source` fields representing first-user acquisition rather than session-level attribution.

Session-scoped attribution could not be reliably reconstructed from the sample, so all acquisition reporting is explicitly labeled as first-user acquisition.

Additional attribution-quality issues included:

- opaque `<Other>` values
- deleted acquisition data
- likely store self-referrals

### Cart tracking coverage

Add-to-cart instrumentation was intermittent before November 25, 2020.

Cart-related trend and funnel metrics therefore use November 25 onward, while sessions, purchases, revenue, and overall conversion use the full analysis period.

### Funnel sequencing

Funnel events were checked for chronological consistency.

The largest sequencing anomaly was checkout occurring before cart in approximately 0.85% of funnel-active sessions.

Purchase-before-checkout was not observed.

Because these anomalies were limited, the session-level funnel model was retained with an explicit quality caveat.

## Dashboard

The Looker Studio dashboard contains four pages:

### 1. Executive Overview

- Sessions
- Users
- Revenue
- Purchases
- Session conversion
- Revenue trend
- Conversion trend
- Commerce funnel
- Stage-to-stage conversion

### 2. Product Performance & Opportunities

- Top products by revenue
- High-traffic / low-conversion products
- Traffic vs conversion opportunity map
- Low-traffic / high-conversion products

### 3. Acquisition & Segment Performance

- First-user acquisition performance
- Device performance
- Conversion comparison by device

### 4. Data Trust & Instrumentation

- Data quality issues by impact
- Funnel sequencing validation
- Tracking coverage limitations

## Repository Structure

The `sql/` directory contains the final analytics models in dependency order.

The pipeline flows broadly as:

Raw GA4 events  
→ canonical sessions  
→ cleaned purchases  
→ product behavior and purchase models  
→ dashboard-ready analytical views  
→ trust and validation views

## What I Would Do Next

In a production environment, I would extend this project by:

- implementing the models in dbt
- adding automated data-quality tests
- materializing high-use models where appropriate
- adding incremental loading
- defining a semantic metrics layer
- adding experiment-analysis models
- replacing static quality thresholds with automated monitoring

## Notes

This project uses a public, obfuscated sample dataset and is intended as a product analytics and data modeling portfolio project.
