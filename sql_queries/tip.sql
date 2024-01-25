select j ->> 'business_id' as business_id, j ->> 'user_id' as user_id, j->> 'compliment_count' as compliment_count,
j->> 'text' as text, j->> 'date' as date
from tip
where j ->> 'business_id' in (select j ->> 'business_id' as business_id
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%');