#' create estimator
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
#' @param cran_packages List of cran packages to be installed.
#' @param github_packages List of github packages to be installed.
#' @param custom_url_packages List of packages to be installed from local, directory or custom url.
#' @param custom_docker_image The name of the docker image from which the image to use for training will be built. If
#' not set, a default CPU based image will be used as the base image.
#' @param inputs list of data references as input
#' @export
create_estimator <- function(source_directory, compute_target = NULL, vm_size = NULL, vm_priority = NULL,
                             entry_script = NULL, script_params = NULL, use_docker = TRUE, cran_packages = NULL,
                             github_packages = NULL, custom_url_packages = NULL,
                             custom_docker_image = NULL, inputs = NULL)
{ 
  # TODO: this will be replaced to official one soon...
  if (is.null(custom_docker_image))
    custom_docker_image <- "ninhu/r-base"

  launch_script <- entry_script
  if (!(is.null(cran_packages) && is.null(github_packages) && is.null(custom_url_packages)))
  {
    launch_script <- create_launch_script(source_directory, entry_script, cran_packages, github_packages, custom_url_packages)

  }
  
  estimator <- azureml$train$estimator$Estimator(source_directory, compute_target = compute_target, vm_size = vm_size,
                                                 vm_priority = vm_priority, entry_script = launch_script, script_params = script_params, use_docker = use_docker,
                                                 custom_docker_image = custom_docker_image, inputs = inputs)
  
  run_config <- estimator$run_config
  run_config$framework <- "R"
  run_config$environment$python$user_managed_dependencies <- TRUE
  invisible(estimator)
}
