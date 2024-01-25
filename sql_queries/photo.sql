select j ->> 'business_id' as business_id, j ->> 'photo_id' as photo_id, j->> 'caption' as caption, j->> 'label' as label
from photo
where j ->> 'business_id' in (select j ->> 'business_id' as business_id
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%');
