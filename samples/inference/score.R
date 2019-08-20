# CAUTION: If init() call failed, the inference launcher will retrying until success
# This results in packages repeatly get installed again and again :( So
# 1) We should check package existence before install
# 2) Have proper error handling in python wrapper is important
install.packages("caret", repos = "http://cran.us.r-project.org")
install.packages("e1071", repos = "http://cran.us.r-project.org")
install.packages("jsonlite", repos = "http://cran.us.r-project.org")
library(jsonlite)
library("azureml")

model <- NULL

init <- function()
{
    # Note: get_model_path is not working properly if source directory is specified in InferenceConfig.
    # azureml$core$model$Model$get_model_path('model.rds')
    # Fired Bug 494437: get_model_path('model.rds') throw execption
    # For POC, use hard-coded path to workaround
    model_path <- "/var/azureml-app/azureml-models/model.rds/1/model.rds"
    model <<- readRDS(model_path)
    message("model is loaded")
}

run <- function(data)
{
    plant <- as.data.frame(fromJSON(data))
    prediction <- predict(model, plant)
    result <- as.character(prediction)

    # object conversion b/w R and python is chanllenge with rpy2
    # returned R data will be converted to a rpy2 vector object in python wrapper however
    # this kind of object is not JSON serializible
    # https://rpy2.readthedocs.io/en/version_2.8.x/robjects_serialization.html
    # Found a workaround online. Althought it's not the best option but it works
    # https://stackoverflow.com/questions/43010705/rpy2-convert-a-r-return-list-vector-to-a-json-object-in-python
    # plumber is the still the long term solution but it requires inference team support
    # also plumber support multiple content types JSON, binary, HTML, etc
    # https://www.rplumber.io/docs/rendering-and-output.html#serializers
    toJSON(result)
}