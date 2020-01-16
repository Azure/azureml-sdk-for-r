# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' @importFrom reticulate import py_str

.onLoad <- function(libname, pkgname) {
  # delay load azureml
  azureml <<- import("azureml", delay_load = list(
    environment = "r-azureml",

    on_load = function() {
      # This function will be called on successful load

      # set user agent
      ver <- toString(utils::packageVersion("azuremlsdk"))
      azureml$"_base_sdk_common"$user_agent$append("azureml-r-sdk", ver)

      # override workspace __repr__ from python
      azureml$core$Workspace$"__repr__" <- function(self) {
        sprintf("create_workspace(name=\"%s\", subscription_id=\"%s\", resource_group=\"%s\")", 
          self$"_workspace_name",
          self$"_subscription_id",
          self$"_resource_group")
        }
    },

    on_error = function(e) {
      if (grepl("No module named azureml", e$message)) {
        stop("Use azuremlsdk::install_azureml() to install azureml python ",
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
