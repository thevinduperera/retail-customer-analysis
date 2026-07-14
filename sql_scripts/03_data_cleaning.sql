USE retail_customer_analysis;

SELECT COUNT(*) AS total_rows 
FROM raw_transactions;

SELECT COUNT(*) AS missing_customer_id
FROM raw_transactions
WHERE CustomerID IS NULL OR CustomerID = '';

SELECT COUNT(*) AS cancellations
FROM raw_transactions
WHERE InvoiceNo LIKE 'C%';

SELECT COUNT(*) AS negative_or_zero_quantity
FROM raw_transactions
WHERE Quantity <= 0;

SELECT COUNT(*) AS negative_or_zero_price
FROM raw_transactions
WHERE UnitPrice <= 0;

SELECT InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID,
       COUNT(*) AS duplicate_count
FROM raw_transactions
GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;

SELECT COUNT(*) AS total_duplicate_groups
FROM (
    SELECT InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    FROM raw_transactions
    GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    HAVING COUNT(*) > 1
) AS dup_groups;

SELECT 
    SUM(duplicate_count - 1) AS excess_duplicate_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM raw_transactions
    GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    HAVING COUNT(*) > 1
) AS dup_counts;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN CustomerID IS NULL OR CustomerID = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS negative_zero_quantity,
    SUM(CASE WHEN UnitPrice <= 0 THEN 1 ELSE 0 END) AS negative_zero_price,
    SUM(CASE WHEN CustomerID IS NULL AND InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) AS missing_id_AND_cancellation,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' AND Quantity <= 0 THEN 1 ELSE 0 END) AS cancellation_AND_negative_qty,
    SUM(CASE WHEN CustomerID IS NULL AND Quantity <= 0 THEN 1 ELSE 0 END) AS missing_id_AND_negative_qty
FROM raw_transactions;



CREATE TABLE cleaned_transactions AS
SELECT * FROM raw_transactions;

SELECT COUNT(*) AS copied_rows 
FROM cleaned_transactions;

CREATE TABLE cancellation_transactions AS
SELECT * FROM raw_transactions
WHERE InvoiceNo LIKE 'C%';

SELECT COUNT(*) AS cancellation_rows
FROM cancellation_transactions;

ALTER TABLE cleaned_transactions
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE cancellation_transactions
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

DELETE FROM cleaned_transactions
WHERE InvoiceNo LIKE 'C%';

SELECT COUNT(*) AS rows_after_cancellation_removal
FROM cleaned_transactions;

DELETE FROM cleaned_transactions
WHERE Quantity <= 0;

SELECT COUNT(*) AS rows_after_quantity_removal
FROM cleaned_transactions;

DELETE FROM cleaned_transactions
WHERE UnitPrice <= 0;

SELECT COUNT(*) AS rows_after_price_removal
FROM cleaned_transactions;

DELETE FROM cleaned_transactions
WHERE CustomerID IS NULL OR CustomerID = '';

SELECT COUNT(*) AS rows_after_customerid_removal
FROM cleaned_transactions;

-- This query failed likely beacuse join is heavy
/*DELETE t1 FROM cleaned_transactions t1
INNER JOIN cleaned_transactions t2
WHERE t1.InvoiceNo = t2.InvoiceNo
    AND t1.StockCode = t2.StockCode
    AND t1.Quantity = t2.Quantity
    AND t1.InvoiceDate = t2.InvoiceDate
    AND t1.CustomerID = t2.CustomerID
    AND t1.UnitPrice = t2.UnitPrice
    AND t1.Description = t2.Description
    AND t1.Country = t2.Country
    AND t1.row_id > t2.row_id;   */
    


SELECT COUNT(*) FROM cleaned_transactions;


CREATE TABLE cleaned_transactions_deduped AS
SELECT 
    MIN(row_id) AS row_id,
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM cleaned_transactions
GROUP BY 
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country;
    
    
SELECT COUNT(*) AS deduped_row_count
FROM cleaned_transactions_deduped;

SELECT COUNT(*) AS remaining_duplicate_groups
FROM (
    SELECT InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    FROM cleaned_transactions_deduped
    GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    HAVING COUNT(*) > 1
) AS remaining_dupes;


SELECT 
    InvoiceNo,
    StockCode,
    Quantity,
    InvoiceDate,
    CustomerID,
    COUNT(*) AS duplicate_count
FROM cleaned_transactions_deduped
GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

SELECT 
    row_id,
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID
FROM cleaned_transactions_deduped
WHERE InvoiceNo IN ('539102','554084','567656','570488')
ORDER BY InvoiceNo, StockCode;


SELECT 
    StockCode,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    FROM cleaned_transactions_deduped
    GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    HAVING COUNT(*) > 1
) AS dupes
GROUP BY StockCode;

SELECT 
    row_id,
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID
FROM cleaned_transactions_deduped
WHERE InvoiceNo = '539102'
ORDER BY row_id
LIMIT 20;

SELECT 
    InvoiceNo,
    StockCode,
    COUNT(*) AS row_count
FROM cleaned_transactions_deduped
WHERE StockCode != 'M'
GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

DELETE FROM cleaned_transactions_deduped
WHERE StockCode = 'M';

SELECT COUNT(*) AS rows_after_M_removal
FROM cleaned_transactions_deduped;

SELECT COUNT(*) AS remaining_duplicate_groups
FROM (
    SELECT InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    FROM cleaned_transactions_deduped
    GROUP BY InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID
    HAVING COUNT(*) > 1
) AS remaining_dupes;



DROP TABLE cleaned_transactions;


RENAME TABLE cleaned_transactions_deduped TO cleaned_transactions;


SELECT COUNT(*) FROM cleaned_transactions;


ALTER TABLE cleaned_transactions
ADD COLUMN Revenue DECIMAL(10,2);

UPDATE cleaned_transactions
SET Revenue = Quantity * UnitPrice;


SELECT 
    MIN(Revenue) AS min_revenue,
    MAX(Revenue) AS max_revenue,
    ROUND(AVG(Revenue), 2) AS avg_revenue,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM cleaned_transactions;



SELECT
    COUNT(*) AS final_row_count,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT Country) AS unique_countries,
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(AVG(Revenue), 2) AS avg_line_revenue
FROM cleaned_transactions;



UPDATE cleaned_transactions
SET Country = TRIM(Country);

SELECT DISTINCT Country
FROM cleaned_transactions
ORDER BY Country;

UPDATE cleaned_transactions
SET Country = TRIM(REPLACE(REPLACE(Country, '\r', ''), '\n', ''));

