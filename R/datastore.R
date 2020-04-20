# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Upload files to the Azure storage a datastore points to
#'
#' @description
#' Upload the data from the local file system to the Azure storage that the
#' datastore points to.
#' @param datastore The `AzureBlobDatastore` or `AzureFileDatastore` object.
#' @param files A character vector of the absolute path to files to upload.
#' @param relative_root A string of the base path from which is used to
#' determine the path of the files in the Azure storage. For example, if
#' we upload `/path/to/file.txt`, and we define the base path to be `/path`,
#' when `file.txt` is uploaded to the blob storage or file share, it will
#' have the path of `/to/file.txt`. If `target_path` is also given, then it
#' will be used as the prefix for the derived path from above. The base path
#' must be a common path of all of the files, otherwise an exception will be
#' thrown.
#' @param target_path A string of the location in the blob container or file
#' share to upload the data to. Defaults to `NULL`, in which case the data is
#' uploaded to the root.
#' @param overwrite If `TRUE`, overwrites any existing data at `target_path`.
#' @param show_progress If `TRUE`, show progress of upload in the console.
#' @return The `DataReference` object for the target path uploaded.
#' @export
#' @md
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

#' Upload a local directory to the Azure storage a datastore points to
#'
#' @description
#' Upload a local directory to the Azure storage the datastore points to.
#' @param datastore The `AzureBlobDatastore` or `AzureFileDatastore` object.
#' @param src_dir A string of the local directory to upload.
#' @param target_path A string of the location in the blob container or
#' file share to upload the data to. Defaults to `NULL`, in which case the data
#' is uploaded to the root.
#' @param overwrite If `TRUE`, overwrites any existing data at `target_path`.
#' @param show_progress If `TRUE`, show progress of upload in the console.
#' @return The `DataReference` object for the target path uploaded.
#' @export
#' @md
upload_to_datastore <- function(datastore,
                                src_dir,
                                target_path = NULL,
                                overwrite = FALSE,
                                show_progress = TRUE) {
  datastore$upload(src_dir, target_path, overwrite, show_progress)
  invisible(NULL)
}

#' Download data from a datastore to the local file system
#'
#' @description
#' Download data from the datastore to the local file system.
#' @param datastore The `AzureBlobDatastore` or `AzureFileDatastore` object.
#' @param target_path A string of the local directory to download the file to.
#' @param prefix A string of the path to the folder in the blob container
#' or file store to download. If `NULL`, will download everything in the blob
#' container or file share
#' @param overwrite If `TRUE`, overwrites any existing data at `target_path`.
#' @param show_progress If `TRUE`, show progress of upload in the console.
#' @return An integer of the number of files successfully downloaded.
#' @export
#' @md
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

#' Get an existing datastore
#'
#' @description
#' Get the corresponding datastore object for an existing
#' datastore by name from the given workspace.
#' @param workspace The `Workspace` object.
#' @param datastore_name A string of the name of the datastore.
#' @return The `azureml.data.azure_sql_database.AzureBlobDatastore`,
#' `azureml.data.azure_sql_database.AzureFileDatastore`,
#' `azureml.data.azure_sql_database.AzureSqlDatabaseDatastore`,
#' `azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore`,
#' `azureml.data.azure_postgre_sql_datastore.AzurePostgreSqlDatastore`, or
#' `azureml.data.azure_sql_database.AzureSqlDatabaseDatastore` object.
#' @export
#' @md
get_datastore <- function(workspace, datastore_name) {
  azureml$core$Datastore$get(workspace, datastore_name)
}

#' Register an Azure blob container as a datastore
#'
#' @description
#' Register an Azure blob container as a datastore. You can choose to use
#' either the SAS token or the storage account key.
#' @param workspace The `Workspace` object.
#' @param datastore_name A string of the name of the datastore. The name
#' must be case insensitive and can only contain alphanumeric characters and
#' underscores.
#' @param container_name A string of the name of the Azure blob container.
#' @param account_name A string of the storage account name.
#' @param sas_token A string of the account SAS token.
#' @param account_key A string of the storage account key.
#' @param protocol A string of the protocol to use to connect to the
#' blob container. If `NULL`, defaults to `'https'`.
#' @param endpoint A string of the endpoint of the blob container.
#' If `NULL`, defaults to `'core.windows.net'`.
#' @param overwrite If `TRUE`, overwrites an existing datastore. If
#' the datastore does not exist, it will create one.
#' @param create_if_not_exists If `TRUE`, creates the blob container
#' if it does not exists.
#' @param skip_validation If `TRUE`, skips validation of storage keys.
#' @param blob_cache_timeout An integer of the cache timeout in seconds
#' when this blob is mounted. If `NULL`, defaults to no timeout (i.e.
#' blobs will be cached for the duration of the job when read).
#' @param grant_workspace_access If `TRUE`, grants workspace Managed Identities
#' (MSI) access to the user storage account. This should be set to `TRUE` if the
#' storage account is in VNET. If `TRUE`, Azure ML will use the workspace MSI
#' token to grant access to the user storage account. It may take a while for
#' the granted access to reflect.
#' @param subscription_id A string of the subscription id of the storage
#' account.
#' @param resource_group A string of the resource group of the storage account.
#' @return The `AzureBlobDatastore` object.
#' @export
#' @section Details:
#' In general we recommend Azure Blob storage over Azure File storage. Both
#' standard and premium storage are available for blobs. Although more
#' expensive, we suggest premium storage due to faster throughput speeds that
#' may improve the speed of your training runs, particularly if you train
#' against a large dataset.
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' ds <- register_azure_blob_container_datastore(ws,
#'                                               datastore_name = 'mydatastore',
#'                                               container_name = 'myazureblobcontainername',
#'                                               account_name = 'mystorageaccoutname',
#'                                               account_key = 'mystorageaccountkey')
#' }
#' @md
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
                              workspace = workspace,
                              datastore_name = datastore_name,
                              container_name = container_name,
                              account_name = account_name,
                              sas_token = sas_token,
                              account_key = account_key,
                              protocol = protocol,
                              endpoint = endpoint,
                              overwrite = overwrite,
                              create_if_not_exists = create_if_not_exists,
                              skip_validation = skip_validation,
                              blob_cache_timeout = blob_cache_timeout,
                              grant_workspace_access = grant_workspace_access,
                              subscription_id = subscription_id,
                              resource_group = resource_group)
}

#' Register an Azure file share as a datastore
#'
#' @description
#' Register an Azure file share as a datastore. You can choose to use
#' either the SAS token or the storage account key.
#' @param workspace The `Workspace` object.
#' @param datastore_name A string of the name of the datastore. The name
#' must be case insensitive and can only contain alphanumeric characters and
#' underscores.
#' @param file_share_name A string of the name of the Azure file share.
#' @param account_name A string of the storage account name.
#' @param sas_token A string of the account SAS token.
#' @param account_key A string of the storage account key.
#' @param protocol A string of the protocol to use to connect to the
#' file store. If `NULL`, defaults to `'https'`.
#' @param endpoint A string of the endpoint of the file store.
#' If `NULL`, defaults to `'core.windows.net'`.
#' @param overwrite If `TRUE`, overwrites an existing datastore. If
#' the datastore does not exist, it will create one.
#' @param create_if_not_exists If `TRUE`, creates the file share
#' if it does not exists.
#' @param skip_validation If `TRUE`, skips validation of storage keys.
#' @return The `AzureFileDatastore` object.
#' @export
#' @section Details:
#' In general we recommend Azure Blob storage over Azure File storage. Both
#' standard and premium storage are available for blobs. Although more
#' expensive, we suggest premium storage due to faster throughput speeds that
#' may improve the speed of your training runs, particularly if you train
#' against a large dataset.
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' ds <- register_azure_file_share_datastore(ws,
#'                                           datastore_name = 'mydatastore',
#'                                           file_share_name = 'myazurefilesharename',
#'                                           account_name = 'mystorageaccoutname',
#'                                           account_key = 'mystorageaccountkey')
#' }
#' @md
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
                                  workspace = workspace,
                                  datastore_name = datastore_name,
                                  file_share_name = file_share_name,
                                  account_name = account_name,
                                  sas_token = sas_token,
                                  account_key = account_key,
                                  protocol = protocol,
                                  endpoint = endpoint,
                                  overwrite = overwrite,
                                  create_if_not_exists = create_if_not_exists,
                                  skip_validation = skip_validation)
}

#' Unregister a datastore from its associated workspace
#'
#' @description
#' Unregister the datastore from its associated workspace. The
#' underlying Azure storage will not be deleted.
#' @param datastore The `AzureBlobDatastore` or `AzureFileDatastore` object.
#' @return None
#' @export
#' @md
unregister_datastore <- function(datastore) {
  datastore$unregister()
  invisible(NULL)
}

#' Initialize a new Azure SQL database Datastore.
#'
#' @description
#' Initialize a new Azure SQL database Datastore.
#'
#' @param workspace The workspace this datastore belongs to.
#' @param datastore_name The datastore name.
#' @param server_name The SQL server name.
#' @param database_name The SQL database name.
#' @param tenant_id The Directory ID/Tenant ID of the service principal.
#' @param client_id The Client ID/Application ID of the service principal.
#' @param client_secret The secret of the service principal.
#' @param resource_url The resource URL, which determines what operations will
#' be performed on the SQL database store, if NULL, defaults to
#' https://database.windows.net/.
#' @param authority_url The authority URL used to authenticate the user, defaults
#' to https://login.microsoftonline.com.
#' @param endpoint The endpoint of the SQL server. If NULL, defaults to
#' database.windows.net.
#' @param overwrite Whether to overwrite an existing datastore. If the datastore does
#' not exist, it will create one. The default is FALSE.
#' @param username The username of the database user to access the database.
#' @param password The password of the database user to access the database.
#' @return The `azureml.data.azure_sql_database_datastore.AzureSqlDatabaseDatastore`
#' object.
#' @export
#' @md
register_azure_sql_database_datastore <- function(workspace, datastore_name,
                                                  server_name, database_name,
                                                  tenant_id, client_id,
                                                  client_secret,
                                                  resource_url = NULL,
                                                  authority_url = NULL,
                                                  endpoint = NULL,
                                                  overwrite = FALSE,
                                                  username = NULL,
                                                  password = NULL) {
  azureml$core$Datastore$register_azure_sql_database(workspace,
                                                     datastore_name,
                                                     server_name,
                                                     database_name,
                                                     tenant_id,
                                                     client_id,
                                                     client_secret,
                                                     resource_url,
                                                     authority_url,
                                                     endpoint,
                                                     overwrite,
                                                     username,
                                                     password)
}

#' Initialize a new Azure PostgreSQL Datastore.
#'
#' @description
#' Initialize a new Azure PostgreSQL Datastore.
#'
#' @param workspace The workspace this datastore belongs to.
#' @param datastore_name The datastore name.
#' @param server_name The PostgreSQL server name.
#' @param database_name The PostgreSQL database name.
#' @param user_id The User ID of the PostgreSQL server.
#' @param user_password The User Password of the PostgreSQL server.
#' @param port_number The Port Number of the PostgreSQL server.
#' @param endpoint The endpoint of the PostgreSQL server. If NULL, defaults to
#' postgres.database.azure.com.
#' @param overwrite Whether to overwrite an existing datastore. If the datastore
#' does not exist, it will create one. The default is FALSE.
#' @return The `azureml.data.azure_postgre_sql_datastore.AzurePostgreSqlDatastore`
#' object.
#' @export
#' @md
register_azure_postgre_sql_datastore <- function(workspace, datastore_name,
                                                 server_name, database_name,
                                                 user_id, user_password,
                                                 port_number = NULL,
                                                 endpoint = NULL,
                                                 overwrite = FALSE) {
  azureml$core$Datastore$register_azure_postgre_sql(workspace,
                                                    datastore_name,
                                                    server_name,
                                                    database_name,
                                                    user_id,
                                                    user_password,
                                                    port_number,
                                                    endpoint,
                                                    overwrite)
}

#' Initialize a new Azure Data Lake Gen2 Datastore.
#'
#' @description
#' Initialize a new Azure Data Lake Gen2 Datastore.
#'
#' @param workspace The workspace this datastore belongs to.
#' @param datastore_name The datastore name.
#' @param filesystem The name of the Data Lake Gen2 filesystem.
#' @param account_name The storage account name.
#' @param tenant_id The Directory ID/Tenant ID of the service principal.
#' @param client_id The Client ID/Application ID of the service principal.
#' @param client_secret The secret of the service principal.
#' @param resource_url The resource URL, which determines what operations will be
#' performed on the data lake store, defaults to https://storage.azure.com/ which
#' allows us to perform filesystem operations.
#' @param authority_url The authority URL used to authenticate the user, defaults to
#' "https://login.microsoftonline.com".
#' @param protocol Protocol to use to connect to the blob container. If None,
#' defaults to "https".
#' @param endpoint The endpoint of the blob container. If None, defaults to
#' "core.windows.net".
#' @param overwrite Whether to overwrite an existing datastore. If the datastore
#' does not exist, it will create one. The default is FALSE.
#' @return The `azureml.data.azure_data_lake_datastore.AzureDataLakeGen2Datastore`
#' object.
#' @section Examples:
#' ```r
#' # Create and register an Azure Data Lake Gen2 Datastore to a workspace.
#'
#' my_adlsgen2_ds <- register_azure_data_lake_gen2_datastore(workspace = your_workspace,
#'                                                           datastore_name = <name for this datastore>,
#'                                                           filesystem = 'test',
#'                                                           tenant_id = your_workspace$auth$tenant_id,
#'                                                           client_id = your_workspace$auth$service_principal_id,
#'                                                           client_secret = your_workspace$auth$service_principal_password)
#' ```
#' @seealso [unregister_datastore()], [get_datastore()]
#' @md
register_azure_data_lake_gen2_datastore <- function(workspace, datastore_name,
                                                    filesystem, account_name,
                                                    tenant_id, client_id,
                                                    client_secret,
                                                    resource_url = NULL,
                                                    authority_url = NULL,
                                                    protocol = NULL,
                                                    endpoint = NULL,
                                                    overwrite = FALSE) {
  azureml$core$Datastore$register_azure_data_lake_gen2(workspace,
                                                       datastore_name,
                                                       filesystem, account_name,
                                                       tenant_id, client_id,
                                                       client_secret,
                                                       resource_url,
                                                       authority_url, protocol,
                                                       endpoint, overwrite)
}
