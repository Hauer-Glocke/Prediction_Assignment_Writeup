rm(list = ls())
cat("\f")


library(readr)
pml_training <- read_csv(url("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"))
pml_testing <- read_csv(url(" https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"))