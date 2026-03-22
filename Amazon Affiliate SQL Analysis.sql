

use amazon_affiliate;

select * from amazon_clicks;
select * from user_behavior;
select * from amazon_conversions;
select * from amazon_products;

-- Creating stagging tables

-- Clicks stagging
create table clicks_stagging
like amazon_clicks;

insert clicks_stagging select * from amazon_clicks;
select * from clicks_stagging;

-- conversions stagging

create table conversions_stagging
like amazon_conversions;

insert conversions_stagging select * from amazon_conversions;
select * from conversions_stagging;

-- products stagging

create table products_stagging
like amazon_products;

insert products_stagging select * from amazon_products;
select * from products_stagging;

-- user stagging

create table user_stagging
like user_behavior;

insert user_stagging select * from user_behavior;
select * from user_stagging;


-- Data Check and Data cleaning 

-- Clicks Table 
select *, row_number() over(partition by session_id) as rn 
from clicks_stagging; -- Checking for duplicates

select *, row_number() over(partition by click_id) as rn 
from clicks_stagging; -- Checking for duplicates

select *, row_number() over(partition by user_id) as rn 
from clicks_stagging; -- Checking for duplicates

select * from clicks_stagging;

-- Conversions Table
-- (Missing values found)
select *, row_number() over(partition by conversion_id) as rn from conversions_stagging;

select count(click_id) from conversions_stagging where click_id = "";
-- Solution
Select co.click_id as conversion_click_id, c.click_id as click_click_id, co.product_title, c.product_title from conversions_stagging co left join clicks_stagging c on co.click_id = c.click_id;
Select *
from conversions_stagging co left join clicks_stagging c on co.click_id = c.click_id;

select * from clicks_stagging;
select * from conversions_stagging;

-- Checking the percentage of missing values in conversions table
SELECT 
  COUNT(*) AS missing_click_conversions,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM conversions_stagging) AS pct_of_total
FROM conversions_stagging
WHERE click_id = "";

-- Labelling clicks ids as attributed and non attributed in conversions table

alter table conversions_stagging 
add column is_attributed_click int;

update conversions_stagging 
set is_attributed_click = 1
where click_id like 'CLK%%';

update conversions_stagging 
set is_attributed_click = 0
where click_id = '';

select * from conversions_stagging;


-- Checking for duplicates in conversion stagging table

select *, row_number() over(partition by conversion_id) as rn 
from conversions_stagging; -- No duplicates found

-- Converting 'release date' type from string to date type 

alter table products_stagging
add column new_release_date date;

update products_stagging
set new_release_date = str_to_date(release_date, '%Y-%m-%d');

alter table products_stagging drop column release_date;
alter table products_stagging change column new_release_date release_date date; 

select * from products_stagging;

-- Checking for duplicates in products stagging

Select *, row_number() over(partition by product_asin) as row_num from products_stagging;

select count(*) from
(Select *, row_number() over(partition by product_asin) as row_num from products_stagging) a 
where a.row_num >1; -- No duplicates found, however an error was made by repeating the same product_asin nummber which has different values in other columns.

-- User stagging
select * from user_stagging;

-- Checking duplicates
select *, row_number() over(partition by session_id) as rn from user_stagging;

--------------------------------------------------------------------------------------------------------------------------

-- Data Analysis 

-- Business Problem 1 - Unclear Revenue Drivers 

-- Question 1: Which products generate the highest total affiliate revenue and commission earned, and 
-- how many conversions do they account for?

select * from conversions_stagging where product_title = "Dyson V8 Cordless Vacuum";

select product_title, round(sum(commission_earned),2) as total_commission, count(*) as num_of_conversions
from conversions_stagging group by product_title order by total_commission desc;

-- Question 2: Which product categories are the top and bottom performers based on total affiliate revenue and average commission per conversion?

select product_category, round(sum(commission_earned),2) as revenue 
from conversions_stagging group by product_category order by revenue desc;

select product_category, round(avg(commission_earned)/count(*),1) as avg_commission_per_conversion, round(avg(order_value),1) as aov
from conversions_stagging group by product_category order by avg_commission_per_conversion desc;

-- Question 3: How does product price range (low, mid, high) impact conversion volume, revenue, and commission earned?

select max(price), min(price) from products_stagging;
select count(*) from products_stagging where price > 700;

Select case
when p.price >= 700 then "High - Above 700 USD"
when p.price between 100 and 699 then "Mid - 100 TO 700 USD"
else "Low - Less than 100 USD"
end as price_category, count(*) as no_of_conversions, round(sum(c.commission_earned),1) as revenue from products_stagging p join conversions_stagging c on 
p.product_asin = c.product_asin and p.product_title = c.product_title
group by price_category
order by no_of_conversions desc;

-- Question 4: Are there products or categories with high click volume but low conversion or commission, indicating inefficient promotion?

Select 
c.product_asin, 
c.product_title, 
count(distinct c.click_id) as no_of_clicks, 
count(distinct co.conversion_id) as no_of_conversions
from clicks_stagging c left join conversions_stagging co on c.user_id = co.user_id and co.is_attributed_click = 1 
group by c.product_asin, c.product_title
order by no_of_clicks desc;


with cte as (
Select 
c.product_category,
c.product_asin, 
c.product_title, 
count(distinct c.click_id) as no_of_clicks, 
count(distinct co.conversion_id) as no_of_conversions,
round(sum(commission_earned),1) as revenue
from clicks_stagging c left join conversions_stagging co on c.user_id = co.user_id and co.is_attributed_click = 1 
group by c.product_asin, c.product_title, c.product_category
order by no_of_clicks desc)
select cte.product_category, 
sum(cte.no_of_clicks) as total_clicks, 
sum(cte.no_of_conversions) as total_conversions 
from cte group by cte.product_category order by total_clicks desc;


-- Business Problem 2: Conversion Funnel Drop-Off 

-- Question 1: How does time spent on page before clicking an affiliate link vary by product category and which categories show high engagement but low conversion rates?

Select c.product_category, round(avg(c.time_on_page_before_click),1) as avg_time_before_click, 
round(avg(u.user_engagement_score),1) as avg_engagement_score,
round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
from clicks_stagging c left join conversions_stagging co on c.click_id = co.click_id join 
user_stagging u on c.user_id = u.user_id
group by product_category
order by avg_time_before_click desc;

-- Do product categories with longer pre-click engagement convert more effectively, or does extended time indicate purchase friction?

Select c.product_category, 
	round(avg(c.time_on_page_before_click),1) as avg_time_before_click,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co 
on c.click_id = co.click_id
group by product_category
order by conversion_rate;

-- What is the average time on page before clicking for users whose clicks eventually converted?

Select co.product_category, 
	round(avg(c.time_on_page_before_click),1) as avg_time_before_click, 
	count(co.conversion_id) as no_of_conversions 
from conversions_stagging co 
inner join clicks_stagging c 
on co.click_id = c.click_id
group by product_category
order by avg_time_before_click desc;

-- How much time before the click does the user take for each product category and how does it compare to commission per conversion.

Select co.product_category, 
	round(avg(c.time_on_page_before_click),1) as avg_time_before_click,
	round(avg(commission_earned),1) as avg_commission_per_conversion, 
	COUNT(DISTINCT co.conversion_id) AS conversions
from conversions_stagging co 
inner join clicks_stagging c on co.click_id = c.click_id
group by product_category
order by avg_time_before_click desc;

-- How do conversion rates and commission earned differ between discounted and non-discounted products?

SELECT
    c.product_asin,
    c.product_title,
    CASE
        WHEN MAX(p.discount_percentage) > 0 THEN 'Discount'
        ELSE 'No Discount'
    END AS discount_flag,
    ROUND(COUNT(DISTINCT co.conversion_id) 
        / COUNT(DISTINCT c.click_id)*100,1) AS conversion_rate,
    ROUND(SUM(co.commission_earned), 2) AS total_commission,
    ROUND(AVG(co.commission_earned), 2) AS avg_commission_per_conversion
FROM clicks_stagging c
LEFT JOIN conversions_stagging co
    ON c.click_id = co.click_id
LEFT JOIN products_stagging p
    ON c.product_asin = p.product_asin
   AND c.product_title = p.product_title
GROUP BY
    c.product_asin,
    c.product_title
ORDER BY total_commission desc;

-- How do conversion rates differ between new and returning users?

select 
	new_vs_returning,
	round(count(distinct co.conversion_id)/count(distinct c.click_id) *100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join user_stagging u on u.user_id = c.user_id 
group by new_vs_returning;

-- Do discounts have a greater impact on conversion rates for new users compared to returning users?

Select 
	new_vs_returning,
case when 
		discount_percentage > 0 then 'Discount'
		else 'No Discount' end as discount_flag,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate 
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id 
left join products_stagging p on p.product_asin = c.product_asin and p.product_title = c.product_title
join user_stagging u on c.user_id = u.user_id
group by 
	new_vs_returning, 
	discount_flag
order by 
	new_vs_returning, 
	discount_flag;

-- How do product ratings and review counts influence conversion likelihood?

select 
	c.product_asin, 
	c.product_title, 
	round(max(rating),1) as avg_rating, 
	round(max(review_count),1) as no_of_reviews, 
	round(count(co.conversion_id)/count(c.click_id)*100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join products_stagging p on c.product_asin = p.product_asin and c.product_title = p.product_title
group by 
	c.product_asin, 
	c.product_title
order by conversion_rate desc;


-- How do conversion rates and engagement metrics differ across device types?

select
	u.device_type,
	round(avg(time_on_page_seconds),1) as avg_time_on_page,
	round(avg(session_duration_minutes),1) as avg_session_min,
	round(avg(page_views_in_session),0) as avg_page_views_in_session,
	round(avg(user_engagement_score),1) as avg_eng_score,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id 
join user_stagging u on c.user_id = u.user_id
group by u.device_type
order by conversion_rate desc;

-- Business Problem 3: Traffic Source Effectiveness

-- How do traffic sources compare in terms of conversion volume, conversion rate and total commission earned? Identify sources with:
-- • High traffic but low commission efficiency
-- • Low traffic but high commission per conversion

select 
	u.traffic_source,
	count(distinct co.conversion_id) as no_of_conversions,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate,
	round(sum(co.commission_earned),1) as total_commission_earned
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join user_stagging u on u.user_id = c.user_id
group by u.traffic_source
order by 2 desc;

-- How does user composition (new vs returning users) vary across traffic sources and how does this impact conversion performance?

Select 
	u.new_vs_returning,
	u.traffic_source,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id =co.click_id
join user_stagging u on c.user_id = u.user_id
group by 
	u.new_vs_returning, 
	u.traffic_source;


with cte as 
	(
	Select 
		u.new_vs_returning,
		u.traffic_source,
		round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
	from clicks_stagging c 
	left join conversions_stagging co on c.click_id =co.click_id
	join user_stagging u on c.user_id = u.user_id
	group by 
		u.new_vs_returning, 
		u.traffic_source
	) 
select 
	count(new_vs_returning) as new_customer, 
	traffic_source 
from user_stagging
where new_vs_returning = 'New' 
group by traffic_source
order by 1 desc;

with cte as 
	(
	Select 
		u.new_vs_returning,
		u.traffic_source,
		round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
	from clicks_stagging c 
	left join conversions_stagging co on c.click_id =co.click_id
	join user_stagging u on c.user_id = u.user_id
	group by 
		u.new_vs_returning, 
		u.traffic_source
	) 
select 
	count(new_vs_returning) as returning_customer,
	traffic_source 
from user_stagging
where new_vs_returning = 'Returning' 
group by traffic_source
order by 1 desc;

-- How do engagement metrics (time on page, scroll depth, engagement score) differ by traffic source, 
-- and which sources drive high engagement but low conversions?

select 
	u.traffic_source, 
	round(avg(u.time_on_page_seconds),1) as avg_time_on_page,
	round(avg(c.page_scroll_depth),1) as avg_page_scroll_depth,
	round(avg(u.user_engagement_score),1) as avg_eng_score,
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join user_stagging u on u.user_id = c.user_id
group by u.traffic_source
order by avg_eng_score;


-- Which traffic sources drive the highest average commission per conversion, indicating higher-quality traffic?

select 
	u.traffic_source, 
	round(avg(co.commission_earned),2) as commision_per_conversion
from conversions_stagging co 
join user_stagging u on co.user_id = u.user_id
where co.is_attributed_click = 1
group by u.traffic_source
order by commision_per_conversion desc;



-- Business Problem 4:
-- User behaviour differs across devices and regions, but we do not know how this affects engagement and conversion outcomes.


-- Business Question 1
-- Which countries generate the highest total affiliate commission, and how do their conversion rates compare?

SELECT
    c.country,
	ROUND(COUNT(DISTINCT CASE 
	WHEN co.conversion_id IS NOT NULL 
	THEN c.click_id END)
/ COUNT(DISTINCT c.click_id) *100,1) AS conversion_rate, 
ROUND(SUM(co.commission_earned),1) as total_aff_rev
FROM clicks_stagging c
LEFT JOIN conversions_stagging co
    ON c.click_id = co.click_id
GROUP BY c.country
ORDER BY total_aff_rev DESC;

-- Are there specific countries or devices that show high engagement but low conversion or commission, indicating potential UX or localisation issues?

select 
	a.country, 
	a.total_aff_com 
from 
		(select 
			c.country, 
			round(avg(u.user_engagement_score),1) as avg_eng_score,
			round(count(distinct case when co.conversion_id is not null then c.click_id end)/count(distinct c.click_id)*100,1) as conversion_rate,
			round(sum(co.commission_earned),1) as total_aff_com
		from clicks_stagging c 
		left join conversions_stagging co on c.click_id = co.click_id
		join user_stagging u on c.user_id = u.user_id
		group by c.country
		order by avg_eng_score desc) a
;

WITH user_clean AS (
SELECT 	user_id,
		AVG(user_engagement_score) AS engagement
FROM user_stagging
GROUP BY user_id
)

SELECT 
c.country,
ROUND(AVG(u.engagement),1) AS avg_eng_score,
ROUND(
COUNT(DISTINCT CASE WHEN co.conversion_id IS NOT NULL THEN c.click_id END)
/
COUNT(DISTINCT c.click_id)*100,1
) AS conversion_rate,
ROUND(SUM(co.commission_earned),1) AS total_aff_com

FROM clicks_stagging c

LEFT JOIN conversions_stagging co
ON c.click_id = co.click_id

JOIN user_clean u
ON c.user_id = u.user_id

GROUP BY c.country;

SELECT click_id, COUNT(*)
FROM conversions_stagging
GROUP BY click_id
HAVING COUNT(*) > 1;


select 
	u.geographic_location,
	u.device_type, 
	round(avg(u.user_engagement_score),1) as avg_eng_score,
	round(count(distinct case when co.conversion_id is not null then c.click_id end)/count(distinct c.click_id)*100,1) as conversion_rate,
	round(sum(co.commission_earned),1) as total_aff_com
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join user_stagging u on c.user_id = u.user_id
group by 
	u.device_type, 
	u.geographic_location
order by avg_eng_score desc;

-- How are users distributed across conversion funnel stages (Awareness, Interest, Consideration, Action) by device type, and which devices show the highest concentration at non-conversion stages?

-- Conversion Funnel Distribution w/o device types
SELECT
    conversion_funnel_stage,
    COUNT(*) AS users,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
    1) AS percentage_of_users
FROM user_stagging
GROUP BY conversion_funnel_stage
ORDER BY percentage_of_users DESC;

-- Convernsion funnel stage sliced and diced by device type
SELECT
    device_type,
    conversion_funnel_stage,
    COUNT(*) AS users,
    
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY device_type),
        1
    ) AS stage_percentage,

    row_number() OVER (
        PARTITION BY device_type
        ORDER BY COUNT(*) DESC
    ) AS stage_rank
FROM user_stagging
GROUP BY device_type, conversion_funnel_stage
ORDER BY device_type, stage_rank;

-- Business problem 5: Customer Value & Retention
-- We lack clarity on whether new or returning users provide higher long-term value through affiliate conversions.

-- Business Question 1: 
-- What is the difference in customer lifetime value (CLV) between new and returning users?

WITH user_level AS (
    SELECT
        u.user_id,
        u.new_vs_returning,
        MAX(co.customer_lifetime_value) AS clv
    FROM user_stagging u
    LEFT JOIN conversions_stagging co
        ON u.user_id = co.user_id
    GROUP BY
        u.user_id,
        u.new_vs_returning
)

SELECT
    new_vs_returning,
    COUNT(user_id) AS users,
    ROUND(SUM(clv),1) AS total_clv,
    ROUND(AVG(clv),1) AS clv_per_user
FROM user_level
GROUP BY new_vs_returning;

-- Which user type contributes more total commission revenue overall?

WITH distinct_users AS (
    SELECT DISTINCT user_id, new_vs_returning
    FROM user_stagging
)

SELECT 
    u.new_vs_returning,
    ROUND(SUM(co.commission_earned),1) AS total_comm_rev,
    ROUND(AVG(co.commission_earned),1) AS avg_comm_rev
FROM distinct_users u
LEFT JOIN conversions_stagging co
    ON u.user_id = co.user_id
GROUP BY u.new_vs_returning
ORDER BY total_comm_rev desc;


WITH cte as 
	(
		select 
			distinct user_id, 
			new_vs_returning 
	from user_stagging
	)
select 
new_vs_returning, 
count(*) 
from cte 
group by new_vs_returning;


-- Which traffic sources attract higher-value returning users?

select 
	u.traffic_source,
	u.new_vs_returning,
	round(avg(co.customer_lifetime_value),1) as avg_clv,
	round(avg(co.commission_earned),1) as avg_commission
from conversions_stagging co 
join user_stagging u on u.user_id = co.user_id
group by 
	u.traffic_source, 
	u.new_vs_returning
having u.new_vs_returning = 'Returning'
order by 3 desc;

-- Business Problem 6
-- Product price, discounts, and ratings vary significantly, but we do not know how these factors influence conversion likelihood and commission earned.


-- Is there a threshold where higher discounts stop improving conversion performance?

select 
	min(discount_percentage), 
	max(discount_percentage) 
from products_stagging;

select 
	case 
		when 
		p.discount_percentage between 1 and 10 then 'Low Discount %'
		when 
		p.discount_percentage between 11 and 20 then 'Mid Discounts %'
		when 
		p.discount_percentage between 21 and 32 then 'High Discount %' 
		else 'No Discount' 
	end as discount_treshold,
	round(count( distinct co.conversion_id)/count(distinct c.click_id) *100,1) as conversion_rate,
	round(sum(co.commission_earned),1) as total_commission_earned
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id
join products_stagging p on p.product_asin = c.product_asin and p.product_title = c.product_title
group by discount_treshold;

-- How do product ratings and review counts differ between converted and non-converted products?

select 
	c.product_asin,
	c.product_title,
	max(rating) as rating,
	max(review_count) as review_count,
	round(count( distinct co.conversion_id)/count( distinct c.click_id) *100) as conversion_rate
from clicks_stagging c 
left join conversions_stagging co on c.click_id =co.click_id
join products_stagging p on c.product_asin = p.product_asin and c.product_title = p.product_title
group by 
	c.product_title, 
	c.product_asin
order by 3 desc;

-- Do higher-rated products consistently generate higher commission revenue?

select 
	co.product_asin, 
	co.product_title, 
	max(p.rating) as rating,
	round(sum(commission_earned),1) as total_comm from conversions_stagging co 
join products_stagging p on p.product_asin = co.product_asin and p.product_title = co.product_title
group by 
	co.product_asin, 
	co.product_title
order by 4 desc;


-- Further analysis 

-- What product category has the highest session time on the website. What's the gap between the average and maximum session time?

select 
	c.product_category, 
	round(avg(u.session_duration_minutes),1) as avg_session, 
	max(u.session_duration_minutes) as highest_duration_session
from clicks_stagging c left join user_stagging u on u.user_id = c.user_id 
group by c.product_category order by avg_session desc;

-- Which product categories have the highest number of conversions and conversion rate?

select 
	c.product_category, 
	round(count(distinct co.conversion_id)/count(distinct c.click_id)*100,1) as conversion_rate,
	count(distinct co.conversion_id) as no_of_conversions
from clicks_stagging c 
left join conversions_stagging co on c.click_id = co.click_id 
group by c.product_category 
order by no_of_conversions desc;

-- What are ratings for products and thier category ratings?

select product_title, 
category,
rating,
round(avg(rating) over(partition by category),1) as category_avg
from products_stagging;


-- How many conversions do discount and non discount products have?

select 
case when discount_percentage > 1 then 'Discount' else 'No Discount'end as discount_flag,
count(distinct conversion_id) as no_of_conversions
from conversions_stagging co
left join products_stagging p on p.product_asin = co.product_asin and p.product_title = co.product_title
group by discount_flag;



