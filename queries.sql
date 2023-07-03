--считает общее количество покупателей
select
    count(distinct customer_id) as customers_count
from customers;


--Первый отчет о десятке лучших продавцов
select
    e.first_name || ' ' || e.last_name as name
    , count(*) as operations
    , sum(p.price * s.quantity) as income
    from employees e
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id
group by 1
order by 3 desc
limit 10;


--Второй отчет содержит информацию о продавцах,
-- чья средняя выручка за сделку меньше средней выручки
-- за сделку по всем продавцам
select
    e.first_name || ' ' || e.last_name as name
    , round(avg(p.price * s.quantity)) as average_income
from employees e
         join sales s on e.employee_id = s.sales_person_id
         join products p on p.product_id = s.product_id
group by 1
having avg(p.price * s.quantity) <
      (select avg(p2.price * s2.quantity)
       from sales s2
       join products p2 on s2.product_id = p2.product_id)
order by 2;


--Третий отчет содержит информацию о выручке по дням недели
select
     e.first_name || ' ' || e.last_name as name
     , extract(dow from sale_date::date) as weekday
     , sum(p.price * s.quantity) as income
from employees e
         join sales s on e.employee_id = s.sales_person_id
         join products p on p.product_id = s.product_id
group by 1,2
order by 2,1;


--Первый отчет - количество покупателей в разных возрастных группах
select
    case
        when age between 16 and 25
            then '16-25'
        when age between 26 and 40
            then '26-40'
        else '40+' end as age_category
    , count(*) as count
from customers
group by 1
order by 1;


--Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке
select
     date_trunc('month', sale_date)::date as data
     , count(distinct customer_id) as total_customers
     , sum(p.price * s.quantity) as income
from employees e
         join sales s on e.employee_id = s.sales_person_id
         join products p on p.product_id = s.product_id
group by 1
order by 1;


--Третий отчет следует составить о покупателях,
-- первая покупка которых была в ходе проведения акций
with tbl as (select
    c.customer_id
    , c.first_name || ' ' || c.last_name as customer
    , sale_date
    , e.first_name || ' ' || e.last_name as seller
    , row_number() over (partition by c.customer_id order by sale_date) as rn
from employees e
         join sales s on e.employee_id = s.sales_person_id
         join products p on p.product_id = s.product_id
         and p.price = 0
         join customers c on c.customer_id = s.customer_id)
select
    customer
    , sale_date
    , seller
from tbl
where rn = 1
order by customer_id;


