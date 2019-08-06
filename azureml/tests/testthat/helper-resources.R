# can be used across all test files
subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID")
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")
location <- Sys.getenv("TEST_LOCATION")
workspace_name <- Sys.getenv("TEST_WORKSPACE_NAME", unset = "r_test_workspace")
cluster_name <- Sys.getenv("TEST_CLUSTER_NAME", unset = "r-cpu-cluster")

package_url <- Sys.getenv('PACKAGE_LOCATION')

install.packages(package_url, repos = NULL, dep = FALSE, type = "source")

library(azureml)

#install_azureml()

existing_ws <- create_workspace(workspace_name, subscription_id = subscription_id, resource_group = resource_group,
                    location = location)

vm_size <- "STANDARD_D2_V2"
existing_compute <- create_aml_compute(workspace = existing_ws, cluster_name = cluster_name, vm_size = vm_size,
                min_nodes = 0, max_nodes = 1)
wait_for_aml_compute(existing_compute)

