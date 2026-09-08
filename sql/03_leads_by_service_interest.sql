-- ============================================================
-- File: 03_leads_by_service_interest.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Analyzes lead demand across different service interests.
-- Calculates both total lead count and each service's share
-- of all recorded leads.
--
-- Used for:
-- - Service demand analysis
-- - "Leads by Service Interest" dashboard visualization
--
-- Source:
-- nexahub-analytics.marketing.leads
-- ============================================================

SELECT
    service_interest,
    COUNT(*) AS total_leads,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        1
    ) AS percentage
FROM `nexahub-analytics.marketing.leads`
GROUP BY service_interest
ORDER BY total_leads DESC;
