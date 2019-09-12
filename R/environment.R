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
environment <- function(name, version = NULL, environment_variables = NULL,
                        cran_packages = NULL, github_packages = NULL,
                        custom_url_packages = NULL, custom_docker_image = NULL,
                        base_image_registry = NULL)
{
  env <- azureml$core$Environment(name)
  env$version <- version
  env$python$user_managed_dependencies <- TRUE
  
  if(!is.null(environment_variables))
  {
    env$environment_variables <- environment_variables
  }
  
  base_docker_image <- custom_docker_image
  image_registry_address <- NULL

  if(!is.null(base_image_registry) && !is.null(base_image_registry$address))
  {
    image_registry_address <- base_image_registry$address
  }
    
  if(is.null(base_docker_image))
  {
    if (is.null(image_registry_address))
    {
      image_registry_address <- "viennaprivate.azurecr.io"
    }
    base_docker_image <- "r-base:cpu"
  }
    
  if(!is.null(image_registry_address))
  {
    base_docker_image <- paste(image_registry_address, base_docker_image, sep = "/")
  }
  
  # if no package is specified, then use base image instead of building a new one
  if(is.null(cran_packages) && is.null(github_packages) && is.null(custom_url_packages))
  {
    if(is.null(custom_docker_image))
    {
      env$docker$base_image <- "r-base:cpu"
      env$docker$base_image_registry$address <- "viennaprivate.azurecr.io"
    }
    else
    {
      env$docker$base_image <- custom_docker_image
    }
  }
  else
  {
    # generate a dockerfile for the environment
    env$docker$base_dockerfile <- generate_docker_file(base_docker_image, cran_packages,
                                                       github_packages, custom_url_packages)
    env$docker$base_image <- NULL
  }

  if (!is.null(base_image_registry))
  {
    env$docker$base_image_registry = base_image_registry
  }
  
  invisible(env)
}

#' Register the environment object in your workspace.
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

#' Get Azure Container Registry.
#' @param address DNS name or IP address of azure container registry(ACR)
#' @param username The username for ACR
#' @param password The password for ACR
#' @export
container_registry <- function(address = NULL, username = NULL, password = NULL)
{
  container_registry <- azureml$core$ContainerRegistry()
  container_registry$address <- address
  container_registry$username <- username
  container_registry$password <- password
  
  invisible(container_registry)
}

#' Generate a dockerfile string to build the image for training.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
generate_docker_file <- function(custom_docker_image = NULL, cran_packages = NULL,
                                 github_packages = NULL, custom_url_packages = NULL)
{
  base_dockerfile <- NULL
  base_dockerfile <- paste(base_dockerfile, sprintf("FROM %s\n", custom_docker_image), sep = "")

  if (!is.null(cran_packages))
  {
    for (package in cran_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e install.packages(\"%s\", repos = \"http://cran.us.r-project.org\")\n", package), sep = "")
    }
  }
  
  if (!is.null(github_packages))
  {
    for (package in github_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e devtools::install_github(\"%s\")\n", package), sep = "")
    }
  }
  
  if (!is.null(custom_url_packages))
  {
    for (package in custom_url_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e install.packages(\"%s\", repos = NULL)\n", package), sep = "")
    }
  }
  invisible(base_dockerfile)
}
