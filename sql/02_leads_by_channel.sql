-- ============================================================
-- File: 02_leads_by_channel.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Aggregates total lead volume by acquisition channel.
--
-- Used for:
-- - Channel performance analysis
-- - "Leads by Channel" dashboard visualization
-- - Channel filter validation
--
-- Source:
-- nexahub-analytics.marketing.leads
-- ============================================================

SELECT
    channel_source,
    COUNT(*) AS total_leads
FROM `nexahub-analytics.marketing.leads`
GROUP BY channel_source
ORDER BY total_leads DESC;
