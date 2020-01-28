#' Copyright(c) Microsoft Corporation.
#' Licensed under the MIT license.

library(azuremlsdk)
library(optparse)
library(caret)
library(glmnet)

options <- list(
  make_option(c("-d", "--data_folder")),
  make_option(c("-p", "--percent_train"))
)

opt_parser <- OptionParser(option_list = options)
opt <- parse_args(opt_parser)

## Print data folder to log 
paste(opt$data_folder)

accidents <- readRDS(file.path(opt$data_folder, "accidents.Rd"))
summary(accidents)

## Create data partition for use with caret
train.pct <- as.numeric(opt$percent_train)
if(length(train.pct)==0 || (train.pct<0) || (train.pct>1)) train.pct <- 0.75
accident_idx <- createDataPartition(accidents$dead, p = train.pct, list = FALSE)
accident_trn <- accidents[accident_idx, ]
accident_tst <- accidents[-accident_idx, ]
## utility function to calculate accuracy in test set
calc_acc = function(actual, predicted) {
  mean(actual == predicted)
}

## GLMNET 
accident_glmnet_mod = train(
  dead ~ .,
  data = accident_trn,
  method = "glmnet"
)
summary(accident_glmnet_mod)

log_metric_to_run("Accuracy",
                  calc_acc(actual = accident_tst$dead,
                           predicted = predict(accident_glmnet_mod, newdata = accident_tst))
)
log_metric_to_run("Method","GLMNET")
log_metric_to_run("TrainPCT",train.pct)

output_dir = "outputs"
if (!dir.exists(output_dir)){
  dir.create(output_dir)
}
saveRDS(accident_glmnet_mod, file = "./outputs/model.rds")

message("Model saved")