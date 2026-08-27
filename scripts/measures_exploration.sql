/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
--Find the total sale
SELECT
    'Total Sales' AS measures_name,
    SUM(sales_amount) AS measures_value
FROM gold.fact_sales
--Find how many items are sold
UNION ALL
SELECT 
    'Total items sold',
    SUM(quantity)
FROM gold.fact_sales
--Find average saleing price
UNION ALL
SELECT
    'Average price',
    AVG(price)
FROM gold.fact_sales
--Find the total number of orders
UNION ALL
SELECT
    'Total orders',
    COUNT(DISTINCT order_number)
FROM gold.fact_sales
--Find the total number of products
UNION ALL
SELECT
    'Total Products',
    COUNT(product_name)
FROM gold.dim_products
--Find the total number of customers
UNION ALL
SELECT
    'Total Customers',
    COUNT(customer_id)
FROM gold.dim_customers
