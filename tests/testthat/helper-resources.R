# can be used across all test files
subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID", unset = NA)
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")
location <- Sys.getenv("TEST_LOCATION")
workspace_name <- Sys.getenv("TEST_WORKSPACE_NAME", unset = "r_sdk_workspace")
cluster_name <- Sys.getenv("TEST_CLUSTER_NAME", unset = "r-cluster-cpu")
test_env <- paste0('test_', as.integer(Sys.time()))
build_num <- Sys.getenv('TEST_BUILD_NUMBER')
build_num <- gsub('[.]', '-', build_num)


library(azuremlsdk)
library(ggplot2)

if (!is.na(subscription_id)) {
  if (is.na(Sys.getenv("AZUREML_PYTHON_INSTALLED", unset = NA))) {
      install_azureml()
  }
  
  existing_ws <- create_workspace(workspace_name,
                                  subscription_id = subscription_id,
                                  resource_group = resource_group,
                                  location = location,
                                  exist_ok = TRUE)
  
  existing_compute <- get_compute(workspace = existing_ws,
                                  cluster_name = cluster_name)
  if (is.null(existing_compute)) {
    vm_size <- "STANDARD_D2_V2"
    existing_compute <- create_aml_compute(workspace = existing_ws,
                                           cluster_name = cluster_name, 
                                           vm_size = vm_size,
                                           min_nodes = 0,
                                           max_nodes = 1)
    wait_for_provisioning_completion(existing_compute)
  }
}
