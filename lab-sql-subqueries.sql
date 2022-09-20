use sakila;



-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory; #Hunchback impossible(film_id = 439)
select * from film;

## WITH JOINS

select count(film_id) as 'Nº copies', title from film f
left join inventory i
using(film_id)
where title = 'Hunchback impossible'
group by title;

## WITH SUBQUERIES 
select f.title, count(f.film_id) as 'Nº copies'
from film f
join inventory i on f.film_id = i.film_id
where title in (
	select title from film
	where title = 'Hunchback impossible');



-- 2. List all films whose length is longer than the average of all the films.

select * from film;
select avg(length) from film;

select title, length from film
where length > (
select avg(length) from film
)
order by length desc;



-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

select * from film_actor; -- film_id, actor_id
select * from actor; -- actor_id, first_name, last_name

##USING JOINS

select a.actor_id, a.first_name, a.last_name from actor a
left join film_actor fa
using(actor_id)
left join film f
using(film_id)
where f.title = 'Alone Trip'
order by actor_id asc;

## USING SUBQUERIES

SELECT  first_name, last_name, actor_id
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in
		(SELECT film_id FROM film
		WHERE title = "Alone Trip")
)
group by actor_id;



-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select * from film; -- rating
select distinct rating from film;

select title, rating from film
where rating = 'PG';

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select * from customer; -- first_name, last_name, address_id 1
select * from address; -- address_id, city_id 2 
select * from country; -- country _id, country 4
select * from city; -- city_id, country_id 3 

## WITH SUBQUERIES

select first_name, last_name, email
from customer
where address_id in (
	select address_id from address
    where city_id in (
		select city_id from city
        where country_id in (
			select country_id from country
            where country = 'Canada')
));

## WITH JOINS

select first_name, last_name, email from customer c
left join address a
using(address_id)
left join city ci
using(city_id)
left join country co
using(country_id)
where country = 'Canada';



-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select * from film; -- film_id, title
select * from film_actor; -- actor_id, film_id

			-- step 1
select actor_id, count(actor_id) as 'Nº_films' from film_actor
group by actor_id
order by Nº_films desc limit 1;

			-- step2
select actor_id, count(film_id) as number from film_actor
group by actor_id
having number = (select max(number) from (
	select actor_id, count(film_id) as number from film_actor
	group by actor_id
    )sub1
    );

		-- step3
select fa.actor_id, f.title, f.film_id from film f
left join film_actor fa
using(film_id)
where actor_id in(
	select count(actor_id) as number from film_actor
	group by actor_id
	having number = (
		select max(number) from (
			select count(actor_id) as number from film_actor
			group by actor_id
			)sub1
	)
)
group by title;



-- 7.Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer 
-- ie: the customer that has made the largest sum of payments
 
select * from payment; -- payment_id, customer_id, amount
select * from rental; -- customer_id, inventory_id
select * from inventory; -- film_id, inventory_id
select * from film; -- film_id, title

			-- STEP 1

SELECT customer_id, sum(amount) as total from payment
group by customer_id
having total = (select max(total) from (
	SELECT customer_id, sum(amount) as total from payment
	group by customer_id
    )sub1
    );

			-- STEP 2

select p.customer_id, p.amount as total, f.film_id, f.title from film f
left join inventory i
using(film_id)
left join rental r
using(inventory_id)
left join payment p
using(customer_id)
group by customer_id
;


select * from payment; -- payment_id, customer_id, amount 4 
select * from rental; -- customer_id, inventory_id 3 
select * from inventory; -- film_id, inventory_id 2 
select * from film; -- film_id, title 1

			-- STEP 3

select film_id, title from film
where film_id in (
	select film_id from (
		select film_id, inventory_id from inventory
        where inventory_id in (
			select inventory_id from (
					select inventory_id, customer_id from rental
                    where customer_id in (
						select customer_id from (
							select customer_id, count(amount)as total from payment
                            group by customer_id
							having total = (
								select max(total) from (
									select count(amount) as total from payment
                                    group by customer_id
                                    )sub1
								)
							)sub2
						)
					)sub3
				)
			)sub4
		)
        order by film_id;



-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

select * from payment; -- customer_id, amount

select customer_id, sum(amount) as total_amount_spent from payment
group by customer_id
having total_amount_spent > (
	select avg(total_amount_spent) from (
		select customer_id, sum(amount) as total_amount_spent from payment
		group by customer_id
	)sub1
);