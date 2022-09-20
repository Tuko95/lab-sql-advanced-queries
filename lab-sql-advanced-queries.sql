use sakila;



-- 1. List each pair of actors that have worked together.

select * from film_actor; -- actor_id, film_id

with cte as(
select actor_id, film_id
from film_actor
group by film_id)

select cte.film_id, cte.actor_id as actor_1, f.actor_id as actor_2 from cte
join film_actor f
on cte.film_id = f.film_id
having actor_1 <> actor_2;



-- 2. For each film, list actor that has acted in more films.

select * from film; -- title, film_id
select * from actor; -- actor_id, first_name, last_name
select * from film_actor; -- actor_id, film_id

with cte as(
select actor_id, count(actor_id) as nº_films, film_id
from film_actor
group by actor_id)

select fa.film_id, f.title, cte.actor_id, cte.nº_films, a.first_name, a.last_name from cte
join film_actor fa
	on cte.film_id = fa.film_id
join actor a
	on cte.actor_id = a.actor_id
join film f
	on cte.film_id = f.film_id
group by film_id
having max(nº_films)
order by film_id asc;
