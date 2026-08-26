/*
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Product Report
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Purpose:
-This report consolidates key product matrics and behaviours
Highlights:
1. Gathers essential fields such as product name, category, subcategory, cost.
2. Segments products by revenue to identify high performer, Mid-range or Low-performer.
3. Aggregate product level matrics:
-Total orders
-Total sales
-Total quantity sold
-Total customer (unique)
-Lifespan(in months)
4. Calculate valuable KPIs:
-Recency (month since last sale)
-Average (AOR)
-Average monthly revenue
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
IF OBJECT_ID ('gold.report_products','v') 
IS NOT NULL
	DROP VIEW gold.report_products;
GO
CREATE VIEW gold.report_products AS
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-Base: Retrive core columns from tables
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*/
WITH base_query AS(
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL),
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
-Product Aggregation: Summarizes key metrics at the product level
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*/
product_aggregation AS (
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan_in_months,
		MAX(order_date) AS last_order_date,
		COUNT(DISTINCT order_number) AS total_order,
		COUNT(DISTINCT customer_key) AS total_customer,
		SUM(sales_amount) AS total_sale,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF (quantity,0)),1) AS avg_selling_price
	FROM base_query
	GROUP BY product_key,
			 product_name,
			 category,
			 subcategory,
			 cost)
/*= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
--Final query: Combine all product results into one output
= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF(MONTH, last_order_date,GETDATE()) AS recency_in_months,
	CASE WHEN total_sale > 50000 THEN 'High-performer'
		 WHEN total_sale >= 10000 THEN 'Mid-range'
		 ELSE 'Low-performer'
	END AS product_segments,
	lifespan_in_months,
	total_order,
	total_sale,
	total_quantity,
	total_customer,
	avg_selling_price,
	CASE WHEN total_order = 0 THEN 0
		 ELSE total_sale / total_order
	END AS avg_order_revenue,
	CASE WHEN lifespan_in_months = 0 THEN total_sale
		 ELSE total_sale / lifespan_in_months
	END AS avg_monthly_revenue
FROM product_aggregation
GO