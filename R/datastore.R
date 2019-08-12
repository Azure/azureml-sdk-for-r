#' Set datastore to download mode
#' @param ds datastore object
#' @export
set_datastore_to_download <- function(ds)
{
  ds$as_download()
  invisible(ds)
}

#' Set datastore to mount mode
#' @param ds datastore object
#' @export
set_datastore_to_mount <- function(ds)
{
  ds$as_mount()
  invisible(ds)
}


#' Upload the data from the local file system to the file share this datastore points to.
#' @param ds datastore object
#' @param files list of absolute path to files to upload
#' @param relative_root the base path from which is used to determine the path
#' of the files in the file share. For example, if we upload /path/to/file.txt, and we define
#' base path to be /path, when file.txt is uploaded to the file share, it will have
#' the path of /to/file.txt. If target_path is also given, then it will be used as
#' the prefix for the derived path from above. The base path must be a common path of
#' all of the files, otherwise an exception will be thrown, defaults to None, which will find
#' the common path.
#' @param target_path location in the file share to upload the data to, defaults to None, the root
#' @param overwrite overwrites, defaults to FALSE
#' @param show_progress progress of upload in the console, defaults to TRUE
#' @export
upload_files_to_azure_datastore <- function(ds, files, relative_root = NULL, target_path = NULL, overwrite = FALSE,
                                            show_progress = TRUE)
{
  ds$upload_files(files, relative_root, target_path, overwrite, show_progress)
  invisible(NULL)
}

#' Download the data from the datastore to the local file system
#' @param ds datastore object
#' @param target_path the local directory to download the file to
#' @param prefix path to the folder in the blob container to
#' download. If set to NULL, will download everything in the blob defaults to NULL
#' @param overwrite overwrite existing file, defaults to FALSE
#' @param show_progress show progress of download in the console, defaults to TRUE
#' @export
download_from_datastore <- function(ds, target_path, prefix = NULL, overwrite = FALSE, show_progress = TRUE)
{
  ds$download(target_path, prefix = prefix, overwrite = overwrite, show_progress = show_progress)
  invisible(NULL)
}