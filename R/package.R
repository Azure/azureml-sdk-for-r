# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' @importFrom reticulate import py_discover_config py_str

.onLoad <- function(libname, pkgname)
{
  # conda doesnt find the environment if not activated, therefore calling
  # py_discover_config to prepend the conda scripts path to path.
  py_discover_config('azureml', 'r-azureml')
  azureml <<- import('azureml', delay_load = list(
    environment = "r-azureml",
    on_error = function(e) {
      if (grepl("No module named azureml", e$message)) {
        stop("Use azureml::install_azureml() to install azureml python ", call. = FALSE)
      }
      else {
        stop(e$message, call. = FALSE)
      }
    }
  ))

  invisible(NULL)
}
