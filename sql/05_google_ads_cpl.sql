-- ============================================================
-- File: 05_google_ads_cpl.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Calculates monthly Cost per Lead (CPL) for Google Ads by
-- combining paid lead volume with monthly advertising spend.
--
-- Formula:
-- CPL = Ad Spend / Paid Leads
--
-- Demonstrates:
-- - Common Table Expressions (CTEs)
-- - Data aggregation
-- - Joining marketing and advertising datasets
-- - KPI calculation
--
-- Sources:
-- nexahub-analytics.marketing.leads
-- nexahub-analytics.marketing.ad_spend
-- ============================================================

WITH google_ads_leads AS (
    SELECT
        FORMAT_DATE('%Y-%m', date) AS month,
        COUNT(*) AS paid_leads
    FROM `nexahub-analytics.marketing.leads`
    WHERE channel_source = 'Google Ads'
    GROUP BY month
),

google_ads_spend AS (
    SELECT
        month,
        SUM(spend_usd) AS spend_usd
    FROM `nexahub-analytics.marketing.ad_spend`
    WHERE channel = 'Google Ads'
    GROUP BY month
)

SELECT
    l.month,
    l.paid_leads,
    s.spend_usd,
    ROUND(
        SAFE_DIVIDE(s.spend_usd, l.paid_leads),
        2
    ) AS cpl_usd
FROM google_ads_leads AS l
INNER JOIN google_ads_spend AS s
    ON l.month = s.month
ORDER BY l.month ASC;
