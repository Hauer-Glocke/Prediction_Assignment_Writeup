rm(list = ls())
cat("\f")

#TASK: The goal of your project is to predict the manner in which they did the 
# exercise. This is the "classe" variable in the training set. You may use any 
# of the other variables to predict with. You should create a report describing
# how you built your model, how you used cross validation, what you think the
# expected out of sample error is, and why you made the choices you did. You
# will also use your prediction model to predict 20 different test cases.

#Loading Data
library(readr)
pml_training <- read_csv(url("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"))
pml_testing <- read_csv(url("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"))

summary(pml_training$classe)
unique(pml_training$classe)

#Data processing

##Adjust Variable Classes
pml_training$classe <- as.factor(pml_training$classe)
pml_training$user_name <- as.factor(pml_training$user_name)
pml_testing$user_name <- as.factor(pml_testing$user_name)

##Deal with NAs
sum(is.na(pml_training)==TRUE) ##Number of NAs, which I need to reduce

library(dplyr)
pml_nas <- pml_training %>%
        is.na() %>%
        as.data.frame()
relevant <- pml_nas[,is.na(summary(pml_nas)[3,])] %>%
        names()

sum(is.na(pml_training[,relevant])==TRUE) ##All variables with NAs are excluded

pml_training <- pml_training[,relevant]
pml_testing <- pml_testing[,relevant]

#Other Model

#Create Training and Testing Set
library(caret)

set.seed(123)
inTrain <- createDataPartition(y = pml_df$X1, p = 0.6, list = FALSE)
pml_training <- pml_df[inTrain,]
pml_testing <- pml_df[-inTrain,]


fitmodel1 <- train(classe ~ total_accel_belt,
                data = pml_training,
                method = "glm",
                family = "binomial") ##Does not work....
pred1 <- predict(fitmodel1, pml_testing)

#Build up a model
library(caret)
fitmodel2 <- train(classe ~ total_accel_belt,
                  data = pml_training,
                  method = "rf")

pred2 <- predict(fitmodel2, pml_testing)  #Only 5 out of 20 are correctly predicted.


###MODEL SELECTION####

init_fit <- glm(classe ~ .,
             family = binomial(link = "probit"), 
             data = pml_training)
best_fit <- step(init_fit, direction = "both")

anova(init_fit, best_fit)

####Predicting with trees####
pml_training <- pml_training[,-1]
pml_testing <- pml_testing[,-1]

modfit <- train(classe ~ .,
                method = "rpart",
                data = pml_training)
print(modfit$finalModel)

library(rattle)
fancyRpartPlot(modfit$finalModel)

pred <- predict(modfit, pml_testing)
acc <- confusionMatrix(pred, pml_testing$classe)

pred <- predict(modfit, pml_pred)


##PreProcess with Caret
#Choose the Variables
preProcess(pml_training[,-c(1, 57)], method="pca" ,thresh=0.9) 
##The outcome variable is variable 57, variable 1 is an ID.



#Expectation of out of sample error

