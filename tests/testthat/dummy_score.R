# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

init <- function()
{
  model <<- readRDS("score.R")
  message("model is loaded")
  
  function(data)
  {
    plant <- as.data.frame(fromJSON(data))
    prediction <- predict(model, plant)
    result <- as.character(prediction)
    toJSON(result)
  }
}