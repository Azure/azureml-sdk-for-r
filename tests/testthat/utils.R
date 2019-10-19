skip_if_no_azureml <- function() {
  if (!reticulate::py_module_available("azureml"))
    skip("azureml not available for testing")
}