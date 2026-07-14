-- Raw Table containing data from original source

LOAD DATA INFILE 'C:/Users/DELL/Documents/Self Project 1/retail_customer_analysis/data/retail_2009_2010.csv'
INTO TABLE retail_customer_analysis.raw_transactions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, CustomerID, Country)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate, '%m/%d/%Y %H:%i');

SELECT COUNT(*) FROM retail_customer_analysis.raw_transactions;

LOAD DATA INFILE 'C:/Users/DELL/Documents/Self Project 1/retail_customer_analysis/data/retail_2010_2011.csv'
INTO TABLE retail_customer_analysis.raw_transactions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, CustomerID, Country)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate, '%m/%d/%Y %H:%i');

SELECT COUNT(*) FROM retail_customer_analysis.raw_transactions;

SELECT 
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date,
    COUNT(*) AS total_rows
FROM retail_customer_analysis.raw_transactions;
