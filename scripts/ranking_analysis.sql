/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/
--What are the 5 wrost performing products in terms or sales
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key 
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount);
-- Find the top 10 customers who have generated highest revenue
SELECT TOP 10
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id,
    c.first_name,
    c.last_name
ORDER BY SUM(f.sales_amount) DESC;
--Find the 3 customers with fewest orders placed
SELECT TOP 3
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_order
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id,
    c.first_name,
    c.last_name
ORDER BY COUNT(DISTINCT order_number);
--Which five products generates the highest revenue?
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key 
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount) DESC;
--Includes ranks
SELECT * FROM 
    (SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER () OVER (ORDER BY SUM(f.sales_amount)DESC) AS rank_products
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.product_name)t
WHERE rank_products <= 5
--What are the 5 wrost performing products in terms or sales
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key 
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount);
-- Find the top 10 customers who have generated highest revenue
SELECT TOP 10
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id,
    c.first_name,
    c.last_name
ORDER BY SUM(f.sales_amount) DESC;
--Find the 3 customers with fewest orders placed
SELECT TOP 3
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_order
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_id,
    c.first_name,
    c.last_name
ORDER BY COUNT(DISTINCT order_number);
