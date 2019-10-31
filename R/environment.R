# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an environment
#'
#' @description
#' Configure the R environment to be used for training or web service
#' deployments. When you submit a run or deploy a model, Azure ML builds a
#' Docker image and creates a conda environment with your specifications from
#' your `Environment` object within that Docker container.
#'
#' If the `custom_docker_image` parameter
#' is not set, Azure ML will build a predefined base image (CPU or GPU
#' depending on the `use_gpu` flag) and install any R packages specified in the
#' `cran_packages`, `github_packages`, or `custom_url_packages` parameters.
#' @param name A string of the name of the environment.
#' @param version A string of the version of the environment.
#' @param environment_variables A named list of environment variables names
#' and values. These environment variables are set on the process where the user
#' script is being executed.
#' @param cran_packages A character vector of CRAN packages to be installed.
#' @param github_packages A character vector of GitHub packages to be installed.
#' @param custom_url_packages A character vector of packages to be installed
#' from local directory or custom URL.
#' @param custom_docker_image A string of the name of the Docker image from
#' which the image to use for training or deployment will be built. If not set,
#' a predefined Docker image will be used. To use an image from a private Docker
#' repository, you will also have to specify the `image_registry_details` parameter.
#' @param image_registry_details A `ContainerRegistry` object of the details of
#' the Docker image registry for the custom Docker image.
#' @param use_gpu Indicates whether the environment should support GPUs.
#' If `TRUE`, a predefined GPU-based Docker image will be used in the environment.
#' If `FALSE`, a predefined CPU-based image will be used. Predefined Docker images
#' (CPU or GPU) will only be used if the `custom_docker_image` parameter is not set.
#' @param shm_size A string for the size of the Docker container's shared
#' memory block. For more information, see
#' [Docker run reference](https://docs.docker.com/engine/reference/run/)
#' If not set, a default value of `'2g'` is used.
#' @return The `Environment` object.
#' @export
#' @section Details:
#' Once built, the Docker image appears in the Azure Container Registry
#' associated with your workspace, by default. The repository name has the form
#' *azureml/azureml_<uuid>*. The unique identifier (*uuid*) part corresponds to
#' a hash computed from the environment configuration. This allows the service
#' to determine whether an image corresponding to the given environment already
#' exists for reuse.
#'
#' If you make changes to an existing environment, such as adding an R package,
#' a new version of the environment is created when you either submit a run,
#' deploy a model, or manually register the environment. The versioning allows
#' you to view changes to the environment over time.
#' @section Predefined Docker images:
#' When submitting a training job or deploying a model, Azure ML runs your
#' training script or scoring script within a Docker container. If no custom
#' Docker image is specified with the `custom_docker_image` parameter, Azure
#' ML will build a predefined CPU or GPU Docker image. The predefine images extend
#' the Ubuntu 16.04 [Azure ML base images](https://github.com/Azure/AzureML-Containers)
#' and include the following dependencies:
#' \tabular{rrr}{
#' **Dependencies** \tab **Version** \tab **Remarks**\cr
#' azuremlsdk \tab latest \tab (from GitHub)\cr
#' R \tab 3.6.0 \tab -\cr
#' Commonly used R packages \tab - \tab 80+ of the most popular R packages for
#' data science, including the IRKernel, dplyr, shiny, ggplot2, tidyr, caret,
#' and nnet. For the full list of packages included, see
#' [here](https://github.com/Azure/azureml-sdk-for-r/tree/master/misc/r-packages-docker.md).\cr
#' Python \tab 3.7.0 \tab -\cr
#' azureml-defaults \tab latest \tab `azureml-defaults` contains the
#' `azureml-core` and `applicationinsights` packages of the Python SDK that
#' are required for tasks such as logging metrics, uploading artifacts, and
#' deploying models. (from pip)\cr
#' rpy2 \tab latest \tab (from conda)\cr
#' CUDA (GPU image only) \tab 10.0 \tab CuDNN (version 7) is also included
#' }
#' @examples
#' # The following example defines an environment that will build the default
#' # base CPU image.
#' \dontrun{
#' r_env <- r_environment(name = 'myr_env',
#'                        version = '1')
#' }
#' @seealso
#' `estimator()`, `inference_config()`
#' @md
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
    env$docker$shm_size <- shm_size
  }

  if (is.null(custom_docker_image)) {
    if (use_gpu) {
      base_image_with_address <- paste0("mcr.microsoft.com/azureml/base-",
                                        "gpu:openmpi3.1.2-cuda10.0-cudnn7-",
                                        "ubuntu16.04")
    }
    else {
      base_image_with_address <- paste0("mcr.microsoft.com/azureml/base:",
                                        "openmpi3.1.2-ubuntu16.04")
    }

    env$docker$base_dockerfile <- generate_docker_file(base_image_with_address,
                                                       cran_packages,
                                                       github_packages,
                                                       custom_url_packages)
    env$docker$base_image <- NULL
  }
  else {
    # if extra package is specified, generate dockerfile
    if (!is.null(cran_packages) ||
        !is.null(github_packages) ||
        !is.null(custom_url_packages)) {
      base_image_with_address <- env$docker$base_image
      registry_address <- env$docker$base_image_registry$address
      if (!is.null(env$docker$base_image_registry$address)) {
        base_image_with_address <- paste(registry_address,
                                         env$docker$base_image,
                                         sep = "/")
      }
      env$docker$base_dockerfile <- generate_docker_file(
        base_image_with_address,
        cran_packages,
        github_packages,
        custom_url_packages,
        FALSE)
      env$docker$base_image <- NULL
    }
  }

  invisible(env)
}

#' Register an environment in the workspace
#'
#' @description
#' The environment is automatically registered with your workspace when you
#' submit an experiment or deploy a web service. You can also manually register
#' the environment with `register_environment()`. This operation makes the
#' environment into an entity that is tracked and versioned in the cloud, and
#' can be shared between workspace users.
#'
#' Whe used for the first time in training or deployment, the environment is
#' registered with the workspace, built, and deployed on the compute target.
#' The environments are cached by the service. Reusing a cached environment
#' takes much less time than using a new service or one that has bee updated.
#' @param workspace The `Workspace` object.
#' @param environment The `Environment` object.
#' @return The `Environment` object.
#' @export
#' @md
register_environment <- function(environment, workspace) {
  env <- environment$register(workspace)
  invisible(env)
}

#' Get an existing environment
#'
#' @description
#' Returns an `Environment` object for an existing environment in
#' the workspace.
#' @param workspace The `Workspace` object.
#' @param name A string of the name of the environment.
#' @param version A string of the version of the environment.
#' @return The `Environment` object.
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' env <- get_environment(ws, name = 'myenv', version = '1')
#' }
#' @export
#' @md
get_environment <- function(workspace, name, version = NULL) {
  azureml$core$Environment$get(workspace, name, version)
}

#' Specify Azure Container Registry details
#'
#' @description
#' Returns a `ContainerRegistry` object with the details for an
#' Azure Container Registry (ACR). This is needed when a custom
#' Docker image used for training or deployment is located in
#' a private image registry. Provide a `ContainerRegistry` object
#' to the `image_registry_details` parameter of either `r_environment()`
#' or `estimator()`.
#' @param address A string of the DNS name or IP address of the
#' Azure Container Registry (ACR).
#' @param username A string of the username for ACR.
#' @param password A string of the password for ACR.
#' @return The `ContainerRegistry` object.
#' @export
#' @seealso
#' `r_environment()`, `estimator()`
#' @md
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
#' @param install_system_packages logical parameter to specify if system
#' packages should be installed at runtime.
generate_docker_file <- function(custom_docker_image = NULL,
                                 cran_packages = NULL,
                                 github_packages = NULL,
                                 custom_url_packages = NULL,
                                 install_system_packages = TRUE) {
  base_dockerfile <- NULL
  base_dockerfile <- paste0(base_dockerfile, sprintf("FROM %s\n",
                                                     custom_docker_image))

  if (install_system_packages) {
    base_dockerfile <- paste0(base_dockerfile, "RUN conda install -c r -y ",
                              "r-essentials=3.6.0 rpy2 && conda clean -ay && ",
                              "pip install --no-cache-dir azureml-defaults\n")

    base_dockerfile <- paste0(base_dockerfile, "ENV TAR=\"/bin/tar\"\n")

    base_dockerfile <- paste0(base_dockerfile, "RUN R -e \"install.packages(",
                              "c(\'remotes\', \'e1071\', \'optparse\'), repos",
                              " = \'http://cran.us.r-project.org\')\"\n")

    base_dockerfile <- paste0(base_dockerfile, "RUN R -e \"remotes::",
                              "install_github(repo = 'https://github.com/",
                              "Azure/azureml-sdk-for-r', ref = 'v0.5.6')\"\n")
  }

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
