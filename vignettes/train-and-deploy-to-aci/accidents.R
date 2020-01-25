#' Copyright(c) Microsoft Corporation.
#' Licensed under the MIT license.

library(azuremlsdk)
library(optparse)
library(caret)
library(gam)

options <- list(
  make_option(c("-d", "--data_folder"))
)

opt_parser <- OptionParser(option_list = options)
opt <- parse_args(opt_parser)

## Print data folder to log 
paste(opt$data_folder)

accidents <- readRDS(file.path(opt$data_folder, "accidents.Rd"))
summary(accidents)

## Create 75% data partition for use with caret
train.pct <- 0.75
accident_idx <- createDataPartition(accidents$dead, p = train.pct, list = FALSE)
accident_trn <- accidents[accident_idx, ]
accident_tst <- accidents[-accident_idx, ]
## utility function to calculate accuracy in test set
calc_acc = function(actual, predicted) {
  mean(actual == predicted)
}

## Basic GLM model
mod.glm <- glm(dead ~ dvcat + seatbelt + frontal + sex + ageOFocc + yearVeh + airbag  + occRole, 
           family=binomial, 
           data=accident_trn)
summary(mod.glm)
log_metric_to_run("Accuracy-glm",
  calc_acc(actual = accident_tst$dead,
           predicted = factor(ifelse(predict(mod.glm)>0.5, "dead","alive")))
  )


## Caret GLM model on training set with 5-fold cross validation
accident_glm_mod <- train(
  form = dead ~ .,
  data = accident_trn,
  trControl = trainControl(method = "cv", number = 5),
  method = "glm",
  family = "binomial"
)
summary(accident_glm_mod)

log_metric_to_run("Accuracy-caretglm",
  calc_acc(actual = accident_tst$dead,
           predicted = predict(accident_glm_mod, newdata = accident_tst))
)

## Caret KNN model
accident_knn_mod = train(
  dead ~ .,
  data = accident_trn,
  method = "knn",
  trControl = trainControl(method = "cv", number = 5)
)
summary(accident_knn_mod)

log_metric_to_run("Accuracy-caretknn",
  calc_acc(actual = accident_tst$dead,
           predicted = predict(accident_knn_mod, newdata = accident_tst))
)


## GLMNET 
accident_glmnet_mod = train(
  dead ~ .,
  data = accident_trn,
  method = "glmnet"
)
summary(accident_glmnet_mod)

log_metric_to_run("Accuracy-caretknn",
                  calc_acc(actual = accident_tst$dead,
                           predicted = predict(accident_glmnet_mod, newdata = accident_tst))
)


output_dir = "outputs"
if (!dir.exists(output_dir)){
  dir.create(output_dir)
}
saveRDS(mod.glm, file = "./outputs/modelglm.rds")
saveRDS(accident_glm_mod, file = "./outputs/modelcaretglm.rds")
saveRDS(accident_knn_mod, file = "./outputs/modelknn.rds")
saveRDS(accident_glmnet_mod, file = "./outputs/modelglmnet.rds")

message("Models saved")