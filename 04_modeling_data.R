#install.packages("tidymodels")
library(tidymodels)
library(tidyverse)
library(MLmetrics)

set.seed(42)

completedData %>%
  count(is_satisfied)

#log reg on whole dataset as we are interested on significance and not prediction so far
log_reg <- glm(is_satisfied ~ ., completedData, family = "binomial")
summary(log_reg)

#due to class imbalance we work with balanced data
set.seed(42)
ind <- sample(2, nrow(balanced_data), replace=TRUE)
train <- balanced_data[ind==1,]
test <- balanced_data[ind==2,]

#distribution is okay
mean(train$is_satisfied == "TRUE")
mean(test$is_satisfied=="TRUE")


#Decision Tree
library(rpart)				        # Popular decision tree algorithm
#install.packages("rattle")
library(rattle)					# Fancy tree plot
library(rpart.plot)	

tree <- rpart(is_satisfied ~ ., train, method = "class", minsplit = 5)
fancyRpartPlot(tree)
tree_test_pred <- predict(tree, test, type = "class")

tree_accuracy <- mean(tree_test_pred == test$is_satisfied)
tree_accuracy

#F1 score
#install.packages("MLmetrics")
#library("MLmetrics")
tree_f1 <- F1_Score(test$is_satisfied, tree_test_pred , positive="TRUE")
tree_f1

tree_prob <- predict(tree, test, type="prob")
tree_prob <- data.frame(tree_prob)
#install.packages("pROC")
#library(pROC)
#???
tree_roc_plot <- autoplot(roc_curve(data.frame(predicted=tree_test_pred, Class1=tree_prob$TRUE., Class2=tree_prob$FALSE. ,truth=test$is_satisfied), truth, Class1, event_level = "second"))  +
  labs(title="Decision Tree")
tree_roc_plot
tree_roc <- yardstick::roc_auc(data.frame(predicted=tree_test_pred, Class1=tree_prob$TRUE., Class2=tree_prob$FALSE. ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()



#convert data into right format
#install.packages("recipes")
library(recipes)
#install.packages("rsample")
library(rsample)
rec <- 
  recipe(is_satisfied ~ ., data = train) %>% 
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors())

#Nearest neighbour
#install.packages("parsnip")
library(parsnip)
nearn <- nearest_neighbor(mode = "classification", neighbors = 5)

#install.packages("workflows")
#install.packages("parsnip")
#install.packages("kknn")
library(workflows)
library(parsnip)
library(kknn)
nearn_wflow <- 
  workflow() %>% 
  add_model(nearn) %>% 
  add_recipe(rec)

nearn_fit <- nearn_wflow %>%
  fit(train)

nearn_fit %>%
  extract_fit_parsnip()

nearn_test_pred <- predict(nearn_fit, test)
nearn_accuracy <- mean(nearn_test_pred$.pred_class == test$is_satisfied)
nearn_accuracy
nearn_f1 <- F1_Score(test$is_satisfied, nearn_test_pred$.pred_class, positive="TRUE")
nearn_f1

nearn_prob <- predict(nearn_fit, test, type="prob")
#???
nearn_roc_plot <- autoplot(roc_curve(data.frame(predicted=nearn_test_pred$.pred_class, Class1=nearn_prob$.pred_TRUE, Class2=nearn_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second")) +  
  labs(title="KNN")
nearn_roc_plot
nearn_roc <- yardstick::roc_auc(data.frame(predicted=nearn_test_pred$.pred_class, Class1=nearn_prob$.pred_TRUE, Class2=nearn_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()


#Support vector machine
svm <- svm_rbf(mode = "classification")

svm_wflow <- 
  workflow() %>% 
  add_model(svm) %>% 
  add_recipe(rec)

svm_fit <- svm_wflow %>%
  fit(train)

svm_fit %>%
  extract_fit_parsnip()

svm_test_pred <- predict(svm_fit, test)
svm_accuracy <- mean(svm_test_pred$.pred_class == test$is_satisfied)
svm_accuracy
svm_f1 <- F1_Score(test$is_satisfied, svm_test_pred$.pred_class, positive="TRUE")
svm_f1

svm_prob <- predict(svm_fit, test, type="prob")
svm_roc_plot <- autoplot(roc_curve(data.frame(predicted=svm_test_pred$.pred_class, Class1=svm_prob$.pred_TRUE, Class2=svm_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second"))  +
  labs(title="SVM")
svm_roc_plot
svm_roc <- yardstick::roc_auc(data.frame(predicted=svm_test_pred$.pred_class, Class1=svm_prob$.pred_TRUE, Class2=svm_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()


#Random Forest
rf <- rand_forest(mode = "classification")

rf_wflow <- 
  workflow() %>% 
  add_model(rf) %>% 
  add_recipe(rec)

rf_fit <- rf_wflow %>%
  fit(train)

rf_fit %>%
  extract_fit_parsnip()

rf_test_pred <- predict(rf_fit, test)
rf_accuracy <- mean(rf_test_pred$.pred_class == test$is_satisfied)
rf_accuracy
rf_f1 <- F1_Score(test$is_satisfied, rf_test_pred$.pred_class, positive="TRUE")
rf_f1

rf_prob <- predict(rf_fit, test, type="prob")
rf_roc_plot <- autoplot(roc_curve(data.frame(predicted=rf_test_pred$.pred_class, Class1=rf_prob$.pred_TRUE, Class2=rf_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second"))  +
  labs(title="Random Forest")
rf_roc_plot
rf_roc <- yardstick::roc_auc(data.frame(predicted=rf_test_pred$.pred_class, Class1=rf_prob$.pred_TRUE, Class2=rf_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()



#log reg
log_reg <- logistic_reg() 

lr_wflow <- 
  workflow() %>% 
  add_model(log_reg) %>% 
  add_recipe(rec)

lr_fit <- lr_wflow %>%
  fit(train)

lr_fit %>%
  extract_fit_parsnip()

lr_test_pred <- predict(lr_fit, test)
lr_accuracy <- mean(lr_test_pred$.pred_class == test$is_satisfied)
lr_accuracy
lr_f1 <- F1_Score(test$is_satisfied, lr_test_pred$.pred_class, positive="TRUE")
lr_f1

lr_prob <- predict(lr_fit, test, type="prob")
lr_roc_plot <- autoplot(roc_curve(data.frame(predicted=lr_test_pred$.pred_class, Class1=lr_prob$.pred_TRUE, Class2=lr_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second")) +
  labs(title="Logistic Regression")
lr_roc_plot
lr_roc <- yardstick::roc_auc(data.frame(predicted=lr_test_pred$.pred_class, Class1=lr_prob$.pred_TRUE, Class2=lr_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()

#Boosting (uses xgboost algorithm)
#install.packages("xgboost")
library(xgboost)
boost <- boost_tree(mode="classification")
boost_wflow <- 
  workflow() %>% 
  add_model(boost) %>% 
  add_recipe(rec)

boost_fit <- boost_wflow %>%
  fit(train)

boost_fit %>%
  extract_fit_parsnip()

boost_test_pred <- predict(boost_fit, test)
boost_accuracy <- mean(boost_test_pred$.pred_class == test$is_satisfied)
boost_accuracy
boost_f1 <- F1_Score(test$is_satisfied, boost_test_pred$.pred_class, positive="TRUE")
boost_f1

boost_prob <- predict(boost_fit, test, type="prob")
boost_roc_plot <- autoplot(roc_curve(data.frame(predicted=boost_test_pred$.pred_class, Class1=boost_prob$.pred_TRUE, Class2=boost_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second")) +
  labs(title="Boosting")
boost_roc_plot
boost_roc <- yardstick::roc_auc(data.frame(predicted=boost_test_pred$.pred_class, Class1=boost_prob$.pred_TRUE, Class2=boost_prob$.pred_FALSE ,truth=test$is_satisfied), truth,Class1, event_level = "second") %>% select(.estimate) %>% pull()


#roc plot comparison
library(ggpubr)
figure <- ggarrange(tree_roc_plot,
                    nearn_roc_plot,
                    svm_roc_plot,
                    rf_roc_plot,
                    lr_roc_plot,
                    boost_roc_plot,
                    #labels = c("Decision Tree", "KNN", "SVM",
                    #           "Random Forest", "Logistic Regression", "Boosting"),
                    #vjust = 0.75,
                    #hjust = -0.5,
                    #font.label = list(size = 9, face = "bold"),
                    ncol = 3, nrow = 2, 
                    align="hv")

figure


#model comparison
model_metrics <-tibble(model=c("tree", "knn", "svm", "rf", "log_reg", "boost"),
       accuracy=c(tree_accuracy, nearn_accuracy, svm_accuracy, rf_accuracy, lr_accuracy, boost_accuracy),
       f1=c(tree_f1, nearn_f1, svm_f1, rf_f1, lr_f1, boost_f1),
       roc=c(tree_roc,nearn_roc, svm_roc, rf_roc, lr_roc, boost_roc))

model_metrics

library(formattable)

formattable(model_metrics, 
            align =c("l","c","c","c")
             )



model_metrics %>%
  pivot_longer(cols = c(accuracy, f1, roc), names_to = "metric") %>%
  ggplot(aes(model, value, fill=model)) +
  geom_col() +
  facet_wrap(~metric) +
  theme_light() +
  coord_flip()





