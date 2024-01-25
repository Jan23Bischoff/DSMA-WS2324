library(tidyverse)

df_business <- read_csv("data/business.csv")
df_checkin <- read_csv("data/checkin.csv")
df_photo <- read_csv("data/photo.csv")
df_review <- read_csv("data/review.csv")
df_tip <- read_csv("data/tip.csv")
df_users <- read_csv("data/users.csv")

#overview of the data line by line
df_business %>%
  glimpse() 


#Average stars in FF is quite low
df_business %>%
  ggplot(aes(stars)) +
  geom_histogram()

# have less than 50 reviews
df_business %>%
  ggplot(aes(review_count)) +
  geom_histogram() +
  scale_x_log10()

#Most FF in Pennsylvania (PA) and Florida (FL)
df_business %>%
  count(state, sort = TRUE) 
#loads map data build in from R, geolocations of the us
us_states <- map_data("state")
# create dataset state abbs and full names of each state
df_states = tibble(abb = datasets::state.abb,
                   full = datasets::state.name) 
#region column is created and converted to right format 
us_states$region <- str_to_title(us_states$region)


#pipe operator to create pipelines. combined with yelp dataset
#map is created number of restaurants from states
df_business %>%
  count(state) %>%
  right_join(df_states, by=c("state"="abb")) %>%
  right_join(us_states, by=c("full"="region")) %>%
  ggplot(aes(long, lat, group=group, fill= n)) +
  geom_polygon()

#what does "u'free'" mean?, if free then most have free Wifi and not necessary for analysis
#assumptions have to be made for the NA restaurants
df_business %>%
  count(wifi)
#assumptions have to be made
df_business %>%
  count(restaurantsdelivery)
#assumptions have to be made
df_business %>%
  count(businessacceptscreditcards)
#assumptions have to be made
df_business %>%
  count(restaurantsgoodforgroups)
#assumptions have to be made
df_business %>%
  count(drivethru)


#checkin 

df_checkin %>% head()

df_checkin %>%
  mutate(date = str_split(date, ",")) -> df_checkin

#convert list with checkins into length of list
df_checkin$number_checkins <- map_vec(df_checkin$date, length)

#check-in graphics
df_checkin %>%
  ggplot(aes(number_checkins)) +
  geom_histogram()+
  scale_x_log10()


df_business %>%
  group_by(name) %>%
  summarise(
    mean_stars = mean(stars),
    count = n()
  ) %>%
  arrange(desc(count), mean_stars) %>%
  head(20)

#the following companies
df_checkin %>%
  ggplot(aes(number_checkins)) +
  geom_histogram() +
  scale_x_log10()

df_business %>%
  group_by(name) %>%
  summarise(
    mean_stars = mean(stars),
    count = n()
  ) %>%
  arrange(desc(count), mean_stars) %>%
  head(10)

df_users %>%
  ggplot(aes(review_count)) +
  geom_histogram() +
  scale_x_log10()

df_users %>% 
  ggplot(aes(average_stars)) +
  geom_histogram()
df_users %>%
  ggplot(aes(review_count, average_stars)) +
  geom_point()

df_users %>%
  ggplot(aes(cut(review_count, breaks = c(0.00,5, 50, 500, 5000, 20000)), average_stars)) +
  geom_boxplot()

