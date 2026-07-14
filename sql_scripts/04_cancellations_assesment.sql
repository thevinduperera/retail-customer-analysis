SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    SUM(CASE WHEN CustomerID IS NULL OR CustomerID = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Quantity >= 0 THEN 1 ELSE 0 END) AS positive_or_zero_quantity,
    SUM(CASE WHEN UnitPrice <= 0 THEN 1 ELSE 0 END) AS negative_or_zero_price,
    COUNT(DISTINCT Country) AS unique_countries,
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date
FROM cancellation_transactions;


SELECT
    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,
    ROUND(AVG(Quantity), 2) AS avg_quantity
FROM cancellation_transactions;


SELECT 
    CASE WHEN StockCode = 'M' THEN 'Manual adjustment' ELSE 'Product transaction' END AS type,
    COUNT(*) AS row_count
FROM cancellation_transactions
GROUP BY CASE WHEN StockCode = 'M' THEN 'Manual adjustment' ELSE 'Product transaction' END;


SELECT
    Country,
    COUNT(*) AS cancellation_rows,
    COUNT(DISTINCT InvoiceNo) AS cancelled_invoices,
    ROUND(SUM(ABS(Quantity * UnitPrice)), 2) AS cancelled_revenue_value
FROM cancellation_transactions
WHERE CustomerID IS NOT NULL
    AND CustomerID != ''
    AND StockCode != 'M'
GROUP BY Country
ORDER BY cancelled_revenue_value DESC
LIMIT 10;




-- Cleaning 

DELETE FROM cancellation_transactions
WHERE StockCode = 'M';

SELECT COUNT(*) AS rows_after_M_removal
FROM cancellation_transactions;

UPDATE cancellation_transactions
SET Country = TRIM(Country);

SELECT DISTINCT Country 
FROM cancellation_transactions
ORDER BY Country;

DELETE FROM cancellation_transactions
WHERE Quantity >= 0;

SELECT COUNT(*) AS rows_after_positive_qty_removal
FROM cancellation_transactions;


UPDATE cancellation_transactions
SET Country = TRIM(REPLACE(REPLACE(Country, '\r', ''), '\n', ''));
