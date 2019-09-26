# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library(jsonlite)
library(azureml)

init <- function()
{
  model <<- readRDS(Sys.getenv("AZUREML_MODEL_DIR"))
  message("model is loaded")
  
  function(data)
  {
    plant <- as.data.frame(fromJSON(data))
    prediction <- predict(model, plant)
    result <- as.character(prediction)
    toJSON(result)
  }
}