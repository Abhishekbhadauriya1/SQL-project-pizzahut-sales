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
 
 select count(order_id) as total_orders
 from orders;
 
 -- 2  Calculate the total revenue generated from pizza sales.
 
 select sum(pizzas.price * order_details.quantity) as total_revenue
 from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id;
 
-- 3  Identify the highest-priced pizza.

select max(price)
from pizzas;

select pizza_id from pizzas
where price=35.95;

-- another query
select pizza_types.name, pizzas.price
from pizzas inner join pizza_types on
pizzas.pizza_type_id=pizza_types.pizza_type_id
order by pizzas.price desc limit 1;

-- 4 Identify the most common pizza size ordered.

select pizzas.size,count(order_details.quantity)
from pizzas inner join order_details on
pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by count(order_details.quantity) desc limit 1;

-- 5 List the top 5 most ordered pizza types along with their quantities.

select pizzas.pizza_type_id,count(order_details.quantity)
from pizzas inner join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_type_id 
order by count(order_details.quantity) desc limit 5;

-- another

select pizza_types.name ,count(order_details.quantity)
from pizzas inner join order_details on pizzas.pizza_id=order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.name
order by count(order_details.quantity) desc limit 5;

-- 6 Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.name, count(order_details.quantity)
from pizzas inner join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name;

-- 7 Determine the distribution of orders by hour of the day.

select hour(order_time),count(order_id)
from orders
group by hour(order_time);

-- 8 Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name)
from pizza_types
group by category;

-- 9 Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity) from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders inner join order_details on order_details.order_id=orders.order_id
group by orders.order_date) as order_quantity;

-- 10 Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizzas inner join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by revenue desc limit 3;

-- 11 Calculate the percentage contribution of each pizza type to total revenue.

select category , (sum(revenue)/817858)*100 as percentage from
(select pizza_types.category, sum(pizzas.price * order_details.quantity) as revenue
from pizzas inner join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category
order by revenue) as basic
group by category ;


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