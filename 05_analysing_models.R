# distribution of reviews sentiment
library(tidyverse)

#is_satisfied: explanation of variable at file 4
#Customer Satisfaction by Review Sentiment
df_sentiment <- read_csv("data/df_review_sentiment.csv")

df_sentiment %>% count(sentiment)

df_review %>% left_join(df_sentiment %>% select(review_id, sentiment)) %>%
  count(is_satisfied, sentiment) %>%
  ggplot(aes(is_satisfied, n, fill = sentiment)) +
  geom_col() +
  theme_light() +
  labs(x="Customer satisfied?", y="Number of Observations", fill="Sentiment")


#Analysis of class prob (text analysis)
#value= average probability that reviews contains category
df_rev_class_prob <- read_csv("data/df_review_class_prob.csv") %>%
  left_join(df_review %>% select(review_id, is_satisfied)) 

#Category Prevalence in Reviews
df_rev_class_prob %>%
  group_by(is_satisfied) %>%
  summarise(
    weather = mean(weather_prob),
    service = mean(service_prob),
    food = mean(food_prob),
    price = mean(price_prob)
  ) %>%
  pivot_longer(cols=c(weather, service, food, price)) %>%
  ggplot(aes(name, value, fill = is_satisfied)) +
  geom_col(position="dodge") +
  theme_light()+
  labs(x="Category",
       y="Share of Reviews")
#We can see that food and service are the main class in reviews for both positive and negative
#weather and price are not that important as customers know about that in advance
#But price seems more important in reviews of unsatisfied customers

#Final Conclusions:
#Difficult to predict customer satisfaction based just on restaurant attributes
#restaurant should include wifi, drivethru, no delivery, not open 24/7,
#low density areas
#restaurants should also create an incentive to get review numbers up

#text analysis found out that service and food are most important
#for customer satisfaction besides restaurant attributes
#courses for service standard
#higher quality food
