Create  database olist;

  ----- 1)  Weekdays and weekend payments statistics 

select kp.Day_End,concat(round((kp.Total_pmt/(select sum(payment_value) from olist_order_payments_dataset))*100,2),"%") as payment_value
from 
(select ord.Day_End,sum(pmt.payment_value) as Total_pmt
from olist_order_payments_dataset as pmt join
(select distinct(order_id), case when weekday(order_purchase_timestamp) in (5,6) then "Weekend" 
else "Weekday"
end as Day_End from olist_orders_dataset) as ord 
on ord.order_id = pmt.order_id group by ord.Day_End)
as kp;



------    2) Number of Orders with review score 5 and payment type as credit card.

select pmt.payment_type,count(pmt.order_id) as Total_Orders 
from olist_order_payments_dataset as pmt join 
(select distinct ord.order_id,rw.review_score from olist_orders_dataset as ord
join olist_order_reviews_dataset rw on ord.order_id = rw.order_id where review_score=5) as RW_5
on pmt.order_id = RW_5.order_id group by pmt.payment_type order by Total_Orders desc;


-----    3)Average number of days taken for order_delivered_customer_date for pet_shop.

select product.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0) as AVG_DELIVERY_DATE
from olist_orders_dataset as ord join 
(select product_id,order_id,product_category_name from olist_products_dataset join olist_order_items_dataset using (product_id)) as product
on ord.order_id = product.order_id where product.product_category_name = "pet_shop" 
group by product.product_category_name;



------ 4)Average price and payment values from customers of sao paulo city.

 ----- (Avg price value)
  select cust.customer_city, 
round(avg(pmt_price.price),0) as AVG_PRICE from olist_customers_dataset as cust
join (select pymnt.customer_id,pymnt.payment_value,item.price from olist_order_items_dataset as item 
join(select ord.order_id,ord.customer_id,pmt.payment_value from olist_orders_dataset as ord 
join olist_order_payments_dataset as pmt on ord.order_id = pmt.order_id) as pymnt
on item.order_id = pymnt.order_id) as pmt_price on cust.customer_id = pmt_price.customer_id where cust.customer_city = "sao paulo";


---- 4)   (avg payment value)
select cust.customer_city, 
round(avg(pmt.payment_value),0) as AVG_PAYMENT_VALUE 
 from olist_customers_dataset as cust
 inner join olist_orders_dataset ord 
 on cust.customer_id = ord.customer_id inner join olist_order_payments_dataset as pmt on ord.order_id = pmt.order_id 
 where customer_city= "sao paulo";


------ 5) Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select rw.review_score,
round(avg(datediff(ord.order_delivered_customer_date,order_purchase_timestamp)),0) 
as Avg_O
from olist_orders_dataset as ord join olist_order_reviews_dataset rw on
rw.order_id = ord.order_id group by rw.review_score order by rw.review_score;


