-- Business Problems

--1. What are the different payment methods, and how many transactions and items were sold with each method?
SELECT
	payment_method,
	COUNT(*),
	SUM(quantity) AS total_items_sold
FROM
	walmart
GROUP BY
	payment_method



--2.  Which category received the highest average rating in each branch?
SELECT
	branch,
	category,
	average_rating
FROM
(
SELECT
	branch,
	category,
	AVG(rating) AS average_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
FROM
	walmart
GROUP BY
	branch,
	category
ORDER BY
	branch,
	average_rating DESC
) as t1
WHERE
	ranking = 1



--3.  What is the busiest day of the week for each branch based on transaction volume?
SELECT
	*
FROM
(
SELECT
	branch,
	COUNT(*) as num_of_sales,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_of_week,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(branch) DESC) AS ranking
FROM
	walmart
GROUP BY
	branch,
	day_of_week
ORDER BY
	branch,
	num_of_sales DESC
) AS t1
WHERE
	ranking = 1



--4.  How many items were sold through each payment method?
SELECT
	payment_method,
	SUM(quantity) AS total_items_sold
FROM
	walmart
GROUP BY
	payment_method



--5.  What are the average, minimum, and maximum ratings for each category in each city?
SELECT
	city,
	category,
	AVG(rating),
	MIN(rating),
	MAX(rating)
FROM
	walmart
GROUP BY
	city,
	category
ORDER BY
	city,
	category



--6. What is the total profit for each category, ranked from highest to lowest?
SELECT 
	category,
	SUM(total * profit_margin) AS total_profit
FROM
	walmart
GROUP BY
	category
ORDER BY
	total_profit DESC




--7. What is the most frequently used payment method in each branch?
SELECT
	branch,
	payment_method,
	times_used
FROM
(
SELECT
	branch,
	payment_method,
	COUNT(payment_method) AS times_used,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) AS ranking
FROM
	walmart
GROUP BY
	branch,
	payment_method
ORDER BY
	branch,
	times_used DESC
) AS t1
WHERE ranking = 1


--8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
SELECT
	branch,
	time_of_day,
	COUNT(time_of_day) AS total_transactions
FROM
(
SELECT
	*,
		CASE
			WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'morning'
			WHEN EXTRACT (HOUR FROM(time::time)) > 18 THEN 'evening'
			ELSE 'afternoon'
		END AS time_of_day
FROM
	walmart
) AS t1
GROUP BY
	branch,
	time_of_day
ORDER BY
	branch,
	total_transactions DESC



--9.  Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2022
AS
(
SELECT
	branch,
	SUM(total) AS revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY branch
),

revenue_2023
AS
(
SELECT
	branch,
	SUM(total) AS revenue
FROM
	walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY branch
)

SELECT 
	ly.branch,
	ROUND((ly.revenue - cy.revenue)::numeric/ly.revenue::numeric * 100, 2) AS difference
FROM revenue_2022 AS ly
JOIN revenue_2023 AS cy
ON ly.branch = cy.branch
GROUP BY
	ly.branch,
	difference
ORDER BY
	difference DESC
LIMIT 5;
	
   