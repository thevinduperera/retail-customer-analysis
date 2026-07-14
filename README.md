# Retail Customer Segmentation and Sales Performance Analysis

RFM-based customer segmentation of a UK online gift and homeware retailer using two years of transactional data.
---

## Business Problem

A UK-based online retailer needs to understand which customers drive the most value, which are at risk of disengaging and where cancellations are concentrated. This project answers those questions by segmenting 5,863 customers into 11 actionable groups using the RFM (Recency, Frequency, Monetary) framework and presenting findings in a three page Power BI dashboard.

---

## Dataset

- **Name:** Online Retail II
- **Source:** UCI Machine Learning Repository - [direct link](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
- **Citation:** Chen, D., Sain, S. L., & Guo, K. (2012). Journal of Database Marketing and Customer Strategy Management, Vol. 19, No. 3
- **Scope:** 1,067,371 transactions across 41 countries, December 2009 to December 2011
- **Note:** Customer base is a mix of  retail consumers and wholesale buyers

---

## Tools

| Tool | Purpose |
|---|---|
| MariaDB (via XAMPP) | Data storage, cleaning, EDA queries, RFM calculation |
| MySQL Workbench | SQL scripting and query execution |
| Power BI Desktop | Interactive three page dashboard |

---

## Methodology

- **Data cleaning:** Preserved raw data untouched. All cleaning done on a working copy. Cancellations isolated into a separate table rather than deleted enabling independent cancellation analysis. Removed missing CustomerIDs, negative quantities, zero prices and duplicates, retaining 73% of original rows (778,726 of 1,067,371).
- **EDA:** Six analytical areas covering revenue trends, country distribution, product performance, customer behaviour, average order value and cancellation patterns.
- **Wholesale investigation:** Two separation methods tested (order frequency threshold and average line quantity). Both found unreliable without a business-defined customer type flag. RFM applied to full customer base. Wholesale customers naturally cluster in top segments due to high frequency and monetary scores.
- **RFM scoring:** 1-5 scale per Hughes (1994) and Chen et al. (2012). Scores calculated using NTILE(5) window functions to ensure data-driven, distribution-based thresholds rather than arbitrary cutoffs.
- **Segmentation:** 125 possible score combinations collapsed into 11 named business segments using rule-based CASE logic, iterated until zero unclassified customers remained.

---

## Key Findings

1. **33% of customers generate 83% of revenue** : Champions and Loyal Customers (1,932 of 5,863 customers) account for £14.4M of £17.2M total revenue.
2. **Loyal Customers are disengaging** : 1,468 customers with high historical spend have an average recency of 97 days. Targeted re-engagement represents the highest potential revenue recovery opportunity.
3. **Q4 revenue peaks from volume, not basket size** : November is the highest revenue month but has below-average order value. Growth lever outside Q4 is AOV improvement, not customer acquisition.
4. **UK cancellation rate (7.07%) is more than double the international rate (3.13%)** : Suggesting a returns culture or fulfilment issue specific to UK operations.
5. **Spain has the highest international cancellation rate at 12.7%** : Driven by large bulk order reversals rather than routine returns, unlike Germany which has many small cancellations.

---

## Project Structure

```
retail-customer-analysis/
├── data/
│   ├── final_rfm_export.csv
│   ├── monthly_revenue.csv
│   ├── cancellations_by_country.csv
│   └── products_summary.csv
├── sql_scripts/
│   ├── 01_setup.sql
│   ├── 02_data_import.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_cancellations_assesment.sql
│   ├── 05_eda.sql
│   ├── 06_rfm_analysis.sql
│   └── 07_exports.sql
├── powerbi/
   └── retail_customer_analysis.pbix

```

---

## How to View

1. Download `retail_customer_analysis.pbix` from the `powerbi/` folder
2. Open with Power BI Desktop
3. The dashboard has three pages navigable via tabs at the bottom

To reproduce the full analysis, run the SQL scripts in numbered order against a MariaDB instance after importing the raw CSV files per the instructions in `02_import.sql`.

---

## Limitations

- **Anonymous transactions excluded:** 236,121 rows (22.8% of original) had no CustomerID and could not be included in RFM analysis. Findings apply to 5,863 identifiable customers only.
- **Mixed customer base:** Dataset includes both retail consumers and wholesale buyers. No explicit customer type flag exists in the data. Wholesale buyers are expected to appear in the Champions segment.
- **Returns not fully reconciled:** 3,457 non-cancellation negative quantity rows removed without matching against a returns table, which was not available.
- **Incomplete December 2011:** Dataset ends December 9, 2011. December figures are not comparable to prior months and should not be interpreted as a seasonal drop.