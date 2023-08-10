-- Give all the customer names per Shipper
use northwind;
select s.company_name as Shipper, c.company_name as Customer
	from shippers s
	join orders o
	on s.shipper_id = o.ship_via
	join customers c
	using (customer_id);


-- Connect Region table and Customer Table
use northwind;
select r.region_description, count(c.customer_id)
	from customers c
	join orders
	using (customer_id)
	join employee_territories
	using (employee_id)
	join territories
	using (territory_id)
	join region r
	using (region_id)
    group by r.region_description;


-- Give number of orders placed by each customer
use northwind;
select c.company_name, count(o.order_id) as Number_of_Orders
from customers c
	join orders o
    using (customer_id)
    group by c.company_name;


-- Number of shipments per each country and customer
use northwind;
select o.ship_country, c.company_name, count(o.order_id) as num_shipments
from customers c
	join orders o
    using (customer_id)
    group by o.ship_country, c.company_name
    order by o.ship_country asc, num_shipments desc;
    

-- list of product categories per customer
use northwind;
select s.company_name, group_concat(distinct c.category_name separator ", ") as product_categories
from suppliers s
	join products p
    using (supplier_id)
    join categories c
    using (category_id)
    group by s.company_name
    order by s.company_name;


-- Revenue earned per customer
use northwind;
select c.company_name,
sum(((1-od.discount) * od.unit_price * od.quantity)) as revenue
from customers c
	join orders o
    using (customer_id)
    join order_details od
    using (order_id)
    where c.company_name = "White Clover Markets"
    and year(o.order_date) = "1996"
    group by c.company_name
    order by revenue desc;


-- For the given customer, find the products ordered on the last order date
use northwind;
select c.company_name,
o.order_date,
count(o.order_id) as orders,
group_concat(distinct p.product_name separator ", ") as products,
concat("$", sum(((1-od.discount) * od.unit_price * od.quantity))) as total_amount
from customers c
	join orders o
    using (customer_id)
    join order_details od
    using (order_id)
    join products p
    using (product_id)
    where c.company_name = "Maison Dewey"
    group by c.company_name, o.order_id, o.order_date
    order by o.order_date desc
    limit 1;


-- Apology choice per customer for delayed orders as per conditions of required dates exceeeding shipped date
use northwind;
select c.company_name as customer,
o.order_id,
concat_ws(" ", e.first_name, e.last_name) as employee,
group_concat(p.product_name separator ", ") as products,
(o.required_date - o.shipped_date) as delay,
case
	when o.required_date - o.shipped_date < -20 then "in-person"
    when o.required_date - o.shipped_date between -20 and -10 then "ceo call"
    when o.required_date - o.shipped_date between -9 and -1 then "sales president call"
end as apology
from customers c
	join orders o
    using (customer_id)
    join order_details od
    using (order_id)
    join products p
    using (product_id)
    join employees e
    using (employee_id)
    where o.required_date - o.shipped_date < 0 
    group by customer, o.order_id, employee, delay, apology
    order by delay;