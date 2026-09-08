# NexaHub Marketing Performance Dashboard

An interactive marketing analytics dashboard built with Google BigQuery
and Looker Studio to analyze lead generation, acquisition channels,
advertising spend, and Cost per Lead (CPL).

## Dashboard Preview

<img width="963" height="720" alt="NexaHub Marketing Dashboard"
src="https://github.com/user-attachments/assets/a733c83d-3b63-4122-9ecf-4b6c7fb9a157" />

## Live Dashboard

🔗 [View the Interactive Looker Studio Dashboard](https://datastudio.google.com/reporting/4562b45e-3b9d-4ad9-9a97-6ba34c1eb14c)

> The dashboard supports dynamic filtering by date range and acquisition channel.

## Objectives

- Monitor total lead generation
- Analyze leads by acquisition channel
- Track leads by service interest
- Analyze lead pipeline status
- Monitor advertising expenditure
- Calculate Cost per Lead (CPL)
- Enable dynamic date and channel filtering

## Tech Stack

- Google Sheets
- Google BigQuery
- SQL
- Looker Studio

## Data Engineering Workflow

This project uses a hybrid ETL/ELT workflow.

### Upstream Data Preparation

Lead data was prepared in Google Sheets before ingestion into BigQuery.

Data-quality and transformation steps included:

- Creating `week_number` from lead dates
- Creating `month_flag` for monthly grouping
- Applying dropdown validation to `channel_source`
- Performing pivot-based validation and sanity checks
- Enforcing consistent acquisition-channel values

### BigQuery Transformation

The prepared lead data was loaded into Google BigQuery, where additional
SQL-based transformations and analytical modeling were performed.

These included:

- Monthly lead aggregation
- Channel-level analysis
- Service-interest analysis
- Lead-status classification
- Conversion labeling
- Google Ads CPL calculation
- Creation of the reusable `v_leads_summary` analytical view

## Data Pipeline

<img width="1448" height="1086" alt="NexaHub Marketing Data Pipeline"
src="https://github.com/user-attachments/assets/988e036c-e910-44e3-afaa-37132c50bca7" />

The workflow can be summarized as:

Google Sheets Lead Register  
→ Data Validation & Upstream Transformation  
→ BigQuery  
→ SQL Transformation & Analytical Modeling  
→ `v_leads_summary`  
→ Ad Spend Integration  
→ Looker Studio  
→ Marketing Dashboard

## SQL Analysis

The repository contains SQL queries for:

- Monthly lead volume
- Lead acquisition by channel
- Service-interest analysis
- Lead-status breakdown
- Google Ads CPL analysis
- Creation of the `v_leads_summary` analytical view

See the [`sql/`](./sql) directory for the complete queries.

## Key Metrics

- Total Leads
- Advertising Spend
- Cost per Lead
- Leads by Channel
- Leads by Service Interest
- Lead Status Distribution

## CPL Calculation

Cost per Lead is calculated as:

CPL = Advertising Spend / Number of Paid Leads

Monthly CPL is analyzed by paid acquisition channel.

## Dashboard Features

- Interactive date range filtering
- Multi-select acquisition channel filtering
- Monthly lead trend analysis
- Service-interest analysis
- Channel distribution
- Lead-status breakdown
- Monthly CPL analysis

## Data Integration

Lead data and advertising spend originate from separate sources.

The datasets are blended using:

- Month
- Acquisition channel

During development, the lead dataset represented month as a `YYYY-MM`
string while the advertising dataset was interpreted as a date.

A standardized month-date field was created to ensure consistent joins
and date filtering in Looker Studio.

## Repository Structure

```text
nexahub-marketing-performance/
│
├── README.md
│
└── sql/
    ├── README.md
    ├── 01_monthly_leads.sql
    ├── 02_leads_by_channel.sql
    ├── 03_leads_by_service_interest.sql
    ├── 04_lead_status_breakdown.sql
    ├── 05_google_ads_cpl.sql
    └── 06_create_leads_summary_view.sql
