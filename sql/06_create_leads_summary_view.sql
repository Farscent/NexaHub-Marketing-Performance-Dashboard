-- ============================================================
-- File: 06_create_leads_summary_view.sql
-- Project: NexaHub Marketing Performance Dashboard
--
-- Purpose:
-- Creates the analytical view used as the primary lead data
-- source for the Looker Studio marketing dashboard.
--
-- The view standardizes important marketing dimensions,
-- including:
-- - Month
-- - Month date
-- - Week number
-- - Acquisition channel
-- - Service interest
-- - Lead status
-- - Country
-- - Conversion indicator
--
-- This remains at lead-level granularity so Looker Studio can
-- dynamically aggregate records based on dashboard filters.
--
-- Source:
-- nexahub-analytics.marketing.leads
--
-- Output:
-- nexahub-analytics.marketing.v_leads_summary
-- ============================================================

CREATE OR REPLACE VIEW
    `nexahub-analytics.marketing.v_leads_summary` AS

SELECT
    -- Month identifier used for reporting and data blending.
    FORMAT_DATE('%Y-%m', date) AS month,

    -- Proper DATE representation of the month.
    -- Useful for Looker Studio date-range controls.
    DATE_TRUNC(date, MONTH) AS month_date,

    -- Calendar week number.
    EXTRACT(WEEK FROM date) AS week_number,

    -- Marketing acquisition source.
    channel_source,

    -- NexaHub service requested by the lead.
    service_interest,

    -- Current lead pipeline status.
    lead_status,

    -- Lead's country.
    country,

    -- Conversion classification.
    CASE
        WHEN lead_status = 'Closed Won' THEN 'Yes'
        ELSE 'No'
    END AS is_converted

FROM `nexahub-analytics.marketing.leads`;
