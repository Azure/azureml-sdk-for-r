# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a new Azure Machine Learning workspace
#'
#' @description
#' Create a new Azure Machine Learning workspace. Throws an exception if the
#' workspace already exists or any of the workspace requirements are not
#' satisfied. When you create new workspace, it automatically creates several
#' Azure resources that are used in the workspace:
#'
#' * Azure Container Registry: Registers Docker containers that you use during
#'   training and when you deploy a model. To minimize costs, ACR is
#'   lazy-loaded until deployment images are created.
#' * Azure Storage account: Used as the default datastore for the workspace.
#' * Azure Application Insights: Stores monitoring information about your
#'   models.
#' * Azure Key Vault: Stores secrets that are used by compute targets and other
#'   sensitive information that's needed by the workspace.
#' @param name A string of the new workspace name. Workspace name has to be
#' between 2 and 32 characters of letters and numbers.
#' @param subscription_id A string of the subscription ID of the containing
#' subscription for the new workspace. The parameter is required if the user has
#' access to more than one subscription.
#' @param resource_group A string of the Azure resource group that is containing
#' the workspace. The parameter defaults to a mutation of the workspace name.
#' @param location A string of the location of the workspace. The parameter
#' defaults to the resource group location. The location has to be a supported
#' region for Azure Machine Learning Services.
#' @param create_resource_group If `TRUE` the resource group will be created
#' if it doesn't exist.
#' @param friendly_name A string of the friendly name for the workspace that
#' can be displayed in the UI.
#' @param storage_account A string of an existing storage account in the Azure
#' resource ID format. The storage will be used by the workspace to save run
#' outputs, code, logs etc. If `NULL` a new storage will be created.
#' @param key_vault A string of an existing key vault in the Azure resource ID
#' format. The key vault will be used by the workspace to store credentials
#' added to the workspace by the users. If `NULL` a new key vault will be
#' created.
#' @param app_insights A string of an existing Application Insights in the Azure
#' resource ID format. The Application Insights will be used by the workspace to
#' log webservices events. If `NULL` a new Application Insights will be created.
#' @param container_registry A string of an existing container registry in the
#' Azure resource ID format. The container registry will be used by the
#' workspace to pull and push both experimentation and webservices images. If
#' `NULL` a new container registry will be created.
#' @param exist_ok If `TRUE` the method will not fail if the workspace already
#' exists.
#' @param show_output If `TRUE` the method will print out incremental progress
#' of method.
#' @param sku A string indicating if the workspace will be "basic" or
#' "enterprise" edition.
#' @return The `Workspace` object.
#' @export
#' @examples
#' # This example requires only minimal specification, and all dependent
#' # resources as well as the resource group will be created automatically.
#' \dontrun{
#' ws <- create_workspace(name = 'myworkspace',
#'                        subscription_id = '<azure-subscription-id>',
#'                        resource_group = 'myresourcegroup',
#'                        location = 'eastus2')
#' }
#'
#' # This example shows how to reuse existing Azure resources by making
#' # use of all parameters utilizing the Azure resource ID format. The specific
#' # Azure resource IDs can be retrieved through the Azure Portal or SDK. This
#' # assumes that the resource group, storage account, key vault, App Insights
#' # and container registry already exist
#' \dontrun{
#' prefix = "subscriptions/<azure-subscription-id>/resourcegroups/myresourcegroup/providers/"
#' ws <- create_workspace(
#'        name = 'myworkspace',
#'        subscription_id = '<azure-subscription-id>',
#'        resource_group = 'myresourcegroup',
#'        create_resource_group = FALSE,
#'        location = 'eastus2',
#'        friendly_name = 'My workspace',
#'        storage_account = paste0(prefix, 'microsoft.storage/storageaccounts/mystorageaccount'),
#'        key_vault = paste0(prefix, 'microsoft.keyvault/vaults/mykeyvault'),
#'        app_insights = paste0(prefix, 'microsoft.insights/components/myappinsights'),
#'        container_registry = paste0(
#'          prefix,
#'          'microsoft.containerregistry/registries/mycontainerregistry'))
#' }
#' @md
create_workspace <- function(
  name,
  subscription_id = NULL,
  resource_group = NULL,
  location = NULL,
  create_resource_group = TRUE,
  friendly_name = NULL,
  storage_account = NULL,
  key_vault = NULL,
  app_insights = NULL,
  container_registry = NULL,
  exist_ok = FALSE,
  show_output = TRUE,
  sku = "basic") {
  ws <-
    azureml$core$Workspace$create(name = name,
                                  subscription_id = subscription_id,
                                  resource_group = resource_group,
                                  location = location,
                                  create_resource_group = create_resource_group,
                                  friendly_name = friendly_name,
                                  storage_account = storage_account,
                                  key_vault = key_vault,
                                  app_insights = app_insights,
                                  container_registry = container_registry,
                                  exist_ok = exist_ok,
                                  show_output = show_output,
                                  sku = sku)
  invisible(ws)
}

#' Get an existing workspace
#'
#' @description
#' Returns a `Workspace` object for an existing Azure Machine Learning
#' workspace. Throws an exception if the workpsace doesn't exist or the
#' required fields don't lead to a uniquely identifiable workspace.
#' @param name A string of the workspace name to get.
#' @param subscription_id A string of the subscription ID to use. The parameter
#' is required if the user has access to more than one subscription.
#' @param resource_group A string of the resource group to use. If `NULL` the
#' method will search all resource groups in the subscription.
#' @return The `Workspace` object.
#' @export
#' @md
get_workspace <- function(name, subscription_id = NULL, resource_group = NULL) {
  tryCatch({
    azureml$core$Workspace$get(name, auth = NULL,
                               subscription_id = subscription_id,
                               resource_group = resource_group)
  },
  error = function(e) {
    if (grepl("No workspaces found with name=", e$message, )) {
      NULL
    } else {
      stop(message(e))
    }
  })
}

#' Load workspace configuration details from a config file
#'
#' @description
#' Returns a `Workspace` object for an existing Azure Machine Learning
#' workspace by reading the workspace configuration from a file. The method
#' provides a simple way of reusing the same workspace across multiple files or
#' projects. Users can save the workspace ARM properties using
#' `write_workspace_config()`, and use this method to load the same workspace
#' in different files or projects without retyping the workspace ARM properties.
#' @param path A string of the path to the config file or starting directory
#' for search. The parameter defaults to starting the search in the current
#' directory.
#' @param file_name A string that will override the config file name to
#' search for when path is a directory path.
#' @return The `Workspace` object.
#' @export
#' @md
load_workspace_from_config <- function(path = NULL, file_name = NULL) {
  azureml$core$workspace$Workspace$from_config(path = path,
                                               "_file_name" = file_name)
}

#' Delete a workspace
#'
#' @description
#' Delete the Azure Machine Learning workspace resource. `delete_workspace()`
#' can also delete the workspace's associated resources.
#' @param workspace The `Workspace` object of the workspace to delete.
#' @param delete_dependent_resources If `TRUE` the workspace's associated
#' resources, i.e. ACR, storage account, key value, and application insights
#' will also be deleted.
#' @param no_wait If `FALSE` do not wait for the workspace deletion to complete.
#' @return None
#' @export
#' @md
delete_workspace <- function(workspace,
                             delete_dependent_resources = FALSE,
                             no_wait = FALSE) {
  workspace$delete(delete_dependent_resources, no_wait)
  invisible(NULL)
}

#' List all workspaces that the user has access to in a subscription ID
#'
#' @description
#' List all workspaces that the user has access to in the specified
#' `subscription_id` parameter. The list of workspaces can be filtered
#' based on the resource group.
#' @param subscription_id A string of the specified subscription ID to
#' list the workspaces in.
#' @param resource_group A string of the specified resource group to list
#' the workspaces. If `NULL` the method will list all the workspaces within
#' the specified subscription in.
#' @return A named list of `Workspace` objects where element name corresponds
#' to the workspace name.
#' @export
#' @md
list_workspaces <- function(subscription_id, resource_group = NULL) {
  azureml$core$workspace$Workspace$list(subscription_id, resource_group)
}

#' Write out the workspace configuration details to a config file
#'
#' @description
#' Write out the workspace ARM properties to a config file. Workspace ARM
#' properties can be loaded later using `load_workspace_from_config()`.
#' The method provides a simple way of reusing the same workspace across
#' multiple files or projects. Users can save the workspace ARM properties
#' using this function, and use `load_workspace_from_config()` to load the
#' same workspace in different files or projects without retyping the
#' workspace ARM properties.
#' @param workspace The `Workspace` object whose config has to be written down.
#' @param path A string of the location to write the config.json file.
#' The parameter defaults to the current working directory.
#' @param file_name A string of the name to use for the config file. The
#' parameter defaults to `'config.json'`.
#' @return None
#' @export
#' @md
write_workspace_config <- function(workspace, path = NULL, file_name = NULL) {
  workspace$write_config(path, file_name)
  invisible(NULL)
}

#' Get the default datastore for a workspace
#'
#' @description
#' Returns the default datastore associated with the workspace.
#'
#' When you create a workspace, an Azure blob container and Azure file share
#' are registered to the workspace with the names `workspaceblobstore` and
#' `workspacefilestore`, respectively. They store the connection information
#' of the blob container and the file share that is provisioned in the storage
#' account attached to the workspace. The `workspaceblobstore` is set as the
#' default datastore, and remains the default datastore unless you set a new
#' datastore as the default with `set_default_datastore()`.
#' @param workspace The `Workspace` object.
#' @return The default `Datastore` object.
#' @export
#' @examples
#' # Get the default datastore for the datastore
#' \dontrun{
#' ws <- load_workspace_from_config()
#' ds <- get_default_datastore(ws)
#' }
#'
#' # If you have not changed the default datastore for the workspace, the
#' # following code will return the same datastore object as the above
#' # example
#' \dontrun{
#' ws <- load_workspace_from_config()
#' ds <- get_datastore(ws, datastore_name = 'workspaceblobstore')
#' }
#' @md
get_default_datastore <- function(workspace) {
  workspace$get_default_datastore()
}

#' Get the default keyvault for a workspace
#'
#' @description
#' Returns a `Keyvault` object representing the default
#' [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview)
#' associated with the workspace.
#' @param workspace The `Workspace` object.
#' @return The `Keyvault` object.
#' @export
#' @seealso
#' `set_secrets()`, `get_secrets()`, `list_secrets()`, `delete_secrets()`
#' @md
get_default_keyvault <- function(workspace) {
  workspace$get_default_keyvault()
}

#' Get the details of a workspace
#'
#' @description
#' Returns the details of the workspace.
#' @param workspace The `Workspace` object.
#' @return workspace details as data frame.
#' @export
#' @section Details:
#' The returned list contains the following named elements:
#' * *id*: URI pointing to the workspace resource, containing subscription ID,
#' resource group, and workspace name.
#' * *name*: Workspace name.
#' * *location*: Workspace region.
#' * *type*: URI of the format `"{providerName}/workspaces"`.
#' * *workspaceid*: Workspace ID.
#' * *description*: Workspace description.
#' * *friendlyName*: Workspace friendly name.
#' * *creationTime*: Time the workspace was created, in ISO8601.
#' * *containerRegistry*: Workspace container registry.
#' * *keyVault*: Workspace key vault.
#' * *applicationInsights*: Workspace App Insights.
#' * *identityPrincipalId*: Workspace identity principal ID.
#' * *identityTenantId*: Workspace tenant ID.
#' * *identityType*: Workspace identity type.
#' * *storageAccount*: Workspace storage account.
#' @md
get_workspace_details <- function(workspace) {
  details <- workspace$get_details()
  as.data.frame(details)
}

#' Set the default datastore for a workspace
#'
#' @description
#' Set the default datastore associated with the workspace.
#' @param workspace The `Workspace` object.
#' @param datastore_name The name of the datastore to be set as default.
#' @return None
#' @export
#' @md
set_default_datastore <- function(workspace, datastore_name) {
  workspace$set_default_datastore(datastore_name)
  invisible(NULL)
}
