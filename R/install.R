# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Install azureml sdk package
#' @param version azureml sdk package version
#' @param envname name of environment to create, if environment other
#' than default is desired
#' @param conda_python_version version of python for conda environment
#' @param restart_session restart R session after installation
#' @param remove_existing_env delete the conda environment if already exists
#' @return None
#' @export
install_azureml <- function(version = "1.10.0",
                            envname = "r-reticulate",
                            conda_python_version = "3.6",
                            restart_session = TRUE,
                            remove_existing_env = FALSE) {
  main_package <- "azureml-sdk"
  default_packages <- c("numpy", "pandas")

  # set version
  main_package <- paste(main_package, "==", version, sep = "")

  # check for anaconda installation
  if (is.null(reticulate::conda_binary())) {
    stop("Anaconda not installed or not in system path.")
  }

  # remove the conda environment if needed
  envs <- reticulate::conda_list()
  env_exists <- envname %in% envs$name
  if (env_exists && remove_existing_env) {
    msg <- sprintf(paste("Environment \"%s\" already exists.",
                         "Remove the environment..."),
                   envname)
    message(msg)
    reticulate::conda_remove(envname)
    env_exists <- FALSE
  }

  if (!env_exists) {
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
