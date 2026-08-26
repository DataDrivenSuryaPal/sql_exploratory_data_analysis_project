/*
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
Customer Report
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
Purpose:
- This report consolidates key customer metrics and behaviors
Highlights:
1. Gather essential fields such as names, ages and transactions details.
2. Segments customer into categories (VIP, Regular, New) and age groups.
3. Aggregates customer level matrics:
- Total orders
- Total sales
- Total quantity purchased
- Total products
- lifespan(in months)
4. Calculates valuable KPIs:
- Recency (Months since last order)
- Average Order Value
- Average monthly Spend
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
IF OBJECT_ID ('gold.report_customers','v') 
IS NOT NULL
	DROP VIEW gold.report_customers;
GO
CREATE VIEW gold.report_customers AS
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
-Base: Retrive core columns from tables
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
WITH base_query AS (
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name,' ',c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate,GETDATE()) AS customer_age
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON f.customer_key = c.customer_key
	WHERE order_date IS NOT NULL)
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
-Customer aggregation: Summarizes key matrics at Customer level
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
,customer_aggregation AS(
	SELECT
		customer_key,
		customer_number,
		customer_name,
		customer_age,
		COUNT(DISTINCT order_number) AS total_order,
		SUM(sales_amount) AS total_sale,
		SUM(quantity) AS total_quantity,
		COUNT(product_key) AS total_product,
		MAX(order_date) AS last_order_date,
		DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan_in_months
	FROM base_query
	GROUP BY customer_key,
			 customer_number,
			 customer_name,
			 customer_age)
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
-Data Segments and calculating valuable KPIs
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
SELECT
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	CASE WHEN customer_age <20 THEN 'Teenager'
		 WHEN customer_age BETWEEN 20 AND 29 THEN 'In 20s'
		 WHEN customer_age BETWEEN 30 AND 39 THEN 'In 30s'
		 WHEN customer_age BETWEEN 40 AND 49 THEN 'In 40s'
		 ELSE '50s and above'
	END AS age_group,
	total_order,
	total_sale,
	total_quantity,
	total_product,
	CASE WHEN lifespan_in_months >= 12 AND total_sale > 5000 THEN 'VIP'
		 WHEN lifespan_in_months >= 12 AND total_sale <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(month,last_order_date,GETDATE()) AS recency,
	lifespan_in_months,
	CASE WHEN total_sale = 0 THEN 0
		 ELSE total_sale/total_order
	END AS avg_monthly_spend
FROM customer_aggregation
GO