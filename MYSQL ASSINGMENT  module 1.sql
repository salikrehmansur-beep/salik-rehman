-- Question 6 : Create a database named ECommerceDB and perform the following tasks:

-- 1. Create database ECommerceDB
create database if not exists ECommerceDB;

-- Use database ecommercedb
use ecommercedb;

-- 2. Create Tables with Constraints
-- a. Categories Table
create table Categories(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- b. Product Table
create table Products(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100) NOT NULL UNIQUE,
CategoryID INT ,
FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
Price DECIMAL(10,2) NOT NULL,
StockQuantity INT
);

-- c. Customers Table
create table Customers(
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL ,
Email VARCHAR(100) UNIQUE,
JoinDate DATE
);

-- d. Orders Table
create table Orders(
OrdersID INT PRIMARY KEY,
CustomerID INT,
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
OrderDate DATE NOT NULL,
TotalAmount DECIMAL(10,2)
);

-- 3. Insert Data
-- a. Inserting data Categories
insert into Categories (CategoryID, CategoryName) values
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');

-- b. Inserting data Products
insert into Products (ProductID, ProductName, CategoryID, Price, StockQuantity) values
(101, 'Laptop Pro', 1, 1200.00, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75.00, 80),
(105, 'Novel: The Great SQL', 2, 25.00, 120),
(106, 'Wireless Earbuds', 1, 150.00, 100),
(107, 'Blender X', 3, 120.00, 60),
(108, 'T-Shirt Casual', 4, 20.00, 300);

-- c. Inserting data Customers
insert into Customers (CustomerID, CustomerName, Email, JoinDate) values
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob the Builder', 'bob@example.com', '2022-11-25'),
(3, 'Charlie Chaplin', 'charlie@example.com', '2023-03-01'),
(4, 'Diana Prince', 'diana@example.com', '2021-04-26');


-- d. Inserting data Oders
insert into Orders (OrdersID, CustomerID, OrderDate, TotalAmount) values
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145.00),
(1004, 3, '2023-01-14', 150.00),
(1005, 2, '2023-09-24', 120.00),
(1006, 1, '2023-06-19', 20.00);

/* Question 7 : Generate a report showing CustomerName, Email, 
and the TotalNumberofOrders for each customer. 
Include customers who have not placed any orders, 
in which case their TotalNumberofOrders should be 0. 
Order the results by CustomerName. */

-- Customer Report (Include 0 orders).
select c.CustomerName, c.Email, count(o.OrdersID) as TotalNumberofOrders
from Customers c 
left join Orders o on o.CustomerID  = o.CustomerID
group by c.CustomerID, c.CustomerName, c.Email
order by c.CustomerName;


/*Question 8 : Retrieve Product Information with Category: 
Write a SQL query to display the ProductName, Price, StockQuantity, and CategoryName for all products. 
Order the results by CategoryName and then ProductName alphabetically.*/ 

-- Product Info with Category.
select 
	p.ProductName, 
	p.Price, 
	p.StockQuantity, 
	cat.CategoryName
from Products p
join Categories cat on p.CategoryID = p.CategoryID
order by cat.CategoryName asc, p.ProductName asc;


/* Question 9 : Write a SQL query that uses a Common Table Expression (CTE) 
and a Window Function (specifically ROW_NUMBER() or RANK()) to display the CategoryName, 
ProductName, and Price for the top 2 most expensive products in each CategoryName. */

-- Top 2 Expensive Products per Category (Using CTE & Window Function)
WITH RankedProducts AS (
    SELECT 
        cat.CategoryName,
        p.ProductName,
        p.Price,
        DENSE_RANK() OVER (PARTITION BY cat.CategoryName ORDER BY p.Price DESC) as RankNum
    FROM Products p
    JOIN Categories cat ON p.CategoryID = cat.CategoryID
)
SELECT CategoryName, ProductName, Price
FROM RankedProducts
WHERE RankNum <= 2;

/* uestion 10 : You are hired as a data analyst by Sakila Video Rentals, a global movie rental company. 
The management team is looking to improve decision-making by analyzing existing customer, rental, and inventory data.
Using the Sakila database, answer the following business questions to support key strategic initiatives.
Tasks & Questions: */

-- Use sakila
use sakila;

/* 10.1 - Identify the top 5 customers based on the total amount they’ve spent. 
Include customer name, email, and total amount spent.*/
SELECT 
    c.first_name, 
    c.last_name, 
    c.email, 
    SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

/* 10.2 - Which 3 movie categories have the highest rental counts? 
Display the category name and number of times movies 
from that category were rented. */

SELECT c.name AS category_name, COUNT(r.rental_id) AS rental_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY rental_count DESC
LIMIT 3;

/* 10.3 - Calculate how many films are available at each store and 
how many of those have never been rented. */

SELECT 
    i.store_id,
    COUNT(i.inventory_id) as total_inventory,
    SUM(CASE WHEN r.rental_id IS NULL THEN 1 ELSE 0 END) as never_rented
FROM inventory i
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY i.store_id;


-- 10.4 - Show the total revenue per month for the year 2023 to analyze business seasonality.
SELECT 
    MONTHNAME(payment_date) as Month, 
    SUM(amount) as Revenue
FROM payment
WHERE YEAR(payment_date) = 2023
GROUP BY MONTH(payment_date), MONTHNAME(payment_date)
ORDER BY MONTH(payment_date);

-- 10.5 - Identify customers who have rented more than 10 times in the last 6 months.
SELECT c.first_name, c.last_name, COUNT(r.rental_id) as rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY c.customer_id
HAVING rental_count > 10;

