CREATE DATABASE Ecommerce_Return_Analysis;

use Ecommerce_Return_Analysis;

CREATE TABLE Customers
(
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_age INT,
    customer_gender VARCHAR(20),
    region VARCHAR(50)
);

CREATE TABLE Products
(
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100)
);

CREATE TABLE Orders
(
    order_id VARCHAR(20) PRIMARY KEY,

    customer_id VARCHAR(20) NOT NULL,

    product_id VARCHAR(20) NOT NULL,

    price DECIMAL(10,2),

    quantity INT,

    discount DECIMAL(5,2),

    payment_method VARCHAR(50),

    order_date DATE,

    delivered_date DATE,

    total_amount DECIMAL(10,2),

    shipping_cost DECIMAL(10,2),

    profit_margin DECIMAL(10,2),

    CONSTRAINT FK_Customer
        FOREIGN KEY(customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT FK_Product
        FOREIGN KEY(product_id)
        REFERENCES Products(product_id)
);

CREATE TABLE Returns
(
    order_id VARCHAR(20) PRIMARY KEY,

    returned VARCHAR(10),

    request_date DATE,

    return_reason VARCHAR(255),

    CONSTRAINT FK_Return
        FOREIGN KEY(order_id)
        REFERENCES Orders(order_id)
);

INSERT INTO Customers
SELECT
customer_id,
MAX(CAST(customer_age AS UNSIGNED)),
MAX(customer_gender),
MAX(region)
FROM Ecommerce_Staging
GROUP BY customer_id;

INSERT INTO Products
SELECT
    product_id,
    MAX(category)
FROM Ecommerce_Staging
GROUP BY product_id;

INSERT INTO Orders
(
    order_id,
    customer_id,
    product_id,
    price,
    quantity,
    discount,
    payment_method,
    order_date,
    delivered_date,
    total_amount,
    shipping_cost,
    profit_margin
)
SELECT
    TRIM(order_id),
    TRIM(customer_id),
    TRIM(product_id),
    CAST(NULLIF(TRIM(price), '') AS DECIMAL(10,2)),
    CAST(NULLIF(TRIM(quantity), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(discount), '') AS DECIMAL(5,2)),
    NULLIF(TRIM(payment_method), ''),
    STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%Y-%m-%d'),
    STR_TO_DATE(NULLIF(TRIM(delivered_date), ''), '%Y-%m-%d'),
    CAST(NULLIF(TRIM(total_amount), '') AS DECIMAL(10,2)),
    CAST(NULLIF(TRIM(shipping_cost), '') AS DECIMAL(10,2)),
    CAST(NULLIF(TRIM(profit_margin), '') AS DECIMAL(10,2))
FROM Ecommerce_Staging
WHERE order_id IS NOT NULL
  AND TRIM(order_id) <> '';
  
  INSERT INTO Returns
(
    order_id,
    returned,
    request_date,
    return_reason
)
SELECT
    TRIM(order_id),
    NULLIF(TRIM(returned), ''),
    STR_TO_DATE(NULLIF(TRIM(request_date), ''), '%Y-%m-%d'),
    NULLIF(TRIM(return_reason), '')
FROM Ecommerce_Staging
WHERE order_id IS NOT NULL
  AND TRIM(order_id) <> '';
  
  SELECT
    (SELECT COUNT(*) FROM Ecommerce_Staging) AS staging_rows,
    (SELECT COUNT(*) FROM Customers) AS customers,
    (SELECT COUNT(*) FROM Products) AS products,
    (SELECT COUNT(*) FROM Orders) AS orders,
    (SELECT COUNT(*) FROM Returns) AS return_records,
    (
        SELECT COUNT(*)
        FROM Returns
        WHERE returned = 'Yes'
    ) AS actual_returns;
    
    --- Checking Relationship ----
    SELECT COUNT(*) AS missing_customers
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS missing_products
FROM Orders o
LEFT JOIN Products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-----------------------
-- 1.Total Orders
select count(*) from orders;

-- 2.Total Customers
Select Count(*) as Total_customers from customers;

-- 3.Total products
Select  Count(*) as Total_products from products;

-- 4.Total_revenue
Select Round(sum(Total_amount),2) as Total_revenue from orders;

-- 5.Total Profit
Select Round(sum(Profit_margin),2) as Total_Profit from orders;

-- 6.Average Order Value 
Select Round(avg(Total_amount),2) as Avg_order_value from Orders;

-- 7.Total Return ORders
Select Count(*) as Total_return_orders from Returns
where returned = 'yes';

-- 8.Return Rate
Select Count(CASE WHEN returned = 'Yes' THEN 1 END) AS returned_orders,
COUNT(*) AS total_orders,
ROUND(COUNT(CASE WHEN returned = 'Yes' THEN 1 END) * 100.0 / COUNT(*),2) AS return_rate_percentage
FROM Returns;

-- 9.Non-Returned Orders
Select Count(*) as Total_return_orders from Returns
where returned = 'no';

-- 10.Total Quantity Sold
Select sum(Quantity) as Total_Quantity_Sold from Orders;

-- 11.Average discount
Select round(avg(discount),2) as Avg_discount from orders;

-- 12.Total Shipping cost
Select Round(sum(shipping_cost),2) as Total_shipping_cost from orders;

-- 13.Average Shipping cost Per order
Select Round(avg(shipping_cost),2) as Average_Shipping_cost from orders; 

-- 14.Profit Margin Percentage 
Select Round(sum(profit_margin) * 100.0 / sum(total_amount) ,2) As profit_margin_percentage From orders;

-- 15.Revenue Per Customer
Select Round(sum(total_amount)/count(distinct customer_id),2) as revenue_per_customer from orders;

-- 16.Orders Per Customers 
Select round(count(*)/count(distinct customer_id),2) as Orders_per_customers from orders;

-- 17.Return Summary
SELECT returned,
COUNT(*) AS order_count,
ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (),2) AS percentage
FROM Returns
GROUP BY returned;

-- 18.Revenue By Return Status
Select r.returned,
COUNT(*) AS Total_orders,
Round(sum(o.Total_amount),2) as revenue
from orders o
join returns r
on o.order_id = r.order_id
group by r.returned;

-- 19.Estimated Revenue From Returned Orders -
Select 
Round(sum(o.Total_amount),2) as revenue
from orders o
join returns r
on o.order_id = r.order_id
where r.returned = 'yes'
group by r.returned;

-- 20.Estimated Profit Associated With Returns
Select 
Round(sum(Profit_margin),2) as Profit_Associated_With_Returns
from orders o
join returns r
on o.order_id = r.order_id
where r.returned = 'yes'
group by r.returned;

-- 21.Combined KPI Query
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT o.product_id) AS total_products,

    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(SUM(o.profit_margin), 2) AS total_profit,
    ROUND(AVG(o.total_amount), 2) AS average_order_value,

    SUM(o.quantity) AS total_quantity_sold,

COUNT(DISTINCT CASE
WHEN r.returned = 'Yes'
THEN o.order_id
END) AS returned_orders,
ROUND(COUNT(DISTINCT CASE WHEN r.returned = 'Yes' THEN o.order_id
END) * 100.0/ COUNT(DISTINCT o.order_id),2 ) AS return_rate_percentage

FROM Orders o
LEFT JOIN Returns r
ON o.order_id = r.order_id;

----------------------
-- Product Analysis
-----------------------

-- 21. category generates the highest revenue?
Select p.product_id,P.category,Round(sum(total_amount),2) as Revenue
from orders o
join products p
on o.product_id = P.product_id
group by p.product_id,P.category
order by Revenue DESC
limit 1;

-- 22.category generates the lowest revenue?
Select p.product_id,P.category,Round(sum(total_amount),2) as Revenue
from orders o
join products p
on o.product_id = P.product_id
group by p.product_id,P.category
order by Revenue
limit 1;

-- 23.Which category has the highest return rate?
Select p.category ,
count(*) as total_orders ,
sum(case when r.returned = 'yes' then 1 else 0 END) as returned_orders,
Round(sum(case when r.returned = 'yes' then 1 else 0 END) * 100.0/count(*),2) as Return_Rate
from orders o
join products p
on o.product_id = P.product_id
join returns r
on o.order_id = r.order_id
group by p.category
order by return_rate DESC
limit 1;
--

-- 24.Which category has the lowest return rate?
Select p.category ,
count(*) as total_orders ,
sum(case when r.returned = 'yes' then 1 else 0 END) as returned_orders,
Round(sum(case when r.returned = 'yes' then 1 else 0 END) * 100.0/count(*),2) as Return_Rate
from orders o
join products p
on o.product_id = P.product_id
join returns r
on o.order_id = r.order_id
group by p.category
order by return_rate
limit 1;

-- 25.Find the top 10 revenue-generating products.
Select p.product_id,P.category,round(sum(o.Total_amount),2) as Revenue
from orders o
join products p
on o.product_id = P.product_id
group by p.product_id,P.category
order by Revenue DESC
limit 10;

-- 26.Find the bottom 10 revenue-generating products.

Select p.product_id,P.category,round(sum(o.Total_amount),2) as Revenue
from orders o
join products p
on o.product_id = P.product_id
group by p.product_id,P.category
order by Revenue 
limit 10;

-- 27.Find the top 10 most returned products.
Select o.product_id,p.category,
count(*) as returned_orders
from orders o
join products p
on o.product_id = P.product_id
join returns r
on o.order_id = r.order_id
Where r.returned = 'YES'
group by  o.product_id,p.category
order by returned_orders DESC
limit 10;

-- 28.Find products that were never returned.
Select o.product_id,p.category,
count(*) as Total_orders
from orders o
join products p
on o.product_id = P.product_id
join returns r
on o.order_id = r.order_id
group by  o.product_id,p.category
Having sum(case When r.returned = 'yes' then 1 else 0 END)
order by Total_orders DESC;

-- 29.Calculate the average selling price by category.
Select p.category, Round(Avg(total_amount),2) as avg_selling_price 
from orders o
join products p
on o.product_id = P.product_id
group by p.category
order by avg_selling_price DESC;

-- 30.Calculate the average quantity sold by category.
Select p.category, Round(Avg(o.quantity),2) as avg_Quantity
from orders o
join products p
on o.product_id = P.product_id
group by p.category
order by avg_Quantity DESC;

-- 31. category generates the highest profit
Select p.category, Round(sum(o.Profit_margin),2) as Highest_Profit
from orders o
join products p
on o.product_id = P.product_id
group by p.category
order by Highest_Profit DESC
limit 1;

-- 32.category generates the lowest profit
Select p.category, Round(sum(o.Profit_margin),2) as Lowest_profit
from orders o
join products p
on o.product_id = P.product_id
group by p.category
order by Lowest_profit 
limit 1;

-- 33.products with the highest discounts.
Select p.Product_id, p.category, Round(avg(o.Discount)*100,2) as Avg_discount_percentage
from orders o
join products p
on o.product_id = P.product_id
group by p.category,p.Product_id
order by Avg_discount_percentage DESC
limit 10;

-- 34. products with the lowest discounts.
Select p.Product_id, p.category, Round(avg(o.Discount)*100,2) as Avg_discount_percentage
from orders o
join products p
on o.product_id = P.product_id
group by p.category,p.Product_id
order by Avg_discount_percentage 
limit 10;

-- 35.category has the highest average shipping cost
Select  p.category, Round(avg(o.Shipping_cost),2) as Avg_Shipping_cost
from orders o
join products p
on o.product_id = P.product_id
group by p.category,p.Product_id
order by Avg_Shipping_cost DESC 
limit 1;

-- 36.category has the lowest average shipping cost
Select  p.category, Round(avg(o.Shipping_cost),2) as Avg_Shipping_cost
from orders o
join products p
on o.product_id = P.product_id
group by p.category,p.Product_id
order by Avg_Shipping_cost 
limit 1;

-- 37.Calculate revenue contribution (%) by category.
Select p.category, Round(sum(o.total_amount),2) as Category_revenue,
Round(sum(o.total_amount) * 100.0 / sum(sum(o.total_amount)) over (),2) As Revenue_category_percentage 
from orders o
join products p
on o.product_id = P.product_id
Group by p.category
order by Revenue_category_percentage DESC;

-- 38.Calculate profit contribution (%) by category.
Select p.category, Round(sum(o.Profit_margin),2) as Category_Profit,
Round(sum(o.Profit_margin) * 100.0 / sum(sum(o.Profit_margin)) over (),2) As Profit_category_percentage 
from orders o
join products p
on o.product_id = P.product_id
Group by p.category
order by Profit_category_percentage DESC;

-- 39.Find products having above-average revenue.
With Product_revenue as
(select product_id,sum(total_amount) as Total_revenue
from Orders
Group by product_id)
Select pr.product_id,p.category,round(pr.total_revenue,2) as Total_revenue
from product_revenue pr
join products p 
on pr.product_id = p.product_id
where pr.total_revenue > 
(select Avg(Total_revenue)
from Product_revenue)
order by pr.Total_revenue DESC;

-- Products having above-average revenue -- 
With Product_Revenue As
( Select Product_id,
		SUM(Total_Amount) As Total_Revenue 
	From Orders 
Group By product_Id) 
Select Pr.Product_id,
		P.Category,
        ROUND(Pr.Total_Revenue,2) As Total_Revenue
From Product_Revenue Pr
JOIN Products P
ON P.Product_Id = Pr.Product_Id 
WHERE Pr.Total_Revenue >
(Select AVG(Total_Revenue) From Product_Revenue)
Order By Pr.Total_Revenue Desc;

-- Products having below-average revenue --- 
With Product_Revenue As
( Select Product_id,
		SUM(Total_Amount) As Total_Revenue 
	From Orders 
Group By product_Id) 
Select Pr.Product_id,
		P.Category,
        ROUND(Pr.Total_Revenue,2) As Total_Revenue
From Product_Revenue Pr
JOIN Products P
ON P.Product_Id = Pr.Product_Id 
WHERE Pr.Total_Revenue >
(Select AVG(Total_Revenue) From Product_Revenue)
Order By Pr.Total_Revenue;

-----------------------------
-- Customer Analysis
-----------------------------
-- Top 10 customers by revenue.
Select customer_id,Round(sum(Total_amount),2) as Total_revenue
from orders 
group by customer_id
order by Total_revenue DESC
limit 10;

-- Top 10 customers by profit.
Select customer_id,Round(sum(Profit_margin),2) as Profit
from orders 
group by customer_id
order by Profit DESC
limit 10;

-- Top 10 customers by total orders.
Select customer_id,Round(count(Order_id),2) as Total_orders
from orders 
group by customer_id
order by Total_orders DESC
limit 10;

-- Top 10 customers by total quantity purchased.
Select customer_id,Round(sum(quantity),2) as Total_quantity
from orders 
group by customer_id
order by Total_quantity DESC
limit 10;

-- Customer with the highest average order value.
Select customer_id,Round(avg(Total_amount),2) as Total_revenue
from orders 
group by c.customer_id
order by Total_revenue DESC
limit 1 ;

-- Customers with the highest number of returned orders.
select o.customer_id,count(*) as returned_orders
from orders o
join returns r
on r.order_id = o.order_id
where r.returned = 'yes'
group by o.customer_id
order by returned_orders desc 
limit 10;

-- Customers who never returned an order.
select o.customer_id,count(*) as Total_orders
from orders o
join returns r
on r.order_id = o.order_id
group by o.customer_id
having sum(case when returned = 'yes' then 1 else 0 END ) = 0
order by Total_orders desc ;

-- Customers with a return rate above 20%.
select o.customer_id,count(*) as Total_orders,
sum(case when returned = 'yes' then 1 else 0 END ) as returned_orders,
round((sum(case when returned = 'yes' then 1 else 0 END )*100.0/count(*)),2) as Return_rate
from orders o
join returns r
on r.order_id = o.order_id
group by o.customer_id
having Return_rate > 20
order by returned_orders DESC;

-- Average revenue of customers who returned products.
Select round(avg(customer_Revenue),2) as customer_Revenue
from
(select o.customer_id,sum(o.total_amount) as customer_revenue
from orders o
join returns r
on r.order_id = o.order_id
where returned = 'yes'
group by o.customer_id) x;

-- Average revenue of customers who never returned products.
Select round(avg(customer_Revenue),2) as customer_Revenue
from
(select o.customer_id,sum(o.total_amount) as customer_revenue
from orders o
join returns r
on r.order_id = o.order_id
group by o.customer_id
having sum(case when returned = 'yes' then 1 else 0 END ) 
 ) x;
 
-- Classify customers as High Value ,Medium Value,Low Value based on total spending.
Select customer_id ,sum(total_amount) as revenue,
case When sum(total_amount) >= 5000 Then 'High Value'
      When sum(total_amount) >= 2500 Then 'Medium Value'
      else 'Low Value'
      End as Customer_segment
from orders 
Group by customer_id
order by revenue DESC;

-- Find VIP customers (Top 5%).
With CustomerRevenue as
(select customer_id,sum(total_amount) as revenue
from orders
group by customer_id)
select * from
(select *, ntile(20) over(order by revenue DESC)grp
From CustomerRevenue) x 
where grp = 1;

-- Find inactive customers (only one order).
Select customer_id,count(order_id) as orders
from orders
group by customer_id
having count(order_id) = 1;

-- Find repeat customers (2+ orders).
Select customer_id,count(order_id) as orders
from orders
group by customer_id
having count(order_id) > 1
order by orders DESC;

-- Find customers whose spending is above the average customer spending.
WITH CustomerRevenue AS
(SELECT customer_id, SUM(total_amount) revenue
FROM Orders
GROUP BY customer_id)
SELECT *
FROM CustomerRevenue
WHERE revenue>
(SELECT AVG(revenue)
FROM CustomerRevenue)
ORDER BY revenue DESC;

-- Revenue by gender.
SELECT c.customer_gender, ROUND(SUM(o.total_amount),2) revenue
FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_gender;

-- Profit by gender.
SELECT c.customer_gender,ROUND(SUM(o.profit_margin),2) profit
FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_gender;

-- Return rate by age group.
SELECT
CASE
WHEN customer_age<25 THEN '18-24'
WHEN customer_age<35 THEN '25-34'
WHEN customer_age<45 THEN '35-44'
WHEN customer_age<55 THEN '45-54'
ELSE '55+'
END AS Age_Group,
ROUND(SUM(total_amount),2) Revenue
FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY Age_Group
ORDER BY Revenue DESC;

-- Average order value by age group.
SELECT

CASE
WHEN c.customer_age<25 THEN '18-24'
WHEN c.customer_age<35 THEN '25-34'
WHEN c.customer_age<45 THEN '35-44'
WHEN c.customer_age<55 THEN '45-54'
ELSE '55+'
END Age_Group,

ROUND(AVG(o.total_amount),2) Average_Order_Value

FROM Customers c

JOIN Orders o
ON c.customer_id=o.customer_id

GROUP BY Age_Group
ORDER BY Average_Order_Value DESC;

-------------------------------------------------------------------------------
----------------------- Regional Analysis ------------------------------------
--------------------------------------------------------------------------------
-- Total Revenue by Region
Select C.region,
	ROUND(SUM(O.Total_amount), 2) as Revenue
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Revenue desc;

-- Total Profit by Region 
Select C.region,
	ROUND(SUM(O.profit_Margin), 2) as Profit 
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Profit desc;

-- Total Orders by Region
Select C.region,
	COUNT(o.order_id) as Total_orders
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Total_orders desc;

-- Total Quantity Sold by Region
Select C.region,
	SUM(O.Quantity) as Total_quantity
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Total_quantity desc;

-- Average Order Value by Region
Select C.region,
	ROUND(AVG(O.Total_amount), 2) as Avg_order_value
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Avg_order_value desc;

-- Average Shipping Cost by Region
Select C.region,
	ROUND(AVG(O.Shipping_cost), 2) as Avg_Shipping_cost
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Avg_Shipping_cost desc;

-- Average Discount by Region
Select C.region,
	ROUND(AVG(O.Discount)*100, 2) as Avg_Discount
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Avg_Discount desc;

-- Return Rate by Region 
Select C.region,
	Count(*) as total_orders,
    SUM(Case when r.returned= 'Yes' then 1 else 0 End ) As Returned_orders,
    ROUND
		(Sum(case when r.Returned = 'Yes' then 1 else 0 End)*100.0
			/ Count(*),2 ) As Return_Rate
From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
JOIN Returns r
ON r.Order_id = O.order_id
Group By C.region
Order by Return_Rate Desc;

-- Region with Highest Revenue
Select C.region,
	ROUND(SUM(O.Total_amount), 2) as Revenue
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Revenue desc
limit 1;

-- Region with Lowest Revenue
Select C.region,
	ROUND(SUM(O.Total_amount), 2) as Revenue
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Revenue
limit 1;

-- Region with Highest Profit
Select C.region,
	ROUND(SUM(O.profit_Margin), 2) as Profit 
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Profit desc
limit 1;

-- Region with Lowest Profit
Select C.region,
	ROUND(SUM(O.profit_Margin), 2) as Profit 
from orders o
JOIN Customers c
ON C.customer_id = O. Customer_id 
Group By C.region 
Order by Profit
limit 1;

-- Region with Highest Return Rate
Select C.region,
	Count(*) as total_orders,
    SUM(Case when r.returned= 'Yes' then 1 else 0 End ) As Returned_orders,
    ROUND
		(Sum(case when r.Returned = 'Yes' then 1 else 0 End)*100.0
			/ Count(*),2 ) As Return_Rate
From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
JOIN Returns r
ON r.Order_id = O.order_id
Group By C.region
Order by Return_Rate Desc
limit 1;

-- Region with Lowest Return Rate
Select C.region,
	Count(*) as total_orders,
    SUM(Case when r.returned= 'Yes' then 1 else 0 End ) As Returned_orders,
    ROUND
		(Sum(case when r.Returned = 'Yes' then 1 else 0 End)*100.0
			/ Count(*),2 ) As Return_Rate
From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
JOIN Returns r
ON r.Order_id = O.order_id
Group By C.region
Order by Return_Rate 
limit 1;

-- Revenue Contribution (%) by Region
Select C.region,
	Round(Sum(O.Total_amount),2) as Total_revenue,
    ROUND(
    SUM(o.total_Amount)*100.0/
		SUM(SUM(o.Total_amount)) Over(), 2
	) Revenue_Percentage
    From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
Group By C.region
Order by Revenue_Percentage Desc;

-- Profit Contribution (%) by Region 
Select C.region,
	Round(Sum(O.profit_margin),2) as Total_Profit,
    ROUND(
    SUM(o.profit_margin)*100.0/
		SUM(SUM(o.profit_margin)) Over(), 2
	) Profit_Percentage
    From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
Group By C.region
Order by Profit_Percentage Desc;

-- Rank Regions by Revenue
Select 	
	C.region,
	ROUND(Sum(O.Total_Amount),2) as Revenue,
    DENSE_RANK() OVER(order by Sum(O.Total_Amount) desc) As Ranking
From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
Group By C.region;

-- Rank Regions by Profit
Select 	
	C.region,
	ROUND(Sum(O.profit_margin),2) as Profit,
    DENSE_RANK() OVER(order by Sum(O.profit_margin) desc) As Ranking
From Customers C
JOIN Orders o 
ON o.Customer_id = c.Customer_id
Group By C.region;

-- Top Selling cayegory in each region
WITH RegionCategory AS
(
SELECT
    c.region,
    p.category,
    SUM(o.total_amount) revenue,

    ROW_NUMBER() OVER(
    PARTITION BY c.region
    ORDER BY SUM(o.total_amount) DESC
    ) rn

FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id

JOIN Products p
ON o.product_id=p.product_id

GROUP BY
    c.region,
    p.category
)

SELECT *
FROM RegionCategory
WHERE rn=1;

------------------
-- Delivery And Return Analysis
------------------
-- Average Delivery Time
Select Round(avg(datediff(delivered_date,order_date)),2) as avg_delivery_time
from orders;

-- Max Delivery time
Select max(datediff(delivered_date,order_date)) as Max_delivery_days
from orders;

-- MIn Delivery time
Select min(datediff(delivered_date,order_date)) as min_delivery_days
from orders;

-- Avg Delivery time by region
Select c.region,Round(avg(datediff(delivered_date,order_date)),2) as avg_delivery_time
from orders o
join customers c
on c.customer_id = o.customer_id
group by c.region
order by avg_delivery_time DESC;

-- Avg Delivery time by Category
Select p.category,Round(avg(datediff(delivered_date,order_date)),2) as avg_delivery_time
from orders o
join products p
on p.product_id = o.product_id
group by p.category
order by avg_delivery_time DESC;

-- Category with Longest Avg Delivery Time
Select p.category,Round(avg(datediff(delivered_date,order_date)),2) as avg_delivery_time
from orders o
join products p
on p.product_id = o.product_id
group by p.category
order by avg_delivery_time DESC
Limit 1;

-- Region with Longest Avg Delivery Time
Select c.region,Round(avg(datediff(delivered_date,order_date)),2) as avg_delivery_time
from orders o
join customers c
on c.customer_id = o.customer_id
group by c.region
order by avg_delivery_time DESC
limit 1;

-- Orders Delivered day More than 7 days
Select order_id,product_id,customer_id,order_date,delivered_date,datediff(delivered_date,order_date) as delivery_days
from orders
where datediff(delivered_date,order_date) > 7
order by delivery_days;

-- Average Return request Delay
Select Round(avg(datediff(r.request_date,o.delivered_date)),2) as Avg_return_request_delay
from orders o
join returns r
on o.order_id = r.order_id
where r.returned = 'yes';

-- Most Common return reason
Select
    return_reason,
    COUNT(*) AS total_returns
from Returns
where returned='Yes'
GROUP BY return_reason
ORDER BY total_returns DESC

-- Return Reasons by Category
SELECT
    p.category,
    r.return_reason,
    COUNT(*) AS total_returns
FROM Orders o
JOIN Products p
ON o.product_id=p.product_id
JOIN Returns r
ON o.order_id=r.order_id
WHERE r.returned='Yes'
GROUP BY
    p.category,
    r.return_reason
ORDER BY
    p.category,
    total_returns DESC;
    
    
--  Return Reasons by Region
SELECT
    c.region,
    r.return_reason,
    COUNT(*) AS total_returns
FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
JOIN Returns r
ON o.order_id=r.order_id
WHERE r.returned='Yes'
GROUP BY
    c.region,
    r.return_reason
ORDER BY
    c.region,
    total_returns DESC;

-- Payment Method with Highest Return Rate
SELECT
    o.payment_method,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN r.returned='Yes' THEN 1 ELSE 0 END) returned_orders,
ROUND(SUM(CASE WHEN r.returned='Yes'THEN 1 ELSE 0 END)
        *100.0/COUNT(*),2
    ) AS return_rate
FROM Orders o
JOIN Returns r
ON o.order_id=r.order_id
GROUP BY o.payment_method
ORDER BY return_rate DESC;


-- TOP 10 Most Return Product
Select o.product_id,p.category,
count(*) Returned_Orders
from Orders o
join Products p
ON o.product_id=p.product_id
join Returns r
ON o.order_id=r.order_id
where returned='Yes'
Group by
o.product_id,
p.category
Order by Returned_Orders DESC
LIMIT 10;

-- Products Never Returned
Select  o.product_id,p.category,
COUNT(*) Total_Orders
FROM Orders o
JOIN Products p
ON o.product_id=p.product_id
JOIN Returns r
ON o.order_id=r.order_id
GROUP BY
o.product_id,
p.category
HAVING
SUM(CASE
WHEN returned='Yes'
THEN 1
ELSE 0
END)=0

ORDER BY Total_Orders DESC;

-----------
-- Time Series Analysis
-----------
-- Monthly Revenue Trend
Select Year(order_date) AS year,
    Month(order_date) AS month,
    ROUND(SUM(total_amount),2) AS total_revenue
From Orders
Group by Year(order_date), Month(order_date)
Order by year, month;

-- Monthly Profit Trend
Select Year(order_date) AS year,
       Month(order_date) AS month,
    ROUND(SUM(profit_margin),2) AS total_profit
From Orders
Group by Year(order_date),Month(order_date)
Order by year, month;

-- Monthly Orders
Select Year(order_date) AS year,
       Month(order_date) AS month,
       COUNT(order_id) AS total_orders
FROM Orders
Group by Year(order_date),Month(order_date)
Order by year, month;

-- Monthly Return Rate
SELECT
YEAR(o.order_date) AS year,
MONTH(o.order_date) AS month,
COUNT(*) total_orders,

SUM(CASE WHEN r.returned='Yes' THEN 1 ELSE 0 END) returned_orders,
ROUND(SUM(CASE WHEN r.returned='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) return_rate
FROM Orders o
JOIN Returns r
ON o.order_id=r.order_id
GROUP BY
YEAR(order_date),
MONTH(order_date)
ORDER BY year,month;

-- Best Sales Month
SELECT YEAR(order_date) year,MONTH(order_date) month,
ROUND(SUM(total_amount),2) revenue
FROM Orders
GROUP BY
YEAR(order_date),
MONTH(order_date)
ORDER BY revenue DESC
LIMIT 1;

-- Worst Sales Month
SELECT YEAR(order_date) year,MONTH(order_date) month,
ROUND(SUM(total_amount),2) revenue
FROM Orders
GROUP BY
YEAR(order_date),
MONTH(order_date)
ORDER BY revenue
LIMIT 1;

-- Average Order Value by Month
SELECT YEAR(order_date) year,MONTH(order_date) month,
ROUND(AVG(total_amount),2) average_order_value
FROM Orders
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY year,month;

-- Monthly Quantity Sold
SELECT YEAR(order_date) year,MONTH(order_date) month,
SUM(quantity) quantity_sold
FROM Orders
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY year,month;

-- Monthly Shipping Cost
SELECT YEAR(order_date) year,MONTH(order_date) month,
ROUND(SUM(shipping_cost),2) shipping_cost
FROM Orders
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY year,month;

-- Monthly Profit Margin %
SELECT YEAR(order_date) year,MONTH(order_date) month,
ROUND(SUM(profit_margin)*100/SUM(total_amount),2) profit_margin_percentage
FROM Orders
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY year,month;


-- Rank Customers by Revenue

SELECT customer_id, SUM(total_amount) revenue,
RANK() OVER(
ORDER BY SUM(total_amount) DESC) revenue_rank
FROM Orders
GROUP BY customer_id;

-- Dense Rank Regions by Profit
SELECT c.region, SUM(o.profit_margin) profit,
DENSE_RANK() OVER(ORDER BY SUM(o.profit_margin) DESC) profit_rank
FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY c.region;

-- Top Product in Each Category
WITH ProductSales AS
(SELECT p.category, o.product_id,
SUM(o.total_amount) revenue,
ROW_NUMBER() OVER(PARTITION BY p.category
ORDER BY SUM(o.total_amount) DESC) rn
FROM Orders o
JOIN Products p
ON o.product_id=p.product_id
GROUP BY
p.category,
o.product_id)
SELECT *
FROM ProductSales
WHERE rn=1;

-- Top 3 Products in Every Category
WITH ProductSales AS 
(SELECT p.category, o.product_id,
SUM(o.total_amount) revenue,
ROW_NUMBER() OVER(PARTITION BY p.category
ORDER BY SUM(o.total_amount) DESC) rn
FROM Orders o
JOIN Products p
ON o.product_id=p.product_id
GROUP BY
p.category,
o.product_id)
SELECT *
FROM ProductSales
WHERE rn<=3;

-- Top 5% Customers
WITH CustomerRevenue AS
(SELECT customer_id,
SUM(total_amount) revenue
FROM Orders
GROUP BY customer_id)
SELECT *
FROM (SELECT *,
NTILE(20) OVER(
ORDER BY revenue DESC) grp
FROM CustomerRevenue)x
WHERE grp=1;

-- Previous Month Revenue (LAG)
WITH MonthlyRevenue AS
(SELECT YEAR(order_date) year,
MONTH(order_date) month,
SUM(total_amount) revenue
FROM Orders
GROUP BY
YEAR(order_date),
MONTH(order_date))
SELECT *,
LAG(revenue) OVER(
ORDER BY year,month) previous_month_revenue
FROM MonthlyRevenue;

--  Month-over-Month Growth %
WITH MonthlyRevenue AS
(SELECT
	YEAR(order_date) year,
	MONTH(order_date) month,
	SUM(total_amount) revenue
FROM Orders
GROUP BY
	YEAR(order_date),
	MONTH(order_date))
SELECT year, month, revenue, LAG(revenue) OVER(
ORDER BY year,month) previous_revenue,
ROUND((revenue-LAG(revenue) OVER(ORDER BY year,month))*100/LAG(revenue) OVER(ORDER BY year,month),2)AS growth_percentage
FROM MonthlyRevenue;

-- Running Revenue
SELECT order_date, SUM(total_amount) revenue, SUM(SUM(total_amount))
OVER(ORDER BY order_date) running_revenue
FROM Orders
GROUP BY order_date;

-- Running Profit
SELECT order_date, SUM(profit_margin) profit, SUM(SUM(profit_margin))
OVER(ORDER BY order_date) running_profit
FROM Orders
GROUP BY order_date;

-- Revenue Contribution %
SELECT customer_id, SUM(total_amount) revenue,
ROUND(SUM(total_amount)*100/SUM(SUM(total_amount))OVER(),2)revenue_percentage
FROM Orders
GROUP BY customer_id
ORDER BY revenue DESC;
