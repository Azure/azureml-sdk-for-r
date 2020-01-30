#' Copyright(c) Microsoft Corporation.
#' Licensed under the MIT license.

library(jsonlite)

init <- function()
{
  model_path <- Sys.getenv("AZUREML_MODEL_DIR")
  model <- readRDS(file.path(model_path, "model.rds"))
  method <- model$method
  message(paste(method, "model loaded"))
  
  function(data)
  {
    vars <- as.data.frame(fromJSON(data))
    prediction <- predict(model, newdata=vars, type="prob")[,"dead"]
    toJSON(prediction)
  }
}