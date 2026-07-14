CREATE TABLE customer_country AS
SELECT CustomerID, Country
FROM (
    SELECT
        CustomerID,
        Country,
        COUNT(*) AS transaction_count,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY COUNT(*) DESC) AS rn
    FROM cleaned_transactions
    GROUP BY CustomerID, Country
) AS ranked
WHERE rn = 1;


SELECT COUNT(*) FROM customer_country;


USE retail_customer_analysis;

CREATE TABLE rfm_final_export AS
SELECT
    s.CustomerID,
    s.recency_days,
    s.frequency,
    s.monetary,
    s.r_score,
    s.f_score,
    s.m_score,
    s.rfm_string,
    s.rfm_total_score,
    s.segment,
    cc.Country
FROM rfm_segments s
LEFT JOIN customer_country cc
    ON s.CustomerID = cc.CustomerID
ORDER BY s.rfm_total_score DESC;


SELECT COUNT(*) FROM rfm_final_export;


SELECT * FROM rfm_final_export
ORDER BY rfm_total_score DESC;




SELECT
    YEAR(InvoiceDate) AS yr,
    MONTH(InvoiceDate) AS mn,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS active_customers,
    ROUND(SUM(Revenue), 2) AS monthly_revenue,
    ROUND(AVG(Revenue), 2) AS avg_line_revenue
FROM cleaned_transactions
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY YEAR(InvoiceDate), MONTH(InvoiceDate);


SELECT
    ct.Country,
    COUNT(DISTINCT ct.InvoiceNo) AS cancelled_invoices,
    COUNT(*) AS cancellation_rows,
    ROUND(SUM(ABS(ct.Quantity * ct.UnitPrice)), 2) AS cancelled_value,
    ROUND(SUM(ABS(ct.Quantity * ct.UnitPrice)) /
        (SELECT SUM(Revenue) FROM cleaned_transactions) * 100, 2) AS pct_of_total_revenue
FROM cancellation_transactions ct
GROUP BY ct.Country
ORDER BY cancelled_value DESC;




SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS times_ordered,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price,
    COUNT(DISTINCT CustomerID) AS unique_customers
FROM cleaned_transactions
WHERE StockCode != 'POST'
    AND StockCode != '23843'
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 20;
