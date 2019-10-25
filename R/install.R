# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Install azureml sdk package
#' @param version azureml sdk package version
#' @param envname name of environment to create
#' @param conda_python_version version of python for conda environment
#' @param restart_session restart R session after installation
#' @param remove_existing_env delete the conda environment if already exists
#' @export
install_azureml <- function(version = NULL,
                            envname = "r-azureml",
                            conda_python_version = "3.6",
                            restart_session = TRUE,
                            remove_existing_env = FALSE) {
  main_package <- "azureml-sdk"
  default_packages <- c("numpy")

  # set version if provided
  if (!is.null(version)) {
    main_package <- paste(main_package, "==", version, sep = "")
  }

  # check for anaconda installation
  if (is.null(reticulate::conda_binary())) {
    stop("Anaconda not installed or not in system path.")
  }

  # create conda environment
  if (remove_existing_env) {
    envs <- reticulate::conda_list()
    if (envname %in% envs$name) {
      msg <- sprintf(paste("Environment \"%s\" already exists.",
                           "Remove the environment..."),
                     envname)
      message(msg)
      reticulate::conda_remove(envname)
    }

    msg <- paste("Creating environment: ", envname)
    message(msg)
    py_version <- paste("python=", conda_python_version, sep = "")
    reticulate::conda_create(envname, packages = py_version)
  }

  # install packages
  reticulate::py_install(
    packages = c(main_package, default_packages),
    envname = envname,
    method = "conda",
    conda = "auto",
    pip = TRUE)

  cat("\nInstallation complete.\n\n")

  if (restart_session && 
      rstudioapi::isAvailable() && 
      rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()

  invisible(NULL)
}
