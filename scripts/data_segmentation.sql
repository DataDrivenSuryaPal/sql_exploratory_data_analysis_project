/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/
/* Segment products into cost ranges and count how many hoe many products 
fall into each segment */
WITH product_segments AS (
	SELECT
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
			 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			 ELSE 'Above 1000'
		END cost_range
	FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT (product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/* Group customers into three segments based on their spending behavior:
-VIP: customers with at least 12 months of history and spending more than 5000
-Regular: Customers with at least 12 months of history and spending 5000 or less
-New: Customers with a lifespan less than 12 months. 
And find the total number of customer by each group */
WITH customer_spending_data AS (
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(month,MIN(f.order_date),MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON f.customer_key = c.customer_key
	WHERE f.order_date IS NOT NULL
	GROUP BY c.customer_key
)
SELECT
customer_segment,
COUNT(customer_key) AS total_customer
FROM(
	SELECT
		customer_key,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending_data)t
GROUP BY customer_segment
ORDER BY total_customer DESC
