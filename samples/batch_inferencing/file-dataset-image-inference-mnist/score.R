library(jsonlite)
library(tensorflow)
library(azuremlsdk)


init <- function() {

  numpy <- reticulate::import("numpy")
  PIL <- reticulate::import("PIL")

  model_path <- azureml$core$Model$get_model_path("mnist")
  message(paste0("model path:", model_path))

  saver = tf$train$import_meta_graph(file.path(model_path, 'mnist-tf.model.meta'))
  sess <- tf$Session()
  saver$restore(sess, file.path(model_path, 'mnist-tf.model'))

  message("model is loaded")

  function(mini_batch) {

    message("run method start")

    resultList <- vector()
    in_tensor = sess$graph$get_tensor_by_name("network/X:0")
    output = sess$graph$get_tensor_by_name("network/output/MatMul:0")

    for (image in mini_batch) {
      # load each image
      data <- PIL$Image$open(image)

      # predict
      prediction <- sample(0:9, 1)
      result <- paste(image, " ", prediction)
      resultList <- c(resultList, result)
    }

    toJSON(resultList)
  }
}
