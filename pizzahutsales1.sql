create database pizzahut
use pizzahut;
select *from pizzas;
 select * from pizza_types;
 select * from order_details;
  select * from orders;
 create table orders(
 order_id int not null ,
 order_date date not null,
 order_time time not null,
 primary key(order_id));
 
 create table order_details(
 order_details_id int not null,
 order_id int not null,
 pizza_id text not null,
 quantity int not null,
 primary key (order_details_id));
 
 -- 1  Retrieve the total number of orders placed.
 
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
 
 -- 2  Calculate the total revenue generated from pizza sales.
 
 SELECT 
    SUM(pizzas.price * order_details.quantity) AS total_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
 
-- 3  Identify the highest-priced pizza.

SELECT 
    MAX(price)
FROM
    pizzas;

SELECT 
    pizza_id
FROM
    pizzas
WHERE
    price = 35.95;

-- another query
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.quantity)
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.quantity) DESC
LIMIT 1;

-- 5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizzas.pizza_type_id, COUNT(order_details.quantity)
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_type_id
ORDER BY COUNT(order_details.quantity) DESC
LIMIT 5;

-- another

SELECT 
    pizza_types.name, COUNT(order_details.quantity)
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY COUNT(order_details.quantity) DESC
LIMIT 5;

-- 6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.name, COUNT(order_details.quantity)
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name;

-- 7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- 8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    INNER JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- 10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category, (SUM(revenue) / 817858) * 100 AS percentage
FROM
    (SELECT 
        pizza_types.category,
            SUM(pizzas.price * order_details.quantity) AS revenue
    FROM
        pizzas
    INNER JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category
    ORDER BY revenue) AS basic
GROUP BY category;


-- 12 Analyze the cumulative revenue generated over time


select order_date, sum(revenue) over(order by order_date) as cum_rev from
(select orders.order_date, sum(pizzas.price * order_details.quantity) as revenue
from pizzas inner join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
join orders on order_details.order_id=orders.order_id
group by orders.order_date) as sales;

-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name , revenue from
(select name , category, revenue, 
rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.name ,pizza_types.category, sum(pizzas.price * order_details.quantity) as revenue
from pizzas inner join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
join orders on order_details.order_id=orders.order_id
group by  pizza_types.name ,pizza_types.category) as a) as b
where rn<=3;