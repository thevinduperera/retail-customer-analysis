SELECT MAX(InvoiceDate) FROM cleaned_transactions;


CREATE TABLE rfm_base AS
SELECT
    CustomerID,
    DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency_days,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    ROUND(SUM(Revenue), 2) AS monetary
FROM cleaned_transactions
GROUP BY CustomerID;


SELECT COUNT(*) AS total_customers FROM rfm_base;


SELECT
    MIN(recency_days) AS min_recency,
    MAX(recency_days) AS max_recency,
    ROUND(AVG(recency_days), 2) AS avg_recency,
    MIN(frequency) AS min_frequency,
    MAX(frequency) AS max_frequency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    MIN(monetary) AS min_monetary,
    MAX(monetary) AS max_monetary,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM rfm_base;


CREATE TABLE rfm_scores AS
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_base;


SELECT COUNT(*) FROM rfm_scores;


SELECT * FROM rfm_scores
ORDER BY monetary DESC
LIMIT 10;



ALTER TABLE rfm_scores
ADD COLUMN rfm_string VARCHAR(10),
ADD COLUMN rfm_total_score INT;

UPDATE rfm_scores
SET 
    rfm_string = CONCAT(r_score, f_score, m_score),
    rfm_total_score = r_score + f_score + m_score;
    

SELECT CustomerID, r_score, f_score, m_score, rfm_string, rfm_total_score
FROM rfm_scores
ORDER BY rfm_total_score DESC
LIMIT 5;


DROP TABLE rfm_segments;

CREATE TABLE rfm_segments AS
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_string,
    rfm_total_score,
    CASE
        WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champions'
        WHEN f_score >= 4 AND m_score >= 4 THEN 'Loyal Customers'
        WHEN r_score = 5 AND f_score <= 2 THEN 'Recent Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Need Attention'
        WHEN r_score >= 3 AND f_score <= 2 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score >= 3 AND f_score >= 2 AND m_score >= 2 THEN 'Developing'
        WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Hibernating'
        WHEN m_score = 1 THEN 'Low Value'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'About To Sleep'
        WHEN r_score = 1 AND f_score = 1 THEN 'Lost'
        ELSE 'Others'
    END AS segment
FROM rfm_scores;


SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rfm_segments), 2) AS pct_of_customers,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(SUM(monetary), 2) AS total_revenue
FROM rfm_segments
GROUP BY segment
ORDER BY total_revenue DESC;

