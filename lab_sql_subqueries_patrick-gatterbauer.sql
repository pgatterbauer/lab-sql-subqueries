# In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

USE sakila;

# Instructions
# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
	f.title, COUNT(i.inventory_id)
FROM
	film f
JOIN
	inventory i
ON
	f.film_id = i.film_id
GROUP BY
	f.title
HAVING
	f.title = 'Hunchback Impossible';
    

# 2. List all films whose length is longer than the average of all the films.

SELECT 
	ROUND(AVG(length), 2) AS avg_length
FROM 
	film;
    
SELECT
	film_id, film.length
FROM
	film
WHERE length > (SELECT 
					ROUND(AVG(length), 2) AS avg_length
				FROM 
					film)
ORDER BY film.length ASC;


# 3. Use subqueries to display all actors who appear in the film Alone Trip.
    
SELECT
	first_name,
	last_name
FROM	
	actor
WHERE
	actor_id IN (SELECT 
					actor_id 
				FROM 
					film_actor 
				WHERE film_id = (SELECT 
									film_id
								FROM 
									film 
								WHERE title = 'Alone Trip'
                                )
				)
;


# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.

# get cagtegory_id for films

SELECT
	category_id
FROM
	category
WHERE
	category.name = 'Family';

# get film_ids for all moves
SELECT
	film_id
FROM
	film_category
WHERE category_id IN (
					SELECT
						category_id
					FROM
						category
					WHERE
						category.name = 'Family'
                        )
;

#getting titles of the films

SELECT
	title, film_id
FROM
	film
WHERE film_id IN (SELECT
					film_id
				FROM
					film_category
				WHERE category_id IN (
									SELECT
										category_id
									FROM
										category
									WHERE
										category.name = 'Family'
										)
				)
;

# 5. Get name and email from customers from Canada using subqueries. 
# Do the same with joins. Note that to create a join, you will have to identify the 
# correct tables with their primary keys and foreign keys, that will help you get the relevant information.

# country -> city -> address -> customer

SELECT
	first_name,
	last_name,
    email
FROM
	customer
WHERE address_id IN (SELECT
						address_id
					FROM
						address
					WHERE city_id IN (
										SELECT 
											city_id
										FROM 
											city
										WHERE country_id IN (SELECT
																country_id
															FROM
																country
															WHERE
																country = 'Canada'
										)
									)
						)
;
                        
# same with join
# 5. Get name and email from customers from Canada using subqueries. 
# customer (customer_id, address_id), address (address_id, city_id), city (city_id, country_id), country(country_id -> counry)
SELECT
	c.first_name,
	c.last_name,
    c.email,
    co.country
FROM
	customer c
JOIN
	address a
ON
	c.address_id = a.address_id
JOIN
	city ci
ON 
	ci.city_id = a.city_id
JOIN
	country co
ON
	co.country_id = ci.country_id
WHERE
	co.country = 'Canada';



# 6. Which are films starred by the most prolific actor? 
# Most prolific actor is defined as the actor that has acted in the most number of films. 
# First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_actor
        WHERE
            actor_id = (SELECT 
                    A.actor_id
                FROM
                    actor A
                        JOIN
                    film_actor B USING (actor_id)
                GROUP BY A.actor_id
                ORDER BY COUNT(B.film_id) DESC
                LIMIT 1))
;
	

# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            inventory A
                JOIN
            rental B USING (inventory_id)
        WHERE
            B.customer_id = (SELECT 
                    customer_id
                FROM
                    payment
                GROUP BY customer_id
                ORDER BY SUM(amount) DESC
                LIMIT 1))
;

# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

SELECT 
    customer_id AS client_id, total AS total_amount_spent
FROM
    (SELECT 
        customer_id, SUM(amount) AS total
    FROM
        payment
    GROUP BY customer_id) AS avg_total
WHERE
    total > (SELECT 
            AVG(total) AS average
        FROM
            (SELECT 
                customer_id, SUM(amount) AS total
            FROM
                payment
            GROUP BY customer_id) AS avg_total)
ORDER BY total DESC
;