skip_if_no_azureml <- function() {
  if (!reticulate::py_module_available("azureml"))
    skip("azureml not available for testing")
}

skip_if_no_subscription <- function() {
  subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID", unset = NA)
  if (is.na(subscription_id))
    skip("subscription not available for testing")
}