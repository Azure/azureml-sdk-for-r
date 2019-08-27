#' Create Estimator
#' @param source_directory A local directory containing experiment configuration files.
#' @param compute_target The ComputeTarget where training will happen. This can either be an object or the
#' string "local".
#' @param vm_size The VM size of the compute target that will be created for the training. Supported values:
#' Any Azure VM size. The list of available VM sizes are listed here:
#' https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs
#' @param vm_priority The VM priority of the compute target that will be created for the training. If not specified,
#' it will be defaulted to 'dedicated'. Supported values: 'dedicated' and 'lowpriority'. This takes effect only when
#' the vm_size param is specified in the input.
#' @param entry_script A string representing the relative path to the file used to start training.
#' @param script_params A named list containing parameters to the entry_script.
#' @param use_docker A bool value indicating if the environment to run the experiment should be docker-based.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param inputs list of data references as input
#' @export
create_estimator <- function(source_directory, compute_target = NULL, vm_size = NULL, vm_priority = NULL,
                             entry_script = NULL, script_params = NULL, use_docker = TRUE, cran_packages = NULL,
                             github_packages = NULL, custom_url_packages = NULL,
                             custom_docker_image = NULL, inputs = NULL)
{
  base_dockerfile <- create_dockerfile(custom_docker_image, cran_packages, github_packages, custom_url_packages)
  estimator <- azureml$train$estimator$Estimator(source_directory, compute_target = compute_target, vm_size = vm_size,
                                                 vm_priority = vm_priority, entry_script = entry_script, script_params = script_params, use_docker = use_docker,
                                                 custom_docker_image = custom_docker_image, inputs = inputs)
  
  run_config <- estimator$run_config
  run_config$framework <- "R"
  run_config$environment$python$user_managed_dependencies <- TRUE
  run_config$environment$docker$base_dockerfile <- base_dockerfile
  run_config$environment$docker$base_image <- NULL
  
  if (is.null(custom_docker_image))
  {
    run_config$environment$docker$base_image_registry$address <- "viennaprivate.azurecr.io"
  }
  
  invisible(estimator)

}

#' Creates a dockerfile which builds the image to run the entry_script.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
create_dockerfile <- function(custom_docker_image = NULL, cran_packages = NULL, github_packages = NULL, custom_url_packages = NULL)
{
  base_dockerfile <- NULL
  if (is.null(custom_docker_image))
  {
    base_dockerfile <- "FROM r-base:cpu\n"
  }
  else
  {
    base_dockerfile <- sprintf("FROM %s\n", custom_docker_image)
  }
  
  if (!is.null(cran_packages))
  {
    for (package in cran_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e install.packages(\"%s\", repos = \"http://cran.us.r-project.org\")\n", package))
    }
  }
  
  if (!is.null(github_packages))
  {
    for (package in github_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e devtools::install_github(\"%s\")\n", package))
    }
  }
  
  if (!is.null(custom_url_packages))
  {
    for (package in custom_url_packages)
    {
      base_dockerfile <- paste(base_dockerfile, sprintf("RUN R -e install.packages(\"%s\", repos = NULL)\n", package))
    }
  }
  
  invisible(base_dockerfile)
}
