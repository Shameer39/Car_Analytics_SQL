/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
 use supply_chain;
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
select * from customer;
select state, count(customer_name) count
from customer_t
group by state;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

select * from order_t;
select distinct customer_feedback from order_t;
with temp as(
select *, case 
when customer_feedback = 'Very Bad' then 1
when customer_feedback = 'Bad' then 2
when customer_feedback = 'Okay' then 3
when customer_feedback = 'Good' then 4
when customer_feedback = 'Very Good' then 5 end as Rating
from order_t)
select quarter_number,avg(Rating) as Avg_Rat
from temp
group by quarter_number
order by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
select * from order_t;
with temp as
(select quarter_number, customer_feedback, count(customer_feedback) as count,
sum(count(customer_feedback))over(partition by quarter_number) as Tot_count
from order_t
group by quarter_number,customer_feedback
order by quarter_number)
select quarter_number, customer_feedback, count,round((count/Tot_count)*100,0) as Pert
from temp
group by quarter_number, customer_feedback;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/
select vehicle_maker,count(customer_id) as count
from order_t o join product_t p on o.product_id=p.product_id
group by vehicle_maker
order by count desc
limit 5;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

select * from customer_t c join order_t o on c.customer_id=o.customer_id
join product_t p on o.product_id=p.product_id;
with temp as (
select state, vehicle_maker, rank()over(partition by state order by count(c.customer_id) desc) as Rank_
from customer_t c join order_t o on c.customer_id=o.customer_id
join product_t p on o.product_id=p.product_id
group by state, vehicle_maker)
select * from temp where rank_ = 1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/
select quarter_number, count(order_id) No_Order
from order_t
group by quarter_number
order by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      with temp2 as(
      with temp as(
      select quarter_number, sum(vehicle_price)over(partition by quarter_number) Revenue,  sum(vehicle_price)over() as Total
      from order_t)
      select quarter_number ,Revenue, (Revenue/Total*100) as Percent
      from temp
      group by quarter_number,Revenue, Percent)
      select round(Percent,2), round(lag(Percent)over(),2) as Prev_Quar, 
      round(lag(Percent)over()-Percent,2) as `QaQ Diff` 
      from temp2;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/
select distinct quarter_number, count(order_id)over(partition by quarter_number) as count_,
sum(vehicle_price)over(partition by quarter_number) as Total_revenue
from order_t;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/
select credit_card_type, avg(discount) as avg_discount
from order_t o join customer_t c on o.customer_id=c.customer_id
group by credit_card_type;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
select quarter_number, round(avg(datediff(ship_date,order_date))) as Avg_time
from order_t
group by quarter_number
order by quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------
