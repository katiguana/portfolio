SELECT
 	count(*) as cust_count,
	country,
	customer_id
FROM clean_retail_transactions
GROUP BY
	country,
	customer_id;

