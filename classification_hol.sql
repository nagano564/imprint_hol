-- create the classification model
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION customer_classification_model(
    INPUT_DATA => SYSTEM$REFERENCE('view', '???'),
    TARGET_COLNAME => '???'
);

select * from customers
where join_date>'2024-02-11'::date;

CREATE OR REPLACE TABLE customer_predictions AS
SELECT email, ???!PREDICT(INPUT_DATA => object_construct(*)) as predictions
from customers;

SELECT * FROM customer_predictions;

select c.email
from customers c
 inner join customer_predictions p on c.email=p.email
where c.join_date>='2024-02-11'::date and predictions:class='GOLD';

-- old customers who are not gold but should be
select c.email
from customers c
 inner join customer_predictions p on c.email=p.email
where c.join_date<'2024-02-11'::date and predictions:class='GOLD'
 and c.total_order_value<=25;