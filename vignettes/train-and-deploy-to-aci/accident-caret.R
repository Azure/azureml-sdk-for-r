accidents <- readRDS(  file.path(
  "vignettes/train-and-deploy-to-aci", #opt$data_folder, 
  "accidents.Rd"))
summary(accidents)

library(caret)

## Create data partition
train.pct <- 0.75
accident_idx <- createDataPartition(accidents$dead, p = train.pct, list = FALSE)
accident_trn <- accidents[accident_idx, ]
accident_tst <- accidents[-accident_idx, ]
## Utility function for calculating accuracy in test set
calc_acc = function(actual, predicted) {
  mean(actual == predicted)
}


accident_glm_mod <- train(
  form = dead ~ .,
  data = accident_trn,
  trControl = trainControl(method = "cv", number = 5),
  method = "glm",
  family = "binomial"
)

calc_acc(actual = accident_tst$dead,
         predicted = predict(accident_glm_mod, newdata = accident_tst))


## K nearest neighbors model
accident_knn_mod = train(
  dead ~ .,
  data = accident_trn,
  method = "knn",
  trControl = trainControl(method = "cv", number = 5)

  )

calc_acc(actual = accident_tst$dead,
         predicted = predict(accident_knn_mod, newdata = accident_tst))
