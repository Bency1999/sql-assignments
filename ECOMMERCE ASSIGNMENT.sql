-- =====================================================================
-- E-COMMERCE CUSTOMER CHURN ANALYSIS — MODULE END ASSIGNMENT 2 (MySQL)
-- Database: ecomm | Table: customer_churn
-- =====================================================================


-- =====================================================================
-- SECTION 1: DATA CLEANING (5 marks)
-- =====================================================================

-- STEP 1a: Impute MEAN (rounded to nearest integer) for these columns
UPDATE customer_churn
SET WarehouseToHome = (SELECT ROUND(AVG(x)) FROM (SELECT WarehouseToHome AS x FROM customer_churn WHERE WarehouseToHome IS NOT NULL) t)
WHERE WarehouseToHome IS NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn
SET HourSpendOnApp = (SELECT ROUND(AVG(x)) FROM (SELECT HourSpendOnApp AS x FROM customer_churn WHERE HourSpendOnApp IS NOT NULL) t)
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = (SELECT ROUND(AVG(x)) FROM (SELECT OrderAmountHikeFromlastYear AS x FROM customer_churn WHERE OrderAmountHikeFromlastYear IS NOT NULL) t)
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = (SELECT ROUND(AVG(x)) FROM (SELECT DaySinceLastOrder AS x FROM customer_churn WHERE DaySinceLastOrder IS NOT NULL) t)
WHERE DaySinceLastOrder IS NULL;

-- STEP 1b: Impute MODE for these columns
UPDATE customer_churn
SET Tenure = (SELECT val FROM (SELECT Tenure AS val, COUNT(*) AS cnt FROM customer_churn WHERE Tenure IS NOT NULL GROUP BY Tenure ORDER BY cnt DESC LIMIT 1) t)
WHERE Tenure IS NULL;

UPDATE customer_churn
SET CouponUsed = (SELECT val FROM (SELECT CouponUsed AS val, COUNT(*) AS cnt FROM customer_churn WHERE CouponUsed IS NOT NULL GROUP BY CouponUsed ORDER BY cnt DESC LIMIT 1) t)
WHERE CouponUsed IS NULL;

UPDATE customer_churn
SET OrderCount = (SELECT val FROM (SELECT OrderCount AS val, COUNT(*) AS cnt FROM customer_churn WHERE OrderCount IS NOT NULL GROUP BY OrderCount ORDER BY cnt DESC LIMIT 1) t)
WHERE OrderCount IS NULL;

-- STEP 1c: Handle outliers — delete rows where WarehouseToHome > 100
DELETE FROM customer_churn WHERE WarehouseToHome > 100;

-- STEP 1d: Fix inconsistent category labels
UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn SET PreferedOrderCat = 'Mobile Phone' WHERE PreferedOrderCat = 'Mobile';

-- STEP 1e: Standardize payment mode values
UPDATE customer_churn SET PreferredPaymentMode = 'Cash on Delivery' WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card' WHERE PreferredPaymentMode = 'CC';


-- =====================================================================
-- SECTION 2: DATA TRANSFORMATION (3 marks)
-- =====================================================================

-- STEP 2a: Rename columns (adjust the datatype to match your actual column)
ALTER TABLE customer_churn CHANGE COLUMN PreferedOrderCat PreferredOrderCat VARCHAR(20);
ALTER TABLE customer_churn CHANGE COLUMN HourSpendOnApp HoursSpentOnApp INT;

-- STEP 2b: Create new columns
ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn SET ComplaintReceived = CASE WHEN Complain = 1 THEN 'Yes' ELSE 'No' END;

ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn SET ChurnStatus = CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Active' END;

-- STEP 2c: Drop original columns
ALTER TABLE customer_churn DROP COLUMN Churn;
ALTER TABLE customer_churn DROP COLUMN Complain;


-- =====================================================================
-- SECTION 3: DATA EXPLORATION AND ANALYSIS (17 marks)
-- =====================================================================

-- Q1: Count of churned and active customers
SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;

-- Q2: Average tenure and total cashback amount of churned customers
SELECT AVG(Tenure) AS AvgTenure, SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q3: Percentage of churned customers who complained
SELECT (SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS PctComplained
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q4: City tier with highest number of churned customers, PreferredOrderCat = Laptop & Accessory
SELECT CityTier, COUNT(*) AS ChurnedCount
FROM customer_churn
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCount DESC
LIMIT 1;

-- Q5: Most preferred payment mode among active customers
SELECT PreferredPaymentMode, COUNT(*) AS Cnt
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY Cnt DESC
LIMIT 1;

-- Q6: Total order amount hike for single customers who prefer mobile phones
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalHike
FROM customer_churn
WHERE MaritalStatus = 'Single' AND PreferredLoginDevice = 'Mobile Phone';

-- Q7: Average number of devices registered among UPI users
SELECT AVG(NumberOfDeviceRegistered) AS AvgDevices
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- Q8: City tier with the highest number of customers
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

-- Q9: Gender that used the highest number of coupons
SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;

-- Q10: Number of customers and max hours spent on app, per preferred order category
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount, MAX(HoursSpentOnApp) AS MaxHoursSpent
FROM customer_churn
GROUP BY PreferredOrderCat;

-- Q11: Total order count for credit card users with the maximum satisfaction score
SELECT SUM(OrderCount) AS TotalOrders
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- Q12: Average satisfaction score of customers who complained
SELECT AVG(SatisfactionScore) AS AvgSatisfaction
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- Q13: Preferred order category among customers who used more than 5 coupons
SELECT DISTINCT PreferredOrderCat
FROM customer_churn
WHERE CouponUsed > 5;

-- Q14: Top 3 preferred order categories by average cashback amount
SELECT PreferredOrderCat, AVG(CashbackAmount) AS AvgCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AvgCashback DESC
LIMIT 3;

-- Q15: Preferred payment modes where avg tenure = 10 months and total orders > 500
SELECT PreferredPaymentMode
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING AVG(Tenure) = 10 AND SUM(OrderCount) > 500;

-- Q16: Categorize by distance from warehouse to home; churn breakdown per category
SELECT
  CASE
    WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
    WHEN WarehouseToHome <= 10 THEN 'Close Distance'
    WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
    ELSE 'Far Distance'
  END AS DistanceCategory,
  ChurnStatus,
  COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory;

-- Q17: Married customers in City Tier-1 whose order count exceeds the overall average
SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);


-- =====================================================================
-- SECTION 4: CUSTOMER RETURNS TABLE
-- =====================================================================

-- STEP 4a: Create and populate the customer_returns table
CREATE TABLE customer_returns (
  ReturnID INT PRIMARY KEY,
  CustomerID INT,
  ReturnDate DATE,
  RefundAmount DECIMAL(10,2)
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

-- STEP 4b: Return details + customer details, for churned customers who complained
SELECT cr.*, e.*
FROM customer_returns cr
JOIN customer_churn e ON cr.CustomerID = e.CustomerID
WHERE e.ChurnStatus = 'Churned' AND e.ComplaintReceived = 'Yes';