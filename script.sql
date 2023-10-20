
-- Requête 1 : Liste des titres de films
SELECT title from film;

-- Requête 2 : Nb de films par catégorie
SELECT count(film_id) as nb_total_films, film_category.category_id, name FROM film_category
INNER JOIN category
ON film_category.category_id = category.category_id 
GROUP BY category.name 

-- Requête 3 : Liste des films dont la durée est supérieure à 120min
SELECT title FROM film
WHERE length > 120;

-- Requête 4 : Liste des films sortis entre 2004 et 2006 (vérifier si il y a bien que des années 2006)
SELECT title as titres_de_films, release_year FROM film
WHERE release_year BETWEEN 2004 AND 2006; 

-- Requête 5 : Liste des films de catégorie "Action" ou "Comédie"
SELECT title as titres_de_films, name as categorie FROM film
JOIN film_category
ON film_category.film_id = film.film_id
JOIN category
ON film_category.category_id = category.category_id
WHERE name = "Action" OR name = "Comedy";

-- Requête 6 : Liste des différentes années de sortie des films
SELECT release_year from film
GROUP BY release_year;

-- Requête 7 : Nb total de films (avec alias "nombre de films" pour la valeur calculée)
SELECT count(title) as nombre_de_films FROM film;

-- Requête 8 : Nb de films par année
SELECT count(title) as nombre_de_films, release_year FROM film 
GROUP BY release_year;

-- Requête 9 : Les notes moyennes par catégorie
SELECT round(avg(rental_rate), 2) as moyenne_des_notes, film_category.category_id, category.name FROM film
FULL JOIN film_category
ON film_category.film_id = film.film_id 
FULL JOIN category
ON category.category_id = film_category.category_id 
GROUP BY film_category.category_id












-- Requête 1 : Liste des 10 films les plus loués >> utilier le nb de rental_date comme nb de location
SELECT title, film.film_id, count() as nb_de_locations FROM film
JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
GROUP BY film.film_id
ORDER BY count() DESC LIMIT 10;




-- Requête 2 : Acteurs ayant joué dans le plus grand nombre de films, liste décroissante avec le nom/prénom et le nombre de films
SELECT film_actor.actor_id, first_name, last_name , COUNT(film_actor.actor_id) as nb_total_films FROM film_actor
LEFT JOIN actor
ON film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id
ORDER BY nb_total_films DESC;


-- Requête 3 : Revenu total généré par mois
SELECT sum(amount) as revenu_total, strftime('%Y-%m', payment_date) as months FROM store
FULL JOIN payment 
ON staff_id = store_id
GROUP BY months

-- Requête 4 : Revenu total généré par chaque magasin par mois pour 2005
SELECT store_id, sum(amount) as revenu_total_ventes, strftime('%Y-%m', payment_date) as months FROM store
FULL JOIN payment
ON staff_id = store_id
WHERE payment_date LIKE "2005-%"
GROUP BY store_id, strftime('%Y-%m', payment_date);

-- Requête 5 : Les clients les plus fidèles, basés sur le nombre de locations.
SELECT first_name, last_name, customer.customer_id, COUNT(rental_id) as nb_total_locations FROM rental
FULL JOIN customer
ON customer.customer_id = rental.customer_id 
GROUP BY customer.customer_id
ORDER BY nb_total_locations DESC
LIMIT 10


-- Requête 6 : Films qui n'ont pas été loués au cours des 6 derniers mois.
-- SELECT rental_date, date(MAX(rental_date), '-6 months') as date_plus_6, inventory.inventory_id, film.film_id, film.title FROM rental
SELECT rental_date, inventory.inventory_id, film.film_id, film.title FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON film.film_id = inventory.film_id
WHERE rental_date NOT BETWEEN '2006-02-14' AND '2005-08-14'
-- WHERE rental_date NOT BETWEEN MAX(rental_date) AND date(MAX(rental_date), '-6 months') 
GROUP BY film.film_id
-- février 2006 + 6 mois (date max) 


-- Requête 7 : Le revenu total de chaque membre du personnel à partir des locations.
SELECT staff_id, SUM(amount) FROM payment
GROUP BY staff_id;

-- Requête 8 : Catégorie de films les plus populaires parmi les clients
SELECT rental_id, COUNT(i.inventory_id) as total_inventaire, fc.category_id, c.name FROM rental
JOIN inventory i
ON i.inventory_id = rental.inventory_id 
JOIN film_category fc 
ON fc.film_id = i.film_id
JOIN category c 
ON c.category_id = fc.category_id 
GROUP BY fc.category_id
ORDER BY total_inventaire DESC

-- Requête 9 : Durée moyenne entre la location d'un film et son retour. 
WITH duree_moyenne_entre_location_retour AS (
	SELECT rental_id, rental_date, return_date, round((JULIANDAY(return_date) - JULIANDAY(rental_date)),2) as difference_en_jours
	FROM rental
	)
SELECT round(AVG(difference_en_jours), 2) as moyenne
FROM duree_moyenne_entre_location_retour;


-- Requête 10 : Acteurs qui ont joué ensemble dans le plus grand nombre de films. Afficher l'acteur 1, l'acteur 2 et le nombre de films en commun.
-- Trier les résultats par ordre décroissant. Attention aux répétitons.



SELECT count(fa1.film_id) as total_films_communs,
fa1.actor_id as actor1,
actor1.first_name as actor1_firstname,
actor1.last_name as actor1_lastname,
fa2.actor_id as actor2,
actor2.first_name as actor2_firstname,
actor2.last_name as actor2_lastname
FROM film_actor fa1 
JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
JOIN actor actor1 ON fa1.actor_id = actor1.actor_id
JOIN actor actor2 ON fa2.actor_id = actor2.actor_id 
GROUP BY actor1.actor_id, actor2.actor_id
ORDER BY total_films_communs DESC




-- Requête Bonus : Clients qui ont loué des films mais n'ont pas d'autres locations dans les 30 jours qui suivent.


WITH deux_dates AS (
	SELECT r1.rental_id, r1.rental_date, r1.customer_id,
	r1.rental_date as rental_date1,
	r2.rental_date as rental_date2
	FROM rental r1
	JOIN rental r2 ON r1.customer_id  = r2.customer_id AND date(r1.rental_date) < date(r2.rental_date)
)
SELECT * FROM deux_dates
--WHERE date(rental_date2) - date(rental_date1) > 30
--ORDER BY customer_id
GROUP BY customer_id
HAVING date(rental_date2) - date(rental_date1) > 30


-- MEILLEURE METHODE : 


WITH deux_dates AS (
	SELECT r1.rental_id, r1.rental_date, r1.customer_id, 
	r1.rental_date as rental_date1,
	r2.rental_date as rental_date2 
	FROM rental r1
	JOIN rental r2 ON r1.customer_id  = r2.customer_id AND date(r1.rental_date) < date(r2.rental_date)
),
difference_deux_dates AS (
	SELECT *, round(JULIANDAY(rental_date2) - JULIANDAY(rental_date1), 2) as difference FROM deux_dates
	--WHERE rental_date1 LIKE "2005-08%" AND rental_date2 LIKE "2005-08%"
	-- GROUP BY customer_id
	)
SELECT customer_id, MIN(difference) FROM difference_deux_dates
GROUP BY customer_id
HAVING difference > 30



-- Requête BONUS suite : 15 jours / aout

WITH deux_dates AS (
	SELECT r1.rental_id, r1.rental_date, r1.customer_id, 
	r1.rental_date as rental_date1,
	r2.rental_date as rental_date2 
	FROM rental r1
	JOIN rental r2 ON r1.customer_id  = r2.customer_id AND date(r1.rental_date) < date(r2.rental_date)
),
difference_deux_dates AS (
	SELECT *, round(JULIANDAY(rental_date2) - JULIANDAY(rental_date1), 2) as difference FROM deux_dates
	WHERE rental_date1 LIKE "2005-08%" AND rental_date2 LIKE "2005-08%"
	-- GROUP BY customer_id
	)
SELECT customer_id, MIN(difference) FROM difference_deux_dates
GROUP BY customer_id
HAVING difference > 15



-- Requêtes Bonus : Altérer votre BDD avec les requêtes suivantes :
	-- Ajoutez un nouveau film dans la base de données. Ce film est intitulé "Sunset Odyssey", est sorti en 2023,
	-- dure 125 minutes et appartient à la catégorie "Drama".
	-- Mettez à jour le film intitulé "Sunset Odyssey" pour qu'il appartienne à la catégorie "Adventure".
	-- DELETE FROM film WHERE title = 'Sunset Odyssey';


SELECT * FROM film
ORDER BY film_id DESC

INSERT INTO film
(film_id, title, release_year, language_id, length, last_update)
VALUES (1001, "SUNSET ODYSSEY", 2023, 1, 125, date("now"))

SELECT * FROM film_category fc 
ORDER BY film_id DESC

INSERT INTO film_category
(film_id, category_id, last_update)
VALUES (1001, 7, date("now"))

INSERT INTO category 
(category_id, name, last_update)
VALUES (17, "Adventure", date("now"))

SELECT * FROM category c 

UPDATE film_category
SET category_id = 17
WHERE film_id = 1001

DELETE FROM film 
WHERE title = "SUNSET ODYSSEY"


