/*
	Create cleaned data table
*/
CREATE TABLE clean_retail_transactions (
	transaction_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	invoice_no TEXT NOT NULL,
	stock_code TEXT NOT NULL,
	description TEXT,
	quantity INTEGER NOT NULL,
	invoice_date TIMESTAMP NOT NULL,
	unit_price NUMERIC(12, 4) NOT NULL,
	customer_id INTEGER,
	country TEXT,
	transaction_type TEXT NOT NULL,
	line_total NUMERIC (14, 4)
);

/* 
	Trim description, customer_id, and country.
	Convert quantity, invoice_date, and unit_price
*/
SELECT
	TRIM(invoice_no) AS invoice_no,
	TRIM(stock_code) AS stock_code,
	NULLIF(TRIM(description), '') AS description,
	quantity::INTEGER AS quantity,
	TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI') AS invoice_date,
	unit_price::NUMERIC(12,4) AS unit_price,
	NULLIF(TRIM(customer_id), '')::INTEGER AS customer_id,
	NULLIF(TRIM(country), '') AS country
FROM raw_retail_transactions
LIMIT 20;

/* 
	Verify record count after removing exact duplicates 
*/
SELECT COUNT(*) AS deduplicated_records
FROM (
	SELECT DISTINCT 
		invoice_no,
		stock_code,
		description,
		quantity,
		invoice_date,
		unit_price,
		customer_id,
		country
	FROM raw_retail_transactions
) AS deduplicated;

/*
	Insert cleaned and deduplicated records
*/
-- remove exact duplicates
WITH deduplicated AS (
	SELECT DISTINCT
		invoice_no,
		stock_code,
		description,
		quantity,
		invoice_date,
		unit_price,
		customer_id,
		country
	FROM raw_retail_transactions
),
-- clean deduplicated data
cleaned AS (
	SELECT 
		TRIM(invoice_no) AS invoice_no,
		TRIM(stock_code) AS stock_code,
		NULLIF(TRIM(description), '') AS description,
		quantity::INTEGER AS quantity,
		TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI') AS invoice_date,
		unit_price::NUMERIC(12, 4) AS unit_price,
		NULLIF(TRIM(customer_id), '')::INTEGER AS customer_id,
		NULLIF(TRIM(country), '') AS country
	FROM deduplicated
)
-- insert cleaned data into clean_retail_transactions
INSERT INTO clean_retail_transactions (
	invoice_no,
	stock_code,
	description,
	quantity,
	invoice_date,
	unit_price,
	customer_id,
	country,
	transaction_type,
	line_total
)
SELECT
	invoice_no,
	stock_code,
	description,
	quantity,
	invoice_date,
	unit_price,
	customer_id,
	country,
	-- set transaction type
	CASE
		WHEN UPPER(invoice_no) LIKE 'C%' THEN 'Cancellation'
		WHEN quantity < 0 THEN 'Inventory Adjustment'
		WHEN unit_price = 0 THEN 'Zero-Value Transaction'
		ELSE 'Sale'
	END AS transaction_type,
	-- calculate line_total
	quantity * unit_price as line_total
FROM cleaned;

/*
	Verify cleaned records and classifications
*/
SELECT
	COUNT(*) AS total_clean_records,
	COUNT(*) FILTER (
		WHERE transaction_type = 'Sale'
	) AS sales,
	COUNT(*) FILTER (
		WHERE transaction_type = 'Cancellation'
	) AS cancellations,
	COUNT(*) FILTER (
		WHERE transaction_type = 'Inventory Adjustment'
	) AS inventroy_adjustments,
	COUNT(*) FILTER (
		WHERE transaction_type = 'Zero-Value Transaction'
	) AS zero_value_transactions
FROM clean_retail_transactions

/*
	Verify missing values after cleaning
*/
SELECT
	COUNT(*) FILTER (
		WHERE invoice_no IS NULL OR TRIM(invoice_no) = ''
	) AS missing_invoice_no,

	COUNT(*) FILTER (
		WHERE stock_code IS NULL OR TRIM(stock_code) = ''
	) AS missing_stock_code,

	COUNT(*) FILTER (
		WHERE description IS NULL
	) AS missing_description,

	COUNT(*) FILTER (
		WHERE quantity IS NULL
	) AS missing_quantity,

	COUNT(*) FILTER (
		WHERE invoice_date IS NULL
	) AS missing_invoice_date,

	COUNT(*) FILTER (
		WHERE unit_price IS NULL
	) AS missing_unit_price,

	COUNT(*) FILTER (
		WHERE customer_id IS NULL
	) AS missing_customer_id,

	COUNT(*) FILTER (
		WHERE country IS NULL
	) AS missing_country,

	COUNT(*) FILTER (
		WHERE transaction_type IS NULL
	) AS missing_transaction_type,

	COUNT(*) FILTER (
		WHERE line_total IS NULL
	) AS missing_line_total
FROM clean_retail_transactions;

/*
	Verify no duplicate records remain
*/
SELECT COALESCE(SUM(duplicate_count - 1), 0) AS remaining_duplicates
FROM (
	SELECT COUNT(*) AS duplicate_count
	FROM clean_retail_transactions
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
) AS duplicates;













	
