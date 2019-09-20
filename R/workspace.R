# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a new Azure Machine Learning Workspace
#' @param name The new workspace name. Workspace name has to be between
#'  2 and 32 characters of letters and numbers.
#' @param subscription_id The subscription ID of the containing subscription
#' for the new workspace. The parameter is required if the user has access to
#'  more than one subscription.
#' @param resource_group The Azure resource group that is containing the
#' workspace. The parameter defaults to a mutation of the workspace name.
#' @param location The location of the workspace. The parameter defaults to
#' the resource group location. The location has to be a supported region for
#' Azure Machine Learning Services.
#' @param create_resource_group When true the resource group will be created
#' if it doesn't exist.
#' @param friendly_name A friendly name for the workspace that can be displayed
#'  in the UI.
#' @param storage_account An existing storage account in the Azure resource ID
#' format. The storage will be used by the workspace to save run outputs, code,
#'  logs etc. If None a new storage will be created.
#' @param key_vault An existing key vault in the Azure resource ID format.
#' The Key vault will be used by the workspace to store credentials added to
#' the workspace by the users. If None a new key vault will be created.
#' @param app_insights An existing Application Insights in the Azure resource
#' ID format. The Application Insights will be used by the workspace to log
#' webservices events. If None a new Application Insights will be created.
#' @param container_registry An existing Container registery in the Azure
#' resource ID format. The Container registery will be used by the workspace
#' to pull and push both experimentation and webservices images. If None a new
#' Container registery will be created.
#' @param exist_ok If TRUE the method will not fail if the workspace already
#' exists.
#' @param show_output If TRUE the method will print out incremental progress of
#' method.
#'
#' @export
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
    show_output = TRUE)
{
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
                                  show_output = show_output)
  invisible(ws)
}

#' Get an existing workspace
#' @param name The workspace name to get.
#' @param subscription_id The subscription ID to use. The parameter is required
#' if the user has access
#' to more than one subscription.
#' @param resource_group The resource group to use. If NULL the method will
#' search all resource groups in the subscription.
#' @return workspace object
#' @export
get_workspace <- function(name, subscription_id = NULL, resource_group = NULL)
{
    azureml$core$Workspace$get(name, auth = NULL,
                               subscription_id = subscription_id,
                               resource_group = resource_group)
}

#' Load workspace from config
#' @param path Path to the config file or starting directory for search.
#' The parameter defaults to starting the search in the current directory.
#' @export
load_workspace_from_config <- function(path = NULL)
{
  azureml$core$workspace$Workspace$from_config(path)
}

#' Delete workspace
#' @param ws The workspace to delete
#' @export
delete_workspace <- function(ws)
{
    ws$delete()
    invisible(NULL)
}

#' List all workspaces that the user has access to in the specified
#' subscription_id parameter.The list of workspaces can be filtered based on the
#' resource group.
#' @param subscription_id To list workspaces in the specified subscription ID.
#' @param resource_group To list workspaces in the specified resource group.
#' If NULL the method will list all the workspaces within the specified
#' subscription.
#' @export
list_workspaces <- function(subscription_id, resource_group = NULL) {
  azureml$core$workspace$Workspace$list(subscription_id, resource_group)
}

#' Write out the Workspace ARM properties to a config file
#' @param ws The workspace whose config has to be written down.
#' @param path User provided location to write the config.json file.
#' The parameter defaults to the current working directory.
#' @param file_name Name to use for the config file. The parameter defaults to
#' config.json.
#' @export
write_workspace_config <- function(ws, path = NULL, file_name = NULL) {
  ws$write_config(path, file_name)
}

#' Get default datastore associated with a workspace
#' @param ws workspace object
#' @export
get_default_datastore <- function(ws) {
  ws$get_default_datastore()
}
