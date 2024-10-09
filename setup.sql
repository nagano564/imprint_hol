USE ROLE accountadmin;
CREATE OR REPLACE DATABASE HOL;
USE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE customer_service_calls (
    date_created DATE,
    support_rep_id STRING,
    transcript STRING
);

INSERT INTO customer_service_calls (date_created, support_rep_id, transcript)
VALUES
    ('2024-08-01', 'A001', 'I just wanted to say thank you so much for helping me with my new credit card order. It arrived so quickly, and activating it was super easy. I've had such a great experience with your service!'),
    ('2024-08-02', 'A002', 'I'm extremely frustrated! I reported fraudulent transactions on my account, and yet I'm still seeing unauthorized charges. This is unacceptable, and I want this resolved immediately.'),
    ('2024-08-03', 'A003', 'I was a bit confused about how to pay my balance online, but your representative walked me through the process so patiently. I'm really grateful for the support, and everything's working perfectly now.'),
    ('2024-08-04', 'A004', 'I've been trying to reach someone for days! My credit card was lost, and I need a replacement urgently. The delays and lack of communication are really disappointing.'),
    ('2024-08-05', 'A001', 'Thank you for helping me understand the rewards program better. I was able to redeem points for my flight tickets, and the whole process was seamless. You guys are the best!'),
    ('2024-08-06', 'A002', 'I can't believe the inconvenience I've faced just trying to update my billing address. I've called multiple times, and no one seems to know what they're doing. This is beyond frustrating!'),
    ('2024-08-07', 'A003', 'I needed assistance with a large purchase, and the credit increase was handled so quickly. I appreciate the efficient service and will definitely recommend your company to others.'),
    ('2024-08-08', 'A004', 'My credit card account was closed without any warning, and now I'm having a hard time reopening it. I've been bounced around between departments, and no one seems able to help. This is terrible customer service!');

-- create table to hold the generated data
create table daily_impressions(day timestamp, impression_count integer);-- create the example customer table

CREATE OR REPLACE TABLE customers AS
SELECT 'user'||seq4()||'_'||uniform(1, 3, random(1))||'@email.com' as email,
dateadd(minute, uniform(1, 525600, random(2)), ('2023-03-11'::timestamp)) as join_date,
round(18+uniform(0,10,random(3))+uniform(0,50,random(4)),-1)+5*uniform(0,1,random(5)) as age_band,
case when uniform(1,6,random(6))=1 then 'Less than $20,000'
       when uniform(1,6,random(6))=2 then '$20,000 to $34,999'
       when uniform(1,6,random(6))=3 then '$35,000 to $49,999'
       when uniform(1,6,random(6))=3 then '$50,000 to $74,999'
       when uniform(1,6,random(6))=3 then '$75,000 to $99,999'
  else 'Over $100,000' end as household_income,
    case when uniform(1,10,random(7))<4 then 'Single'
       when uniform(1,10,random(7))<8 then 'Married'
       when uniform(1,10,random(7))<10 then 'Divorced'
  else 'Widowed' end as marital_status,
  greatest(round(normal(2.6, 1.4, random(8))), 1) as household_size,
  0::float as total_order_value,
  FROM table(generator(rowcount => 100000));

  select * from customers limit 100;
-- Next we will fill the total order value column for customers who have existed for a long enough time. We use the demographic data to influence the total order value, so that the model can pick up the effects.

-- set total order values for longer-term customers
update customers
set total_order_value=round((case when uniform(1,3,random(9))=1 then 0
    else abs(normal(15, 5, random(10)))+
        case when marital_status='Married' then normal(5, 2, random(11)) else 0 end +
        case when household_size>2 then normal(5, 2, random(11)) else 0 end +
        case when household_income in ('$50,000 to $74,999', '$75,000 to $99,999', 'Over $100,000') then normal(5, 2, random(11)) else 0 end
    end), 2)
where join_date<'2024-02-11'::date;

select * from customers limit 100;
-- Finally, we fill in the total order value for customers who have more recently signed up. As such, they are more likely to have $0 total order value, and their totals are lower on average.

-- set total order value for more recent customers
update customers
set total_order_value=round((case when uniform(1,3,random(9))<3 then 0
    else abs(normal(10, 3, random(10)))+
        case when marital_status='Married' then normal(5, 2, random(11)) else 0 end +
        case when household_size>2 then normal(5, 2, random(11)) else 0 end +
        case when household_income in ('$50,000 to $74,999', '$75,000 to $99,999', 'Over $100,000') then normal(5, 2, random(11)) else 0 end
    end), 2)
where join_date>='2024-02-11'::date;
-- Verify the data
-- We can run the following statement to verify our data.

-- verify the data loading
select * from customers;

create or replace view customer_training
as select age_band, household_income, marital_status, household_size, case when total_order_value<10 then 'BRONZE'
    when total_order_value<=25 and total_order_value>10 then 'SILVER'
    else 'GOLD' END as segment
from customers
where join_date<'2024-02-11'::date;

select * from customer_training;