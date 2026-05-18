# Customer Retention & Cohort Analysis
### End-to-End Data Analytics Project | SQL · Python · Power BI

---

## Project Overview

This project analyses customer retention, revenue patterns, and purchasing behaviour for a UK-based online retailer using the [UCI Online Retail II dataset](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (~805,000 transactions, Dec 2009 – Dec 2011).

The business operates in a **wholesale/B2B model** — selling to small businesses, gift shops, and resellers across 40+ countries. Understanding *who* buys, *how often*, and *when they stop* is critical for revenue stability in this kind of model.

**Core business questions answered:**
- Is revenue growing or declining, and where is growth concentrated?
- Which customers are responsible for most of the revenue — and are they at risk?
- How quickly do customers disengage after their first purchase?
- Which products and markets drive disproportionate value?

---

## Key Findings

### 1. Revenue is heavily seasonal — Q4 is make-or-break
Revenue peaks sharply in October–November each year, driven by holiday wholesale demand. Q4 accounts for a disproportionate share of annual revenue. A dip in December is an **artefact of truncated data** (the 2011 dataset ends December 9th), not a business trend.

> **So what?** Planning, stock procurement, and campaign timing should be anchored around Q4. Missing this window has outsized revenue consequences.
> **For whom?** Operations and commercial planning teams.
> **By when?** Q3 preparation is the critical window — before demand spikes.

---

### 2. ~4% of customers generate ~50% of revenue (Pareto effect)
A small cohort of high-frequency, high-spend buyers dominates revenue.The top customer alone accounts for over £608,000 across 145 orders. This concentration is extreme even for B2B.                           

> **So what?** Losing even a handful of top customers could materially damage revenue. These relationships need active account management, not passive retention.
> **For whom?** Sales and account management teams.
> **By when?** Immediately — this is an ongoing risk, not a future one.

---

### 3. The "At Risk" segment is the highest-urgency intervention group
RFM segmentation identified **615 At Risk customers** with an average monetary value of ~£2,517 but an average recency of ~359 days — they used to spend significantly but haven't purchased in roughly a year.

> **So what?** These customers have proven willingness to spend at scale, but time is running out. Re-engagement is still possible; churn becomes permanent the longer they're ignored.
> **For whom?** CRM and retention marketing teams.
> **By when?** Within the next 30–60 days. Beyond that, the probability of win-back drops sharply.

---

### 4. Retention collapses after Month 1
Cohort analysis shows that customer retention drops steeply in Month 2 — typically falling to 20–30% — and then stabilises at a low level. Very few customers return consistently beyond month 3.

> **So what?** The biggest retention opportunity is the window immediately after the first purchase. An onboarding or re-engagement touchpoint in the first 4–6 weeks could meaningfully improve lifetime value.
> **For whom?** CRM, email marketing, and customer success teams.
> **By when?** Post-first-purchase automation should be the first intervention to test.

---

### 5. Revenue is geographically concentrated — UK dominates
The UK generates the vast majority of revenue. Among international markets, the Netherlands, Ireland, Germany, and France show meaningful volume — but no single international market approaches UK scale.

> **So what?** International growth exists but is nascent. Investing in 2–3 high-performing non-UK markets selectively is more defensible than spreading resources thin.
> **For whom?** Commercial and market expansion teams.

---

## Dataset & Limitations

**Dataset:** UCI Online Retail II | ~805K rows after cleaning | Dec 2009 – Dec 2011

**Key limitations to be aware of:**

- **2010 is the only complete baseline year.** The 2009 data begins in December, and 2011 ends on December 9th. Year-over-year comparisons should anchor to 2010 as the baseline.
- **RFM analysis qualified 5,484 customers** out of ~26,000 unique customer IDs. The gap (~20,500) represents cancelled orders, one-time incomplete transactions, and data quality exclusions. This is a separate **conversion and cancellation analysis problem**, not a flaw in the segmentation — but it means RFM findings apply to the *active buyer* population only.
- **B2B wholesale behaviour** means purchasing patterns differ from D2C e-commerce. Large single-order quantities, long gaps between repeat purchases, and near-binary Champions/Lost splits in RFM are expected, not anomalies.

---

## Technical Stack

| Layer | Tool |
|---|---|
| Data Cleaning | Python (pandas) |
| Data Storage | PostgreSQL |
| SQL Analysis | PostgreSQL (pgAdmin) |
| Visualisation | Python (seaborn, matplotlib) |
| RFM Segmentation | Python (pandas) |
| Dashboard | Power BI Desktop |

---

## Project Structure

```
customer-retention-analysis/
│
├── data/
│   └── online_retail_II_full.csv          # Raw concatenated dataset
│
├── outputs/
│   ├── revenue_by_month.csv
│   ├── country_wise_sales.csv
│   ├── stock_code_top10.csv
│   ├── top10_customer.csv
│   ├── spend_segment_info.csv
│   ├── frequency_of_orders.csv
│   ├── cohort_analysis_pct.csv
│   ├── rfm_segments.csv
│   └── charts/
│       ├── chart1_monthly_revenue.png
│       ├── chart2_country_revenue.png
│       ├── chart3_top10_products.png
│       ├── chart4_top10_customers.png
│       ├── chart5_spend_segments.png
│       ├── chart6_frequency_distribution.png
│       └── cohort_heatmap.png
│
├── notebooks/
│   ├── 01_data_cleaning_preprocessing.ipynb
|   ├── 02_load_to_postgres.ipynb
│   ├── 03_visualisations.ipynb
│   └── 04_rfm_segmentation.ipynb
│
├── sql/
│   └── analysis_queries.sql
│
└── README.md
```

---

## Six-Phase Methodology

### Phase 1 — Data Cleaning (Python)
Loaded both sheets of the UCI `.xlsx` file, concatenated them, and applied cleaning rules: removed rows with null CustomerIDs, filtered out non-product stock codes (e.g. `POST`, `M`, `DOT`), removed cancellations (InvoiceNo starting with `C`), and eliminated zero/negative quantity and price entries. Output: ~805K clean rows saved to CSV.

### Phase 2 — SQL Analysis (PostgreSQL)
Loaded cleaned data into a PostgreSQL database (`retail_project`, `online_retail` table). Wrote queries to analyse monthly revenue trends, country-level sales distribution, top customers by revenue, product-level performance, customer order frequency segments, and cohort retention (% of first-month buyers returning each subsequent month).

### Phase 3 — Python Visualisations (seaborn / matplotlib)
Produced six charts from the SQL outputs: monthly revenue trend, country revenue (UK excluded for scale), top 10 products, top 10 customers, spend segment distribution, and order frequency distribution (capped at 20 orders). Also produced a cohort retention heatmap.

### Phase 4 — RFM Segmentation (Python)
Assigned each of 5,484 qualifying customers a Recency, Frequency, and Monetary score (1–4 scale). Combined scores into RFM segments: Champions, Loyal, At Risk, Lost, and others. Reference date: December 10, 2011 (one day after the last transaction).

### Phase 5 — Power BI Dashboard
Built a four-page interactive dashboard:
- **Revenue Overview** — monthly trend, Q4 seasonality callout
- **Customer Segmentation** — Pareto donut charts, RFM scatter plot, spend segments
- **Cohort Retention** — conditional formatting matrix (heatmap equivalent)
- **Product Analysis** — top 10 products and geographic revenue breakdown


## Dashboard Preview

### Revenue Overview
![Revenue Overview](assets/dashboard_revenue.png)

### Customer Segmentation
![Customer Segmentation](assets/dashboard_segmentation.png)

### Cohort Retention
![Cohort Retention](assets/dashboard_cohort.png)

### Product Analysis
![Product Analysis](assets/dashboard_product.png)


### Phase 6 — Documentation
This README. Business findings framed around decision-relevance: so what, for whom, by when.

---

## How to Reproduce

1. Download the UCI Online Retail II dataset from [UCI ML Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
2. Run `phase1_data_cleaning.py` to produce the cleaned CSV
3. Load the CSV into PostgreSQL (database: `retail_project`, table: `online_retail`)
4. Run SQL queries in `phase2_analysis_queries.sql` and export results as CSVs to `outputs/`
5. Run `phase3_visualisations.py` and `phase4_rfm_segmentation.py`
6. Open Power BI Desktop and load the CSVs from `outputs/`

> **Note:** PostgreSQL connection uses `127.0.0.1` (not `localhost`). Adjust connection strings if needed.

---

## About This Project

Built as part of a data analyst portfolio to demonstrate end-to-end analytical thinking: from raw data to business-ready insight. The guiding principle throughout was **"think like a business analyst who uses code as a tool"** — understanding the *why* behind every step, not just the mechanics.
