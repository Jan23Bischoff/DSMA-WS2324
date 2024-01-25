select j ->> 'business_id' as business_id, j ->> 'date'::varchar as date
from checkin
where j ->> 'business_id' in (select j ->> 'business_id' as business_id
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%');