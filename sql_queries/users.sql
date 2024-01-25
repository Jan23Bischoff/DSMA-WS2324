select j ->> 'user_id' as user_id, j->> 'name' as name, j->>'review_count' as review_count, j->>'yelping_since' as yelping_since,
j->> 'friends' as friends, j->>'useful' as useful, j->>'funny' as funny, j ->>'cool' as cool, j->>'fans' as fans,
j->>'elite' as elite, j->>'average_stars' as average_stars, j->>'compliment_hot' as compliment_hot,
j->>'compliment_more' as compliment_more,j->>'compliment_profile' as compliment_profile,
j->>'compliment_cute' as compliment_cute,j->>'compliment_list' as compliment_list,
j->>'compliment_note' as compliment_note,j->>'compliment_plain' as compliment_plain,
j->>'compliment_cool' as compliment_cool,j->>'compliment_funny' as compliment_funny,
j->>'compliment_writer' as compliment_writer,j->>'compliment_photos' as compliment_photos
from users
where j ->> 'user_id' in
(select j ->> 'user_id'
from review
where j ->> 'business_id' in (select j ->> 'business_id' as business_id
from business
where j->> 'categories' like '%Restaurants%' and
j->> 'categories' like '%Fast Food%'));