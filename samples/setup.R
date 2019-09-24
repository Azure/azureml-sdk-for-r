# skip the lines before `subscription_id <- ...` if azureml R package and its python 
# sdk is already installed.
devtools::install_github('https://github.com/Azure/azureml-sdk-for-r')

library(azureml)
install_azureml()

subscription_id <- Sys.getenv("SUBSCRIPTION_ID", unset = "<my-subscription-id>")
resource_group <- Sys.getenv("RESOURCE_GROUP", unset = "<my-resource-group>")
workspace_name <- Sys.getenv("WORKSPACE_NAME", unset = "<my-workspace-name>")
location <- Sys.getenv("WORKSPACE_REGION", unset = "<my-region>")

ws <- create_workspace(name = workspace_name, subscription_id = subscription_id, resource_group = resource_group,
                       location = location, create_resource_group = TRUE, exist_ok = TRUE)
write_workspace_config(ws, path = '.')

