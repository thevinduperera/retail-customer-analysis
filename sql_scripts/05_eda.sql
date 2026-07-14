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
    Country,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(AVG(Revenue), 2) AS avg_line_revenue,
    ROUND(SUM(Revenue) / (SELECT SUM(Revenue) FROM cleaned_transactions) * 100, 2) AS revenue_pct
FROM cleaned_transactions
GROUP BY Country
ORDER BY total_revenue DESC;


SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS times_ordered,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price
FROM cleaned_transactions
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 20;


SELECT
    COUNT(DISTINCT CustomerID) AS total_customers,
    ROUND(AVG(order_count), 2) AS avg_orders_per_customer,
    MAX(order_count) AS max_orders_single_customer,
    MIN(order_count) AS min_orders_single_customer,
    ROUND(AVG(customer_revenue), 2) AS avg_revenue_per_customer,
    MAX(customer_revenue) AS max_revenue_single_customer,
    MIN(customer_revenue) AS min_revenue_single_customer
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count,
        ROUND(SUM(Revenue), 2) AS customer_revenue
    FROM cleaned_transactions
    GROUP BY CustomerID
) AS customer_summary;




SELECT
    CASE
        WHEN order_count >= 50 THEN '50+ orders (almost certainly wholesale)'
        WHEN order_count >= 20 THEN '20-49 orders (likely wholesale)'
        WHEN order_count >= 5 THEN '5-19 orders (mixed)'
        ELSE '1-4 orders (likely retail)'
    END AS customer_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_revenue), 2) AS avg_revenue,
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    ROUND(SUM(customer_revenue) / (SELECT SUM(Revenue) FROM cleaned_transactions) * 100, 2) AS revenue_pct
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count,
        ROUND(SUM(Revenue), 2) AS customer_revenue
    FROM cleaned_transactions
    GROUP BY CustomerID
) AS customer_summary
GROUP BY
    CASE
        WHEN order_count >= 50 THEN '50+ orders (almost certainly wholesale)'
        WHEN order_count >= 20 THEN '20-49 orders (likely wholesale)'
        WHEN order_count >= 5 THEN '5-19 orders (mixed)'
        ELSE '1-4 orders (likely retail)'
    END
ORDER BY avg_revenue DESC;









SELECT
    CASE
        WHEN order_count >= 20 THEN 'Wholesale (20+ orders)'
        ELSE 'Retail (under 20 orders)'
    END AS segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    ROUND(AVG(customer_revenue), 2) AS avg_revenue,
    ROUND(SUM(customer_revenue) / (SELECT SUM(Revenue) 
        FROM cleaned_transactions) * 100, 2) AS revenue_pct
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count,
        ROUND(SUM(Revenue), 2) AS customer_revenue
    FROM cleaned_transactions
    GROUP BY CustomerID
) AS customer_summary
GROUP BY
    CASE
        WHEN order_count >= 20 THEN 'Wholesale (20+ orders)'
        ELSE 'Retail (under 20 orders)'
    END;




SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count,
    ROUND(AVG(Quantity), 2) AS avg_line_quantity,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM cleaned_transactions
GROUP BY CustomerID
ORDER BY avg_line_quantity DESC
LIMIT 20;


SELECT
    YEAR(InvoiceDate) AS yr,
    MONTH(InvoiceDate) AS mn,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    ROUND(AVG(Quantity), 2) AS avg_line_quantity
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
ORDER BY cancelled_value DESC
LIMIT 15;
