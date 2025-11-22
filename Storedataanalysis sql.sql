use storedata;
select count(*) from storedata;
select * from storedata;
alter table store_data drop column MyUnknownColumn;

CREATE TABLE store (
    index_id INT,
    order_id VARCHAR(50),
    cust_id INT,
    gender VARCHAR(10),
    age INT,
    order_date DATE,
    status VARCHAR(20),
    channel VARCHAR(20),
    sku VARCHAR(100),
    category VARCHAR(50),
    size VARCHAR(10),
    qty INT,
    currency VARCHAR(10),
    amount DECIMAL(10,2),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(10),
    b2b varchar(20)
);
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Storedata.csv'
INTO TABLE storedata
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(index_id, order_id, cust_id, gender, age, @order_date, status, channel, sku, category, size, @qty,
 currency, amount, ship_city, ship_state, ship_postal_code, ship_country, b2b)
SET 
  order_date = STR_TO_DATE(@order_date, '%d-%m-%Y'),
  qty = CASE 
        WHEN LOWER(@qty) = 'one' THEN 1
        WHEN LOWER(@qty) = 'two' THEN 2
        WHEN LOWER(@qty) = 'three' THEN 3
        WHEN LOWER(@qty) = 'four' THEN 4
        ELSE @qty
       END;

select gender,count(*) from store

group by gender;


-- update storedata set  gender="Men" where gender="M";
update store set gender="Women" where gender="W";
set sql_safe_updates=0;





-- Basic Analysis (1–10)

-- Total number of orders kitne hain?
select count(*) from store;
-- Total revenue calculate karo.
select sum(amount) from store;
-- Total quantity sold kitni hai?
select count(qty)from store;
-- Average order value (AOV) nikalo.
select sum(amount)/ count(distinct order_id) from store;
-- Maximum order amount kya hai?
select max(amount) from store;
-- Minimum customer age kya hai?
select min(age) from store;
-- Top 5 cities jahan se sabse zyada orders aaye.
select ship_city, count(*) as top_orders from store
group by ship_city
order by top_orders desc
limit 5;  
-- Women vs Men orders ka count.
select gender, count(*) as total_orders from store
group by gender
order by total_orders desc;
-- -- Category-wise order count.
select category , count(*) as total_orders from store
group by category;
-- -- Channel-wise (Amazon, Myntra, Ajio) revenue.
select channel, sum(amount) as total_revenue from store
group by channel 
order by total_revenue desc;
-- -- 📌 Intermediate Analysis (11–25)

-- -- Kis state ne sabse zyada revenue generate kiya?
select ship_state, sum(amount) as total_revenue
from store
group by ship_state
order by total_revenue desc;
-- -- Month-wise total orders ka trend banao.
select month(order_date) as month_by_orders, count(*) as total_orders from store
group by month_by_orders
order by total_orders desc;
-- -- Age group buckets banao: 0-20, 21-30, 31–45, 46–60, 60+. Count nikalo.
select 
case
   when age between 0 and 20 then '0-20'
   when age between 21 and 30 then '21-30'
   when age between 31 and 45 then '31-45'
   when age between 46 and 60 then '46-60'
   when age>60 then '60+'
   else 'unknown'
end as age_group,
count(*) as total_count
from store
group by age_group
order by total_count desc;
   
-- -- Which SKU generated maximum revenue?
select sku ,max(amount) as max_revenue from store
group by sku
order by max_revenue desc
;
-- -- Top 10 highest paying customers (by customer amount).
select cust_id, sum(amount) as top_pay
from store
group by cust_id
order by top_pay desc
limit 10;
-- -- Duplicate orders check karo.
select order_id ,count(*) as duplicated from store
group by order_id
having duplicated >1;
SELECT *
FROM store
WHERE order_id IN (
    SELECT order_id
    FROM store
    GROUP BY order_id
    HAVING COUNT(*) > 1
);


-- CANCELLED orders ka count.
select  count(*) as total_cenceled from store
where status='cancelled';
select status,count(*) from store
group by  status;
-- Delivered vs Pending orders ratio.
select 
 sum(case when status='Delivered' then 1 else 0 end) as deliverd_orders,
 sum(case when status='Pending' then 1 else 0 end) as pending_orders
from store;
-- Which city ordered the highest quantity?
select ship_city,count(*) as total_orders from store
group by ship_city
order by total_orders desc
limit 1;
-- Category-wise average revenue per order.
select category, sum(amount)/ count(distinct order_id) as avg_revenue_per_order
from store
group by category;
-- B2B vs B2C revenue comparison.
select 
case 
when b2b=True then 'b2b'
else 'b2c'
end as customer_type,
sum(amount) as total_revenue
from store
group by 
   case 
     when b2b= true then 'b2b'
     else 'b2c'
     end;
     
select b2b,count(*) from store
group by b2b;
-- Payment currency ka distribution.
select currency, count(*) from store
group by currency;
-- Revenue per state ka bar chart banao.

-- Regression: Age vs Amount ka relationship check karo.

-- Size-wise revenue (S, M, L, XXL).

-- 📌 Advanced SQL & Excel Analysis (26–40)

-- RFM Analysis: Recency, Frequency, Monetary segments banao.
WITH ref AS (
    SELECT MAX(order_date) AS ref_date FROM store
),
rfm AS (
    SELECT 
        cust_id,
        -- Recency
        MIN(datediff(ref.ref_date, order_date)) AS recency,
        
        -- Frequency
        COUNT(DISTINCT order_id) AS frequency,
        
        -- Monetary
        SUM(amount) AS monetary
    FROM store, ref
    GROUP BY cust_id
)
SELECT * FROM rfm
ORDER BY monetary DESC;


-- Cohort analysis: first order month → retention rate.
with first_order as (
select 
cust_id,
date_format(min(order_date), '%y-%m') as cohort_month
from store
group by cust_id
)
select * from first_order;
-- Average delivery time (agar delivery date ho).
SELECT 
    AVG(datediff('day', delivery_date - order_date)) AS avg_delivery_days
FROM store
WHERE status = 'Delivered'
  AND delivery_date IS NOT NULL;
use storedata;
-- Customer lifetime value estimate karo.
select 
cust_id,
sum(Amount) as total_revenue,
count(order_id) as total_orders
from store
group by cust_id
order by total_revenue desc;
-- Each customer ki total transaction count.
select cust_id,
count(order_id) as total_transaction from store
group by cust_id
order by total_transaction desc;
-- City-wise cancellation rate.

    SELECT
        ship_city,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
    FROM store
    GROUP BY ship_city 
    order by total_orders desc;

-- Category-wise return rate (agar return field ho).
 SELECT
        category,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
    FROM store
    GROUP BY category;
-- Daily revenue trend (line chart).

-- Which age group spends the highest on average?

-- Which channel brings the most consistent sales?
SELECT
    category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
FROM store
GROUP BY category;
WITH monthly_sales AS (
    SELECT
        channel,
        DATE_FORMAT(order_date, '%Y-%m-01') AS month,
        SUM(amount) AS monthly_revenue
    FROM store
    GROUP BY channel, DATE_FORMAT(order_date, '%Y-%m-01')
),
variance_calc AS (
    SELECT
        channel,
        AVG(monthly_revenue) AS avg_monthly_sales,
        VARIANCE(monthly_revenue) AS sales_variance
    FROM monthly_sales
    GROUP BY channel
)
SELECT
    channel,
    avg_monthly_sales,
    sales_variance,
    ROUND((1 / NULLIF(sales_variance, 0)), 4) AS consistency_score
FROM variance_calc
ORDER BY sales_variance ASC;
WITH monthly_sales AS (
    SELECT
        channel,
        DATE_FORMAT(order_date, '%Y-%m-01') AS month,
        SUM(amount) AS monthly_revenue
    FROM store
    GROUP BY channel, DATE_FORMAT(order_date, '%Y-%m-01')
),
variance_calc AS (
    SELECT
        channel,
        AVG(monthly_revenue) AS avg_monthly_sales,
        VARIANCE(monthly_revenue) AS sales_variance
    FROM monthly_sales
    GROUP BY channel
)
SELECT
    channel,
    avg_monthly_sales,
    sales_variance,
    ROUND((1 / NULLIF(sales_variance, 0)), 4) AS consistency_score
FROM variance_calc
ORDER BY sales_variance ASC;



 
 -- lowest variance = most consistent

-- Order_id prefix se platform detect karo (like 171 → Myntra).
SELECT
    order_id,
    CASE
        WHEN LEFT(order_id, 3) = '171' THEN 'Myntra'
        WHEN LEFT(order_id, 3) = '402' THEN 'Amazon'
        WHEN LEFT(order_id, 3) = '701' THEN 'Ajio'
        ELSE 'Other'
    END AS platform
FROM store;

-- Most popular product size in each state.
WITH size_stats AS (
    SELECT
        ship_state,
        size,
        SUM(qty) AS total_qty,
        ROW_NUMBER() OVER (
            PARTITION BY ship_state
            ORDER BY SUM(qty) DESC
        ) AS rn
    FROM store
    GROUP BY ship_state, size
)
SELECT
    ship_state,
    size AS most_popular_size,
    total_qty
FROM size_stats
WHERE rn = 1
ORDER BY total_qty desc;

-- High-value customers segment (Amount>1000).
SELECT
    cust_id,
    SUM(amount) AS total_spent,
    COUNT(order_id) AS total_orders
FROM store
GROUP BY cust_id
HAVING SUM(amount) > 1000
ORDER BY total_spent DESC;

-- SKU with lowest conversion (Qty < 1).
SELECT
    sku,
    COUNT(*) AS total_attempts,
    SUM(qty) AS total_qty
FROM store
GROUP BY sku
HAVING SUM(qty) < 1
ORDER BY total_attempts DESC;

-- State-wise customers count based on cust_id.
SELECT
    ship_state,
    COUNT(DISTINCT cust_id) AS customer_count
FROM store
GROUP BY ship_state
ORDER BY customer_count DESC;
