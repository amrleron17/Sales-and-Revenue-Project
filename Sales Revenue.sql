CREATE DATABASE sales_revenue;
USE sales_revenue;

CREATE TABLE sales_data (
    SaleID INT AUTO_INCREMENT PRIMARY KEY,
    ProductCategory VARCHAR(50),
    Region VARCHAR(50),
    CustomerSegment VARCHAR(50),
    IsPromotionApplied VARCHAR(10),
    ProductionCost DECIMAL(10,2),
    MarketingSpend DECIMAL(10,2),
    SeasonalDemandIndex DECIMAL(10,2),
    CompetitorPrice DECIMAL(10,2),
    CustomerRating DECIMAL(3,2),
    EconomicIndex DECIMAL(10,2),
    StoreCount INT,
    SalesRevenue DECIMAL(12,2)
);

SELECT *
FROM sales_data;

-- FOR BACKUP
	
    CREATE TABLE sales_data_raw
    LIKE sales_data;
    
    INSERT sales_data_raw
    SELECT *
    FROM sales_data;
    
    SELECT *
    FROM sales_data_raw;

-- 


-- 1. Checking & Removing Duplicates

SELECT *,
row_number() OVER(
partition by SaleID, ProductCategory, Region, CustomerSegment, IsPromotionApplied, ProductionCost,
MarketingSpend, SeasonalDemandIndex, CompetitorPrice, CustomerRating, EconomicIndex, StoreCount, SalesRevenue
) AS row_num
FROM sales_data;


WITH duplicate_cte AS
(
	SELECT *,
	row_number() OVER(
	partition by SaleID, ProductCategory, Region, CustomerSegment, IsPromotionApplied, ProductionCost,
	MarketingSpend, SeasonalDemandIndex, CompetitorPrice, CustomerRating, EconomicIndex, StoreCount, SalesRevenue
	) AS row_num
	FROM sales_data
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;                                                     
                                                    -- no duplicates
                                                    
                                                    

-- 2. STARDARDIZING THE DATA
SELECT *
FROM sales_data;

-- 3. SEE & REMOVE NULLS / MISSING
SELECT COUNT(*) - COUNT(ProductionCost) AS MissingProductionCost,
       COUNT(*) - COUNT(MarketingSpend) AS MissingMarketingSpend,
       COUNT(*) - COUNT(SalesRevenue) AS MissingSalesRevenue
FROM sales_data;

-- CHECK IF THERE IS NEGATIVE / ZERO VALUES
SELECT * 
FROM sales_data
WHERE ProductionCost < 0 OR SalesRevenue < 0;


SELECT *
FROM sales_data
WHERE SalesRevenue > (SELECT AVG(SalesRevenue) + 3*STDDEV(SalesRevenue) FROM sales_data);

-- Detected an outlier at SaleID 991. 
-- The SalesRevenue exceeded 3 standard deviations above the mean, 
-- indicating an unusually high sales transaction. 
-- This could represent either a genuine large sale or a potential data entry error.



-- ANALYSIS QUERIES

-- Average Sales by Region
SELECT Region, ROUND(AVG(SalesRevenue),2) AS AvgRevenue
FROM sales_data
GROUP BY Region
ORDER BY AvgRevenue DESC;

-- Impact of Promotion on Sales
SELECT IsPromotionApplied, ROUND(AVG(SalesRevenue),2) AS AvgRevenue
FROM sales_data
GROUP BY IsPromotionApplied;

-- Top Performing Product Categories
SELECT ProductCategory, SUM(SalesRevenue) AS TotalRevenue
FROM sales_data
GROUP BY ProductCategory
ORDER BY TotalRevenue DESC;

-- Customer Segment with most Revenue
SELECT CustomerSegment, 
       ROUND(AVG(SalesRevenue), 2) AS AvgRevenue
FROM sales_data
GROUP BY CustomerSegment
ORDER BY AvgRevenue DESC;

-- Average Production Cost and Revenue per Product Category
SELECT ProductCategory,
       ROUND(AVG(ProductionCost),2) AS AvgCost,
       ROUND(AVG(SalesRevenue),2) AS AvgRevenue
FROM sales_data
GROUP BY ProductCategory
ORDER BY AvgRevenue DESC;











											


