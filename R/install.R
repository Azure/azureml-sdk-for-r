# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Install azureml sdk package
#' @param version pip version
#' @param environment name of environment to create
#' @param conda_python_version version of python for conda environment
#' @export
install_azureml <- function(version = NULL,
                            environment = "r-azureml",
                            conda_python_version = "3.6")
{
  main_package = "azureml-sdk"
  default_packages <- c("numpy")
  
  # set version if provided
  if (!is.null(version))
  {
    main_package = paste(main_package, "==", version, sep="")
  }
  
  # check for anaconda installation
  if (is.null(reticulate::conda_binary()))
  {
    stop("Anaconda not installed or not in system path.")
  }
  
  # create conda environment if missing
  envs <- reticulate::conda_list()
  if (environment %in% envs$name)
  {
    msg = paste("Using existing environment: ", environment)
    message(msg)
  }
  else
  {
    msg = paste("Creating environment: ", environment)
    message(msg)
    reticulate::conda_create(environment, packages = "python=3.6")
  }
  
  # install packages
  reticulate::py_install(
    packages = c(main_package, default_packages),
    environment = environment,
    method = "conda",
    conda = "auto",
    python_version = conda_python_version,
    pip = TRUE)

  cat("\nInstallation complete.\n\n")
  
  if (rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()
  
  invisible(NULL)
  
}
