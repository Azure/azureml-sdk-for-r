# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Configure the python environment where the experiment is executed.
#' @param name The name of the environment
#' @param version The version of the environment
#' @param environment_variables A dictionary of environment variables names and values.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param base_image_registry Image registry that contains the base image.
#' @export
create_environment <- function(name, version = NULL, environment_variables = NULL,
                               cran_packages = NULL, github_packages = NULL,
                               custom_url_packages = NULL, custom_docker_image = NULL,
                               base_image_registry = NULL)
{
  env <- azureml$core$Environment(name)
  env$version <- version
  
  if(!is.null(environment_variables))
  {
    env$environment_variables <- environment_variables
  }
  
  env$docker$base_dockerfile <- create_docker_file(custom_docker_image, cran_packages,
                                                   github_packages, custom_url_packages,
                                                   base_image_registry)
  env$docker$base_image <- NULL
  if (!is.null(base_image_registry))
  {
    env$docker$base_image_registry = base_image_registry
  }
  
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

#' Create a dockerfile string to build the image for training.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
#' @param base_image_registry Image registry that contains the base image.
create_docker_file <- function(custom_docker_image = NULL, cran_packages = NULL,
                               github_packages = NULL, custom_url_packages = NULL,
                               base_image_registry = NULL)
{
  base_dockerfile <- NULL
  image_registry_address <- NULL

  if(!is.null(base_image_registry) && !is.null(base_image_registry$address))
  {
    image_registry_address <- base_image_registry$address
  }
  
  if(is.null(custom_docker_image))
  {
    if (is.null(image_registry_address))
    {
      image_registry_address <- "viennaprivate.azurecr.io"
    }
    custom_docker_image <- "r-base:cpu"
  }
  
  if(!is.null(image_registry_address))
  {
    custom_docker_image <- paste(image_registry_address, custom_docker_image, sep = "/")
  }
  
  base_dockerfile <- paste(base_dockerfile, sprintf("FROM %s\n", custom_docker_image), sep = "")

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
