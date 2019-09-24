# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Upload the data from the local file system to the Azure storage this
#' datastore points to.
#' @param datastore datastore object
#' @param files list of absolute path to files to upload
#' @param relative_root the base path from which is used to determine the path
#' of the files in the file share. For example, if we upload /path/to/file.txt,
#' and we define base path to be /path, when file.txt is uploaded to the file
#' share, it will have the path of /to/file.txt. If target_path is also given,
#' then it will be used as the prefix for the derived path from above. The base
#' path must be a common path of all of the files, otherwise an exception will
#' be thrown, defaults to None, which will find the common path.
#' @param target_path location in the file share to upload the data to, defaults
#' to None, the root
#' @param overwrite overwrites, defaults to FALSE
#' @param show_progress progress of upload in the console, defaults to TRUE
#' @export
upload_files_to_datastore <- function(datastore, files,
                                      relative_root = NULL,
                                      target_path = NULL, 
                                      overwrite = FALSE,
                                      show_progress = TRUE) {
  datastore$upload_files(files,
                         relative_root,
                         target_path,
                         overwrite,
                         show_progress)
  invisible(NULL)
}

#' Upload the data from the local file system to the Azure storage this
#' datastore points to.
#' @param datastore datastore object
upload_files_to_datastore <- function(datastore,
                                      files,
                                      relative_root = NULL,
                                      target_path = NULL, 
                                      overwrite = FALSE,
                                      show_progress = TRUE)
{
  datastore$upload_files(files,
                         relative_root,
                         target_path,
                         overwrite,
                         show_progress)
  invisible(NULL)
}

#' Upload the data from the local file system to the Azure storage this
#' datastore points to.
#' @param datastore datastore object
#' @param src_dir the local directory to upload
#' @param target_path location in the file share to upload the data to, defaults
#' to None, the root
#' @param overwrite overwrites, defaults to FALSE
#' @param show_progress progress of upload in the console, defaults to TRUE
#' @export
upload_to_datastore <- function(datastore,
                                src_dir,
                                target_path = NULL, 
                                overwrite = FALSE,
                                show_progress = TRUE) {
  datastore$upload(src_dir, target_path, overwrite, show_progress)
  invisible(NULL)
}

#' Download the data from the datastore to the local file system
#' @param datastore datastore object
#' @param target_path the local directory to download the file to
#' @param prefix path to the folder in the blob container to download. If set to
#' NULL, will download everything in the blob defaults to NULL
#' @param overwrite overwrite existing file, defaults to FALSE
#' @param show_progress show progress of download in the console, defaults to
#' TRUE
#' @export
download_from_datastore <- function(datastore,
                                    target_path,
                                    prefix = NULL,
                                    overwrite = FALSE,
                                    show_progress = TRUE) {
  datastore$download(target_path,
              prefix = prefix,
              overwrite = overwrite,
              show_progress = show_progress)
  invisible(NULL)
}

#' Get a datastore by name
#' @param workspace The workspace object
#' @param datastore_name The name of the datastore.
#' @return The corresponding datastore for that name.
#' @export
get_datastore <- function(workspace, datastore_name)
{
  azureml$core$Datastore$get(workspace, datastore_name)
}

#' Register an Azure Blob Container to the datastore.
#' You can choose to use SAS Token or Storage Account Key
#' @param workspace The workspace object
#' @param datastore_name The name of the datastore, case insensitive, can only 
#' contain alphanumeric characters and _
#' @param container_name The name of the azure blob container.
#' @param account_name The storage account name.
#' @param sas_token An account SAS token, defaults to NULL.
#' @param account_key A storage account key, defaults to NULL.
#' @param protocol Protocol to use to connect to the blob container. If NULL, 
#' defaults to https.
#' @param endpoint The endpoint of the blob container. If NULL, defaults to 
#' core.windows.net.
#' @param overwrite overwrites an existing datastore. If the datastore does not 
#' exist, it will create one, defaults to FALSE
#' @param create_if_not_exists create the file share if it does not exists, 
#' defaults to FALSE
#' @param skip_validation skips validation of storage keys, defaults to FALSE
#' @param blob_cache_timeout When this blob is mounted, set the cache timeout 
#' to this many seconds. If NULL, defaults to no timeout (i.e. blobs will be 
#' cached for the duration of the job when read).
#' @param grant_workspace_access grants Workspace Managed Identities(MSI) access 
#' to the user storage account, defaults to FALSE This should be set if the 
#' Storage account is in VNET. If set to TRUE, we will use the Workspace MSI 
#' token to grant access to the user storage account. It may take a while for 
#' the granted access to reflect.
#' @param subscription_id The subscription id of the storage account, defaults 
#' to NULL.
#' @param resource_group The resource group of the storage account, defaults 
#' to NULL.
#' @return The blob datastore.
#' @export
register_azure_blob_container_datastore <- function(
                                                workspace, 
                                                datastore_name, 
                                                container_name, 
                                                account_name, 
                                                sas_token = NULL, 
                                                account_key = NULL, 
                                                protocol = NULL, 
                                                endpoint = NULL, 
                                                overwrite = FALSE, 
                                                create_if_not_exists = FALSE, 
                                                skip_validation = FALSE, 
                                                blob_cache_timeout = NULL, 
                                                grant_workspace_access = FALSE, 
                                                subscription_id = NULL, 
                                                resource_group = NULL) {
  azureml$core$Datastore$register_azure_blob_container(
                                 workspace=workspace,
                                 datastore_name=datastore_name,
                                 container_name=container_name,
                                 account_name=account_name,
                                 sas_token=sas_token,
                                 account_key=account_key,
                                 protocol=protocol,
                                 endpoint=endpoint,
                                 overwrite=overwrite,
                                 create_if_not_exists=create_if_not_exists,
                                 skip_validation=skip_validation,
                                 blob_cache_timeout=blob_cache_timeout,
                                 grant_workspace_access=grant_workspace_access,
                                 subscription_id=subscription_id,
                                 resource_group=resource_group)
}

#' Register an Azure File Share to the datastore.
#' You can choose to use SAS Token or Storage Account Key
#' @param workspace The workspace object
#' @param datastore_name The name of the datastore, case insensitive, can only 
#' contain alphanumeric characters and _
#' @param file_share_name The name of the azure file container.
#' @param account_name The storage account name.
#' @param sas_token An account SAS token, defaults to NULL.
#' @param account_key A storage account key, defaults to NULL.
#' @param protocol Protocol to use to connect to the blob container. 
#' If NULL, defaults to https.
#' @param endpoint The endpoint of the blob container. 
#' If NULL, defaults to core.windows.net.
#' @param overwrite overwrites an existing datastore. If the datastore does not 
#' exist, it will create one, defaults to FALSE
#' @param create_if_not_exists create the file share if it does not exists, 
#' defaults to FALSE
#' @param skip_validation skips validation of storage keys, defaults to FALSE
#' @return The file datastore.
#' @export
register_azure_file_share_datastore <- function(workspace, 
                                                datastore_name, 
                                                file_share_name, 
                                                account_name, 
                                                sas_token = NULL, 
                                                account_key = NULL, 
                                                protocol = NULL, 
                                                endpoint = NULL, 
                                                overwrite = FALSE, 
                                                create_if_not_exists = FALSE, 
                                                skip_validation = FALSE) {
  azureml$core$Datastore$register_azure_file_share(
                                     workspace=workspace,
                                     datastore_name=datastore_name,
                                     file_share_name=file_share_name,
                                     account_name=account_name,
                                     sas_token=sas_token,
                                     account_key=account_key,
                                     protocol=protocol,
                                     endpoint=endpoint,
                                     overwrite=overwrite,
                                     create_if_not_exists=create_if_not_exists,
                                     skip_validation=skip_validation)
}

#' Unregisters the datastore. the underlying storage service will not 
#' be deleted.
#' @param datastore datastore object
#' @export
unregister_datastore <- function(datastore) {
  datastore$unregister()
  invisible(NULL)
}