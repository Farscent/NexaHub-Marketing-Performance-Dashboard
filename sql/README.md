# SQL Analysis

These GoogleSQL scripts analyze NexaHub lead acquisition and prepare two BigQuery views for the Looker Studio dashboard: a lead-level view for volume and status analysis, and a monthly channel view for advertising spend and Paid CPL.

## Query Overview

| File | Description |
|---|---|
| [01_monthly_leads.sql](01_monthly_leads.sql) | Counts leads by acquisition month |
| [02_leads_by_channel.sql](02_leads_by_channel.sql) | Counts leads by acquisition channel |
| [03_leads_by_service_interest.sql](03_leads_by_service_interest.sql) | Calculates service-interest counts and percentage shares using a window aggregation |
| [04_lead_status_breakdown.sql](04_lead_status_breakdown.sql) | Counts current statuses and labels `Closed Won` records |
| [05_google_ads_cpl.sql](05_google_ads_cpl.sql) | Earlier Google Ads monthly CPL example using an inner join |
| [06_create_leads_summary_view.sql](06_create_leads_summary_view.sql) | Creates `marketing.v_leads_summary` at lead grain |
| [07_create_channel_month_view.sql](07_create_channel_month_view.sql) | Creates `marketing.v_channel_month` by joining monthly lead counts and spend |

**Query 07 is the current CPL layer.** Query 05 is retained for reference: its inner join excludes unmatched months, and its join assumes `ad_spend.month` matches the lead-side `YYYY-MM` string. It is not required to build either current view.

## Inputs and Execution

The scripts reference `nexahub-analytics.marketing`. Replace this project and dataset prefix when running them elsewhere.

| Table | Expected source grain | Required fields |
|---|---|---|
| `marketing.leads` | One recorded lead per row | `date`, `channel_source`, `service_interest`, `lead_status`, `country` |
| `marketing.ad_spend` | One month and paid channel per row | `month`, `channel`, `spend_usd` |

Use a BigQuery **DATE** for `leads.date` to match the lead-analysis scripts, strings for categorical fields, and a numeric type for `spend_usd`. Query 07 accepts a spend month whose string representation begins with `YYYY-MM`, such as `2026-03` or a DATE value `2026-03-01`. Malformed non-null month values fail parsing rather than being silently dropped.

1. Load both inputs and confirm their columns and data types.
2. Run query 06 and query 07 to create the views. Both read the base tables directly, so neither depends on the other.
3. Run the validation queries below.
4. Connect the views to Looker Studio as described in the dashboard mapping.
5. Run queries 01–04 independently when exploring the data.

The repository's [sample CSV](../data/leads_sample.csv) contains two illustrative leads. Reproducing the dashboard's exact totals requires the full 30-lead source and six spend records, which are not committed here.

## Analytical Views

### `marketing.v_leads_summary`

**Grain: one row per source lead.**

Provides `month`, `month_date`, `week_number`, `channel_source`, `service_interest`, `lead_status`, `country`, and `is_converted`.

- `month_date` is the first day of the lead's acquisition month.
- `week_number` uses BigQuery's `WEEK` convention, which starts on Sunday; it is not an ISO week number.
- `is_converted = 'Yes'` means the recorded status is currently `Closed Won`.
- The view does not expose the original daily lead date or perform deduplication.

### `marketing.v_channel_month`

**Grain: one row per month and channel.**

The query:

1. Counts leads and currently closed-won leads by month and trimmed channel name.
2. Normalizes spend month values into a month-start DATE and aggregates spend by channel.
3. Joins the aggregates with a `FULL OUTER JOIN` on `month_date` and `channel_source`.
4. Adds paid-channel classification, CPL, current closed-won share, and availability labels.

Aggregating before joining prevents monthly spend from being repeated once per lead.

| Field | Meaning |
|---|---|
| `month_date` | Month-start reporting date |
| `channel_source` | Acquisition channel |
| `is_paid_channel` | True for Google Ads and LinkedIn |
| `total_leads` | Lead count for the month and channel |
| `closed_won_leads` | Count currently marked `Closed Won` |
| `spend_usd` | Recorded spend; NULL when absent or when any grouped spend amount is missing |
| `spend_record_count` | Number of source spend rows in the group; zero when unmatched |
| `cpl_usd` | Spend divided by lead count for paid channels |
| `closed_won_share` | Currently closed-won leads divided by all leads in the group |
| `cpl_status` | Availability or exclusion reason |

## CPL and Missing Data

| Condition | Behavior |
|---|---|
| Paid channel with spend and leads | Calculate `SAFE_DIVIDE(spend_usd, total_leads)` |
| Spend record without matching leads | Retain the row, set lead count to zero, and return NULL CPL |
| Paid-channel leads without a spend record | Retain the leads; spend and CPL remain NULL |
| Any missing spend amount within a group | Group spend and CPL remain NULL |
| Channel outside Google Ads and LinkedIn | CPL is NULL and status is `Not in paid-channel scope` |

Other status labels are `Missing spend record`, `Missing spend amount`, `No leads recorded`, and `Available`.

The SQL does not currently reject negative spend, null join keys, or duplicate source leads. Duplicate spend rows are aggregated, so validate the source grain rather than assuming the aggregation removes duplicates.

For a selection spanning multiple months or channels, divide total paid spend by total paid leads. Do not average the row-level `cpl_usd` values.

## Validation SQL

### Inspect the Monthly Output

```sql
SELECT *
FROM `nexahub-analytics.marketing.v_channel_month`
ORDER BY month_date, channel_source;
```

### Reconcile Full-Period Totals

```sql
SELECT
    SUM(total_leads) AS total_leads,
    SUM(IF(is_paid_channel, total_leads, 0)) AS paid_leads,
    SUM(spend_usd) AS total_spend_usd,
    CASE
        WHEN COUNTIF(is_paid_channel AND spend_usd IS NULL) > 0
            THEN NULL
        ELSE ROUND(
            SAFE_DIVIDE(
                SUM(IF(is_paid_channel, spend_usd, 0)),
                SUM(IF(is_paid_channel, total_leads, 0))
            ),
            2
        )
    END AS overall_paid_cpl_usd,
    SUM(closed_won_leads) AS closed_won_leads
FROM `nexahub-analytics.marketing.v_channel_month`;
```

For the full March–May dashboard source, expect **30 total leads, 14 paid leads, $7,900 spend, $564.29 Paid CPL, and 8 currently closed-won leads**. Compare these against independent counts and sums from the source tables.

### Investigate Multiple Spend Records

```sql
SELECT month_date, channel_source, spend_record_count
FROM `nexahub-analytics.marketing.v_channel_month`
WHERE spend_record_count > 1;
```

Expect no rows for the original input, which has one spend record per month and paid channel. Returned rows need investigation; they are not automatically duplicates if a future input uses a different grain.

These are manual checks. Edge-case behavior is documented from the SQL and is not presented as an automated test suite.

## Dashboard Mapping and Filters

| Dashboard component | View | Metric |
|---|---|---|
| Total Leads | `v_leads_summary` | Record Count |
| Leads per Month | `v_leads_summary` | Record Count, grouped by `month_date` |
| Leads by Service Interest | `v_leads_summary` | Record Count, grouped by `service_interest` |
| Lead Status Breakdown | `v_leads_summary` | Record Count, grouped by `lead_status` |
| Leads by Channel | `v_leads_summary` | Record Count, grouped by `channel_source` |
| Ad Spend | `v_channel_month` | `SUM(spend_usd)` |
| Paid CPL and Monthly CPL | `v_channel_month` | `SUM(spend_usd) / SUM(total_leads)`, with `is_paid_channel = TRUE` |

Use `month_date` as a full **Date** field for the date-range dimension, set default ranges to **Auto**, and test channel-control coverage across both sources. In the monthly view, lead volume is **SUM(total_leads)**; Record Count would count month–channel rows.

Use complete-month selections. Service, status, and country filters belong to lead-level analysis; monthly spend has no corresponding allocation by those dimensions.

For March, all-channel reporting should show **10 total leads, 5 paid leads, $2,300 spend, and $460 Paid CPL**. The four lead charts should describe those same 10 leads. See the [project README](../README.md) for the live report and further validation results.

