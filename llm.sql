USE DATABASE HOL;
USE SCHEMA PUBLIC;

SELECT * FROM customer_service_calls;

select transcript, snowflake.cortex.sentiment(transcript) from customer_service_calls;

select transcript, snowflake.cortex.summarize(transcript) as my_summary
from customer_service_calls;

SET prompt = 
'### 
Summarize this transcript in less than 200 words. 
Put the called_reason, sentiment as positive or negative and summary in json format. 
###';

select snowflake.cortex.complete('llama2-70b-chat',concat('[INST]',$prompt,transcript,'[/INST]')) as summary
from customer_service_calls ;

select snowflake.cortex.complete('mixtral-8x7b',concat('[INST]',$prompt,transcript,'[/INST]')) as summary
from customer_service_calls ;

select snowflake.cortex.complete('mistral-7b',concat('[INST]',$prompt,transcript,'[/INST]')) as summary
from customer_service_calls ;

select snowflake.cortex.complete('gemma-7b',concat('[INST]',$prompt,transcript,'[/INST]')) as summary
from customer_service_calls ;