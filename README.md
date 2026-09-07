# NexaHub Marketing Performance Dashboard

An interactive marketing analytics dashboard built with
BigQuery and Looker Studio to analyze lead generation,
channel performance, advertising spend, and CPL.

## Dashboard Preview

<img width="963" height="720" alt="image" src="https://github.com/user-attachments/assets/a733c83d-3b63-4122-9ecf-4b6c7fb9a157" />

## Objectives

- Monitor total lead generation
- Analyze leads by acquisition channel
- Track leads by service interest
- Analyze lead status
- Calculate Cost per Lead (CPL)
- Enable dynamic date and channel filtering

## Tech Stack

- Google BigQuery
- Looker Studio
- SQL
- CSV / Google Sheets

## Data Pipeline

Lead Register
      ↓
BigQuery
      ↓
v_leads_summary
      ↓
        + Ad Spend CSV
      ↓
Looker Studio Blend
      ↓
Marketing Dashboard

## Key Metrics

- Total Leads
- Advertising Spend
- Cost per Lead
- Leads by Channel
- Leads by Service Interest
- Lead Status Distribution

## CPL Calculation

CPL = Advertising Spend / Number of Leads

## Dashboard Features

- Date range filtering
- Multi-select channel filtering
- Monthly lead trends
- Service-interest analysis
- Channel distribution
- Lead-status breakdown
- Monthly CPL analysis
