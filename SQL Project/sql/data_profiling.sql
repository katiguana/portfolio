-- total number of records
SELECT COUNT(*) AS total_records
FROM raw_retail_transactions;

-- preview the dataset
SELECT *
FROM raw_retail_transactions
LIMIT 10;

-- check for missing values in each column
SELECT
	COUNT(*) FILTER (
		WHERE NULLIF(TRIM(invoice_no), '') IS NULL
	) AS missing_invoice_no,

	COUNT(*) FILTER (
		WHERE NULLIF(TRIM(stock_code), '') IS NULL
	) AS missing_stock_code,

	 COUNT(*) FILTER (
        WHERE NULLIF(TRIM(description), '') IS NULL
    ) AS missing_description,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(quantity), '') IS NULL
    ) AS missing_quantity,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(invoice_date), '') IS NULL
    ) AS missing_invoice_date,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(unit_price), '') IS NULL
    ) AS missing_unit_price,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(customer_id), '') IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(country), '') IS NULL
    ) AS missing_country
FROM raw_retail_transactions;

-- identify duplicate records
SELECT 
	invoice_no,
	stock_code,
	description,
	quantity,
	invoice_date,
	unit_price,
	customer_id,
	country,
	COUNT(*) AS duplicate_count
FROM raw_retail_transactions
GROUP BY
	invoice_no,
	stock_code,
	description,
	quantity,
	invoice_date,
	unit_price,
	customer_id,
	country
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- count rows that are duplicates of another row
SELECT
	SUM(duplicate_count - 1) AS duplicate_rows
FROM (
	SELECT COUNT(*) AS duplicate_count
	FROM raw_retail_transactions
	GROUP BY
		invoice_no,
		stock_code,
		description,
		quantity,
		invoice_date,
		unit_price,
		customer_id,
		country
	HAVING COUNT(*) > 1
) duplicates;

-- count cancelled transactions
SELECT
	COUNT(*) AS cancelled_records
FROM raw_retail_transactions
WHERE UPPER(invoice_no) LIKE 'C%';

-- compare cancellations with negative quantities
SELECT
	CASE
		WHEN UPPER(invoice_no) LIKE 'C%' THEN 'Cancelled'
		ELSE 'Not Cancelled'
	END AS invoice_status,
	CASE 
		WHEN quantity::INTEGER < 0 THEN 'Negative Quantity'
		ELSE 'Positive Quantity'
	END AS quantity_status,
	COUNT(*) AS record_count
FROM raw_retail_transactions
GROUP BY invoice_status, quantity_status
ORDER BY invoice_status, quantity_status;

-- find neg quantities that are not cancellations
SELECT
	stock_code,
	description,
	COUNT(*) AS record_count,
	MIN(quantity::INTEGER) AS min_quantity,
	MAX(quantity::INTEGER) AS max_quantity
FROM raw_retail_transactions
WHERE UPPER(invoice_no) NOT LIKE 'C%'
	AND quantity::INTEGER < 0
GROUP BY stock_code, description
ORDER BY record_count DESC
LIMIT 50;

-- find quantity values that are not valid integers
SELECT DISTINCT quantity
FROM raw_retail_transactions
WHERE TRIM(quantity) !~ '^-?[0-9]+$';

-- examine quantity range
SELECT
	MIN(quantity::INTEGER) AS min_quantity,
	MAX(quantity::INTEGER) AS max_quantity,
	COUNT(*) FILTER (
		WHERE quantity::INTEGER < 0
	) AS neg_quantity_records,
	COUNT(*) FILTER (
		WHERE quantity::INTEGER = 0
	) AS zero_quantity_records
FROM raw_retail_transactions
WHERE TRIM(quantity) ~ '^-?[0-9]+$';

-- find non-numeric unit prices
SELECT DISTINCT unit_price
FROM raw_retail_transactions
WHERE TRIM(unit_price) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- examine unit price range
SELECT
	MIN(unit_price::INTEGER) AS min_unit_price,
	MAX(unit_price::INTEGER) AS max_unit_price,
	COUNT(*) FILTER (
		WHERE unit_price::INTEGER < 0
	) AS neg_unit_price_records,
	COUNT(*) FILTER (
		WHERE unit_price::INTEGER = 0
	) AS zero_unit_price_records
FROM raw_retail_transactions
WHERE TRIM(unit_price) ~ '^-?[0-9]+$';

-- examine records with zero unit price
SELECT
	stock_code,
	description,
	COUNT(*) AS record_count
FROM raw_retail_transactions
WHERE unit_price::NUMERIC = 0
GROUP BY stock_code, description
ORDER BY record_count DESC
LIMIT 20;

-- number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM raw_retail_transactions
WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL;

-- number of unique products
SELECT COUNT(DISTINCT stock_code) AS unique_products
FROM raw_retail_transactions
WHERE NULLIF(TRIM(stock_code), '') IS NOT NULL;

-- number of transactions by country
SELECT
	country,
	COUNT(*) AS transaction_records
FROM raw_retail_transactions
GROUP BY country
ORDER BY transaction_records DESC;

-- inspect date format
SELECT DISTINCT invoice_date
FROM raw_retail_transactions
ORDER BY invoice_date
LIMIT 20;

-- inspect missing descriptions
SELECT
	stock_code,
	COUNT(*) AS missing_description_count
FROM raw_retail_transactions
WHERE NULLIF(TRIM(description), '') IS NULL
GROUP BY stock_code
ORDER BY missing_description_count DESC;











	
