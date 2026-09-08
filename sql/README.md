# SQL Analysis

This directory contains the SQL queries used to analyze NexaHub's
marketing lead data and prepare the analytical layer for the Looker
Studio dashboard.

## Query Overview

| File | Description |
|---|---|
| `01_monthly_leads.sql` | Calculates total leads generated per month |
| `02_leads_by_channel.sql` | Analyzes lead volume by acquisition channel |
| `03_leads_by_service_interest.sql` | Measures demand and percentage distribution across services |
| `04_lead_status_breakdown.sql` | Analyzes pipeline status and classifies converted leads |
| `05_google_ads_cpl.sql` | Calculates monthly Google Ads Cost per Lead |
| `06_create_leads_summary_view.sql` | Creates the analytical view consumed by Looker Studio |

## Data Sources

Two main tables are used:

### `marketing.leads`

Contains lead-level marketing data including:

- Lead date
- Acquisition channel
- Service interest
- Lead status
- Country

### `marketing.ad_spend`

Contains monthly paid advertising expenditure by channel:

- Month
- Advertising channel
- Spend in USD

## Analytical View

The dashboard primarily consumes:

`marketing.v_leads_summary`

The view provides standardized dimensions for interactive analysis in
Looker Studio while maintaining lead-level granularity.

## Cost per Lead

Paid advertising efficiency is evaluated using:

CPL = Advertising Spend / Paid Leads

The repository contains a dedicated Google Ads CPL query, while the
Looker Studio dashboard blends the summarized lead data with advertising
spend to support channel-level analysis.
