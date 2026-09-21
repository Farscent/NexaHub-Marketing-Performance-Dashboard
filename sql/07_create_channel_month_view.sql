CREATE OR REPLACE VIEW
    `nexahub-analytics.marketing.v_channel_month` AS

WITH monthly_leads AS (
    SELECT
        DATE_TRUNC(CAST(date AS DATE), MONTH) AS month_date,
        TRIM(channel_source) AS channel_source,
        COUNT(*) AS total_leads,
        COUNTIF(lead_status = 'Closed Won') AS closed_won_leads
    FROM `nexahub-analytics.marketing.leads`
    GROUP BY month_date, channel_source
),

monthly_spend AS (
    SELECT
        -- Convert YYYY-MM or a date representation into a month-start DATE.
        PARSE_DATE(
            '%Y-%m-%d',
            CONCAT(SUBSTR(CAST(month AS STRING), 1, 7), '-01')
        ) AS month_date,
        TRIM(channel) AS channel_source,

        -- Keep spend unavailable if any input amount is missing.
        CASE
            WHEN COUNTIF(spend_usd IS NULL) > 0 THEN NULL
            ELSE SUM(spend_usd)
        END AS spend_usd,

        COUNT(*) AS spend_record_count
    FROM `nexahub-analytics.marketing.ad_spend`
    GROUP BY month_date, channel_source
),

combined AS (
    SELECT
        COALESCE(l.month_date, s.month_date) AS month_date,
        COALESCE(l.channel_source, s.channel_source) AS channel_source,
        COALESCE(l.total_leads, 0) AS total_leads,
        COALESCE(l.closed_won_leads, 0) AS closed_won_leads,
        s.spend_usd,
        COALESCE(s.spend_record_count, 0) AS spend_record_count
    FROM monthly_leads AS l
    FULL OUTER JOIN monthly_spend AS s
        ON l.month_date = s.month_date
        AND l.channel_source = s.channel_source
)

SELECT
    month_date,
    channel_source,
    channel_source IN ('Google Ads', 'LinkedIn') AS is_paid_channel,
    total_leads,
    closed_won_leads,
    spend_usd,
    spend_record_count,

    CASE
        WHEN channel_source IN ('Google Ads', 'LinkedIn')
        THEN SAFE_DIVIDE(spend_usd, total_leads)
        ELSE NULL
    END AS cpl_usd,

    SAFE_DIVIDE(
        closed_won_leads,
        total_leads
    ) AS closed_won_share,

    CASE
        WHEN channel_source NOT IN ('Google Ads', 'LinkedIn')
            THEN 'Not in paid-channel scope'
        WHEN spend_record_count = 0
            THEN 'Missing spend record'
        WHEN spend_usd IS NULL
            THEN 'Missing spend amount'
        WHEN total_leads = 0
            THEN 'No leads recorded'
        ELSE 'Available'
    END AS cpl_status

FROM combined;
