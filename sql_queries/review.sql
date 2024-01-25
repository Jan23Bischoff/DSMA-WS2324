select j ->> 'business_id' as business_id, j ->> 'user_id' as user_id, j->> 'review_id' as review_id,
j->> 'stars' as stars, j->> 'date' as date, j->> 'text' as text, j->>'useful' as useful, j->>'funny' as funny,
j->>'cool' as cool
from review
where j ->> 'business_id' in (select j ->> 'business_id' as business_id
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%');
