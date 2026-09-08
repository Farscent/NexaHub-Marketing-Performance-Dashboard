-- ============================================================
-- File: 04_lead_status_breakdown.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Aggregates leads by pipeline status and labels successful
-- conversions using the "Closed Won" status.
--
-- Conversion definition:
-- Closed Won = Yes
-- All other statuses = No
--
-- Used for:
-- - Lead pipeline analysis
-- - Conversion classification
-- - "Lead Status Breakdown" dashboard visualization
--
-- Source:
-- nexahub-analytics.marketing.leads
-- ============================================================

SELECT
    lead_status,
    COUNT(*) AS total_leads,
    CASE
        WHEN lead_status = 'Closed Won' THEN 'Yes'
        ELSE 'No'
    END AS is_converted
FROM `nexahub-analytics.marketing.leads`
GROUP BY lead_status
ORDER BY total_leads DESC;
