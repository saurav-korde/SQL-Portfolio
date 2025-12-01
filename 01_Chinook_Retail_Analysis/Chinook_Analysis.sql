/*
DATE: 2025-11-30
PROJECT: Chinook Music Store Analysis
AUTHOR: Saurav Korde
GOAL: Analyze customer trends and sales performance using PostgreSQL.
*/

-- ---------------------------------------------------------
-- Q1: Brazilian Market Analysis
-- Goal: Find all customers in Brazil (Name & Email)
-- ---------------------------------------------------------
SELECT 
    first_name, 
    last_name, 
    email
FROM customer
WHERE country = 'Brazil';

-- ---------------------------------------------------------
-- Q2: The High Rollers
-- Goal: Find the top 10 highest value invoices.
-- Show: Invoice Date, Billing City, and Total.
-- Order: Highest Total first.
-- ---------------------------------------------------------
SELECT
    invoice_date, 
    billing_city, 
    total
FROM invoice
ORDER BY total DESC
LIMIT 10;

-- ---------------------------------------------------------
-- Q3: The "Rock" Catalog
-- Goal: Find all tracks that are NOT 'Rock' or 'Metal'.
-- Show: Track Name, Composer, and GenreId.
-- Note: Use relational operators (OR, IN, NOT).
-- ---------------------------------------------------------
SELECT
    name AS track_name, 
    composer, 
    genre_id
FROM track
WHERE genre_id NOT IN (1, 3);  -- Because 1 = Rock, 3 = Metal

-- ---------------------------------------------------------
-- Q4: Album Size Analysis
-- Goal: How many tracks are in each album?
-- Show: AlbumId and the Count of Tracks.
-- Order: Albums with the most tracks first.
-- ---------------------------------------------------------
SELECT
    album_id, 
    COUNT(*) AS track_count
FROM track
GROUP BY album_id
ORDER BY track_count DESC;

-- ---------------------------------------------------------
-- Q5: Sales by Country (The Big Picture)
-- Goal: Which countries bring in the most revenue?
-- Show: BillingCountry and Total Sales.
-- Constraint: Only show countries with more than $100 in total sales.
-- ---------------------------------------------------------
SELECT
    billing_country, 
    SUM(total) AS total_sales
FROM invoice
GROUP BY billing_country
HAVING SUM(total) > 100
ORDER BY total_sales DESC;

-- ---------------------------------------------------------
-- Q6: The Support Team Performance
-- Goal: We need to connect customers to their support reps.
-- Show: Customer First Name, Customer Last Name, Support Rep First Name (from Employee table).
-- Concept: INNER JOIN.
-- ---------------------------------------------------------
SELECT
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    e.first_name AS support_rep_first_name
FROM customer c
INNER JOIN employee e ON c.support_rep_id = e.employee_id;

-- ---------------------------------------------------------
-- Q7: Track Sales Details
-- Goal: The Finance team needs a detailed line-item report.
-- Show: Invoice ID, Track Name, and Unit Price.
-- Concept: JOINing InvoiceLine and Track tables.
-- ---------------------------------------------------------
SELECT
    il.invoice_id,
    t.name AS track_name,
    il.unit_price
FROM invoice_line il
INNER JOIN track t ON il.track_id = t.track_id;

-- ---------------------------------------------------------
-- Q8: Best Selling Artist
-- Goal: Who is our top-selling artist of all time?
-- Show: Artist Name and Total Track Sales.
-- Concept: JOINing 3+ tables (InvoiceLine -> Track -> Album -> Artist).
-- ---------------------------------------------------------
SELECT
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice_line il
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN album al ON t.album_id = al.album_id
INNER JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_sales DESC
LIMIT 1; -- Top-selling artist

-- ---------------------------------------------------------
-- Q9: VIP Customers (Subqueries)
-- Goal: Find customers who have spent more than the average customer.
-- Show: Customer Name and Total Spent.
-- Concept: Subquery in the WHERE or HAVING clause.
-- ---------------------------------------------------------
WITH Customer_Spending AS (
    SELECT customer_id, SUM(total) as total_spent
    FROM invoice
    GROUP BY customer_id
)
SELECT * FROM Customer_Spending
WHERE total_spent > (SELECT AVG(total_spent) FROM Customer_Spending)
ORDER BY total_spent DESC;

-- ---------------------------------------------------------
-- Q10: Categorizing Track Lengths
-- Goal: Group tracks into 'Short', 'Medium', and 'Long'.
-- Logic: Short < 2 mins, Medium 2-5 mins, Long > 5 mins.
-- Show: Track Name, Milliseconds, and Category.
-- Concept: CASE Statement.
-- ---------------------------------------------------------
SELECT
    name AS track_name,
    milliseconds,
    CASE
        WHEN milliseconds < 120000 THEN 'Short'
        WHEN milliseconds BETWEEN 120000 AND 300000 THEN 'Medium'
        ELSE 'Long'
    END AS category
FROM track;
