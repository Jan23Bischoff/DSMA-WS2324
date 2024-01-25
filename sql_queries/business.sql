select j ->> 'city' as city, j->> 'name' as name, j -> 'hours' ->> 'Monday' as Monday, 
j -> 'hours' ->> 'Tuesday' as Tuesday, j -> 'hours' ->> 'Wednesday' as Wednesday, 
j -> 'hours' ->> 'Thursday' as Thursday, j -> 'hours' ->> 'Friday' as Friday, 
j -> 'hours' ->> 'Saturday' as Saturday, j -> 'hours' ->> 'Sunday' as Sunday, 
 cast(j ->>'stars' as dec(3,2)) as stars, j ->> 'state' as state, j ->> 'address' as address, j ->> 'is_open' as is_open,
	   j ->> 'latitude' as latitude, j ->> 'longitude' as longitude,
	   j->'attributes' ->> 'WiFi' as WiFi, j->'attributes' ->> 'DriveThru' as DriveThru, j->'attributes' ->> 'RestaurantsDelivery' as RestaurantsDelivery,
	   j->'attributes' ->> 'BusinessAcceptsCreditCards' as BusinessAcceptsCreditCards, 
	   j->'attributes' ->> 'RestaurantsGoodForGroups' as RestaurantsGoodForGroups,
	   j ->> 'business_id' as business_id,
	   j ->> 'postal_code' as postal_code,
	   j ->> 'review_count' as review_count
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%';