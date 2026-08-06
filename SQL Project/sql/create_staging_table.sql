DROP TABLE IF EXISTS raw_retail_transactions;

CREATE TABLE raw_retail_transactions (
    raw_row_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_no TEXT,
    stock_code TEXT,
    description TEXT,
    quantity TEXT,
    invoice_date TEXT,
    unit_price TEXT,
    customer_id TEXT,
    country TEXT
);