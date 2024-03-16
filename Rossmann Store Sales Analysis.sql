-- YEARLY SALES

SELECT 
    year(t.date) AS Year, 
    format(SUM(t.Sales),0) AS Total_Sales, 
    format(AVG(t.Sales),0) AS AVG_Sales
FROM train t
GROUP BY 
    year(t.date)
ORDER BY 
    format(SUM(t.Sales),0) DESC,
    format(AVG(t.Sales),0) DESC;

-- Customer to Sales Ratio

SELECT
    t.Date,
    t.Sales,
    t.Customers,

    CASE
        WHEN Customers > 0 THEN Sales / Customers
        ELSE 0
    END AS SalesPerCustomer
FROM
    train t
WHERE
    Open = 1 -- Including only the days when the store was open.
ORDER BY
    t.Date;


-- Sales Before and After Competition Opening

WITH CompetitorOpening AS (
    SELECT
        s.Store,
        -- Constructing the competitor's opening date from year and month
        -- Assuming '01' as the day for simplicity
        CAST(CONCAT(CompetitionOpenSinceYear, '-', LPAD(CompetitionOpenSinceMonth, 2, '0'), '-01') AS DATE) AS CompetitorOpeningDate
    FROM
        store s
    WHERE
        CompetitionOpenSinceYear IS NOT NULL AND CompetitionOpenSinceMonth IS NOT NULL
),

-- Calculating average sales before and after the competitor's opening for each store.

SalesPerformance AS (
    SELECT
        t.Store,
        AVG(CASE 
            WHEN t.Date < c.CompetitorOpeningDate THEN t.Sales 
            ELSE NULL 
        END) AS AvgSalesBefore,
        AVG(CASE 
            WHEN t.Date >= c.CompetitorOpeningDate THEN t.Sales 
            ELSE NULL 
        END) AS AvgSalesAfter
    FROM
        train t
    JOIN
        CompetitorOpening c ON t.Store = c.Store
    GROUP BY
        t.Store
)

-- Selecting the final results, and filtering out stores with no significant change if needed.

SELECT
    *,
    -- Calculating the difference or percentage change might also be insightful
    (AvgSalesAfter - AvgSalesBefore) / NULLIF(AvgSalesBefore, 0) AS ChangeInSales
FROM
    SalesPerformance
-- Optionally, order by ChangeInSales to see which stores were most affected
ORDER BY
    ChangeInSales DESC;

-- Seasonal Sales Breakdown

SELECT
    EXTRACT(YEAR FROM Date) AS Year,
    CASE
        WHEN EXTRACT(MONTH FROM Date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM Date) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(MONTH FROM Date) IN (9, 10, 11) THEN 'Fall'
        WHEN EXTRACT(MONTH FROM Date) IN (12, 1, 2) THEN 'Winter'
    END AS Season,
    format(sum(Sales),0) AS TotalSales
FROM
    train
WHERE
    Open = 1 -- Including only the days when the store was open.
GROUP BY
    Year,
    Season
ORDER BY
    Year,
    CASE Season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
        WHEN 'Winter' THEN 4
    END;



