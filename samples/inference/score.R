library(jsonlite)
library(azureml)

init <- function(model_path)
{
    # get_model_path('model.rds') doesn't work in R session for some reason
    # Fired Bug 494437 for investigation
    # As a workaround, pass in model_path through init()
    model <<- readRDS(model_path)
    message("model is loaded")

    function(data)
    {
        plant <- as.data.frame(fromJSON(data))
        prediction <- predict(model, plant)
        result <- as.character(prediction)

        # object conversion b/w R and python is chanllenge with rpy2
        # returned R data will be converted to a rpy2 vector object in python
        # and this kind of object is not JSON serializible.
        # https://rpy2.readthedocs.io/en/version_2.8.x/robjects_serialization.html

        # The workaround is to convert to JSON in R first althought it's not the best option
        # https://stackoverflow.com/questions/43010705/rpy2-convert-a-r-return-list-vector-to-a-json-object-in-python
        toJSON(result)

        # plumber supports different response type like JSON, binary, HTML, etc
        # so it is definitely the long term solution but it requires support from inference team first
        # https://www.rplumber.io/docs/rendering-and-output.html#serializers
    }
}