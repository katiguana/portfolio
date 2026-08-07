-- create cleaned data table
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

SELECT * FROM clean_retail_transactions;