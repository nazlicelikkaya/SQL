-- SQL SESSION-1, 11.01.2023, SQL BASIC COMMANDS

-- SELECT

SELECT 1

SELECT 'Martin' 

SELECT 1, 'Martin'

SELECT 'Martin' AS first_name

SELECT 1 AS ID, 'Martin' AS FirstName

SELECT 1 AS 'ID', 'Martin' AS 'FirstName'

SELECT 1 AS 'ID', 'Martin' AS [First Name]

-- FROM

SELECT *
FROM sale.customer

SELECT first_name 
FROM sale.customer

SELECT first_name,last_name 
FROM sale.customer

SELECT email,first_name,last_name 
FROM sale.customer

-- WHERE

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE city='Atlanta';

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE NOT city='Atlanta';

SELECT first_name,last_name,street,state
FROM sale.customer
WHERE city='Atlanta';

-- AND / OR

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE state='TX' AND city='Allen';

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE state='TX' OR city='Allen';

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE last_name='Chan' AND state='TX' OR state='NY';

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE last_name='Chan' AND (state='TX' OR state='NY');

-- IN / NOT IN

SELECT first_name,last_name,street,city,state
FROM sale.customer
WHERE state='TX' AND city IN ('Allen','Austin');

-- LIKE
-- '_' any single character
-- '%' unknown character numbers

SELECT *
FROM sale.customer
WHERE email LIKE '%yahoo%';

SELECT *
FROM sale.customer
WHERE email LIKE 'yahoo%';

SELECT *
FROM sale.customer
WHERE first_name LIKE 'Di_ne';

SELECT *
FROM sale.customer
WHERE first_name LIKE '[TZ]%';

SELECT *
FROM sale.customer
WHERE first_name LIKE '[T-Z]%';

-- BETWEEN

SELECT *
FROM product.product
WHERE list_price BETWEEN 599 AND 999;

SELECT *
FROM sale.orders
WHERE order_date 
	BETWEEN '2018-01-05' 
		AND '2018-01-08'

-- <, >, <=, >=, =, != <>

SELECT *
FROM product.product
WHERE list_price < 1000;

-- IS NULL / IS NOT NULL

SELECT *
FROM sale.customer
WHERE phone IS NULL;

SELECT *
FROM sale.customer
WHERE phone IS NOT NULL;

-- TOP N

SELECT TOP 10 *
FROM sale.orders

SELECT TOP 10 customer_id
FROM sale.customer

-- ORDER BY

SELECT TOP 10 *
FROM sale.orders
ORDER BY order_id DESC;

SELECT TOP 10 *
FROM sale.orders
ORDER BY order_id ASC;

SELECT first_name, last_name, city, state
FROM sale.customer
ORDER BY first_name ASC, last_name DESC;

SELECT first_name, last_name, city, state
FROM sale.customer
ORDER BY 1,2;

SELECT first_name, last_name, city, state
FROM sale.customer
ORDER BY customer_id DESC;

-- DISTINCT

SELECT DISTINCT state
FROM sale.customer

SELECT DISTINCT state, city
FROM sale.customer
--ORDER BY state DESC;

SELECT DISTINCT *  -- duplicate rows
FROM sale.customer

-----------------------------------------------

SELECT DISTINCT [first_name], [last_name], [phone], [email], [street], [city], [state], [zip_code]
FROM sale.customer
