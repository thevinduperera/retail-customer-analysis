CREATE DATABASE retail_customer_analysis;
USE retail_customer_analysis;

CREATE TABLE raw_transactions (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
);

DESCRIBE raw_transactions;
