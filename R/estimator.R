# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an estimator
#'
#' @description
#' An Estimator wraps run configuration information for specifying details
#' of executing an R script. Running an Estimator experiment
#' (using `submit_experiment()`) will return a `ScriptRun` object and
#' execute your training script on the specified compute target.
#' @param source_directory A string of the local directory containing
#' experiment configuration and code files needed for the training job.
#' @param compute_target The `AmlCompute` object for the compute target
#' where training will happen.
#' @param vm_size A string of the VM size of the compute target that will be
#' created for the training job. The list of available VM sizes
#' are listed [here](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs).
#' Provide this parameter if you want to create AmlCompute as the compute target
#' at run time, instead of providing an existing cluster to the `compute_target`
#' parameter. If `vm_size` is specified, a single-node cluster is automatically
#' created for your run and is deleted automatically once the run completes.
#' @param vm_priority A string of either `'dedicated'` or `'lowpriority'` to
#' specify the VM priority of the compute target that will be created for the
#' training job. Defaults to `'dedicated'`. This takes effect only when the
#' `vm_size` parameter is specified.
#' @param entry_script A string representing the relative path to the file used
#' to start training.
#' @param script_params A named list of the command-line arguments to pass to
#' the training script specified in `entry_script`.
#' @param cran_packages A character vector of CRAN packages to be installed.
#' @param github_packages A character vector of GitHub packages to be installed.
#' @param custom_url_packages A character vector of packages to be installed
#' from local directory or custom URL.
#' @param custom_docker_image A string of the name of the Docker image from
#' which the image to use for training will be built. If not set, a default
#' CPU-based image will be used as the base image. To use an image from a
#' private Docker repository, you will also have to specify the
#' `image_registry_details` parameter.
#' @param image_registry_details A `ContainerRegistry` object of the details of
#' the Docker image registry for the custom Docker image.
#' @param use_gpu Indicates whether the environment to run the experiment should
#' support GPUs. If `TRUE`, a GPU-based default Docker image will be used in the
#' environment. If `FALSE`, a CPU-based image will be used. Default Docker
#' images (CPU or GPU) will only be used if the `custom_docker_image` parameter
#' is not set.
#' @param environment_variables A named list of environment variables names
#' and values. These environment variables are set on the process where the user
#' script is being executed.
#' @param shm_size A string for the size of the Docker container's shared
#' memory block. For more information, see
#' [Docker run reference](https://docs.docker.com/engine/reference/run/).
#' If not set, a default value of `'2g'` is used.
#' @param max_run_duration_seconds An integer of the maximum allowed time for
#' the run. Azure ML will attempt to automatically cancel the run if it takes
#' longer than this value.
#' @param environment The `Environment` object that configures the R
#' environment where the experiment is executed. This parameter is mutually
#' exclusive with the other environment-related parameters `custom_docker_image`
#' , `image_registry_details`, `use_gpu`, `environment_variables`, `shm_size`,
#' `cran_packages`, `github_packages`, and `custom_url_packages` and if set
#' will take precedence over those parameters.
#' @return The `Estimator` object.
#' @export
#' @seealso
#' `r_environment()`, `container_registry()`, `submit_experiment()`
#' @md
estimator <- function(source_directory,
                      compute_target = NULL,
                      vm_size = NULL,
                      vm_priority = NULL,
                      entry_script = NULL,
                      script_params = NULL,
                      cran_packages = NULL,
                      github_packages = NULL,
                      custom_url_packages = NULL,
                      custom_docker_image = NULL,
                      image_registry_details = NULL,
                      use_gpu = FALSE,
                      environment_variables = NULL,
                      shm_size = NULL,
                      max_run_duration_seconds = NULL,
                      environment = NULL) {

  launch_script <- create_launch_script(source_directory,
                                        entry_script,
                                        cran_packages,
                                        github_packages,
                                        custom_url_packages)

  est <- azureml$train$estimator$Estimator(
                            source_directory,
                            compute_target = compute_target,
                            vm_size = vm_size,
                            vm_priority = vm_priority,
                            entry_script = launch_script,
                            script_params = script_params,
                            custom_docker_image = custom_docker_image,
                            image_registry_details = image_registry_details,
                            environment_variables = environment_variables,
                            shm_size = shm_size,
                            max_run_duration_seconds = max_run_duration_seconds,
                            environment_definition = environment)

  run_config <- est$run_config
  run_config$framework <- "R"

  if (is.null(environment)) {

    run_config$environment$python$user_managed_dependencies <- TRUE

    if (is.null(custom_docker_image)) {
      processor <- "cpu"
      if (use_gpu) {
        processor <- "gpu"
      }

      run_config$environment$docker$base_image <- paste("r-base",
                                                        processor,
                                                        sep = ":")
      run_config$environment$docker$base_image_registry$address <-
        "viennaprivate.azurecr.io"
    }
  }

  invisible(est)
}

#' Creates a R launch script which contains all the packages to be installed
#' before running entry_script
#' @param source_directory A local directory containing experiment configuration
#' files.
#' @param entry_script A string representing the relative path to the file used
#' to start training.
#' @param cran_packages character vector of cran packages to be installed.
#' @param github_packages character vector of github packages to be installed.
#' @param custom_url_packages character vector of packages to be installed from
#' local, directory or custom url.
create_launch_script <- function(source_directory,
                                 entry_script,
                                 cran_packages = NULL,
                                 github_packages = NULL,
                                 custom_url_packages = NULL) {
  launch_file_name <- "_generated_launcher.R"
  launch_file_conn <- file(file.path(source_directory, launch_file_name),
                           open = "w")

  writeLines(
    c("# This is the auto-generated launcher file.",
      "# It installs the packages specified in the estimator.",
      "# Once all the packages are successfully installed, ",
      "# it will execute the entry script."),
    launch_file_conn)

  if (!is.null(cran_packages)) {
    writeLines(sprintf("install.packages(\"%s\", repos = \"%s\")\n",
                       cran_packages,
                       "http://cran.us.r-project.org"),
               launch_file_conn)
  }

  if (!is.null(github_packages)) {
    writeLines(sprintf("devtools::install_github(\"%s\")\n", github_packages),
               launch_file_conn)
  }

  if (!is.null(custom_url_packages)) {
    writeLines(sprintf("install.packages(\"%s\", repos = NULL)\n",
                       custom_url_packages), launch_file_conn)
  }

  writeLines(sprintf("source(\"%s\")", entry_script), launch_file_conn)

  close(launch_file_conn)
  invisible(launch_file_name)
}
