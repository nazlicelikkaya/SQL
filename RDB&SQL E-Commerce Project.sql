SELECT *
FROM dbo.e_commerce_data;

--- DATA ANALYSIS ---

-- 1. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 Cust_ID, Customer_Name, COUNT(Ord_ID) num_of_order
FROM dbo.e_commerce_data
GROUP BY Cust_ID, Customer_Name
ORDER BY COUNT(Ord_ID) DESC;



-- 2. Find the customer whose order took the maximum time to get shipping.

SELECT TOP 1 Cust_ID, Customer_Name, DaysTakenForShipping
FROM dbo.e_commerce_data
ORDER BY DaysTakenForShipping DESC;



-- 3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

--** Number of customers in January is 94
WITH t1 AS (
    SELECT DISTINCT Cust_ID, Customer_Name,
        DATEPART(MONTH, Order_Date) order_month
    FROM dbo.e_commerce_data
    WHERE YEAR(Order_Date) = 2011
)
SELECT COUNT(DISTINCT Cust_ID) num_of_customers_in_Jan
FROM t1
WHERE order_month = 1;



--** Number of customers who came back every month over the entire year in 2011
WITH t1 AS (
    SELECT DISTINCT Cust_ID, Customer_Name,
        DATEPART(MONTH, Order_Date) order_month
    FROM dbo.e_commerce_data
    WHERE YEAR(Order_Date) = 2011
)
SELECT
    COUNT(CASE WHEN order_month = 1 THEN 1 END) January,
    COUNT(CASE WHEN order_month = 2 THEN 1 END) February,
    COUNT(CASE WHEN order_month = 3 THEN 1 END) March,
    COUNT(CASE WHEN order_month = 4 THEN 1 END) April,
    COUNT(CASE WHEN order_month = 5 THEN 1 END) May,
    COUNT(CASE WHEN order_month = 6 THEN 1 END) June,
    COUNT(CASE WHEN order_month = 7 THEN 1 END) July,
    COUNT(CASE WHEN order_month = 8 THEN 1 END) August,
    COUNT(CASE WHEN order_month = 9 THEN 1 END) September,
    COUNT(CASE WHEN order_month = 10 THEN 1 END) October,
    COUNT(CASE WHEN order_month = 11 THEN 1 END) November,
    COUNT(CASE WHEN order_month = 12 THEN 1 END) December
FROM t1 a
WHERE EXISTS (
    SELECT DISTINCT Cust_ID, Customer_Name,
        DATEPART(MONTH, Order_Date) order_month
    FROM dbo.e_commerce_data b
    WHERE YEAR(Order_Date) = 2011
        AND MONTH(Order_Date) = 1
        AND a.Cust_ID = b.Cust_ID
);




-- 4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.

SELECT DISTINCT Cust_ID, Customer_Name, Ord_ID, Order_Date
FROM dbo.e_commerce_data a
WHERE EXISTS (
        SELECT Cust_ID, COUNT(Ord_ID) num_of_order
        FROM (
            SELECT DISTINCT Cust_ID, Customer_Name, Ord_ID, Order_Date
            FROM dbo.e_commerce_data
        ) t
        WHERE a.Cust_ID = t.Cust_ID
        GROUP BY Cust_ID
        HAVING COUNT(Ord_ID) >= 3);
-------------------------------------------------------------------------

WITH t1 AS (
SELECT DISTINCT Cust_ID, Customer_Name, Ord_ID, Order_Date 
FROM dbo.e_commerce_data a
WHERE EXISTS (
        SELECT Cust_ID, COUNT(Ord_ID) num_of_order
        FROM (
            SELECT DISTINCT Cust_ID, Customer_Name, Ord_ID, Order_Date
            FROM dbo.e_commerce_data
        ) t
        WHERE a.Cust_ID = t.Cust_ID
        GROUP BY Cust_ID
        HAVING COUNT(Ord_ID) >= 3)
), t2 AS (
    SELECT *,
        RANK() OVER(PARTITION BY Cust_ID ORDER BY Order_Date) order_num
    FROM t1
), t3 AS (
    SELECT *,
        LEAD(Order_Date) OVER(PARTITION BY Cust_ID ORDER BY Order_Date) third_order_date
    FROM t2
    WHERE order_num = 1 OR order_num = 3
)
SELECT Cust_ID, Customer_Name, Order_Date AS firs_order_date, third_order_date,
    DATEDIFF (DAY, Order_Date, third_order_date) Diff_day,
    DATEDIFF (MONTH, Order_Date, third_order_date) Diff_month,
    DATEDIFF (YEAR, Order_Date, third_order_date) Diff_year
FROM t3
WHERE order_num = 1;


-- 5. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer.

--** List of customers who purchased both product 11 and product 14
SELECT Cust_ID, Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'
INTERSECT
SELECT Cust_ID, Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14';

------------------------------------------------------

--** The ratio of these products to the total number of products purchased by the customer.
WITH t1 AS 
(
SELECT Cust_ID, 
	SUM(CASE WHEN Prod_ID = 'Prod_11' THEN Order_Quantity ELSE 0 END ) prod_11 ,
	SUM (CASE WHEN Prod_ID = 'Prod_14' THEN Order_Quantity ELSE 0 END ) prod_14
FROM e_commerce_data
GROUP BY Cust_ID
HAVING
	SUM(CASE WHEN Prod_ID = 'Prod_11' THEN Order_Quantity ELSE 0 END ) > 0
	AND
	SUM (CASE WHEN Prod_ID = 'Prod_14' THEN Order_Quantity ELSE 0 END ) > 0
), t2 AS (
SELECT Cust_ID, SUM (Order_Quantity) Total_prod
FROM e_commerce_data
GROUP BY Cust_ID
)
SELECT t1.Cust_ID, 
    CONVERT(VARCHAR(5), CAST(100.0*prod_11/Total_prod AS numeric(18,2))) + ' %' AS prod_11_rate, 
    CONVERT(VARCHAR(5), CAST(100.0*prod_14/Total_prod AS numeric(18,2))) + ' %' AS prod_14_rate
FROM t1, t2
WHERE t1.Cust_ID = t2.Cust_ID;



---------------------------------------------------------------------------------

--- Customer Segmentation ---
/*
    Categorize customers based on their frequency of visits. The following steps will guide you. If you want, you can track your own way.
1. Create a 'view' that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
2. Create a 'view' that keeps the number of monthly visits by users. (Show separately all months from the beginning business)
3. For each visit of customers, create the next month of the visit as a separate column.
4. Calculate the monthly time gap between two consecutive visits by each customer.
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
    For example:
    o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
    o Labeled as regular if the customer has made a purchase every month. Etc.
*/

GO

CREATE VIEW order_month AS
SELECT Cust_ID, YEAR(Order_Date) year, MONTH(Order_Date) month,
    DENSE_RANK() OVER(ORDER BY YEAR(Order_Date), MONTH(Order_Date)) month_num
FROM e_commerce_data;
GO 

CREATE VIEW next_month AS
SELECT DISTINCT *,
    LEAD(month_num) OVER(PARTITION BY Cust_ID ORDER BY month_num) next_month
FROM order_month;
GO

CREATE VIEW time_gaps AS
SELECT *, next_month - month_num AS time_gap
FROM next_month;
GO

CREATE VIEW customer_status AS
SELECT Cust_ID,
    CASE
        WHEN avg_time_gap IS NULL THEN 'New Customer'
		WHEN avg_time_gap = 1 THEN 'Loyal Customer'
		WHEN avg_time_gap > 1 AND avg_time_gap <= 6 THEN 'Regular Customer'
		WHEN avg_time_gap > 6 AND avg_time_gap <=12 THEN 'Need Based Customer'
		WHEN avg_time_gap > 12 THEN 'Irregular Customer'
    END Customer_Status
FROM (
    SELECT *, AVG(time_gap) OVER(PARTITION BY Cust_ID) avg_time_gap
    FROM time_gaps) t;
GO

SELECT *
FROM customer_status;



--- Month-Wise Retention Rate ---
/*
Find month-by-month customer retention rate since the start of the business.
There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project.
So, we will be interested in how many of the customers in the previous month could be retained in the next month.
Proceed step by step by creating 'views'. You can use the view you got at the end of the Customer Segmentation section as a source.

1. Find the number of customers retained month-wise. (You can use time gaps) 
2. Calculate the month-wise retention rate.

Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month
*/


SELECT *
FROM time_gaps
WHERE time_gap = 1;
-----------------------------------------

WITH t1 AS(
    SELECT *, COUNT(Cust_ID) OVER(PARTITION BY year, month) month_total
    FROM time_gaps
), t2 AS(
    SELECT DISTINCT year, month, month_total, COUNT(Cust_ID) OVER(PARTITION BY year, month) retained_total
    FROM t1
    WHERE time_gap = 1
)
SELECT *, CAST((1.0 * retained_total / month_total) AS DECIMAL (5, 3)) retention_rate
FROM t2;









