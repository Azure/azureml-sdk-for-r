# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

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
#' @param use_gpu Indicates whether the environment to run the experiment should support GPUs.
#' If TRUE, a GPU - based default Docker image will be used in the environment. If FALSE, a CPU - based
#' image will be used. Default Docker images (CPU or GPU) will be used only if the 'custom_docker_image'
#' parameter is not set.
#' @export
estimator <- function(source_directory, compute_target = NULL, vm_size = NULL, vm_priority = NULL,
                      entry_script = NULL, script_params = NULL, use_docker = TRUE, cran_packages = NULL,
                      github_packages = NULL, custom_url_packages = NULL,
                      custom_docker_image = NULL, inputs = NULL, use_gpu = FALSE)
{ 
  launch_script <- create_launch_script(source_directory, entry_script, cran_packages, github_packages, custom_url_packages)
  est <- azureml$train$estimator$Estimator(source_directory, compute_target = compute_target, vm_size = vm_size,
                                           vm_priority = vm_priority, entry_script = launch_script, script_params = script_params, use_docker = use_docker,
                                           custom_docker_image = custom_docker_image, inputs = inputs)
  
  run_config <- est$run_config
  run_config$framework <- "R"
  run_config$environment$python$user_managed_dependencies <- TRUE
  
  if (is.null(custom_docker_image))
  {
    processor <- "cpu"
    if (use_gpu)
    {
      processor <- "gpu"
    }

    run_config$environment$docker$base_image <- paste("r-base", processor, sep = ":")
    run_config$environment$docker$base_image_registry$address <- "viennaprivate.azurecr.io"
  }
  
  invisible(est)

}

#' Creates a R launch script which contains all the packages to be installed before running entry_script
#' @param source_directory A local directory containing experiment configuration files.
#' @param entry_script A string representing the relative path to the file used to start training.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from local, directory or custom url.
create_launch_script <- function(source_directory, entry_script, cran_packages = NULL, github_packages = NULL, custom_url_packages = NULL)
{
  launch_file_name <- "launcher.R"
  launch_file_conn <- file(file.path(source_directory, launch_file_name), open = "w")
  
  writeLines("# This is the auto-generated launcher file.\n# It installs the packages specified in the estimator.\n# Once all the packages are successfully installed, it will execute the entry script.\n", launch_file_conn)
  
  if (!is.null(cran_packages))
  {
    writeLines(sprintf("install.packages(\"%s\", repos = \"http://cran.us.r-project.org\")\n", cran_packages), launch_file_conn)
  }
  
  if (!is.null(github_packages))
  {
    writeLines(sprintf("devtools::install_github(\"%s\")\n", github_packages), launch_file_conn)
  }
  
  if (!is.null(custom_url_packages))
  {
    writeLines(sprintf("install.packages(\"%s\", repos = NULL)\n", custom_url_packages), launch_file_conn)
  }
  
  writeLines(sprintf("source(\"%s\")", entry_script), launch_file_conn)
  
  close(launch_file_conn)
  invisible(launch_file_name)
}
