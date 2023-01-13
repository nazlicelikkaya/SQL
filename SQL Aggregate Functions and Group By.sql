-- SQL SESSION-2, 12.01.2023, AGGREGATE FUNCTIONS AND GROUP BY CLAUSE

/* Order of operations:
	1. FROM
	2. JOIN
	3. WHERE
	4. GROUP BY
	5. HAVING
	6. SELECT
	7. DISTINCT
	8. ORDER BY
	9. TOP N  */

-- COUNT

-- how many products in the product table?

SELECT *
FROM product.product

SELECT COUNT(product_id) AS num_of_product
FROM product.product

SELECT COUNT(*) AS num_of_product
FROM product.product

----------------
--bad practise
SELECT COUNT(1)
FROM product.product;

SELECT COUNT('clarusway')
FROM product.product;

SELECT 1

SELECT product_name,1
FROM product.product;
----------------------

SELECT *
FROM sale.customer

SELECT COUNT(phone)
FROM sale.customer

SELECT COUNT(*)
FROM sale.customer

-- How many records have a null value in the phone column?

SELECT COUNT(*)
FROM sale.customer
WHERE phone IS NULL;

SELECT COUNT(phone)
FROM sale.customer
WHERE phone IS NULL;

-- How many customers are located in NY state?

SELECT COUNT(customer_id) AS num_of_customers
FROM sale.customer
WHERE state = 'NY';

-- COUNT DISTINCT

--How many -different- city in the customer table?

SELECT COUNT(city)
FROM sale.customer

SELECT COUNT(DISTINCT city)
FROM sale.customer

-- MIN / MAX

--What are the minimum and maximum model years of products?

SELECT *
FROM product.product

SELECT MIN(model_year), MAX(model_year)
FROM product.product

--What are the min and max list prices for category id 5?

SELECT MIN(list_price), MAX(list_price)
FROM product.product
WHERE category_id=5

SELECT MAX(list_price)
FROM product.product
WHERE category_id=5

SELECT TOP 1 list_price
FROM product.product
WHERE category_id=5
ORDER BY list_price DESC;

-- SUM
--What is the total list price of the products that belong to category 6?

SELECT SUM(list_price)
FROM product.product
WHERE category_id=6

--How many product sold in order_id 45?

SELECT *
FROM sale.order_item

SELECT SUM(quantity)
FROM sale.order_item
WHERE order_id = 45;

--AVG

--What is the avg list price of the 2020 model products?
--float

SELECT AVG(list_price)
FROM product.product
WHERE model_year = 2020;

--Find the average order quantity for product 130.
--integer

SELECT AVG(quantity*1.0)
FROM sale.order_item
WHERE product_id=130

---------------------------------------------------------------
-- GROUP BY
---------------------------------------------------------------

SELECT *
FROM product.product

SELECT DISTINCT model_year
FROM product.product

SELECT model_year
FROM product.product
GROUP BY model_year

--count

--How many products are in each model year?

SELECT model_year, COUNT(product_id)
FROM product.product
GROUP BY model_year

--Write a query that returns the number of products priced over $1000 by brands.

SELECT brand_id, COUNT(product_id) most_expensive_prod
FROM product.product
WHERE list_price > 1000
GROUP BY brand_id
ORDER BY most_expensive_prod DESC; --ORDER BY COUNT(product_id) DESC

--COUNT DISTINCT WITH GROUP BY
SELECT brand_id, COUNT(DISTINCT category_id)
FROM product.product
GROUP BY brand_id;

SELECT brand_id, category_id
FROM product.product
GROUP BY brand_id, category_id

select order_id, product_id--, max(list_price)
from sale.order_item
group by order_id, product_id
order by order_id;

select *
from sale.order_item

-- MIN/MAX

--Find the first and last purchase dates for each customer.

SELECT customer_id, 
	MIN(order_date) first_order, 
	MAX(order_date) last_order
FROM sale.orders
GROUP BY customer_id

-- Find min and max product prices of each brand.

SELECT brand_id, 
	MIN(list_price) min_price, 
	MAX(list_price) max_price
FROM product.product
GROUP BY brand_id

--SUM / AVG

---find the total discount amount of each order

SELECT * FROM sale.order_item

SELECT order_id, 
	SUM(quantity * list_price * discount) total_amount
FROM sale.order_item
GROUP BY order_id

SELECT order_id, list_price*2,
	SUM(quantity * list_price * (1-discount)) total_amount,
	SUM(quantity * list_price * discount) total_amount
FROM sale.order_item
WHERE order_id=1 AND product_id=8
GROUP BY order_id, list_price

---What is the average list price for each model year?

SELECT model_year, AVG(list_price)
FROM product.product
GROUP BY model_year

-------------------------------------------------------------------

--INTERVIEW QUESTION: 
--Write a query that returns the most repeated name in the customer table.

SELECT TOP 1 first_name, COUNT(*) freq
FROM sale.customer
GROUP BY first_name
ORDER BY freq DESC

---- Find the state where "yandex" is used the most? (with number of users)

SELECT TOP 1 [state],COUNT(email) AS num_of_yandex_mail
FROM sale.customer
WHERE email LIKE '%yandex%'
GROUP BY [state]
ORDER BY num_of_yandex_mail DESC;