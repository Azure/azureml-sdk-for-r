# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' @importFrom reticulate import use_condaenv py_str

.onLoad <- function(libname, pkgname) {
  use_condaenv("r-azureml")
  
  # delay load azureml
  azureml <<- import('azureml', delay_load = list(
    environment = "r-azureml",
    
    on_load = function() {
      # This function will be called on successful load
      ver <- toString(utils::packageVersion("azureml"))
      azureml$"_base_sdk_common"$user_agent$append("azureml-r-sdk", ver)
    },
    
    on_error = function(e) {
      if (grepl("No module named azureml", e$message)) {
        stop("Use azureml::install_azureml() to install azureml python ",
             call. = FALSE)
      } else {
        stop(e$message, call. = FALSE)
      }
    }
  ))

  # for solving login hang issue on rstudio server
  if (grepl("rstudio-server", Sys.getenv("RS_RPOSTBACK_PATH"))) {
    webbrowser <- reticulate::import("webbrowser")
    # this will force to use device code login
    webbrowser$"_tryorder" <- list()
  }

  invisible(NULL)
}
