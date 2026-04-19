-- Financial KPI Dashboard — analytical queries
--
-- Prerequisites: load data/cleaned_data.csv into a table named cleaned_sales with columns:
--   Date (date), Region (text), Category (text), Revenue, Profit, Quantity (numeric).
--
-- Dialect notes:
--   • PostgreSQL: queries below use DATE_TRUNC — works as-is.
--   • SQL Server: replace DATE_TRUNC('month', "Date") with DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1).
--   • SQLite: use strftime('%Y-%m-01', Date) AS month_start and group by that string.

-- =============================================================================
-- 1) Revenue aggregation by region and category
-- =============================================================================
SELECT
    Region,
    Category,
    SUM(Revenue) AS total_revenue,
    SUM(Profit) AS total_profit,
    SUM(Quantity) AS total_quantity,
    CASE
        WHEN SUM(Revenue) > 0 THEN 100.0 * SUM(Profit) / SUM(Revenue)
    END AS profit_margin_pct
FROM cleaned_sales
GROUP BY Region, Category
ORDER BY total_revenue DESC;

-- =============================================================================
-- 2) Top segments by revenue (with contribution % of portfolio)
-- =============================================================================
WITH seg AS (
    SELECT
        Region,
        Category,
        SUM(Revenue) AS segment_revenue
    FROM cleaned_sales
    GROUP BY Region, Category
),
tot AS (
    SELECT SUM(segment_revenue) AS portfolio_revenue FROM seg
)
SELECT
    s.Region,
    s.Category,
    s.segment_revenue,
    100.0 * s.segment_revenue / NULLIF(t.portfolio_revenue, 0) AS contribution_pct
FROM seg s
CROSS JOIN tot t
ORDER BY s.segment_revenue DESC
LIMIT 20;

-- SQL Server: use TOP (20) ... ORDER BY ... ; PostgreSQL/SQLite: LIMIT works as above.

-- =============================================================================
-- 3) Monthly revenue and MoM / YoY growth
-- =============================================================================
WITH m AS (
    SELECT
        DATE_TRUNC('month', "Date")::date AS month_start,
        SUM(Revenue) AS monthly_revenue
    FROM cleaned_sales
    GROUP BY DATE_TRUNC('month', "Date")
)
SELECT
    month_start,
    monthly_revenue,
    100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month_start))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month_start), 0) AS mom_growth_pct,
    100.0 * (monthly_revenue - LAG(monthly_revenue, 12) OVER (ORDER BY month_start))
        / NULLIF(LAG(monthly_revenue, 12) OVER (ORDER BY month_start), 0) AS yoy_growth_pct
FROM m
ORDER BY month_start;

-- SQLite: replace DATE_TRUNC with strftime('%Y-%m-01', Date) and parse to date.
-- SQL Server: use DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) for month bucket.

-- =============================================================================
-- 4) Revenue concentration (Herfindahl index on category shares)
-- =============================================================================
WITH cat AS (
    SELECT Category, SUM(Revenue) AS r FROM cleaned_sales GROUP BY Category
), s AS (
    SELECT SUM(r) AS total_r FROM cat
)
SELECT
    SUM(POWER(c.r / NULLIF(s.total_r, 0), 2)) AS revenue_hhi_categories
FROM cat c
CROSS JOIN s;

-- =============================================================================
-- 5) Performance-oriented view: region rollups for dashboard filters
-- =============================================================================
SELECT
    Region,
    SUM(Revenue) AS revenue,
    SUM(Profit) AS profit,
    SUM(Quantity) AS volume,
    CASE WHEN SUM(Revenue) > 0 THEN 100.0 * SUM(Profit) / SUM(Revenue) END AS margin_pct
FROM cleaned_sales
GROUP BY Region
ORDER BY revenue DESC;
