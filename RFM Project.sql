/*
Description:
-----------
This query extracts sales data from various views/tables to calculate RFM metrics (Recency, Frequency, Monetary)
for retail customers. It performs the following steps:
  - Joins multiple data sources including Sales, Sales Customer Facts, Department, Date, Retail Transaction, 
    and Sales Table views.
  - Filters for retail transactions where the Division is Retail
  - Calculates:
      * Recency: Days since the last purchase.
      * Frequency: Total number of purchases.
      * Monetary: Total amount spent.
  - Aggregates the data by phone, customer name, and store details.

*/

WITH SalesData AS (
    SELECT
          [Date]
        , [STORE]
        , [Store Name]
        , [CUSTOMERNAME]
        , [Phone]
        , [Email]
        , [Checkout Sales]
    FROM Sales_Vw AS Sales
    LEFT JOIN Department_Vw AS DV
        ON Sales.[Department_Sk] = DV.[Department_Sk]
    LEFT JOIN [Date_Vw] AS Dates
        ON Sales.[Tran_Dt_Sk] = Dates.[Date_Sk]
    LEFT JOIN [RetailTransactionTable_vw] AS a
        ON Sales.[Invoice Number] = a.RECEIPTID 
           AND Dates.[Date] = a.TRANSDATE 
    LEFT JOIN [SalesTable_vw] AS b
        ON a.SALESORDERID = b.SALESID
    WHERE Division = 'Retail'
),
RFM AS (
    SELECT 
          [Phone]
        , [CUSTOMERNAME]
        , [STORE]
        , [Store Name]
        -- Recency: Days since the last purchase
        , DATEDIFF(day, MAX([Date]), CAST(GETDATE() AS DATE)) AS Recency
        -- Frequency: Total number of purchases
        , COUNT([CUSTOMERNAME]) AS Frequency
        -- Monetary: Total amount spent
        , SUM([Checkout Sales]) AS Monetary
    FROM SalesData
    GROUP BY
          [Phone]
        , [CUSTOMERNAME]
        , [STORE]
        , [Store Name]
)
---- Aggregate the data by phone, customer name, and store details
SELECT 
      [Phone]
    , [CUSTOMERNAME]
    , [STORE]
    , [Store Name]
    , Recency
    , Frequency
    , Monetary
FROM RFM
ORDER BY 
      Recency
    , Frequency DESC
    , Monetary DESC;
