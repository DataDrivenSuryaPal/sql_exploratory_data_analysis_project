/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
--Find the date of the frst and the last order
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM  gold.fact_sales;
--How many years of sales are available and also months
SELECT
    DATEDIFF(year,MIN(order_date),MAX(order_date)) AS oeder_range_year
FROM gold.fact_sales;
--Find the youngest and the oldest customer
SELECT
    MIN(birthdate) AS oldest_customer,
    MAX(birthdate) AS youngest_customer
FROM gold.dim_customers;
--Find the age of the oldest and the youngest customer
SELECT
    DATEDIFF(year,MIN(birthdate),GETDATE()) AS oldest_age,
    DATEDIFF(year,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers;
--Find the gap between orderdate andd shipping date and due date
SELECT
    order_date,
    DATEDIFF(day,order_date,shipping_date) AS days_diff_order_and_ship,
    shipping_date,
    DATEDIFF(day,shipping_date,due_date) AS days_diff_ship_and_due,
    due_date
FROM gold.fact_sales;
