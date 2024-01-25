library(tidyverse)
library(skimr)

df_business <- read_csv("data/business.csv")

#original motivation of study
#low stars for fast food
#our customer plans to open new restaurants and wants to know:
# what factors impact customer satisfaction and where to look for new locations

#6472 fast food restaurants in the yelp dataset
summary(df_business)


#Distribution of Average Star Ratings for Fast Food Restaurants
df_business %>%
  ggplot(aes(stars)) +
  geom_bar() +
  theme_light() +
  labs(x="Average Stars", y="Number of Observations")



df_business %>%
  group_by(name) %>%
  summarise(
    mean_stars = mean(stars),
    count = n()
  ) %>%
  arrange(desc(count), mean_stars) %>%
  head(15) -> df_business_top_15

#Number of Restaurants in the Yelp Dataset
df_business_top_15 %>%
  mutate(
    name = as.factor(name)
  ) %>%
  ggplot(aes(fct_reorder(name, count), count)) +
  geom_col() +
  coord_flip() +
  theme_light() +
  labs(x="Fast Food Chain", y="Number of Restaurants")

businesses_top_15 <- df_business_top_15$name
businesses_top_15

#We focus only on the top 15 chains (over 100 restaurantsin the yelp dataset)
df_business %>%
  filter(name %in% businesses_top_15) -> df_business

#Distribution of Average Star Ratings for Top 15 Fast Food Restaurants
df_business %>%
  ggplot(aes(stars)) +
  geom_bar() +
  theme_light() +
  labs(x="Average Stars", y="Number of Observations")

#Average Stars for Top 15 Fast Food Restaurants
df_business %>%
  group_by(name) %>%
  summarise(
    stars = mean(stars)
  ) %>%
  ggplot(aes(fct_reorder(name, stars), stars)) +
  geom_col() +
  theme_light() +
  coord_flip() +
  labs(x="", y="Average Stars")



#create new variable open_24_7 based on the opening times
df_business %>%
  mutate(
    open_24_7 = ifelse(monday == "0:0-0:0" &
                   tuesday == "0:0-0:0" &
                   wednesday == "0:0-0:0" &
                   thursday == "0:0-0:0" &
                   friday == "0:0-0:0" &
                   saturday == "0:0-0:0" &
                   sunday == "0:0-0:0", TRUE, FALSE)
  ) -> df_business

#327 NA values in open_24_7
sum(df_business$open_24_7, na.rm = TRUE)

df_review <- read_csv("data/review.csv")
#filter for reviews about the fast food restaurants from top 15 chains
df_review %>% filter(business_id %in% df_business$business_id) -> df_review

#85818 reviews about 
nrow(df_review)

#distribution of stars not normally distributed
#would expect bell shape
df_review %>%
  ggplot(aes(stars)) +
  geom_histogram() +
  theme_light() +
  labs(x="Stars", y="Number of Observations")

#Hypothesis: Users with exceptionally bad/good experiences only give 1 / 5 star ratings
#checking for hypothesis and solution: filter out users with less than 5 reviews on fast food
#to get a better image we want to exclude users who just signed up to yelp to trash a restaurant experience
df_users <- read_csv("data/users.csv")
users_with_reviews_on_top_15_fast_food <- unique(df_review$user_id)

#60862 users with reviews on top 15 chains
length(users_with_reviews_on_top_15_fast_food)

#including all users could lead to such outlier experiences
df_users %>%
  filter(user_id %in% users_with_reviews_on_top_15_fast_food) %>%
  ggplot(aes(average_stars)) +
  geom_histogram() 

#checking if it is better when using only user with more than 4 reviews on yelp
#closer to normal distribution
df_users %>%
  filter(user_id %in% users_with_reviews_on_top_15_fast_food) %>%
  filter(review_count > 4) %>%
  ggplot(aes(average_stars)) +
  geom_histogram() +
  theme_light() +
  labs(x="Average Stars", y="Number of Observations")

#using only those users that have more than 4 reviews on yelp to analyse their opinion
df_users %>%
  filter(review_count > 4) %>% select(user_id) %>% pull() -> users_with_5_or_more_reviews



#filter for reviews from users with more than 4 reviews to exclude outlier texts due to very good/bad experiences
#64708 reviews left
df_review %>%
  filter(user_id %in% users_with_5_or_more_reviews) -> df_review

#still a lot of one star ratings 
df_review  %>%
  ggplot(aes(stars)) +
  geom_histogram() +
  theme_light() +
  labs(x="Stars", y="Number of Observations")


#export of df_review to Python for Sentiment analysis
#readr::write_csv(df_review, "data/df_review_export_python.csv")

df_review %>% count(stars)


 
#df_users %>% 
#  filter(user_id %in% users_with_5_or_more_reviews) -> df_users

#df_users %>%
#  mutate(friends = str_split(friends, ",")) -> df_users

#convert list with friends into length of list
#df_users$friends <- map_vec(df_users$friends, length)

df_review %>%
  left_join(df_users %>% select(user_id, average_stars)) %>%
  mutate(better_than_average_star = stars >= average_stars) -> df_review

#Looking at stars distribution we can see that some users have a low average rating
#so we restrict being satisfied to greater than average and being atleast 4 stars in the next step
df_review %>%
  ggplot(aes(stars)) +
  geom_bar() +
  theme_light() +
  labs(x="Stars", y="Number of Observations") +
  facet_wrap(~better_than_average_star)

#dependent variable
df_review %>%
  mutate(
    is_satisfied = (stars > 3) & (better_than_average_star == TRUE)
      ) -> df_review

#we see problems with wifi, therefore we need to recode the values
# assumption: if an attribute is not included in yelp then the restaurant does not have this attribute
df_business %>%
  mutate(
    wifi = recode(wifi, 
                  "u'free'" = "free",
                  "'free'" = "free",
                  "'no'" = "no",
                  "'paid'" = "paid",
                  "u'no'" = "no",
                  "u'paid'" = "paid"),
    wifi = na_if(wifi, "None"),
    restaurantsdelivery = na_if(restaurantsdelivery, "None"),
    restaurantsdelivery = replace_na(restaurantsdelivery, "False"), 
    drivethru = replace_na(drivethru, "False"),
    open_24_7 = replace_na(open_24_7, FALSE),
    wifi = replace_na(wifi, "no")
  ) -> df_business

df_business %>%
  count(wifi)

df_uszip = read_csv("data/uszips.csv")

df_business %>%
  left_join(df_uszip %>% select(zip, density), by = c("postal_code" = "zip")) -> df_business


df_review %>% 
  left_join(df_business %>% select(business_id, wifi, drivethru, restaurantsdelivery, review_count, open_24_7, density)) %>%
  left_join(read_csv("data/df_review_sentiment.csv") %>% select(review_id, sentiment))-> final_data



final_data %>% 
  select(is_satisfied, wifi, drivethru, restaurantsdelivery, open_24_7, density, review_count)  -> final_data


#analysis of missing values
library(VIM)
aggr_plot <- aggr(final_data, col=c('green','red'), numbers=TRUE, sortVars=TRUE, labels=names(data), cex.axis=0.5, gap=2, ylab=c("Histogram of missing data","Pattern"))

#using mice pmm to fill missing density values
library(mice)
tempData <- mice(final_data,m=3,maxit=30,meth="pmm",seed=500)
summary(tempData)

completedData <- complete(tempData,1)

#get data into right format for models
completedData %>%
  mutate(
    is_satisfied = as.factor(is_satisfied),
    open_24_7 = as.character(open_24_7),
    open_24_7 = ifelse(open_24_7=="FALSE", "False", "True"),
  ) -> completedData

#class imbalance
share_satisfied <- mean(completedData$is_satisfied == "TRUE")
share_satisfied

completedData %>% count(is_satisfied)

n_true <- completedData %>% count(is_satisfied) %>% filter(is_satisfied=="TRUE")%>% select(n) %>% pull()

#downsampling of overrespresented data to get balanced dataset
balanced_data <- completedData %>%
  filter(is_satisfied =="TRUE") %>%
  bind_rows(completedData %>%
             filter(is_satisfied=="FALSE") %>%
             slice_sample(n=n_true))

summary(balanced_data)


