-- ============================================================
-- Project  : Customer Retention & Cohort Analysis
-- Dataset  : UCI Online Retail II (Dec 2009 - Dec 2011)
-- Database : PostgreSQL | retail_project | online_retail
-- Purpose  : Revenue trends, customer behaviour, cohort retention
-- ============================================================


-- ============================================================
-- Query 1 — Monthly Revenue Trend
-- Goal: Track how total revenue, orders, and unique customers
--       change month over month across the full dataset
-- ============================================================

SELECT
    DATE_TRUNC('month', invoicedate) AS revenue_month,
    ROUND(SUM(total_price)::numeric, 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM online_retail
WHERE total_price > 0
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY revenue_month;


-- ============================================================
-- Query 2 — Top 10 Countries by Revenue
-- Goal: Identify which markets generate the most revenue
--       and compare order volume vs average order value
-- ============================================================

SELECT
    country,
    ROUND(SUM(total_price)::numeric, 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT invoice) AS total_orders,
    ROUND((SUM(total_price) / COUNT(DISTINCT invoice))::numeric, 2) AS avg_order_value
FROM online_retail
WHERE total_price > 0
    AND country IS NOT NULL
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Query 3 — Top 10 Best Selling Products
-- Goal: Find which products drive the most revenue and volume
--       Excludes non-product stock codes (postage, manual, etc.)
-- ============================================================

SELECT
    stockcode,
    description,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_price)::numeric, 2) AS total_revenue,
    COUNT(DISTINCT invoice) AS times_ordered,
    ROUND((SUM(total_price) / NULLIF(SUM(quantity), 0))::numeric, 2) AS avg_unit_price
FROM online_retail
WHERE total_price > 0
    AND quantity > 0
    AND description IS NOT NULL
    AND stockcode NOT IN ('M', 'POST', 'DOT', 'BANK CHARGES', 'PADS')
    AND stockcode ~ '^[0-9]'
GROUP BY stockcode, description
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Query 4 — Top 10 Customers by Revenue
-- Goal: Identify high-value customers and their purchase history
--       Supports Pareto analysis (~4% customers = ~50% revenue)
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT invoice) AS total_orders,
    ROUND(SUM(total_price)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_price)::numeric, 2) AS avg_order_value,
    MIN(invoicedate::date) AS first_purchase,
    MAX(invoicedate::date) AS last_purchase
FROM online_retail
WHERE total_price > 0
    AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Query 5 — Purchase Frequency Distribution
-- Goal: Understand how many orders customers typically place
--       Reveals one-time buyers vs repeat purchasers
-- ============================================================

SELECT
    order_count,
    COUNT(customer_id) AS num_customers
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS order_count
    FROM online_retail
    WHERE total_price > 0
        AND customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_orders
GROUP BY order_count
ORDER BY order_count;


-- ============================================================
-- Query 6 — Customer Spend Segmentation
-- Goal: Group customers into spend tiers to understand
--       how revenue is distributed across the customer base
-- ============================================================

SELECT
    CASE
        WHEN total_revenue >= 10000 THEN 'High Value (10k+)'
        WHEN total_revenue >= 1000  THEN 'Mid Value (1k-10k)'
        WHEN total_revenue >= 100   THEN 'Low Value (100-1k)'
        ELSE 'Micro (under 100)'
    END AS spend_segment,
    COUNT(customer_id) AS num_customers,
    ROUND(AVG(total_revenue)::numeric, 2) AS avg_revenue_in_segment,
    ROUND(SUM(total_revenue)::numeric, 2) AS segment_total_revenue
FROM (
    SELECT
        customer_id,
        SUM(total_price) AS total_revenue
    FROM online_retail
    WHERE total_price > 0
        AND customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_totals
GROUP BY spend_segment
ORDER BY segment_total_revenue DESC;


-- ============================================================
-- Query 7 — Cohort Retention Table
-- Goal: Measure what % of customers from each monthly cohort
--       return to purchase in subsequent months
-- Note:  Month 0 = cohort's first purchase month (always 100%)
--        Retention typically drops sharply after Month 1
-- ============================================================

WITH customer_cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date::TIMESTAMP)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT
        cc.customer_id,
        cc.cohort_month,
        EXTRACT(YEAR FROM AGE(
            DATE_TRUNC('month', o.invoice_date::TIMESTAMP),
            cc.cohort_month
        )) * 12
        + EXTRACT(MONTH FROM AGE(
            DATE_TRUNC('month', o.invoice_date::TIMESTAMP),
            cc.cohort_month
        )) AS month_number
    FROM online_retail o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
    WHERE o.customer_id IS NOT NULL
),
cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS customers
    FROM cohort_data
    GROUP BY cohort_month, month_number
),
retention AS (
    SELECT
        cohort_month,
        month_number,
        customers,
        FIRST_VALUE(customers) OVER (
            PARTITION BY cohort_month ORDER BY month_number
        ) AS cohort_size,
        ROUND(
            100.0 * customers / FIRST_VALUE(customers) OVER (
                PARTITION BY cohort_month ORDER BY month_number
            ), 1
        ) AS retention_pct
    FROM cohort_counts
)
SELECT * FROM retention
ORDER BY cohort_month, month_number;