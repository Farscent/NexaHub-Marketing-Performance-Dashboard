-- ============================================================
-- File: 01_monthly_leads.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Calculates the total number of leads generated each month.
--
-- Used for:
-- - Monthly lead trend analysis
-- - "Leads per Month" dashboard visualization
--
-- Source:
-- nexahub-analytics.marketing.leads
-- ============================================================

SELECT
    FORMAT_DATE('%Y-%m', date) AS month,
    COUNT(*) AS total_leads
FROM `nexahub-analytics.marketing.leads`
GROUP BY month
ORDER BY month ASC;
