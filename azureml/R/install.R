#' Create conda environment
#' @param environment_name name of environment to create
create_conda_env <- function(environment_name)
{
  envs <- reticulate::conda_list()
  if (environment_name %in% envs$name)
  {
    message("Using existing r-azureml environment.")
  }
  else
  {
    reticulate::conda_create(environment_name, packages = "python=3.6")
  }
}

#' Install azureml
#' @param version pip version
#' @export
install_azureml <- function(version = NULL, environment_name = "r-azureml")
{
  if (is.null(reticulate::conda_binary()))
  {
    stop("Anaconda not installed or not in system path.")
  }

  package_name = "azureml-sdk"
  if (!is.null(version))
  {
    package_name = paste(package_name, "==", version, sep="")
  }
  # create conda environment
  create_conda_env(environment_name)

  reticulate::conda_install(environment_name, package_name, pip = TRUE)
  reticulate::conda_install(environment_name, "numpy")
}