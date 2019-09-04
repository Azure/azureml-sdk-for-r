# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Configure the python environment where the experiment is executed.
#' @param name The name of the environment
#' @param version The version of the environment
#' @param environment_variables A dictionary of environment variables names and values.
#' @param r This section specifies which R environment to use on the target compute.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @export
create_environment <- function(name, version = NULL, environment_variables = NULL,
                               r = NULL, cran_packages = NULL, github_packages = NULL,
                               custom_url_packages = NULL, custom_docker_image = NULL)
{
  env <- azureml$core$Environment(name)
  env$version <- version
  
  if(!is.null(environment_variables))
  {
    env$environment_variables <- environment_variables
  }
  
  env$docker$base_dockerfile <- create_docker_file(custom_docker_image, cran_packages,
                                                   github_packages, custom_url_packages)
  env$docker$base_image <- NULL
  
  invisible(env)
}


#' Returns the environment object
#' @param workspace The workspace
#' @param environment The python environment where the experiment is executed.
#' @export
register_environment <- function(environment, workspace)
{
  env <- environment$register(workspace)
  invisible(env)
}

#' Return the environment object.
#' @param workspace The workspace
#' @param name The name of the environment
#' @param version The version of the environment
#' @export
get_environment <- function(workspace, name, version = NULL)
{
  azureml$core$Environment$get(workspace, name, version)
}

#' Return the list of environments in the workspace.
#' @param workspace The workspace
#' @export
list_environments_in_workspace <- function(workspace)
{
  environments <- azureml$core$Environment$list(workspace)
  invisible(environments)
}

#' Create a dockerfile string forto build the image for training.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
create_docker_file <- function(custom_docker_image = NULL, cran_packages = NULL,
                               github_packages = NULL, custom_url_packages = NULL)
{
  base_dockerfile <- NULL
  
  if(!is.null(custom_docker_image))
  {
    base_dockerfile <- paste(base_dockerfile, sprintf("FROM %s\n", custom_docker_image))
  }
  else
  {
    base_dockerfile <- paste(base_dockerfile, "FROM viennaprivate.azurecr.io/r-base:cpu\n")
  }
  
  if (!is.null(cran_packages))
  {
    base_dockerfile <- paste(base_dockerfile, sprintf("install.packages(\"%s\", repos = \"http://cran.us.r-project.org\")\n", cran_packages))
  }
  
  if (!is.null(github_packages))
  {
    base_dockerfile <- paste(base_dockerfile, sprintf("devtools::install_github(\"%s\")\n", github_packages))
  }
  
  if (!is.null(custom_url_packages))
  {
    base_dockerfile <- paste(base_dockerfile, sprintf("install.packages(\"%s\", repos = NULL)\n", custom_url_packages))
  }
  invisible(base_dockerfile)
}
