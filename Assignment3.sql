/*Discount Effects

Generate a report including product IDs and discount effects on 

whether the increase in the discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. */

---Solution 1

WITH T1 AS
(
SELECT product_id, discount, SUM(quantity) total_quantity
FROM	sale.order_item
GROUP BY	
		product_id, discount
)
SELECT DISTINCT T1.product_id,
CASE WHEN LAST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) > FIRST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) THEN 'Positive'
WHEN LAST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) < FIRST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) THEN 'Negative'
WHEN LAST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) = FIRST_VALUE(T1.total_quantity) OVER(PARTITION BY T1.product_id ORDER BY T1.product_id) THEN 'Neutral' END AS Discount_Effect
FROM T1
ORDER BY 1


----Solution 2
WITH T1 AS
(
SELECT product_id, discount, SUM(quantity) total_quantity
FROM	sale.order_item
GROUP BY	
		product_id, discount
), T2 AS
(
SELECT	product_id, discount, total_quantity,
		FIRST_VALUE(total_quantity) OVER (PARTITION BY product_id ORDER BY discount) AS first_dis_quantity,
		LAST_VALUE(total_quantity) OVER (PARTITION BY product_id ORDER BY discount ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_dis_quantity
FROM	T1
), T3 AS
(
SELECT	*,  1.0 * (last_dis_quantity - first_dis_quantity) / first_dis_quantity AS increase_rate
FROM T2
) 
SELECT distinct	product_id, 
		CASE WHEN	increase_rate BETWEEN -0.10 AND 0.10 THEN 'NEUTRAL'
			WHEN	increase_rate > 0.10 THEN 'POSITIVE'
			ELSE	'NEGATIVE'
		END	AS discount_affect
FROM	T3

