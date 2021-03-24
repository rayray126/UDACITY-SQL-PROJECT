QUESTION 1

WITH sub AS (
		SELECT f.title as film_title,
			   c.name AS category_name,
			   r.rental_id
		FROM film f
		JOIN film_category as fc
		ON   f.film_id = fc.film_id
		JOIN category c
		ON   c.category_id = fc.category_id
		JOIN inventory i
		ON   f.film_id = i.film_id
		JOIN rental r
		ON 	 i.inventory_id = r.inventory_id
)

   SELECT film_title,
	        category_name,
	        COUNT(rental_id) AS rental_count
    FROM sub
   WHERE category_name
      IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY film_title, category_name
ORDER BY category_name, film_title;



QUESTION 2

SELECT s.store_id,
	        EXTRACT(ISOYEAR FROM r.rental_date) AS rental_year,
	        EXTRACT(MONTH FROM r.rental_date) AS rental_month,
	        COUNT(r.rental_id) AS count_rentals
     FROM rental r
     JOIN staff
    USING (staff_id)
     JOIN store s
    USING (store_id)
 GROUP BY store_id, rental_year, rental_month
 ORDER BY store_id, rental_year, rental_month;



 QUESTION 3


 WITH top_10 AS (
   SELECT C.customer_id,
 	       SUM(p.amount) AS total_payment
     FROM customer c
 	  JOIN payment p
    USING (customer_id)
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 10
 )

 	SELECT c.first_name || ' ' || c.last_name AS customer_name,
 		     DATE_TRUNC('month', p.payment_date) AS payment_month,
 		     COUNT(p.payment_id) AS num_payments,
 		     SUM(p.amount) AS total_payment
 	  FROM customer c
     JOIN payment p
 	 USING (customer_id)
 	  JOIN top_10
 	 USING (customer_id)
   GROUP BY 1, 2
   ORDER BY 1, 2


QUESTION 4

WITH t1 AS (
		SELECT f.title as film_title,
	         c.name AS category_name,
			     NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
		 FROM film f
		 JOIN film_category as fc
		USING (film_id)
		 JOIN category c
		USING (category_id)
)
  SELECT DISTINCT *
   FROM (
   SELECT category_name,
	        standard_quartile,
	        COUNT(film_title)
	        OVER(PARTITION BY standard_quartile ORDER BY category_name)
    FROM t1
   WHERE category_name
      IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 1) sub
