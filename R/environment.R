# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Configure the R environment where the experiment is executed.
#' @param name The name of the environment
#' @param version The version of the environment
#' @param environment_variables A dictionary of environment variables names and
#' values.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from
#' local, directory or custom url.
#' @param custom_docker_image The name of the docker image from which the image
#' to use for training will be built. If not set, a default CPU based image will
#' be used as the base image.
#' @param image_registry_details The details of the Docker image registry.
#' @param use_gpu Indicates whether the environment to run the experiment should
#' support GPUs.
#' If TRUE, a GPU - based default Docker image will be used in the environment.
#' If FALSE, a CPU - based image will be used. Default Docker images
#' (CPU orGPU) will be used only if the 'custom_docker_image' parameter is not
#' set.
#' @param shm_size The size of the Docker container's shared memory block.
#' @return the environment object.
#' @export
r_environment <- function(name, version = NULL,
                          environment_variables = NULL,
                          cran_packages = NULL,
                          github_packages = NULL,
                          custom_url_packages = NULL,
                          custom_docker_image = NULL,
                          image_registry_details = NULL,
                          use_gpu = FALSE,
                          shm_size = NULL) {
  env <- azureml$core$Environment(name)
  env$version <- version
  env$python$user_managed_dependencies <- TRUE
  env$environment_variables <- environment_variables
  env$docker$enabled <- TRUE
  env$docker$base_image <- custom_docker_image

  if (!is.null(image_registry_details)) {
    env$docker$base_image_registry <- image_registry_details
  }
  if (!is.null(shm_size)) {
    env$docker$shm_size = shm_size
  }

  if (is.null(custom_docker_image)) {
    processor <- "cpu"
    if (use_gpu) {
      processor <- "gpu"
    }
    env$docker$base_image <- paste("r-base",
                                   processor,
                                   sep = ":")
    env$docker$base_image_registry$address <-
      "viennaprivate.azurecr.io"
  }

  # if extra package is specified, generate dockerfile
  if (!is.null(cran_packages) ||
      !is.null(github_packages) ||
      !is.null(custom_url_packages)) {
    base_image_with_address <- NULL
    registry_address <- env$docker$base_image_registry$address
    if (!is.null(env$docker$base_image_registry$address)) {
      base_image_with_address <- paste(registry_address,
                                       env$docker$base_image,
                                       sep = "/")
    }
    env$docker$base_dockerfile <- generate_docker_file(base_image_with_address,
                                                       cran_packages,
                                                       github_packages,
                                                       custom_url_packages)
    env$docker$base_image <- NULL
  }

  invisible(env)
}

#' Register the environment object in your workspace.
#' @param workspace The workspace
#' @param environment The python environment where the experiment is executed.
#' @export
register_environment <- function(environment, workspace) {
  env <- environment$register(workspace)
  invisible(env)
}

#' Return the environment object.
#' @param workspace The workspace
#' @param name The name of the environment
#' @param version The version of the environment
#' @export
get_environment <- function(workspace, name, version = NULL) {
  azureml$core$Environment$get(workspace, name, version)
}

#' Get Azure Container Registry.
#' @param address DNS name or IP address of azure container registry(ACR)
#' @param username The username for ACR
#' @param password The password for ACR
#' @export
container_registry <- function(address = NULL,
                               username = NULL,
                               password = NULL) {
  container_registry <- azureml$core$ContainerRegistry()
  container_registry$address <- address
  container_registry$username <- username
  container_registry$password <- password

  invisible(container_registry)
}

#' Generate a dockerfile string to build the image for training.
#' @param custom_docker_image The name of the docker image from which the image
#' to use for training will be built. If not set, a default CPU based image will
#' be used as the base image.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from
#' local, directory or custom url.
generate_docker_file <- function(custom_docker_image = NULL,
                                 cran_packages = NULL,
                                 github_packages = NULL,
                                 custom_url_packages = NULL) {
  base_dockerfile <- NULL
  base_dockerfile <- paste0(base_dockerfile, sprintf("FROM %s\n",
                                                    custom_docker_image))

  if (!is.null(cran_packages)) {
    for (package in cran_packages) {
      base_dockerfile <- paste0(
          base_dockerfile,
          sprintf("RUN R -e \"install.packages(\'%s\', ", package),
          "repos = \'http://cran.us.r-project.org\')\"\n")
    }
  }

  if (!is.null(github_packages)) {
    for (package in github_packages) {
      base_dockerfile <- paste0(
          base_dockerfile,
          sprintf("RUN R -e \"devtools::install_github(\'%s\')\"\n", package))
    }
  }

  if (!is.null(custom_url_packages)) {
    for (package in custom_url_packages) {
      base_dockerfile <- paste0(
          base_dockerfile,
          sprintf("RUN R -e \"install.packages(\'%s\', repos = NULL)\"\n", 
                  package))
    }
  }

  invisible(base_dockerfile)
}
